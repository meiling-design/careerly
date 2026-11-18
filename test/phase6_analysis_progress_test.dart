import 'dart:async';

import 'package:careerly/core/state/state.dart';
import 'package:careerly/data/models/analysis_project.dart';
import 'package:careerly/data/models/analysis_result.dart';
import 'package:careerly/data/models/job.dart';
import 'package:careerly/data/models/parsed_job.dart';
import 'package:careerly/data/models/quota_state.dart';
import 'package:careerly/data/models/resume_file.dart';
import 'package:careerly/data/models/resume_profile.dart';
import 'package:careerly/data/repositories/analysis_repository.dart';
import 'package:careerly/data/repositories/resume_repository.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/analysis/presentation/analysis_page.dart';
import 'package:careerly/features/analysis/presentation/widgets/careerly_analysis_progress.dart';
import 'package:careerly/features/analysis/state/analysis_provider.dart';
import 'package:careerly/features/profile/state/resume_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Careerly Phase 6 —— 补做「AI 正在分析」复合组件
/// [CareerlyAnalysisProgress]（D28）。
///
/// 真值来源：Figma `AnalysisProcessing`（`src/App.tsx` L1864-2118）。
///
/// ## 这份测试钉住什么
///
/// 1. **结构齐备**：标题栏 / 上下文胶囊 / 大百分比 / 当前任务行 /
///    5 步时间线 / 「退出分析」—— 都在，且文案逐字对齐 Figma。
/// 2. **UI 时钟独立推进**：百分比随 [AppMotion.analysisTick] 递增，
///    缓动 `1-(1-frac)^2.2`；时间线 5 步按节拍逐次完成。
/// 3. **两条时钟不互踩**：真实分析比时间线慢，组件定格在
///    「分析完成！· 100%」等待，不自行切页；比时间线快，被结果页替换。
/// 4. **退出 = 中止 + 回滚额度**（Provider `exitAnalysis`）：
///    退出后状态回「新建分析」、额度回滚、迟到的僵尸结果被作废。
/// 5. **onDone 只通知、不导航**：UI 时钟定格后触发回调，切页仍由
///    Provider 状态决定。
///
/// ## 为何要注入 Repository
///
/// 默认 Mock 的 `analyze` 是 `Future.delayed`，时长固定；这里用桩注入
/// **可配时长**，才能覆盖「分析比时间线慢（定格等待）」与
/// 「退出后僵尸结果作废」两条分支（同 Phase 5/6 的桩注入先例）。

// ---------------------------------------------------------------------------
// 桩实现（顶层）
// ---------------------------------------------------------------------------

/// 可控时长的分析仓库。
///
/// `analyze` 返回一个 **永不自动完成** 的 [Completer.future]（不产生定时器），
/// 因此「分析比 UI 时钟慢」的分支不会在测试末尾残留 pending Timer；
/// 需要「迟到结果」时手动 [completeLatestAnalysis] 补发即可。
class StubAnalysisRepository implements AnalysisRepository {
  StubAnalysisRepository({this.quota = QuotaState.free});

  QuotaState quota;
  int analyzeCalls = 0;

  final List<_PendingAnalysis> _pending = <_PendingAnalysis>[];

  @override
  Future<List<AnalysisProject>> fetchProjects() async =>
      const <AnalysisProject>[];

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async => null;

  @override
  Future<List<Job>> fetchJobLibrary() async => const <Job>[];

  @override
  Future<QuotaState> fetchQuota() async => quota;

  // ③ 岗位 URL：本文件不测抓取（见 `phase6_job_url_test.dart`），
  // 但接口要求实现 —— 明确抛「未实现」，别假装成功。
  @override
  Future<ParsedJob> parseJobUrl(String url) async =>
      throw UnimplementedError('测试桩不覆盖岗位链接抓取');

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
  }) {
    analyzeCalls++;
    // P1-03：任务开始时后端预占一次额度；桩模拟服务端读数。
    quota = quota.copyWith(
      reserved: (quota.reserved + 1).clamp(0, quota.total),
    );
    final _PendingAnalysis pending = _PendingAnalysis(
      Completer<AnalysisProject>(),
      _buildProject(analyzeCalls, title: title, rawJd: rawJd),
    );
    _pending.add(pending);
    return pending.completer.future;
  }

  /// 补发最近一次未完成分析的结果 —— 模拟「迟到的僵尸结果」。
  void completeLatestAnalysis() {
    for (final _PendingAnalysis pending in _pending) {
      if (!pending.completer.isCompleted) {
        quota = quota.copyWith(
          reserved: (quota.reserved - 1).clamp(0, quota.total),
          used: (quota.used + 1).clamp(0, quota.total),
        );
        pending.completer.complete(pending.project);
        return;
      }
    }
  }

  AnalysisProject _buildProject(
    int seq, {
    required String title,
    required String rawJd,
  }) {
    final DateTime now = DateTime(2026, 1, 1);
    final Job job = Job(
      id: 'stub-job-$seq',
      title: title.trim().isEmpty ? '测试岗位 A' : title.trim(),
      rawJd: rawJd,
      source: 'paste',
      createdAt: now,
    );
    return AnalysisProject(
      id: 'stub-project-$seq',
      name: job.title,
      jobs: <Job>[job],
      results: <AnalysisResult>[
        AnalysisResult(
          id: 'stub-result-$seq',
          projectId: 'stub-project-$seq',
          version: 1,
          matches: <JobMatch>[
            JobMatch(
              jobId: job.id,
              score: 42, // 夹具值，不是产品数据
              rank: 1,
              reasons: const <String>['测试夹具：匹配依据'],
              gaps: const <String>['测试夹具：能力 Gap'],
              suggestion: '测试夹具：成长建议',
            ),
          ],
          createdAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _PendingAnalysis {
  _PendingAnalysis(this.completer, this.project);

  final Completer<AnalysisProject> completer;
  final AnalysisProject project;
}

class StubResumeRepository implements ResumeRepository {
  @override
  Future<ResumeProfile> fetchProfile() async => ResumeProfile.empty;

  @override
  Future<List<ResumeVersion>> fetchVersions() async => const <ResumeVersion>[];

  @override
  Future<List<int>> fetchVersionOriginalPdf(String versionId) async =>
      const <int>[];

  @override
  Future<void> setCurrentVersion(String versionId) async {}

  // ResumeRepository 新增「删除版本」（PRD §14）—— 桩同步实现。
  @override
  Future<void> deleteVersion(String versionId) async {}

  @override
  Future<void> submitResumeText(String text) async {}

  // ResumeRepository 新增「选择文件」路径（D67 关闭）—— 桩同步实现。
  @override
  Future<void> submitResumeFile(ResumeFileData file) async {}

  @override
  Future<ResumeProfile> buildBaseline() async => ResumeProfile.empty;
}

void main() {
  // ---------------------------------------------------------------------------
  // 宿主
  // ---------------------------------------------------------------------------

  Widget pageHost({
    required AnalysisRepository analysis,
    ResumeRepository? resume,
  }) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<AnalysisRepository>.value(value: analysis),
        Provider<ResumeRepository>.value(
          value: resume ?? StubResumeRepository(),
        ),
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

  /// 从「新建分析」走完「添加岗位 → 开始分析」进入进度视图。
  Future<void> enterProgress(
    WidgetTester tester,
    StubAnalysisRepository repo,
  ) async {
    await tester.pumpWidget(pageHost(analysis: repo));
    await tester.pump(); // 首帧 → load / loadQuota
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    await tester.tap(find.text('粘贴 JD 添加岗位'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '测试岗位描述');
    await tester.pump();
    await tester.ensureVisible(find.text('添加岗位'));
    await tester.pump();
    await tester.tap(find.text('添加岗位'));
    await tester.pump();
    await tester.ensureVisible(find.text('开始分析（1 个岗位）'));
    await tester.pump();
    await tester.tap(find.text('开始分析（1 个岗位）'));
    await tester.pump(); // 同步置为 loading → 进度视图
  }

  /// 卸载整棵 widget 树 → 触发进度组件 `dispose`，取消未决的
  /// UI 时钟 `Timer`（否则 `testWidgets` 会报 `!timersPending`）。
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
  }

  AnalysisProvider providerOf(WidgetTester tester) =>
      Provider.of<AnalysisProvider>(
        tester.element(find.byType(AnalysisPage)),
        listen: false,
      );

  group('CareerlyAnalysisProgress 结构', () {
    testWidgets('标题栏 / 胶囊 / 百分比 / 任务行 / 5 步 / 退出按钮齐备', (tester) async {
      final repo = StubAnalysisRepository();
      await enterProgress(tester, repo);

      expect(find.text('AI 正在分析'), findsOneWidget);
      expect(find.text('正在分析'), findsOneWidget);
      expect(find.text('新建分析'), findsNothing);
      expect(find.text('历史分析'), findsNothing);
      expect(find.text('1 份简历 × 1 个目标岗位'), findsOneWidget);
      expect(find.text('分析进度'), findsOneWidget);
      // 5 步标题逐字对齐 Figma。
      expect(find.text('岗位需求解析'), findsOneWidget);
      expect(find.text('简历信息解析'), findsOneWidget);
      expect(find.text('能力匹配分析'), findsOneWidget);
      expect(find.text('识别能力 Gap'), findsOneWidget);
      expect(find.text('生成分析报告'), findsOneWidget);
      expect(find.text('退出分析'), findsOneWidget);
      // 初始百分比（analysisStartPercent = 1）。
      expect(find.text('1'), findsWidgets);

      await unmount(tester);
    });
  });

  group('CareerlyAnalysisProgress UI 时钟', () {
    testWidgets('百分比按缓动递增，且不因 UI 时钟走完而切页', (tester) async {
      final repo = StubAnalysisRepository();
      await enterProgress(tester, repo);

      // 400ms → 第 1 步（1300ms）内：20 * (1-(1-10/32.5)^2.2) ≈ 11。
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('11'), findsOneWidget);

      // 再 600ms（累计 1000ms）→ ≈ 19。
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('19'), findsOneWidget);
      expect(find.text('11'), findsNothing);

      // 时间线走完（总 7.3s + settle 500）→ 定格「分析完成！」，仍在进度视图。
      await tester.pump(const Duration(seconds: 8));
      expect(find.text('分析完成！'), findsOneWidget);
      // 真实分析（30s）未返回，结果页不出现。
      expect(find.text('测试岗位 A'), findsNothing);

      await unmount(tester);
    });

    testWidgets('5 步按节拍推进：完成态 / 进行中 / 等待中数量正确', (tester) async {
      final repo = StubAnalysisRepository();
      await enterProgress(tester, repo);

      // 第 1 步 1300ms 后：步 0 完成，步 1 进行中，步 2-4 等待中。
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.text('已完成 · 100%'), findsOneWidget);
      expect(find.textContaining('进行中 ·'), findsOneWidget);
      expect(find.text('等待中'), findsNWidgets(3));

      await unmount(tester);
    });
  });

  group('退出分析（Provider.exitAnalysis）', () {
    testWidgets('确认 Sheet 出现，点「退出」后回到新建分析且**保留**预占额度', (tester) async {
      final repo = StubAnalysisRepository();
      await enterProgress(tester, repo);

      // 进入分析时后端已预占 1 次额度（P1-03）。
      final before = providerOf(tester).quota!;
      expect(before.reserved, 1);
      expect(before.used, 0);

      await tester.ensureVisible(find.text('退出分析'));
      await tester.pump();
      await tester.tap(find.text('退出分析'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('正在分析中'), findsOneWidget);
      expect(find.text('继续分析'), findsOneWidget);

      await tester.tap(find.text('退出'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 回到「新建分析」表单（岗位信息保留，按钮带岗位计数）。
      expect(find.text('开始分析（1 个岗位）'), findsOneWidget);
      // P1-05：退出页面 ≠ 取消服务器任务，额度**不**回滚。
      final after = providerOf(tester).quota!;
      expect(after.reserved, 1);
      expect(after.used, 0);
      expect(after.remaining, 2);
    });

    testWidgets('「继续分析」关闭 Sheet 且保持进度视图', (tester) async {
      final repo = StubAnalysisRepository();
      await enterProgress(tester, repo);

      await tester.ensureVisible(find.text('退出分析'));
      await tester.pump();
      await tester.tap(find.text('退出分析'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('继续分析'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('正在分析中'), findsNothing);
      expect(find.text('AI 正在分析'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('迟到的僵尸结果被作废：退出后等分析完成也不切页', (tester) async {
      final repo = StubAnalysisRepository();
      await enterProgress(tester, repo);

      await tester.ensureVisible(find.text('退出分析'));
      await tester.pump();
      await tester.tap(find.text('退出分析'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('退出'));
      await tester.pump();

      // 补发迟到的分析结果 —— 应被代际号作废，不进入结果页。
      repo.completeLatestAnalysis();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(find.text('开始分析（1 个岗位）'), findsOneWidget);
      expect(find.text('测试岗位 A'), findsNothing);
      expect(
        providerOf(tester).analysisState,
        isA<AsyncInitial<AnalysisProject>>(),
      );
    });
  });

  group('onDone 回调', () {
    testWidgets('UI 时钟定格后触发 onDone，且只通知不导航', (tester) async {
      var done = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: CareerlyTheme.light(),
          home: Scaffold(
            body: CareerlyAnalysisProgress(
              jobCount: 1,
              onDone: () => done = true,
            ),
          ),
        ),
      );

      // 总时长 7.3s + settle 500 + advance 900，加上 40ms 节拍取整 ≈ 8.72s。
      await tester.pump(const Duration(milliseconds: 8800));
      await tester.pump();

      expect(done, isTrue);
      expect(find.text('分析完成！'), findsOneWidget);
    });
  });
}
