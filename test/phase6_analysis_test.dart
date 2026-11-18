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

/// Careerly Phase 6 —— 分析（`新建分析` / `历史分析`）。
///
/// 依据：
///
/// ```text
/// PRD §9   分析｜看见距离     —— 页面定位 / 一级 Tag / 结果 / 分析中 / 历史分析
/// IA  §7   分析 IA            —— 一级结构与各处归属
/// Baseline §5                 —— 额度规则（进页面不扣，点「开始分析」才扣）
/// CLAUDE.md §5.2 / §5.5 / §7  —— 额度 / 四态 / 不编造产品数据
/// D28                         —— CareerlyAnalysisProgress 归 Phase 6
/// ```
///
/// ## 这份测试钉住什么
///
/// 1. **一级内部分类恰好两个**（PRD §9.2 / IA §7.1）——
///    `新建分析 | 历史分析`，默认落在新建分析。
/// 2. **额度只在「开始分析」时扣**（`CLAUDE.md` §5.2 的硬规则）——
///    进页面 / 填 JD / 空 JD 提交，**都不扣**；失败**回滚**。
/// 3. **四态齐备**（`CLAUDE.md` §5.5）—— 历史分析的 Loading / Empty / Error / Retry。
/// 4. **不得编造产品数据**（`CLAUDE.md` §7 / D64 ⑥）——
///    本页曾把 Figma 原型里的 `Resume V3 · 2026.08.27` 与
///    `5项 / 4段 / 6个` 写死在「当前简历」卡上。那是演示值，
///    漏进产品就会被当成需求。这里用**反假数据断言**守着这条线。
///
/// ## 为什么要注入 Repository
///
/// `MockAnalysisRepository` 的 `fetchQuota` 恒返回 `QuotaState.free`，
/// 因此 **额度耗尽 / 分析失败 / 历史列表非空** 三态在默认 Mock 下不可达。
/// 用桩实现注入，免得这些分支在验收前从未被执行过
/// （同 Phase 5 对 State 02 / 03 的处置，见 D75）。
void main() {
  // ---------------------------------------------------------------------------
  // 夹具
  // ---------------------------------------------------------------------------

  /// 一份有内容的简历画像：2 项能力 / 1 段经历 / 3 个项目。
  final ResumeProfile filledProfile = ResumeProfile(
    versions: <ResumeVersion>[
      ResumeVersion(
        id: 'v1',
        label: '测试版简历',
        uploadedAt: DateTime(2026, 3, 4),
        isCurrent: true,
      ),
    ],
    workExperiences: const <String>['测试经历'],
    projectExperiences: const <String>['测试项目 1', '测试项目 2', '测试项目 3'],
    skills: const <String>['测试能力 1', '测试能力 2'],
  );

  // ---------------------------------------------------------------------------
  // 宿主
  // ---------------------------------------------------------------------------

  Widget host({
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

  Future<void> pumpPage(
    WidgetTester tester,
    Widget widget, {
    Duration delay = Duration.zero,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pump(); // 首帧 → postFrameCallback → load() / loadQuota()
    await tester.pump(delay + const Duration(milliseconds: 1)); // Future 完成
    await tester.pump(); // 重建
  }

  /// 取到当前页面上的 Provider —— 用于断言**状态**而不只是文案。
  AnalysisProvider providerOf(WidgetTester tester) =>
      Provider.of<AnalysisProvider>(
        tester.element(find.byType(AnalysisPage)),
        listen: false,
      );

  /// 切到「历史分析」。
  Future<void> tapHistory(WidgetTester tester) async {
    await tester.tap(find.text('历史分析'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
  }

  /// 走完「粘贴 JD → 添加岗位」两步，让「开始分析」可用。
  Future<void> addJob(WidgetTester tester, String jd) async {
    await tester.tap(find.text('粘贴 JD 添加岗位'));
    await tester.pump();
    // 展开后只有一个输入框：JD 多行文本。
    // （Figma 没有「岗位名称」输入框 —— 岗位名由 JD 首行推导。）
    await tester.enterText(find.byType(TextField).first, jd);
    await tester.pump();
    // ⚠️ 800×600 的测试视口下，「添加岗位」落在首屏之外（y≈653）。
    //    不先滚到可见就 tap，点击会**静默打空** ——
    //    tap 只发一条 warning，不抛异常，于是岗位从未添加、
    //    「开始分析」保持禁用，失败点会跑到几条断言之后，
    //    看起来像是额度逻辑错了。先 ensureVisible 再点。
    await tester.ensureVisible(find.text('添加岗位'));
    await tester.pump();
    await tester.tap(find.text('添加岗位'));
    await tester.pump();
  }

  CareerlyButton analyzeButton(WidgetTester tester) =>
      tester.widget<CareerlyButton>(find.byType(CareerlyButton));

  // ---------------------------------------------------------------------------
  // 一、一级内部分类（PRD §9.2 / IA §7.1）
  // ---------------------------------------------------------------------------

  group('一级内部分类', () {
    testWidgets('恰好两个 Tag：新建分析 | 历史分析', (WidgetTester tester) async {
      await pumpPage(tester, host(analysis: StubAnalysisRepository()));

      expect(find.text('新建分析'), findsOneWidget);
      expect(find.text('历史分析'), findsOneWidget);
      expect(
        find.text('职业分析'),
        findsOneWidget,
        reason: 'IA §7.1：这是分析页面唯一的一级内部分类',
      );
    });

    testWidgets('默认落在「新建分析」，不渲染历史列表', (WidgetTester tester) async {
      await pumpPage(
        tester,
        host(
          analysis: StubAnalysisRepository(
            projects: <AnalysisProject>[
              AnalysisProject(id: 'p1', name: '夹具项目'),
            ],
          ),
        ),
      );

      // 新建分析的标志：当前简历卡 + 提交 JD 的入口。
      expect(find.text('当前简历'), findsOneWidget);
      expect(find.text('粘贴 JD 添加岗位'), findsOneWidget);
      // 历史列表的内容**不该**出现。
      expect(find.text('夹具项目'), findsNothing);
    });

    testWidgets('切到「历史分析」后展示项目列表', (WidgetTester tester) async {
      await pumpPage(
        tester,
        host(
          analysis: StubAnalysisRepository(
            projects: <AnalysisProject>[
              AnalysisProject(id: 'p1', name: '夹具项目'),
            ],
          ),
        ),
      );

      await tapHistory(tester);

      // 历史卡按 Figma 显示「一次分析 · N 个岗位」，不再渲染项目名。
      expect(find.text('一次分析 · 0 个岗位'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 二、额度门禁与扣减时机（CLAUDE.md §5.2 —— 硬规则）
  // ---------------------------------------------------------------------------

  group('额度', () {
    testWidgets('进入分析页**不扣**额度', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository();
      await pumpPage(tester, host(analysis: repository));

      expect(
        providerOf(tester).quota,
        QuotaState.free,
        reason: 'CLAUDE.md §5.2：进入分析页面不扣额度',
      );
      expect(repository.quotaCalls, 1, reason: '读额度一次，但只读不扣');
      expect(find.textContaining('剩余 3 / 3 次'), findsOneWidget);
    });

    testWidgets('有额度时「开始分析」可用', (WidgetTester tester) async {
      await pumpPage(tester, host(analysis: StubAnalysisRepository()));
      await addJob(tester, '测试 JD 文本');

      expect(analyzeButton(tester).onPressed, isNotNull);
      // Figma CTA：已添加岗位时带数量后缀（`开始分析（N 个岗位）`）。
      expect(find.text('开始分析（1 个岗位）'), findsOneWidget);
    });

    testWidgets('额度耗尽 → 按钮禁用 + 显示剩余次数', (WidgetTester tester) async {
      await pumpPage(
        tester,
        host(
          analysis: StubAnalysisRepository(
            quota: const QuotaState(total: 3, used: 3),
          ),
        ),
      );
      await addJob(tester, '测试 JD 文本');

      expect(
        analyzeButton(tester).onPressed,
        isNull,
        reason: 'PRD §16：canAnalyze == false 时禁用「开始分析」',
      );
      expect(find.text('额度不足，暂不可分析'), findsOneWidget);
      expect(find.text('免费次数已用完'), findsOneWidget);
    });

    testWidgets('额度尚未读出时**保守禁用**', (WidgetTester tester) async {
      await pumpPage(
        tester,
        host(
          analysis: StubAnalysisRepository(
            delay: const Duration(milliseconds: 300),
          ),
        ),
      );
      // 只推进一半：额度还没回来。
      await tester.pump(const Duration(milliseconds: 100));
      await addJob(tester, '测试 JD 文本');

      expect(
        analyzeButton(tester).onPressed,
        isNull,
        reason: '额度未知时不得误放行',
      );
      expect(find.textContaining('剩余'), findsNothing);

      // 断言完成后**排空定时器**。
      //
      // 本用例刻意只推进 100ms（桩延迟 300ms），若就此结束，
      // flutter_test 会在拆除时报「A Timer is still pending even after
      // the widget tree was disposed」。断言必须落在「额度未知」这个窗口里，
      // 因此排空只能放在断言**之后** —— 顺序不能调换。
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
    });
  });

  // ---------------------------------------------------------------------------
  // 三、扣减与回滚（CLAUDE.md §5.2）
  // ---------------------------------------------------------------------------

  group('扣减与回滚', () {
    testWidgets('JD 为空 → **不扣**额度，且不调用分析', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository();
      await pumpPage(tester, host(analysis: repository));

      // 直接调 Provider 验一条更本质的路径：
      // 空 JD 必须在**扣减之前**就被拦下。
      await providerOf(tester).startAnalysis(title: '测试', rawJd: '   ');
      await tester.pump();

      expect(repository.analyzeCalls, 0, reason: '空 JD 不该走到 Repository');
      expect(
        providerOf(tester).quota,
        QuotaState.free,
        reason: 'CLAUDE.md §5.2：未发起分析不得扣减',
      );
    });

    testWidgets('点击「开始分析」→ 扣 1 次', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository();
      await pumpPage(tester, host(analysis: repository));
      await addJob(tester, '测试 JD 文本');

      await tester.tap(find.text('开始分析（1 个岗位）'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(repository.analyzeCalls, 1);
      expect(providerOf(tester).quota?.used, 1);
      expect(providerOf(tester).quota?.remaining, 2);
      // 成功后进入结果态。
      expect(find.text('分析结果'), findsOneWidget);
    });

    testWidgets('分析失败 → **回滚**额度 + 呈现 Error', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        analyzeError: Exception('夹具：分析失败'),
      );
      await pumpPage(tester, host(analysis: repository));
      await addJob(tester, '测试 JD 文本');

      await tester.tap(find.text('开始分析（1 个岗位）'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(repository.analyzeCalls, 1);
      expect(
        providerOf(tester).quota,
        QuotaState.free,
        reason: 'CLAUDE.md §5.2：分析失败 → 回滚额度',
      );
      expect(providerOf(tester).analysisState.isFailure, isTrue);
    });

    testWidgets('失败后**不静默**：给出可重试的 Error 态', (WidgetTester tester) async {
      final StubAnalysisRepository repository = StubAnalysisRepository(
        analyzeError: Exception('夹具：分析失败'),
      );
      await pumpPage(tester, host(analysis: repository));
      await addJob(tester, '测试 JD 文本');

      await tester.tap(find.text('开始分析（1 个岗位）'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(
        find.text('重试'),
        findsOneWidget,
        reason: 'CLAUDE.md §5.5：Error 态必须可重试',
      );

      // 重试会再走一次分析（先扣后回滚，净值仍为 0）。
      await tester.tap(find.text('重试'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(repository.analyzeCalls, 2);
      expect(providerOf(tester).quota?.used, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // 三之二、分析结果页（2026-11-15 设计稿）
  // ---------------------------------------------------------------------------

  group('分析结果页（设计稿 2026-11-15）', () {
    Future<void> openResult(WidgetTester tester) async {
      await pumpPage(tester, host(analysis: StubAnalysisRepository()));
      await addJob(tester, '测试 JD 文本');
      await tester.tap(find.text('开始分析（1 个岗位）'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
    }

    testWidgets('旧版页头与分段 Tab 不再出现在结果页', (WidgetTester tester) async {
      await openResult(tester);

      expect(find.text('分析结果'), findsOneWidget);
      expect(find.text('职业分析'), findsNothing);
      expect(find.text('新建分析'), findsNothing);
      expect(find.text('历史分析'), findsNothing);
    });

    testWidgets('标准导航栏 + 两颗操作胶囊', (WidgetTester tester) async {
      await openResult(tester);

      // 设计稿：圆形返回钮 + 居中标题；下方「岗位匹配度 / 更新分析」。
      expect(find.text('岗位匹配度'), findsOneWidget);
      expect(find.text('更新分析'), findsOneWidget);
      expect(find.byIcon(Icons.headphones_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('基础信息行：小字置灰、单行摘要', (WidgetTester tester) async {
      await openResult(tester);

      expect(
        find.text('2026.01.01 · 1 个目标岗位'),
        findsOneWidget,
        reason: '设计稿：基于简历 · 日期 · N 个目标岗位',
      );
    });

    testWidgets('Top 1 主推卡：徽标 / 详情 / 超大分数 / 打勾清单', (
      WidgetTester tester,
    ) async {
      await openResult(tester);

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('最佳匹配'), findsOneWidget);
      expect(find.text('查看详情'), findsOneWidget);
      expect(find.text('测试 JD 文本'), findsOneWidget);
      expect(find.text('42%'), findsOneWidget);
      expect(find.text('较上次 —'), findsOneWidget);

      final Finder checklist = find.byKey(
        const ValueKey<String>('analysis-result-checklist'),
      );
      expect(checklist, findsOneWidget);
      for (final String item in <String>[
        '匹配度报告',
        '能力分析',
        '能力 Gap',
        '成长建议',
      ]) {
        expect(
          find.descendant(of: checklist, matching: find.text(item)),
          findsOneWidget,
          reason: '设计稿的 2×2 打勾清单必须齐全：$item',
        );
      }
    });

    testWidgets('320dp 窄屏不溢出', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await openResult(tester);

      expect(tester.takeException(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // 四、四态（CLAUDE.md §5.5）—— 历史分析
  // ---------------------------------------------------------------------------

  group('历史分析的四态', () {
    testWidgets('Empty：没有分析记录', (WidgetTester tester) async {
      await pumpPage(tester, host(analysis: StubAnalysisRepository()));
      await tapHistory(tester);

      expect(find.text('还没有分析记录'), findsOneWidget);
    });

    testWidgets('Loading：数据未回来时可见', (WidgetTester tester) async {
      await pumpPage(
        tester,
        host(
          analysis: StubAnalysisRepository(
            delay: const Duration(milliseconds: 300),
          ),
        ),
      );

      await tester.tap(find.text('历史分析'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.text('还没有分析记录'), findsOneWidget);
    });

    testWidgets('Error + Retry：读取失败可重试', (WidgetTester tester) async {
      await pumpPage(
        tester,
        host(
          analysis: FailingProjectsRepository(
            error: Exception('夹具：读取失败'),
          ),
        ),
      );
      await tapHistory(tester);

      expect(find.text('重试'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 五、不得编造产品数据（CLAUDE.md §7 / D64 ⑥）
  // ---------------------------------------------------------------------------

  group('反假数据', () {
    /// Figma 原型里「当前简历」卡上的演示值 —— 一个都不许出现在产品里。
    const List<String> fabricated = <String>[
      '5项',
      '4段',
      '6个',
      'Resume V3',
      '2026.08.27',
    ];

    testWidgets('无简历时**不回落**到 Figma 的演示值', (WidgetTester tester) async {
      await pumpPage(tester, host(analysis: StubAnalysisRepository()));

      for (final String value in fabricated) {
        expect(
          find.textContaining(value),
          findsNothing,
          reason: 'CLAUDE.md §7：`$value` 是 Figma 的演示数据，不得进入产品',
        );
      }
    });

    testWidgets('无简历时呈现 Empty，而不是 `0项 / 0段 / 0个`', (WidgetTester tester) async {
      await pumpPage(tester, host(analysis: StubAnalysisRepository()));

      expect(find.text('还没有上传简历'), findsOneWidget);
      expect(
        find.textContaining('0项'),
        findsNothing,
        reason: '「没有」与「0 项」不是一回事，后者也是一种编造',
      );
      expect(find.text('更换'), findsNothing, reason: '没有东西可换');
    });
  });

  // ---------------------------------------------------------------------------
  // 六、当前简历卡读**真实**画像
  // ---------------------------------------------------------------------------

  group('当前简历卡', () {
    testWidgets('有简历时读真实 length，不写死', (WidgetTester tester) async {
      await pumpPage(
        tester,
        host(
          analysis: StubAnalysisRepository(),
          resume: StubResumeRepository(profile: filledProfile),
        ),
      );

      expect(find.text('2项'), findsOneWidget);
      expect(find.text('1段'), findsOneWidget);
      expect(find.text('3个'), findsOneWidget);
      expect(find.textContaining('测试版简历'), findsOneWidget);
      expect(find.textContaining('2026.03.04'), findsOneWidget);
    });

    testWidgets('版本没有上传日期时**不编造**日期', (WidgetTester tester) async {
      await pumpPage(
        tester,
        host(
          analysis: StubAnalysisRepository(),
          resume: StubResumeRepository(
            profile: ResumeProfile(
              versions: <ResumeVersion>[
                const ResumeVersion(id: 'v1', label: '测试版简历'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('测试版简历'), findsOneWidget);
      expect(find.textContaining('更新'), findsNothing);
    });
  });
}

// -----------------------------------------------------------------------------
// 桩实现
//
// ⚠️ 夹具里的岗位名与分数**不是产品数据** —— 刻意用中性词（「测试岗位 A」）
// 和一个明显的夹具值，以免被误读成 Mock 的产品数据（`CLAUDE.md` §7）。
// -----------------------------------------------------------------------------

/// 可配置的分析仓库。
class StubAnalysisRepository implements AnalysisRepository {
  StubAnalysisRepository({
    this.quota = QuotaState.free,
    this.projects = const <AnalysisProject>[],
    this.analyzeError,
    this.delay = Duration.zero,
  });

  QuotaState quota;
  final List<AnalysisProject> projects;
  final Object? analyzeError;
  final Duration delay;

  /// [analyze] 被调用的次数 —— 用来验证「不该走到 Repository 的路径没走」。
  int analyzeCalls = 0;

  /// [fetchQuota] 被调用的次数 —— 用来验证「读额度 ≠ 扣额度」。
  int quotaCalls = 0;

  Future<void> _wait() => Future<void>.delayed(delay);

  @override
  Future<List<AnalysisProject>> fetchProjects() async {
    await _wait();
    return projects;
  }

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async {
    await _wait();
    for (final AnalysisProject project in projects) {
      if (project.id == projectId) return project;
    }
    return null;
  }

  @override
  Future<List<Job>> fetchJobLibrary() async {
    await _wait();
    return const <Job>[];
  }

  @override
  Future<QuotaState> fetchQuota() async {
    quotaCalls++;
    await _wait();
    return quota;
  }

  // ③ 岗位 URL：抓取链路的测试在 `phase6_job_url_test.dart`。
  // 这里明确抛「未实现」，免得本文件里误走这条路的用例静默通过。
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
  }) async {
    analyzeCalls++;
    // P1-03：真实后端在任务开始时原子预占额度；桩同步模拟这个状态。
    quota = quota.copyWith(
      reserved: (quota.reserved + 1).clamp(0, quota.total),
    );
    await _wait();
    final Object? failure = analyzeError;
    if (failure != null) {
      quota = quota.copyWith(
        reserved: (quota.reserved - 1).clamp(0, quota.total),
      );
      throw failure;
    }
    quota = quota.copyWith(
      reserved: (quota.reserved - 1).clamp(0, quota.total),
      used: (quota.used + 1).clamp(0, quota.total),
    );

    final DateTime now = DateTime(2026, 1, 1);
    final String projectId = 'stub-project-$analyzeCalls';
    final Job job = Job(
      id: '$projectId-job',
      title: title.trim().isEmpty ? '测试岗位 A' : title.trim(),
      rawJd: rawJd,
      source: 'paste',
      createdAt: now,
    );
    return AnalysisProject(
      id: projectId,
      name: job.title,
      jobs: <Job>[job],
      results: <AnalysisResult>[
        AnalysisResult(
          id: '$projectId-result-1',
          projectId: projectId,
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

/// 可配置的简历仓库 —— 用来验证「当前简历」卡读的是**真实画像**。
class StubResumeRepository implements ResumeRepository {
  StubResumeRepository({this.profile = ResumeProfile.empty});

  final ResumeProfile profile;

  @override
  Future<ResumeProfile> fetchProfile() async => profile;

  @override
  Future<List<ResumeVersion>> fetchVersions() async => profile.versions;

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
  Future<ResumeProfile> buildBaseline() async => profile;
}

/// 只让 [AnalysisRepository.fetchProjects] 失败的桩 —— 用于历史分析的 Error 态。
class FailingProjectsRepository implements AnalysisRepository {
  FailingProjectsRepository({required this.error});

  final Object error;

  @override
  Future<List<AnalysisProject>> fetchProjects() async => throw error;

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async => null;

  @override
  Future<List<Job>> fetchJobLibrary() async => const <Job>[];

  @override
  Future<QuotaState> fetchQuota() async => QuotaState.free;

  @override
  Future<ParsedJob> parseJobUrl(String url) async => throw error;

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
  }) async => throw error;
}
