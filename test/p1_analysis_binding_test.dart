import 'dart:async';

import 'package:careerly/data/api/analysis_task_store.dart';
import 'package:careerly/data/models/analysis_job_input.dart';
import 'package:careerly/data/models/analysis_project.dart';
import 'package:careerly/data/models/analysis_result.dart';
import 'package:careerly/data/models/analysis_task.dart';
import 'package:careerly/data/models/job.dart';
import 'package:careerly/data/models/parsed_job.dart';
import 'package:careerly/data/models/quota_state.dart';
import 'package:careerly/data/repositories/analysis_repository.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/analysis/presentation/job_detail_page.dart';
import 'package:careerly/features/analysis/state/analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// P1-01 / P1-02 / P1-05 的前端回归测试。
///
/// 钉住四件事：
/// 1. 分析结果按**保存的 JD 快照**展示，不读当前岗位的 rawJd；
/// 2. 历史数据没有快照时显示明确缺失态；
/// 3. 退出分析页不取消服务器任务、不回滚服务端预占额度；
/// 4. 重新进入能查询任务状态并刷新结果 / 额度。

// ---------------------------------------------------------------------------
// 夹具
// ---------------------------------------------------------------------------

JobSnapshot _snapshot({
  bool available = true,
  String rawJd = '岗位职责：\n1. 负责 AI 产品规划\n\n任职要求：\n1. 3 年经验\n2. 有 B 端经验',
}) {
  return JobSnapshot(
    jobId: 'job-1',
    title: '原始岗位名',
    company: '原始公司',
    rawJd: rawJd,
    source: 'url',
    sourceUrl: 'https://example.com/job/1',
    importMethod: 'url',
    capturedAt: DateTime.utc(2026, 11, 18),
    available: available,
  );
}

AnalysisProject _project({JobSnapshot? snapshot, bool withSnapshot = true}) {
  final Job job = const Job(
    id: 'job-1',
    title: '当前岗位名',
    company: '当前公司',
    rawJd: 'CURRENT JD SHOULD NOT BE SHOWN',
  );
  final AnalysisResult result = AnalysisResult(
    id: 'result-1',
    projectId: 'project-1',
    version: 1,
    resumeVersionId: 'resume-v2',
    resumeVersionLabel: 'V2',
    matches: const <JobMatch>[
      JobMatch(
        jobId: 'job-1',
        score: 78,
        rank: 1,
        reasons: <String>['测试夹具：匹配依据'],
        gaps: <String>['测试夹具：能力 Gap'],
      ),
    ],
    jobSnapshots: withSnapshot
        ? <JobSnapshot>[snapshot ?? _snapshot()]
        : <JobSnapshot>[const JobSnapshot(jobId: 'job-1', available: false)],
    createdAt: DateTime.utc(2026, 11, 18),
  );
  return AnalysisProject(
    id: 'project-1',
    name: '原始岗位名',
    jobs: <Job>[job],
    results: <AnalysisResult>[result],
    createdAt: DateTime.utc(2026, 11, 18),
    updatedAt: DateTime.utc(2026, 11, 18),
  );
}

class _P1Repository implements AnalysisRepository {
  _P1Repository({required this.projects});

  List<AnalysisProject> projects;
  QuotaState quota = QuotaState.free;
  int analyzeCalls = 0;

  @override
  Future<List<AnalysisProject>> fetchProjects() async => projects;

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async {
    for (final AnalysisProject p in projects) {
      if (p.id == projectId) return p;
    }
    return null;
  }

  @override
  Future<List<Job>> fetchJobLibrary() async => const <Job>[];

  @override
  Future<ParsedJob> parseJobUrl(String url) async =>
      throw UnimplementedError();

  @override
  Future<QuotaState> fetchQuota() async => quota;

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
    List<AnalysisJobInput>? jobs,
  }) async {
    analyzeCalls++;
    return projects.first;
  }
}

/// 同时实现 [AnalysisProgressSource]，用于验证 P1-05 的退出 / 恢复语义。
class _P1ProgressRepository implements AnalysisRepository, AnalysisProgressSource {
  _P1ProgressRepository({required this.project});

  AnalysisProject project;
  QuotaState quota = QuotaState.free;
  AnalysisTask task = const AnalysisTask(
    taskId: 'task-1',
    status: AnalysisTask.statusProcessing,
  );
  int cancelCalls = 0;
  int fetchTaskCalls = 0;

  @override
  Future<List<AnalysisProject>> fetchProjects() async => <AnalysisProject>[project];

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async => project;

  @override
  Future<List<Job>> fetchJobLibrary() async => const <Job>[];

  @override
  Future<ParsedJob> parseJobUrl(String url) async =>
      throw UnimplementedError();

  @override
  Future<QuotaState> fetchQuota() async => quota;

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
    List<AnalysisJobInput>? jobs,
  }) async => project;

  @override
  Future<AnalysisTask> startAnalysisTask({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
    List<AnalysisJobInput>? jobs,
  }) async {
    quota = quota.copyWith(reserved: 1);
    return task;
  }

  @override
  Future<AnalysisTask> fetchAnalysisTask(String taskId) async {
    fetchTaskCalls++;
    return task;
  }

  @override
  Future<AnalysisTask> cancelAnalysisTask(String taskId) async {
    cancelCalls++;
    return task;
  }
}

// ---------------------------------------------------------------------------
// 1 / 2. JD 原文快照
// ---------------------------------------------------------------------------

void main() {
  group('P1-02 岗位原文快照', () {
    testWidgets('详情页展示保存的 JD，而不是当前岗位 rawJd', (tester) async {
      final repo = _P1Repository(projects: <AnalysisProject>[_project()]);
      final provider = AnalysisProvider(repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<AnalysisProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: CareerlyTheme.light(),
            home: const AnalysisJobDetailPage(jobId: 'job-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('岗位原文'), findsOneWidget);
      expect(find.textContaining('负责 AI 产品规划'), findsOneWidget);
      expect(find.textContaining('链接导入'), findsOneWidget);
      expect(find.textContaining('CURRENT JD SHOULD NOT BE SHOWN'), findsNothing);
      // 标题也来自快照（历史记录不随岗位改名漂移）。
      expect(find.text('原始岗位名'), findsWidgets);
    });

    testWidgets('默认折叠，可展开 / 收起', (tester) async {
      final repo = _P1Repository(projects: <AnalysisProject>[_project()]);
      final provider = AnalysisProvider(repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<AnalysisProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: CareerlyTheme.light(),
            home: const AnalysisJobDetailPage(jobId: 'job-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('展开全文'), findsOneWidget);
      await tester.tap(find.text('展开全文'));
      await tester.pump();
      expect(find.text('收起原文'), findsOneWidget);
      await tester.tap(find.text('收起原文'));
      await tester.pump();
      expect(find.text('展开全文'), findsOneWidget);
    });

    testWidgets('历史数据没有快照 → 明确缺失态，不展示当前 JD', (tester) async {
      final repo = _P1Repository(
        projects: <AnalysisProject>[_project(withSnapshot: false)],
      );
      final provider = AnalysisProvider(repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<AnalysisProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: CareerlyTheme.light(),
            home: const AnalysisJobDetailPage(jobId: 'job-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('没有保存岗位原文'), findsOneWidget);
      expect(find.textContaining('CURRENT JD SHOULD NOT BE SHOWN'), findsNothing);
    });

    test('模型解析 jobSnapshots 与缺失标记', () {
      final result = AnalysisResult.fromJson(<String, dynamic>{
        'id': 'r',
        'projectId': 'p',
        'version': 1,
        'resumeVersionId': 'v1',
        'resumeVersionLabel': 'V1',
        'jobSnapshots': <Map<String, dynamic>>[
          <String, dynamic>{
            'jobId': 'j1',
            'title': 'T',
            'company': 'C',
            'rawJd': 'JD',
            'available': true,
          },
          <String, dynamic>{'jobId': 'j2', 'available': false},
        ],
      });
      expect(result.resumeVersionLabel, 'V1');
      expect(result.snapshotFor('j1')!.rawJd, 'JD');
      expect(result.snapshotFor('j2')!.available, isFalse);
    });
  });

  group('P1-03 额度模型', () {
    test('预占计入剩余额度，且确认前不增加 used', () {
      const QuotaState base = QuotaState(total: 3, used: 0);
      final QuotaState reserved = base.consume();
      expect(reserved.used, 0);
      expect(reserved.reserved, 1);
      expect(reserved.remaining, 2);
      expect(reserved.rollback(), base);
    });
  });

  group('P1-05 退出与恢复', () {
    test('退出页面：不取消任务、不回滚预占、保留任务句柄', () async {
      final repo = _P1ProgressRepository(project: _project());
      final taskStore = InMemoryActiveAnalysisTaskStore();
      final provider = AnalysisProvider(repo, taskStore: taskStore);
      await provider.loadQuota();

      unawaited(provider.startAnalysis(title: '岗位', rawJd: 'JD'));
      await Future<void>.delayed(Duration.zero);
      expect(provider.quota!.reserved, 1);
      expect(await taskStore.read(), 'task-1');

      provider.exitAnalysis();
      await Future<void>.delayed(Duration.zero);

      expect(repo.cancelCalls, 0, reason: '退出页面不得取消服务器任务');
      expect(provider.quota!.reserved, 1, reason: '服务端预占不得被退出回滚');
      expect(await taskStore.read(), 'task-1', reason: '重新进入要能恢复同一条任务');
    });

    test('重新进入：查询真实状态，完成后刷新结果与额度', () async {
      final repo = _P1ProgressRepository(project: _project());
      final taskStore = InMemoryActiveAnalysisTaskStore();
      await taskStore.write('task-1');
      final provider = AnalysisProvider(repo, taskStore: taskStore);
      repo.quota = const QuotaState(total: 3, used: 1);
      await provider.loadQuota();

      // 服务端：任务已完成，额度已从预占转为消耗。
      repo.task = const AnalysisTask(
        taskId: 'task-1',
        status: AnalysisTask.statusCompleted,
        projectId: 'project-1',
      );
      repo.quota = const QuotaState(total: 3, used: 1);

      await provider.restoreActiveTask();

      expect(repo.fetchTaskCalls, 1);
      expect(provider.analysisState.dataOrNull?.id, 'project-1');
      expect(provider.quota!.used, 1);
      expect(provider.quota!.reserved, 0);
      expect(await taskStore.read(), isNull, reason: '终态后清除本地句柄');
    });
  });
}
