import 'package:careerly/data/models/analysis_job_input.dart';
import 'package:careerly/data/models/analysis_project.dart';
import 'package:careerly/data/models/analysis_result.dart';
import 'package:careerly/data/models/job.dart';
import 'package:careerly/data/models/parsed_job.dart';
import 'package:careerly/data/models/quota_state.dart';
import 'package:careerly/data/repositories/analysis_repository.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/analysis/presentation/analysis_loader.dart';
import 'package:careerly/features/analysis/presentation/job_detail_page.dart';
import 'package:careerly/features/analysis/state/analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// P1-01 —— 成长可比性（Flutter 侧）。
///
/// 比较规则**只属于后端**（`growth.annotate_match_previous_scores`：
/// 同一 jobKey + 同一 jdHash + 不同 resumeFingerprint + 同一
/// scoringVersion）。前端唯一允许做的事：把后端下发的
/// `JobMatch.previousScore` 原样展示；为 `null` 时不展示任何增长数值。
///
/// 这份测试钉住的是**反面**：即使项目里有两条结果、jobId 相同，
/// 只要后端没有下发 `previousScore`，前端也**不得**自己相减。

// ---------------------------------------------------------------------------
// 夹具
// ---------------------------------------------------------------------------

const Job _jobA = Job(id: 'job-a', title: 'AI 产品经理', rawJd: 'JD A');

AnalysisResult _result({
  required int version,
  required String jobId,
  required int score,
  int? previousScore,
}) {
  return AnalysisResult(
    id: 'result-$version',
    projectId: 'project-1',
    version: version,
    matches: <JobMatch>[
      JobMatch(
        jobId: jobId,
        score: score,
        rank: 1,
        previousScore: previousScore,
      ),
    ],
    createdAt: DateTime(2026, 11, 1 + version),
  );
}

AnalysisProject _project(List<AnalysisResult> results, {List<Job>? jobs}) {
  return AnalysisProject(
    id: 'project-1',
    name: 'AI 产品经理',
    jobs: jobs ?? const <Job>[_jobA],
    results: results,
  );
}

void main() {
  group('P1-01 previousScore 只来自后端', () {
    test('JSON 缺少 previousScore → null（历史后端 / 不可比）', () {
      final JobMatch match = JobMatch.fromJson(<String, dynamic>{
        'jobId': 'job-a',
        'score': 82,
        'rank': 1,
      });
      expect(match.previousScore, isNull);
      expect(match.scoreDelta, isNull);
    });

    test('JSON 带 previousScore → 原样保留并计算 delta', () {
      final JobMatch match = JobMatch.fromJson(<String, dynamic>{
        'jobId': 'job-a',
        'score': 82,
        'rank': 1,
        'previousScore': 78,
      });
      expect(match.previousScore, 78);
      expect(match.scoreDelta, 4);
    });

    test('toJson 往返不丢 previousScore', () {
      const JobMatch match = JobMatch(
        jobId: 'job-a',
        score: 82,
        rank: 1,
        previousScore: 78,
      );
      expect(JobMatch.fromJson(match.toJson()).previousScore, 78);
    });
  });

  group('findAnalysisJobEntry 不自行推断', () {
    test('两条结果同 jobId，但后端未下发 previousScore → 无「较上次」', () {
      // 这正是旧实现会算错的地方：相邻结果的 jobId 相同，旧代码会
      // 直接 82 - 78 = +4，哪怕岗位已改名 / JD 已改版 / 简历没换。
      final AnalysisProject project = _project(<AnalysisResult>[
        _result(version: 1, jobId: 'job-a', score: 78),
        _result(version: 2, jobId: 'job-a', score: 82),
      ]);

      final AnalysisJobEntry? entry = findAnalysisJobEntry(
        <AnalysisProject>[project],
        'job-a',
      );

      expect(entry, isNotNull);
      expect(entry!.match.score, 82);
      expect(entry.previousScore, isNull);
      expect(entry.delta, isNull, reason: '不可比时不得展示增长数值');
    });

    test('后端下发 previousScore 时原样使用', () {
      final AnalysisProject project = _project(<AnalysisResult>[
        _result(version: 1, jobId: 'job-a', score: 78),
        _result(
          version: 2,
          jobId: 'job-a',
          score: 82,
          previousScore: 78,
        ),
      ]);

      final AnalysisJobEntry? entry = findAnalysisJobEntry(
        <AnalysisProject>[project],
        'job-a',
      );

      expect(entry!.previousScore, 78);
      expect(entry.delta, 4);
    });

    test('跨岗位隔离：别的岗位的 previousScore 不会串到当前岗位', () {
      const Job jobB = Job(id: 'job-b', title: 'AI 产品运营', rawJd: 'JD B');
      final AnalysisProject project = AnalysisProject(
        id: 'project-1',
        name: 'AI 产品运营',
        jobs: const <Job>[_jobA, jobB],
        results: <AnalysisResult>[
          AnalysisResult(
            id: 'result-1',
            projectId: 'project-1',
            version: 1,
            matches: const <JobMatch>[
              JobMatch(jobId: 'job-a', score: 78, rank: 2, previousScore: 70),
              JobMatch(jobId: 'job-b', score: 82, rank: 1),
            ],
          ),
        ],
      );

      final AnalysisJobEntry? entryA = findAnalysisJobEntry(
        <AnalysisProject>[project],
        'job-a',
      );
      final AnalysisJobEntry? entryB = findAnalysisJobEntry(
        <AnalysisProject>[project],
        'job-b',
      );

      expect(entryA!.previousScore, 70);
      expect(entryB!.previousScore, isNull, reason: '岗位 B 没有可比的上次分数');
    });
  });

  group('岗位详情页展示', () {
    testWidgets('不可比时不出现「较上次 ↑ +」', (WidgetTester tester) async {
      final AnalysisProject project = _project(<AnalysisResult>[
        _result(version: 1, jobId: 'job-a', score: 78),
        _result(version: 2, jobId: 'job-a', score: 82),
      ]);
      final AnalysisProvider provider = AnalysisProvider(
        _StubRepository(project),
      );
      await provider.load();

      await tester.pumpWidget(
        ChangeNotifierProvider<AnalysisProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: CareerlyTheme.light(),
            home: const AnalysisJobDetailPage(jobId: 'job-a'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('较上次 ↑'), findsNothing);
      expect(find.text('82'), findsOneWidget);
    });

    testWidgets('可比时展示后端下发的增长数值', (WidgetTester tester) async {
      final AnalysisProject project = _project(<AnalysisResult>[
        _result(version: 1, jobId: 'job-a', score: 78),
        _result(version: 2, jobId: 'job-a', score: 82, previousScore: 78),
      ]);
      final AnalysisProvider provider = AnalysisProvider(
        _StubRepository(project),
      );
      await provider.load();

      await tester.pumpWidget(
        ChangeNotifierProvider<AnalysisProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: CareerlyTheme.light(),
            home: const AnalysisJobDetailPage(jobId: 'job-a'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('较上次 ↑ +4%'), findsOneWidget);
    });
  });
}

/// 只提供项目列表的最小仓库。
class _StubRepository implements AnalysisRepository {
  _StubRepository(this.project);

  final AnalysisProject project;

  @override
  Future<List<AnalysisProject>> fetchProjects() async => <AnalysisProject>[
    project,
  ];

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async => project;

  @override
  Future<List<Job>> fetchJobLibrary() async => project.jobs;

  @override
  Future<QuotaState> fetchQuota() async => QuotaState.free;

  @override
  Future<ParsedJob> parseJobUrl(String url) async =>
      throw UnimplementedError('本测试不覆盖岗位链接抓取');

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
    List<AnalysisJobInput>? jobs,
  }) async => project;
}
