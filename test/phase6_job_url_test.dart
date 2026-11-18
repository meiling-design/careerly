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
import 'package:careerly/features/profile/state/growth_celebration_provider.dart';
import 'package:careerly/features/profile/state/resume_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// ③ 岗位 URL —— 「粘贴链接 → 抓取 → 回填 JD 文本框」。
///
/// 依据：
///
/// ```text
/// CLAUDE.md §5.2  额度只在点击「开始分析」时扣 —— 抓取不扣
/// CLAUDE.md §5.5  四态：Loading / Empty / Error / Retry / Disabled
/// CLAUDE.md §7    Mock 不得编造产品数据（抓不到就报错，不造假 JD）
/// 产品侧裁决       落点 = 抓取回填 JD 文本框（2026-10-02）
/// ```
///
/// ## 为什么要有这份测试
///
/// 这条路径**改前是坏的**：`onConfirmUrl` 把链接**原样写进 JD 文本框**，
/// 于是「开始分析」把一条 `https://...` 当招聘描述发给后端解析。
/// 界面看起来一切正常（岗位胶囊有了、按钮可点），错误只在分析结果里。
///
/// 因此这里钉的不是「有没有回填」，而是**回填进去的到底是什么**：
///
/// ```text
/// ✅ JD 框 = 抓回来的正文
/// ❌ JD 框 = 那条链接            ← 旧行为，必须钉死
/// ```
void main() {
  // ---------------------------------------------------------------------------
  // 夹具
  // ---------------------------------------------------------------------------

  const String url = 'https://www.zhipin.com/job/detail/abc123';
  const String crawledTitle = '高级 Python 后端工程师';
  const String crawledJd =
      '岗位职责：负责 AI Agent 平台的服务端设计与开发。\n'
      '任职要求：5 年以上 Python 经验，熟悉 FastAPI、PostgreSQL、Docker。';

  const ParsedJob crawled = ParsedJob(
    url: url,
    title: crawledTitle,
    company: '某某科技',
    description: crawledJd,
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
        // 分析成功后会向成长庆祝 Provider 记一笔（生产由 careerlyProviders 注入）。
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

  AnalysisProvider providerOf(WidgetTester tester) =>
      Provider.of<AnalysisProvider>(
        tester.element(find.byType(AnalysisPage)),
        listen: false,
      );

  /// 展开「粘贴岗位 URL」表单。
  ///
  /// ⚠️ 800×600 的测试视口下这些按钮落在首屏之外，不先滚到可见就 tap 会
  /// **静默打空**（tap 只发 warning 不抛异常），失败点跑到几条断言之后。
  Future<void> openUrlForm(WidgetTester tester) async {
    await tester.ensureVisible(find.text('粘贴岗位 URL'));
    await tester.pump();
    await tester.tap(find.text('粘贴岗位 URL'));
    await tester.pump();
  }

  /// 填入链接并点确认（按钮文案由状态决定，故按位置找确认钮）。
  Future<void> submitUrl(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField).first, value);
    await tester.pump();
    await tester.ensureVisible(find.text('添加岗位'));
    await tester.pump();
    await tester.tap(find.text('添加岗位'));
    await tester.pump();
  }

  /// JD 输入框里的文本。表单关闭时读不到 —— 先展开「粘贴 JD」。
  ///
  /// 展开 JD 表单用的是**同一个** `TextEditingController`，
  /// 所以这既能读回填结果，也正是用户「看得到、改得动」的那条路径。
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
  // 一、成功路径：抓回来的正文进 JD 框（不是那条链接）
  // ---------------------------------------------------------------------------

  group('抓取回填（成功）', () {
    testWidgets('JD 框 = 抓回来的正文，**不是**那条链接', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        parseResult: crawled,
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      // 仓库确实收到了用户粘的那条链接。
      expect(repository.parsedUrls, <String>[url]);

      final String jd = await jdBoxText(tester);
      expect(jd, crawledJd, reason: '回填的必须是抓回来的 JD 正文');
      expect(
        jd.contains('https://'),
        isFalse,
        reason: '旧行为把链接本身当 JD 发给后端，这里把它钉死',
      );
    });

    testWidgets('岗位名 = 抓回来的 title（胶囊可见，不用域名凑）', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        parseResult: crawled,
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(find.text(crawledTitle), findsOneWidget);
      // 旧行为显示的是「岗位（zhipin.com）」这种域名推导名。
      expect(find.text('岗位（zhipin.com）'), findsNothing);
      expect(find.text('已添加 1 个目标岗位'), findsOneWidget);
    });

    testWidgets('抓到的岗位走的是原有分析链路：rawJd 是正文、title 是岗位名', (
      WidgetTester tester,
    ) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        parseResult: crawled,
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      await tester.ensureVisible(find.text('开始分析（1 个岗位）'));
      await tester.pump();
      await tester.tap(find.text('开始分析（1 个岗位）'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(repository.analyzeCalls, 1);
      expect(repository.analyzedTitle, crawledTitle);
      expect(repository.analyzedJd, crawledJd);
    });

    testWidgets('抓取**不扣额度**（CLAUDE.md §5.2）', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        parseResult: crawled,
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(providerOf(tester).quota, QuotaState.free);
      expect(find.textContaining('剩余 3 / 3 次'), findsOneWidget);
      expect(
        repository.analyzeCalls,
        0,
        reason: '抓取不是分析 —— 不得建任务、不得扣额度',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 二、Loading：抓取是在等一个几十秒的网络动作，必须看得见
  // ---------------------------------------------------------------------------

  group('抓取中（Loading / Disabled）', () {
    testWidgets('等待期间：转圈行可见、确认钮不可点、输入框禁用', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        manualParse: true,
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);

      expect(find.text('正在抓取岗位信息…'), findsOneWidget);
      expect(find.text('抓取中…'), findsOneWidget);
      // 确认钮此时挂着「抓取中…」，且不可点（防重复提交 = 重复爬取）。
      final CareerlyButton confirm = tester.widget<CareerlyButton>(
        find.byType(CareerlyButton),
      );
      expect(confirm.onPressed, isNull, reason: '等待期间不得重发');
      // 输入框禁用（CareerlyInput 的 Disabled 态）。
      final TextField field = tester.widget<TextField>(
        find.byType(TextField).first,
      );
      expect(field.enabled, isFalse);
      // 岗位还没添加 → 「开始分析」保持禁用，不产生半成品岗位。
      expect(analyzeButton(tester).onPressed, isNull);

      // 放行，收尾（避免 pending timer / 未完成的 future 跨用例残留）。
      repository.completeParse(crawled);
      await tester.pump();
      await tester.pump();
    });
  });

  // ---------------------------------------------------------------------------
  // 三、Error / Retry：抓不到要说清楚，并且**不能**产生一个空 JD 的岗位
  // ---------------------------------------------------------------------------

  group('抓不到（Error / Retry）', () {
    testWidgets('失败：表单里显示后端文案 + 按钮变「重试」', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        parseError: const NetworkError(
          message: '未能从该链接抓取到岗位信息。请确认链接可公开访问，或直接粘贴 JD 文本',
        ),
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(
        find.text('未能从该链接抓取到岗位信息。请确认链接可公开访问，或直接粘贴 JD 文本'),
        findsOneWidget,
      );
      expect(find.text('重试'), findsOneWidget);
      // 链接还在框里 —— 失败后用户要么改、要么重试，不该被迫重粘一遍。
      final TextField field = tester.widget<TextField>(
        find.byType(TextField).first,
      );
      expect(field.controller?.text, url);
    });

    testWidgets('失败**不产生**目标岗位：「开始分析」仍禁用', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        parseError: const NetworkError(message: '抓取失败'),
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(find.text('已添加 1 个目标岗位'), findsNothing);
      expect(find.text('还没有添加目标岗位'), findsOneWidget);
      expect(
        analyzeButton(tester).onPressed,
        isNull,
        reason: '抓取失败不得留下一个 JD 为空的岗位（失败无痕的反面）',
      );
    });

    testWidgets('重试 → 再次抓取并成功回填', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        parseError: const NetworkError(message: '抓取失败'),
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      // 网络恢复，再点「重试」。
      repository.parseError = null;
      repository.parseResult = crawled;
      await tester.ensureVisible(find.text('重试'));
      await tester.pump();
      await tester.tap(find.text('重试'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(repository.parsedUrls, <String>[url, url]);
      expect(find.text(crawledTitle), findsOneWidget);
    });

    testWidgets('取消后重开：上一次的失败红字被清掉', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        parseError: const NetworkError(message: '抓取失败'),
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.text('抓取失败'), findsOneWidget);

      await tester.ensureVisible(find.text('取消'));
      await tester.pump();
      await tester.tap(find.text('取消'));
      await tester.pump();

      await openUrlForm(tester);
      expect(
        find.text('抓取失败'),
        findsNothing,
        reason: '旧错误留着会被读成「这次输入就错了」',
      );
      expect(providerOf(tester).jobUrlState.isInitial, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // 四、迟到结果：抓取途中取消 → 结果不得偷写进已关闭的表单
  // ---------------------------------------------------------------------------

  group('取消（迟到结果作废）', () {
    testWidgets('抓取途中取消 → 结果不写进 JD 框、岗位也不添加', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        manualParse: true,
      );
      await pumpPage(tester, host(repository));
      await openUrlForm(tester);
      await submitUrl(tester, url);

      // 用户等不下去，点了取消。
      await tester.ensureVisible(find.text('取消'));
      await tester.pump();
      await tester.tap(find.text('取消'));
      await tester.pump();

      // 此时抓取才回来。
      repository.completeParse(crawled);
      await tester.pump();
      await tester.pump();

      expect(find.text('已添加 1 个目标岗位'), findsNothing);
      expect(find.text('粘贴岗位 URL'), findsOneWidget, reason: '表单已关闭且未重开');
      expect(analyzeButton(tester).onPressed, isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// 桩
// ---------------------------------------------------------------------------

/// 可编排的抓取 / 分析仓库。
class StubAnalysisRepository implements AnalysisRepository {
  StubAnalysisRepository({
    this.quota = QuotaState.free,
    this.parseResult,
    this.parseError,
    this.manualParse = false,
  });

  QuotaState quota;

  /// 抓取成功时返回的岗位。
  ParsedJob? parseResult;

  /// 抓取失败时抛出的错误。
  Object? parseError;

  /// `true` 时不自动返回 —— 由 [completeParse] / [failParse] 决定何时完成，
  /// 用来测「抓取还在路上」的中间态。
  bool manualParse;

  /// 收到过的链接，按顺序。
  final List<String> parsedUrls = <String>[];

  int analyzeCalls = 0;
  String? analyzedTitle;
  String? analyzedJd;

  Completer<ParsedJob>? _pending;

  void completeParse(ParsedJob job) => _pending!.complete(job);

  void failParse(Object error) => _pending!.completeError(error);

  @override
  Future<ParsedJob> parseJobUrl(String url) {
    parsedUrls.add(url);
    if (manualParse) {
      _pending = Completer<ParsedJob>();
      return _pending!.future;
    }
    final Object? failure = parseError;
    if (failure != null) return Future<ParsedJob>.error(failure);
    return Future<ParsedJob>.value(parseResult!);
  }

  @override
  Future<List<AnalysisProject>> fetchProjects() async =>
      const <AnalysisProject>[];

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async => null;

  @override
  Future<List<Job>> fetchJobLibrary() async => const <Job>[];

  @override
  Future<QuotaState> fetchQuota() async => quota;

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
  }) async {
    analyzeCalls++;
    analyzedTitle = title;
    analyzedJd = rawJd;
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
