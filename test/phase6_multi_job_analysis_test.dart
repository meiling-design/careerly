import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/models/analysis_job_input.dart';
import 'package:careerly/data/models/analysis_project.dart';
import 'package:careerly/data/models/analysis_result.dart';
import 'package:careerly/data/models/job.dart';
import 'package:careerly/data/models/parsed_job.dart';
import 'package:careerly/data/models/quota_state.dart';
import 'package:careerly/data/models/resume_file.dart';
import 'package:careerly/data/models/resume_profile.dart';
import 'package:careerly/data/repositories/analysis_repository.dart';
import 'package:careerly/data/repositories/resume_repository.dart';
import 'package:careerly/design_system/components/careerly_button.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/analysis/presentation/analysis_page.dart';
import 'package:careerly/features/analysis/state/analysis_provider.dart';
import 'package:careerly/features/profile/state/growth_celebration_provider.dart';
import 'package:careerly/features/profile/state/resume_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// 多岗位分析（2026-11-18）。
///
/// 依据：
///
/// ```text
/// PRD §9.4       对本次全部岗位统一执行匹配并输出；多岗位排序
/// PRD §17        MVP 验收：多岗位匹配完成、排序稳定
/// CLAUDE.md §5.2 额度按**一次分析**扣，不按岗位数扣
/// ```
///
/// ## 这份测试钉住什么
///
/// 1. 表单可以连续添加多个岗位（胶囊 + 数量 + CTA 文案同步）；
/// 2. 「开始分析」只发**一次**请求，并把**全部**岗位草稿原样传下去；
/// 3. 结果页按 `rank` 展示多个岗位，而不是只显示第一个。
void main() {
  // ---------------------------------------------------------------------------
  // 夹具（JD 首行就是岗位名，与页面推导规则一致）
  // ---------------------------------------------------------------------------

  const String firstJd = '后端工程师\n负责 AI 平台服务端研发与稳定性建设。\n任职要求：熟悉 Python、FastAPI。';
  const String secondJd = '产品经理\n负责 AI 产品的需求分析与落地推进。\n任职要求：具备 B 端产品经验。';

  const String firstTitle = '后端工程师';
  const String secondTitle = '产品经理';

  // ---------------------------------------------------------------------------
  // 宿主
  // ---------------------------------------------------------------------------

  Widget host(MultiJobStubAnalysisRepository analysis) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<AnalysisRepository>.value(value: analysis),
        Provider<ResumeRepository>.value(value: _StubResumeRepository()),
        ChangeNotifierProvider<AnalysisProvider>(
          create: (BuildContext context) =>
              AnalysisProvider(context.read<AnalysisRepository>()),
        ),
        ChangeNotifierProvider<ResumeProvider>(
          create: (BuildContext context) =>
              ResumeProvider(context.read<ResumeRepository>()),
        ),
        // 分析成功后页面会向成长庆祝 Provider 记一笔。
        ChangeNotifierProvider<GrowthCelebrationProvider>(
          create: (BuildContext context) => GrowthCelebrationProvider(),
        ),
      ],
      child: MaterialApp(
        theme: CareerlyTheme.light(),
        home: const AnalysisPage(),
      ),
    );
  }

  Future<void> pumpPage(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pump(); // 首帧 → postFrameCallback → load() / loadQuota()
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
  }

  /// 走完「粘贴 JD → 添加岗位」两步。
  ///
  /// 800×600 的测试视口下「添加岗位」落在首屏之外，不先滚到可见就 tap
  /// 会静默打空（只发 warning，不抛异常）。
  Future<void> addJob(WidgetTester tester, String jd) async {
    await tester.ensureVisible(find.text('粘贴 JD 添加岗位'));
    await tester.pump();
    await tester.tap(find.text('粘贴 JD 添加岗位'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, jd);
    await tester.pump();
    await tester.ensureVisible(find.text('添加岗位'));
    await tester.pump();
    await tester.tap(find.text('添加岗位'));
    await tester.pump();
  }

  /// 提交表单并等结果页。
  Future<void> analyze(WidgetTester tester, String buttonLabel) async {
    await tester.ensureVisible(find.text(buttonLabel));
    await tester.pump();
    await tester.tap(find.text(buttonLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
  }

  CareerlyButton analyzeButton(WidgetTester tester) =>
      tester.widget<CareerlyButton>(find.byType(CareerlyButton));

  // ---------------------------------------------------------------------------
  // 一、表单 → 请求 → 结果
  // ---------------------------------------------------------------------------

  group('多岗位分析', () {
    testWidgets('添加两个岗位 → 一次请求带全部岗位 → 结果按排名展示', (WidgetTester tester) async {
      final MultiJobStubAnalysisRepository repository =
          MultiJobStubAnalysisRepository();
      await pumpPage(tester, host(repository));

      // 第一个岗位。
      await addJob(tester, firstJd);
      expect(find.text(firstTitle), findsOneWidget);
      expect(find.text('已添加 1 个目标岗位，可继续添加'), findsOneWidget);

      // 第二个岗位。
      await addJob(tester, secondJd);
      expect(find.text(firstTitle), findsOneWidget);
      expect(find.text(secondTitle), findsOneWidget);
      expect(find.text('已添加 2 个目标岗位，可继续添加'), findsOneWidget);
      expect(find.text('开始分析（2 个岗位）'), findsOneWidget);
      expect(analyzeButton(tester).onPressed, isNotNull);

      await analyze(tester, '开始分析（2 个岗位）');

      // 一次分析、一次请求、两个岗位草稿 —— 额度不按岗位数扣。
      expect(repository.analyzeCalls, 1);
      expect(repository.analyzedJobs.length, 2);
      expect(
        repository.analyzedJobs.map((AnalysisJobInput j) => j.title).toList(),
        <String>[firstTitle, secondTitle],
      );
      expect(
        repository.analyzedJobs.map((AnalysisJobInput j) => j.rawJd).toList(),
        <String>[firstJd, secondJd],
      );

      // 结果页：Top 1 主卡 + #2 岗位卡。
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
      expect(find.text(firstTitle), findsOneWidget);
      expect(find.text(secondTitle), findsOneWidget);
      expect(find.textContaining('2 个目标岗位'), findsOneWidget);
    });

    testWidgets('同一份 JD 重复添加不会产生第二个岗位', (WidgetTester tester) async {
      final MultiJobStubAnalysisRepository repository =
          MultiJobStubAnalysisRepository();
      await pumpPage(tester, host(repository));

      await addJob(tester, firstJd);
      await addJob(tester, firstJd);

      expect(find.text(firstTitle), findsOneWidget);
      expect(
        find.text('已添加 1 个目标岗位，可继续添加'),
        findsOneWidget,
        reason: '同一份 JD 不应被重复分析',
      );
      expect(find.text('开始分析（1 个岗位）'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// 桩
// ---------------------------------------------------------------------------

/// 记录多岗位请求，并按岗位数返回真实形状的项目（每个岗位一条 match）。
class MultiJobStubAnalysisRepository implements AnalysisRepository {
  int analyzeCalls = 0;
  List<AnalysisJobInput> analyzedJobs = <AnalysisJobInput>[];

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
    analyzedJobs = jobs == null
        ? <AnalysisJobInput>[
            AnalysisJobInput(
              title: title,
              rawJd: rawJd,
              company: company,
              source: source,
              sourceUrl: sourceUrl,
            ),
          ]
        : List<AnalysisJobInput>.of(jobs);

    final DateTime now = DateTime(2026, 1, 1);
    final String projectId = 'stub-project-$analyzeCalls';

    final List<Job> jobsModels = <Job>[
      for (int i = 0; i < analyzedJobs.length; i++)
        Job(
          id: '$projectId-job-${i + 1}',
          title: analyzedJobs[i].title,
          company: analyzedJobs[i].company,
          rawJd: analyzedJobs[i].rawJd,
          source: analyzedJobs[i].source,
          createdAt: now,
        ),
    ];
    final List<JobMatch> matches = <JobMatch>[
      for (int i = 0; i < jobsModels.length; i++)
        JobMatch(
          jobId: jobsModels[i].id,
          // 夹具值，不是产品数据：只用于验证排序与多卡渲染。
          score: 80 - i * 10,
          rank: i + 1,
        ),
    ];

    return AnalysisProject(
      id: projectId,
      name: jobsModels.first.title,
      jobs: jobsModels,
      results: <AnalysisResult>[
        AnalysisResult(
          id: '$projectId-result-1',
          projectId: projectId,
          version: 1,
          matches: matches,
          createdAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<AnalysisProject>> fetchProjects() async =>
      const <AnalysisProject>[];

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async => null;

  @override
  Future<List<Job>> fetchJobLibrary() async => const <Job>[];

  @override
  Future<ParsedJob> parseJobUrl(String url) async =>
      throw const NetworkError(message: '本用例不涉及链接抓取');

  @override
  Future<QuotaState> fetchQuota() async => QuotaState.free;
}

class _StubResumeRepository implements ResumeRepository {
  @override
  Future<ResumeProfile> fetchProfile() async => ResumeProfile.empty;

  @override
  Future<List<ResumeVersion>> fetchVersions() async => const <ResumeVersion>[];

  @override
  Future<List<int>> fetchVersionOriginalPdf(String versionId) async =>
      const <int>[];

  @override
  Future<void> setCurrentVersion(String versionId) async {}

  @override
  Future<void> deleteVersion(String versionId) async {}

  @override
  Future<void> submitResumeText(String text) async {}

  @override
  Future<void> submitResumeFile(ResumeFileData file) async {}

  @override
  Future<ResumeProfile> buildBaseline() async => ResumeProfile.empty;
}
