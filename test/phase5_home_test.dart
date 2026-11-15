import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/data/models/home_summary.dart';
import 'package:careerly/data/repositories/home_repository.dart';
import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/home/presentation/home_content.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/home/presentation/widgets/home_analysis_section.dart';
import 'package:careerly/features/home/presentation/widgets/home_hero_card.dart';
import 'package:careerly/features/home/presentation/widgets/home_stil_cards.dart';
import 'package:careerly/features/home/state/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Careerly Phase 5 —— 首页三态。
///
/// 依据 **D64**（见 `docs/05_progress/TODO.md` §3.2）：
///
/// ```text
/// State 01  首次使用（没有职业基线）
/// State 02  已有简历（有基线、没有岗位分析）
/// State 03  已有简历 + 岗位分析  ←  Figma 那版首页**就是**这一态
/// ```
///
/// ## 这份测试钉住什么
///
/// 1. **State 01 文案 = D64 ② 逐字** —— 产品侧给的规格，
///    改一个字都算回归。
/// 2. **Figma 的硬编码假数据不得出现**（D64 ⑥ / `CLAUDE.md` §7）
///    —— `Alex` / `86%` / `排名 #1` / `AI 能力 68→76` 这些是原型里的
///    演示数据，一旦漏进 Mock 就会被当成需求。
/// 3. **三态共用同一套视觉结构**（D64 ①bis「只替换文字内容，
///    不要修改 figma 视觉设计」）—— 这条约束在代码里的表达是
///    「视觉组件不认识 `HomeStage`」，这里用**结构不变量**把它钉死：
///    三个状态下 Hero / 卡片区 / 区块的存在性、卡片数量、
///    可点卡片数量**完全相同**。
/// 4. **State 03 的数据来自 `HomeSummary`**，取不到就留空，
///    **不回落**到原型里的字符串。
///
/// ## 为什么要注入 Repository
///
/// 当前 Mock 只返回空摘要 → **只有 State 01 可达**
/// （登记 **待裁决 · D75**）。State 02 / 03 用桩实现注入摘要来验证，
/// 免得这条内容分支在验收前从未被执行过。
void main() {
  // ---------------------------------------------------------------------------
  // 桩实现
  // ---------------------------------------------------------------------------

  /// 返回固定摘要的桩。**不是**产品数据 —— 测试夹具刻意用中性词
  /// （「测试岗位 A」），以免被误读成 Mock 的产品数据。
  /// 记 [delay] 是为了让 Loading 态可断言。
  Widget host(HomeSummary summary, {Duration delay = Duration.zero}) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<HomeRepository>(
          create: (_) => _StubHomeRepository(summary, delay: delay),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (BuildContext context) =>
              HomeProvider(context.read<HomeRepository>()),
        ),
      ],
      child: MaterialApp(theme: CareerlyTheme.light(), home: const HomePage()),
    );
  }

  Widget routerHost(HomeSummary summary) {
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: <RouteBase>[
        GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
        GoRoute(
          path: AppRoutes.profileCapability,
          builder: (_, _) => const Scaffold(body: Text('职业能力路由')),
        ),
        GoRoute(
          path: AppRoutes.analysis,
          builder: (_, _) => const Scaffold(body: Text('分析路由')),
        ),
      ],
    );
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<HomeRepository>(create: (_) => _StubHomeRepository(summary)),
        ChangeNotifierProvider<HomeProvider>(
          create: (BuildContext context) =>
              HomeProvider(context.read<HomeRepository>()),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: CareerlyTheme.light(),
      ),
    );
  }

  Future<void> pumpStub(
    WidgetTester tester,
    HomeSummary summary, {
    Duration delay = Duration.zero,
  }) async {
    await tester.pumpWidget(host(summary, delay: delay));
    await tester.pump(); // 首帧 → postFrameCallback → load()
    await tester.pump(delay + const Duration(milliseconds: 1)); // Future 完成
    await tester.pump(); // 重建
  }

  /// Mock 数据层的默认延迟是 600ms。
  Future<void> pumpRealApp(WidgetTester tester, String location) async {
    await tester.pumpWidget(CareerlyApp(initialLocation: location));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 限定在首页**页面内**断言。
  ///
  /// `StatefulShellRoute.indexedStack` 会把其他三个分支一起建在树里，
  /// 全局 `find.text` 可能匹配到别的分支的文案。
  Finder onHome(Finder matching) =>
      find.descendant(of: find.byType(HomePage), matching: matching);

  Finder homeText(String text) => onHome(find.text(text));

  // ---------------------------------------------------------------------------
  // 夹具
  // ---------------------------------------------------------------------------

  /// State 02：有基线、没有任何岗位分析。
  const HomeSummary baselineOnly = HomeSummary(hasBaseline: true);

  /// State 03：有基线 + 两个岗位。
  const HomeSummary analyzed = HomeSummary(
    hasBaseline: true,
    headline: '当前与目标岗位的匹配度 61 分',
    subheadline: '最需要补上的是「测试能力」',
    suggestions: <String>['建议甲', '建议乙'],
    recentGrowth: <String>['成长甲', '成长乙'],
    matchChanges: <MatchChange>[
      MatchChange(jobId: 'j1', jobTitle: '测试岗位 A', score: 61, delta: 4),
      MatchChange(jobId: 'j2', jobTitle: '测试岗位 B', score: 42, delta: 0),
    ],
  );

  // ---------------------------------------------------------------------------
  // State 01 —— 默认 Mock 可达，走**真实** App 装配
  // ---------------------------------------------------------------------------

  group('Phase 5 · 首页 State 01（首次使用）', () {
    testWidgets('Hero：时段问候 + 品牌短句 + 新建分析', (WidgetTester tester) async {
      await pumpRealApp(tester, '/home');

      expect(
        homeText(homeGreetingFor(DateTime.now())),
        findsOneWidget,
        reason: '问候语随当前时段变化',
      );
      expect(homeText('看见能力，也看见前进的自己~'), findsOneWidget);
      expect(homeText('新建分析'), findsOneWidget);
    });

    testWidgets('四张卡片与「第一次分析」引导语', (WidgetTester tester) async {
      await pumpRealApp(tester, '/home');

      // 第三张卡为建议入口，内容仍按未分析状态提供引导。
      expect(homeText('下一步建议'), findsOneWidget);
      expect(homeText('不确定提升方向？'), findsOneWidget);
      expect(homeText('和 AI 聊聊职业方向'), findsOneWidget);

      // 第一张卡 · 当前状态（标题固定，无数据时圆环显示「暂无数据」）
      expect(homeText('当前状态'), findsOneWidget);
      expect(homeText('暂无数据'), findsOneWidget);
      expect(homeText('匹配度'), findsOneWidget);

      // 第二张卡 · 成长记录（标题固定）
      expect(homeText('成长记录'), findsOneWidget);
      expect(homeText('简历更新、技能增加'), findsOneWidget);
      expect(homeText('都会成为职业资产'), findsOneWidget);

      // 第四张卡 · 今日内容。
      expect(homeText('今天也可以向前一步\n先看见自己，再决定下一步。'), findsOneWidget);
      expect(homeText('去新建分析'), findsOneWidget);
      expect(homeText('查看成长记录'), findsOneWidget);
      expect(homeText('与AI聊聊'), findsOneWidget);

      // 岗位匹配变化区块 → 第一次分析引导
      expect(homeText('开始你的第一次分析'), findsOneWidget);
      expect(homeText('找到一个你感兴趣的岗位，把 JD 粘贴进 Careerly。'), findsOneWidget);
      expect(homeText('分析第一个岗位 →'), findsOneWidget);

      // Figma 的两颗匹配变化操作。
      expect(homeText('最新匹配变化'), findsOneWidget);
      expect(homeText('查看全部'), findsOneWidget);
    });

    testWidgets('不得出现 Figma 的硬编码假数据（D64 ⑥ / §7）', (WidgetTester tester) async {
      await pumpRealApp(tester, '/home');

      // 假名 / 假读数 / 假岗位 / 假排名 / 假成长 / 假日期。
      // 每一条都能在 `docs/Careerly App Interface Design (Copy)/src/App.tsx`
      // 里找到出处 —— 这正是它们危险的原因：看起来像真的。
      for (final String fabricated in <String>[
        'Alex',
        'Alex 的职业主页',
        '86%',
        'AI 产品经理',
        '数据产品经理',
        '排名 #1',
        'AI 能力 68→76 ↑8',
        '新增 AI Agent 项目',
        '2026/9/12',
      ]) {
        expect(
          homeText(fabricated),
          findsNothing,
          reason: 'Figma 原型里的演示数据不得进入产品：$fabricated',
        );
      }
    });

    testWidgets('最新变化按钮滚动定位；查看全部进入分析路由', (WidgetTester tester) async {
      await pumpRealApp(tester, '/home');

      final GoRouter router = GoRouter.of(
        tester.element(find.byType(HomePage)),
      );
      final Finder changesButton = homeText('最新匹配变化');
      await tester.ensureVisible(changesButton);
      await tester.tap(changesButton);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(homeText('开始你的第一次分析')).dy,
        greaterThanOrEqualTo(0),
      );

      final Finder viewAllButton = homeText('查看全部');
      await tester.ensureVisible(viewAllButton);
      await tester.tap(viewAllButton);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(seconds: 1));
      expect(router.routeInformationProvider.value.uri.path, '/analysis');
    });

    testWidgets('成长入口进入我的成长记录子路由', (WidgetTester tester) async {
      await pumpRealApp(tester, '/home');
      final GoRouter router = GoRouter.of(
        tester.element(find.byType(HomePage)),
      );
      final Finder growthAction = homeText('查看成长记录');
      await tester.ensureVisible(growthAction);
      await tester.tap(growthAction);
      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      expect(
        router.routeInformationProvider.value.uri.path,
        '/profile/growth-record',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // State 02 —— 有基线、无岗位（★ 文案为 AI 起草 → D76）
  // ---------------------------------------------------------------------------

  group('Phase 5 · 首页 State 02（已有简历）', () {
    testWidgets('Hero：时段问候 + 品牌短句 + 新建分析', (WidgetTester tester) async {
      await pumpStub(tester, baselineOnly);

      expect(homeText(homeGreetingFor(DateTime.now())), findsOneWidget);
      expect(homeText('看见能力，也看见前进的自己~'), findsOneWidget);
      expect(homeText('新建分析'), findsOneWidget);

      // 不再显示旧空态标题与按钮。
      expect(homeText('还没有岗位分析'), findsNothing);
      expect(homeText('添加目标岗位'), findsNothing);
      expect(homeText('上传简历'), findsNothing);
    });

    testWidgets('「当前状态」卡标题固定，无数据时圆环显示暂无数据', (WidgetTester tester) async {
      await pumpStub(tester, baselineOnly);

      expect(homeText('当前状态'), findsOneWidget);
      expect(homeText('暂无数据'), findsOneWidget);
      expect(homeText('匹配度'), findsOneWidget);
      expect(homeText('职业基线已建立'), findsNothing);
    });

    testWidgets('区块仍停在「第一次分析」引导，尚未进入岗位列表', (WidgetTester tester) async {
      await pumpStub(tester, baselineOnly);

      expect(homeText('开始你的第一次分析'), findsOneWidget);
      expect(homeText('岗位匹配变化'), findsNothing);
    });

    testWidgets('「当前状态」卡的无数据入口进入分析页', (WidgetTester tester) async {
      await tester.pumpWidget(routerHost(baselineOnly));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(find.text('当前状态'), findsOneWidget);
      final Finder action = find.text('去新建分析');
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(find.text('分析路由'), findsOneWidget);
    });

    testWidgets('首次分析无匹配变化记录时仍显示已分析首页', (WidgetTester tester) async {
      await pumpStub(
        tester,
        const HomeSummary(
          hasBaseline: true,
          headline: '当前与目标岗位的匹配度 61 分',
          subheadline: '已识别 4 项能力维度',
        ),
      );

      // Hero 不因有数据而换成旧版数据卡。
      expect(homeText(homeGreetingFor(DateTime.now())), findsOneWidget);
      expect(homeText('新建分析'), findsOneWidget);
      expect(homeText('当前职业状态'), findsNothing);

      // 没有匹配变化时，区块仍进入「岗位匹配变化」形态，只是没有行。
      expect(homeText('岗位匹配变化'), findsOneWidget);
      expect(homeText('开始你的第一次分析'), findsNothing);
      expect(homeText('已完成目标岗位分析'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // State 03 —— Figma 那版首页 + 真实数据
  // ---------------------------------------------------------------------------

  group('Phase 5 · 首页 State 03（已有岗位分析）', () {
    testWidgets('Hero 与空态同构：问候 + 品牌短句 + 新建分析', (WidgetTester tester) async {
      await pumpStub(tester, analyzed);

      // 有数据时**不**回落到旧版数据卡（岗位名 / 查看分析）。
      expect(homeText(homeGreetingFor(DateTime.now())), findsOneWidget);
      expect(homeText('看见能力，也看见前进的自己~'), findsOneWidget);
      expect(homeText('新建分析'), findsOneWidget);
      expect(homeText('当前职业状态'), findsNothing);
      expect(homeText('查看分析'), findsNothing);
      expect(homeText('当前与目标岗位的匹配度 61 分'), findsNothing);
      expect(homeText('最需要补上的是「测试能力」'), findsNothing);

      // 真实数据只进入四象限与列表。
      expect(homeText('测试岗位 A'), findsOneWidget);
      expect(homeText('TOP 1'), findsOneWidget);

      // 匹配度读数从真实摘要渲染到「当前状态」卡。
      expect(homeText('61%'), findsNWidgets(2));
      expect(homeText('匹配度'), findsOneWidget);
    });

    testWidgets('岗位匹配变化列表：排名 / 匹配度 / 变化 Chip', (WidgetTester tester) async {
      await pumpStub(tester, analyzed);

      expect(homeText('岗位匹配变化'), findsOneWidget);

      // 排名 1 / 2 用奖牌（Figma `rankEmoji`）。
      expect(homeText('🥇'), findsOneWidget);
      expect(homeText('🥈'), findsOneWidget);

      expect(homeText('测试岗位 A'), findsOneWidget);
      expect(homeText('测试岗位 B'), findsOneWidget);
      expect(homeText('61%'), findsNWidgets(2));
      expect(homeText('42%'), findsOneWidget);

      // 上升 → `↑ +N%`；持平（`delta == 0`）→ 破折号，与 Figma 一致。
      expect(homeText('↑ +4%'), findsOneWidget);
      expect(homeText('—'), findsOneWidget);
    });

    testWidgets('卡片改由真实摘要填充，取不到就留空', (WidgetTester tester) async {
      await pumpStub(tester, analyzed);

      // 下一步建议使用真实摘要中的前两条建议。
      expect(homeText('下一步建议'), findsOneWidget);
      expect(homeText('建议甲'), findsOneWidget);
      expect(homeText('建议乙'), findsOneWidget);

      // 状态卡使用真实匹配分；右上角只放短标签，不塞长句。
      expect(homeText('TOP 1'), findsOneWidget);
      expect(homeText('最近有 2 个岗位匹配变化'), findsNothing);
      expect(homeText('61%'), findsNWidgets(2));

      // 成长卡的两行 = `recentGrowth`。
      expect(homeText('成长记录'), findsOneWidget);
      expect(homeText('成长甲'), findsOneWidget);
      expect(homeText('成长乙'), findsOneWidget);
    });

    testWidgets('delta 缺失（`null`）同样显示破折号，不显示 `+0%`', (
      WidgetTester tester,
    ) async {
      await pumpStub(
        tester,
        const HomeSummary(
          hasBaseline: true,
          matchChanges: <MatchChange>[
            MatchChange(jobId: 'j1', jobTitle: '测试岗位 A', score: 61),
          ],
        ),
      );

      expect(homeText('—'), findsOneWidget);
      expect(homeText('↑ +0%'), findsNothing);
      expect(homeText('61%'), findsNWidgets(2));
    });

    testWidgets('摘要为空时列表不留空壳行', (WidgetTester tester) async {
      await pumpStub(
        tester,
        const HomeSummary(
          hasBaseline: true,
          matchChanges: <MatchChange>[
            MatchChange(jobId: 'j1', jobTitle: '测试岗位 A', score: 61),
          ],
        ),
      );

      expect(homeText('岗位匹配变化'), findsOneWidget);
      expect(homeText('🥇'), findsOneWidget);
      expect(homeText('🥈'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // 三态共用同一套首页结构
  // ---------------------------------------------------------------------------

  group('Phase 5 · 三态共用首页结构', () {
    /// 结构不变量。
    ///
    /// 「只替换文字内容，不要修改 figma 视觉设计」在代码里的表达是
    /// 「视觉组件不认识 `HomeStage`」。这条测试是它的**外部可观察证据**：
    /// 三个状态下版面骨架逐项相同。
    Future<void> expectSameSkeleton(
      WidgetTester tester, {
      required String label,
    }) async {
      expect(
        find.byType(HomeHeroCard),
        findsOneWidget,
        reason: '$label · Hero',
      );
      expect(
        find.byType(HomeStilCards),
        findsOneWidget,
        reason: '$label · 卡片区',
      );
      expect(
        find.byType(HomeAnalysisSection),
        findsOneWidget,
        reason: '$label · 区块',
      );

      // 2×2 卡片区固定为两行。
      expect(
        find.descendant(
          of: find.byType(HomeStilCards),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is SizedBox && widget.height == 198,
          ),
        ),
        findsNWidgets(2),
        reason: '$label · 2×2 卡片行数',
      );

      // 其中三张可点、一张不可点（「今日一句」在 Figma 里没有 onClick）。
      expect(
        find.descendant(
          of: find.byType(HomeStilCards),
          matching: find.byType(CareerlyPressFeedback),
        ),
        findsNWidgets(3),
        reason: '$label · 可点卡片数',
      );
    }

    testWidgets('State 01（真实 Mock）', (WidgetTester tester) async {
      await pumpRealApp(tester, '/home');
      await expectSameSkeleton(tester, label: 'State 01');
    });

    testWidgets('State 02', (WidgetTester tester) async {
      await pumpStub(tester, baselineOnly);
      await expectSameSkeleton(tester, label: 'State 02');
    });

    testWidgets('State 03', (WidgetTester tester) async {
      await pumpStub(tester, analyzed);
      await expectSameSkeleton(tester, label: 'State 03');
    });

    testWidgets('首页适配 320dp 窄屏且无布局溢出', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpStub(tester, analyzed);

      final Size heroSize = tester.getSize(find.byType(HomeHeroCard));
      expect(heroSize.width, 320);
      expect(heroSize.height, closeTo(227 * 320 / 390, 0.1));
      expect(tester.takeException(), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // 四态（CLAUDE.md §5.5）—— 加载生命周期
  // ---------------------------------------------------------------------------

  group('Phase 5 · 首页四态（Loading / Error / Retry）', () {
    testWidgets('Loading：先出加载态，再出内容', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(baselineOnly, delay: const Duration(milliseconds: 200)),
      );
      await tester.pump();

      expect(find.text('正在载入你的职业主页'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.text('正在载入你的职业主页'), findsNothing);
      expect(homeText('当前状态'), findsOneWidget);
    });

    testWidgets('Error：失败给出错误态与重试入口', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: <SingleChildWidget>[
            Provider<HomeRepository>(create: (_) => _FailingHomeRepository()),
            ChangeNotifierProvider<HomeProvider>(
              create: (BuildContext context) =>
                  HomeProvider(context.read<HomeRepository>()),
            ),
          ],
          child: MaterialApp(
            theme: CareerlyTheme.light(),
            home: const HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('重试'), findsOneWidget);
      // 失败时**不得**渲染三态内容 —— 那是「成功且无数据」的形态。
      expect(find.byType(HomeHeroCard), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // §9-4 · 匹配操作行窄屏不溢出
  // ---------------------------------------------------------------------------

  group('§9-4 · 匹配操作行窄屏不溢出', () {
    Future<void> pumpSection(WidgetTester tester, double available) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CareerlyTheme.light(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: available,
                child: const HomeAnalysisSection(
                  content: HomeSectionContent.firstAnalysis(
                    title: '开始你的第一次分析',
                    body: '添加一个目标岗位，看看你离它有多远',
                    actionLabel: '去添加岗位',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    /// 两颗操作都必须存在；窄屏可等比缩小按钮内容，但不能隐藏操作。
    void expectMatchControls() {
      expect(find.text('最新匹配变化'), findsOneWidget);
      expect(find.text('查看全部'), findsOneWidget);
    }

    testWidgets('320dp 屏（可用宽 280）', (WidgetTester tester) async {
      await pumpSection(tester, 280);
      expectMatchControls();
      expect(tester.takeException(), isNull, reason: '窄屏操作按钮应缩小且不溢出');
    });

    testWidgets('360dp 屏（可用宽 320）', (WidgetTester tester) async {
      await pumpSection(tester, 320);
      expectMatchControls();
      expect(tester.takeException(), isNull, reason: '360dp 是主流 Android 宽度');
    });

    testWidgets('宽屏操作组居中且不溢出', (WidgetTester tester) async {
      await pumpSection(tester, 800);
      expectMatchControls();
      expect(tester.takeException(), isNull);

      final Rect section = tester.getRect(find.byType(HomeAnalysisSection));
      final Rect label = tester.getRect(find.text('最新匹配变化'));
      expect(
        label.center.dx,
        greaterThan(section.left),
        reason: '宽屏操作组应处于版心范围内',
      );
      expect(label.right, lessThan(section.right));
    });
  });
}

/// 返回固定摘要的桩实现。
class _StubHomeRepository implements HomeRepository {
  _StubHomeRepository(this._summary, {this.delay = Duration.zero});

  final HomeSummary _summary;
  final Duration delay;

  @override
  Future<HomeSummary> fetchSummary() =>
      Future<HomeSummary>.delayed(delay, () => _summary);
}

/// 必定失败的桩实现，用来让 Error / Retry 态真实可达。
class _FailingHomeRepository implements HomeRepository {
  @override
  Future<HomeSummary> fetchSummary() async =>
      throw Exception('stub failure (test only)');
}
