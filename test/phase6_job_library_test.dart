import 'dart:async';

import 'package:careerly/core/errors/app_error.dart';
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
import 'package:careerly/features/profile/state/resume_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// 分析页「从历史岗位添加」（PRD §9.3「从历史岗位中添加」）。
///
/// 依据：
///
/// ```text
/// PRD §9.3                   「从历史岗位中添加」是新建分析的明文能力
/// 设计稿 §七「历史岗位」      展示「岗位名 · 分析日期」；选择后直接加入当前分析
/// CLAUDE.md §5.2             **不扣额度** —— 只有「开始分析」扣
/// CLAUDE.md §5.5             四态：Loading / Empty / Error / Retry
/// CLAUDE.md §7               Mock 不得编造产品数据（空库就是空库）
/// ```
///
/// ## 为什么要有这份测试
///
/// 这条链路**建好之后一直是断的**：后端 `GET /api/v1/analysis/jobs` 与
/// 数据层 `fetchJobLibrary()` 都已存在，但**全仓没有任何调用者** ——
/// 用户在产品里根本用不到 PRD 明文承诺的能力。
///
/// 因此这里钉的不是「有没有弹层」，而是**选完之后表单里到底是什么**：
///
/// ```text
/// ✅ JD 框 = Job.rawJd（上次存下来的原文）   ← 「不必重新粘贴」的全部意义
/// ✅ 岗位名 = Job.displayName（公司 · 岗位）
/// ❌ JD 框 = 空 / 岗位名 = 空              ← 等于没接上，必须钉死
/// ```
void main() {
  // ---------------------------------------------------------------------------
  // 夹具
  // ---------------------------------------------------------------------------

  /// 分析日期固定，便于断言渲染出的日期文案。
  final DateTime analyzedAt = DateTime(2026, 9, 1);

  const String historyTitle = 'AI 产品经理';
  const String historyCompany = '某某科技';
  const String historyJd = '岗位职责：负责 AI 产品的需求分析与落地推进。';

  Job historyJob() => Job(
    id: 'job-history-1',
    title: historyTitle,
    company: historyCompany,
    rawJd: historyJd,
    source: 'paste',
    createdAt: analyzedAt,
  );

  // ---------------------------------------------------------------------------
  // 宿主
  // ---------------------------------------------------------------------------

  Widget host(StubAnalysisRepository analysis) {
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

  AnalysisProvider providerOf(WidgetTester tester) =>
      Provider.of<AnalysisProvider>(
        tester.element(find.byType(AnalysisPage)),
        listen: false,
      );

  /// 点开第三颗虚线按钮。
  ///
  /// ⚠️ 800×600 的测试视口下这颗按钮落在首屏之外，不先滚到可见就 tap 会
  /// **静默打空**（tap 只发 warning 不抛异常），失败点跑到几条断言之后。
  Future<void> tapAddFromHistory(WidgetTester tester) async {
    await tester.ensureVisible(find.text('从历史岗位添加'));
    await tester.pump();
    await tester.tap(find.text('从历史岗位添加'));
  }

  /// 展开「粘贴 JD」表单并读回 JD 框里的文本。
  ///
  /// 展开用的是**同一个** `TextEditingController`，所以这既能读回填结果，
  /// 也正是用户「看得到、改得动」的那条路径。
  Future<String> jdBoxText(WidgetTester tester) async {
    await tester.ensureVisible(find.text('粘贴 JD 添加岗位'));
    await tester.pump();
    await tester.tap(find.text('粘贴 JD 添加岗位'));
    await tester.pump();
    final TextField field = tester.widget<TextField>(
      find.byType(TextField).first,
    );
    return field.controller?.text ?? '';
  }

  CareerlyButton analyzeButton(WidgetTester tester) =>
      tester.widget<CareerlyButton>(find.byType(CareerlyButton));

  // ---------------------------------------------------------------------------
  // 一、入口与空库
  // ---------------------------------------------------------------------------

  group('入口与空库', () {
    testWidgets('空库：弹层打开并显示 Empty 态（不是列表、不是错误）', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository();
      await pumpPage(tester, host(repository));
      await tapAddFromHistory(tester);
      await tester.pumpAndSettle();

      // 弹层自身的标题与说明。
      expect(find.text('历史岗位'), findsOneWidget);
      // 空库是**真实的**空 —— 第一次用的用户必然看到它
      //（Mock 也返回空，见 `mock_analysis_repository.dart`）。
      expect(find.text('还没有历史岗位'), findsOneWidget);
      expect(find.text('重试'), findsNothing);
      expect(repository.jobLibraryCalls, 1);
      // 打开选择列表**不是分析**：不建任务、不扣额度。
      expect(repository.analyzeCalls, 0);
      expect(providerOf(tester).quota, QuotaState.free);
    });

    testWidgets('读取中：先取数再开弹层，Loading 文案可见', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        manualJobLibrary: true,
      );
      await pumpPage(tester, host(repository));
      await tapAddFromHistory(tester);
      // ⚠️ 不能用 pumpAndSettle —— 转圈是无限动画，会一直等下去。
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('正在读取历史岗位…'), findsOneWidget);

      // 放行，避免带着未完成的 future 收尾。
      repository.completeJobLibrary(<Job>[historyJob()]);
      await tester.pump();
      await tester.pump();
      expect(find.text('$historyCompany · $historyTitle'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 二、列表与选择
  // ---------------------------------------------------------------------------

  group('选择历史岗位', () {
    testWidgets('列表渲染「公司 · 岗位」+「YYYY.MM.DD 分析过」', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        jobs: <Job>[historyJob()],
      );
      await pumpPage(tester, host(repository));
      await tapAddFromHistory(tester);
      await tester.pumpAndSettle();

      expect(find.text('$historyCompany · $historyTitle'), findsOneWidget);
      expect(find.text('2026.09.01 分析过'), findsOneWidget);
      expect(find.text('还没有历史岗位'), findsNothing);
    });

    testWidgets('无 createdAt 的行：不编造日期（CLAUDE.md §7）', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        jobs: <Job>[
          const Job(id: 'job-no-date', title: historyTitle, rawJd: historyJd),
        ],
      );
      await pumpPage(tester, host(repository));
      await tapAddFromHistory(tester);
      await tester.pumpAndSettle();

      expect(find.text(historyTitle), findsOneWidget);
      // ⚠️ 不能用 `textContaining('分析过')` —— 弹层自己的说明句里也有
      // 「分析过」三个字。这里只认**日期行**（以「 分析过」结尾）。
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && (widget.data ?? '').endsWith(' 分析过'),
        ),
        findsNothing,
      );
    });

    testWidgets('选中 → 弹层关闭 + 表单回填 + 「开始分析（1 个岗位）」可用', (
      WidgetTester tester,
    ) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        jobs: <Job>[historyJob()],
      );
      await pumpPage(tester, host(repository));
      await tapAddFromHistory(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('$historyCompany · $historyTitle'));
      await tester.pump();
      await tester.tap(find.text('$historyCompany · $historyTitle'));
      await tester.pumpAndSettle();

      // 弹层已关闭。
      expect(find.text('历史岗位'), findsNothing);
      // 岗位胶囊 + 计数文案都反映了这次选择。
      expect(find.text('$historyCompany · $historyTitle'), findsOneWidget);
      expect(find.text('已添加 1 个目标岗位'), findsOneWidget);

      // 最关键的一条：JD 框 = 上次存下来的原文（`Job.rawJd`）。
      expect(
        await jdBoxText(tester),
        historyJd,
        reason: '选历史岗位的意义就是「不必重新粘贴 JD」—— 回填空串等于没接上',
      );

      // 岗位加好了 → 「开始分析」可用。
      await tester.ensureVisible(find.text('开始分析（1 个岗位）'));
      await tester.pump();
      expect(analyzeButton(tester).onPressed, isNotNull);
    });

    testWidgets('取消 → 不添加岗位、表单保持原样', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        jobs: <Job>[historyJob()],
      );
      await pumpPage(tester, host(repository));
      await tapAddFromHistory(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('取消'));
      await tester.pump();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(find.text('历史岗位'), findsNothing);
      expect(find.text('已添加 1 个目标岗位'), findsNothing);
      expect(find.text('还没有添加目标岗位'), findsOneWidget);
      expect(analyzeButton(tester).onPressed, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // 三、读取失败（Error / Retry）
  // ---------------------------------------------------------------------------

  group('读取失败', () {
    testWidgets('失败 → Error 文案 + 重试钮；重试成功后列表出现', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        jobLibraryError: const NetworkError(message: '历史岗位读取失败'),
      );
      await pumpPage(tester, host(repository));
      await tapAddFromHistory(tester);
      await tester.pumpAndSettle();

      // 如实报错，而不是静默给一个空列表 —— 空列表会被读成「你没有历史岗位」。
      expect(find.text('历史岗位读取失败'), findsOneWidget);
      expect(find.text('还没有历史岗位'), findsNothing);
      expect(find.text('重试'), findsOneWidget);

      // 网络恢复。
      repository.jobLibraryError = null;
      repository.jobs = <Job>[historyJob()];
      await tester.ensureVisible(find.text('重试'));
      await tester.pump();
      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();

      expect(repository.jobLibraryCalls, 2);
      expect(find.text('$historyCompany · $historyTitle'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// 桩
// ---------------------------------------------------------------------------

/// 可编排的历史岗位库 / 分析仓库。
class StubAnalysisRepository implements AnalysisRepository {
  StubAnalysisRepository({
    this.quota = QuotaState.free,
    this.jobs = const <Job>[],
    this.jobLibraryError,
    this.manualJobLibrary = false,
  });

  QuotaState quota;

  /// 岗位库返回的岗位。
  List<Job> jobs;

  /// 岗位库读取失败时抛出的错误。
  Object? jobLibraryError;

  /// `true` 时不自动返回 —— 由 [completeJobLibrary] 决定何时完成，
  /// 用来测「还在读」的中间态。
  bool manualJobLibrary;

  int jobLibraryCalls = 0;
  int analyzeCalls = 0;

  Completer<List<Job>>? _pendingLibrary;

  void completeJobLibrary(List<Job> value) => _pendingLibrary!.complete(value);

  @override
  Future<List<Job>> fetchJobLibrary() {
    jobLibraryCalls++;
    if (manualJobLibrary) {
      _pendingLibrary = Completer<List<Job>>();
      return _pendingLibrary!.future;
    }
    final Object? failure = jobLibraryError;
    if (failure != null) return Future<List<Job>>.error(failure);
    return Future<List<Job>>.value(jobs);
  }

  @override
  Future<List<AnalysisProject>> fetchProjects() async =>
      const <AnalysisProject>[];

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async => null;

  @override
  Future<QuotaState> fetchQuota() async => quota;

  @override
  Future<ParsedJob> parseJobUrl(String url) async =>
      throw const NetworkError(message: '本用例不涉及链接抓取');

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
  }) async {
    analyzeCalls++;
    final DateTime now = DateTime(2026, 1, 1);
    final String projectId = 'stub-project-$analyzeCalls';
    final Job job = Job(
      id: '$projectId-job',
      title: title,
      rawJd: rawJd,
      source: 'paste',
      createdAt: now,
    );
    return AnalysisProject(
      id: projectId,
      name: title,
      jobs: <Job>[job],
      results: <AnalysisResult>[
        AnalysisResult(
          id: '$projectId-result-1',
          projectId: projectId,
          version: 1,
          matches: <JobMatch>[
            JobMatch(jobId: job.id, score: 42, rank: 1), // 夹具值，不是产品数据
          ],
          createdAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _StubResumeRepository implements ResumeRepository {
  @override
  Future<ResumeProfile> fetchProfile() async => ResumeProfile.empty;

  @override
  Future<List<ResumeVersion>> fetchVersions() async => const <ResumeVersion>[];

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
