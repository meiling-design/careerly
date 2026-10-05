import 'package:careerly/app/app.dart';
import 'package:careerly/data/models/home_summary.dart';
import 'package:careerly/data/repositories/home_repository.dart';
import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/home/presentation/home_content.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/home/presentation/widgets/home_analysis_section.dart';
import 'package:careerly/features/home/presentation/widgets/home_header.dart';
import 'package:careerly/features/home/presentation/widgets/home_hero_card.dart';
import 'package:careerly/features/home/presentation/widgets/home_stil_cards.dart';
import 'package:careerly/features/home/state/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      child: MaterialApp(
        theme: CareerlyTheme.light(),
        home: const HomePage(),
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
    testWidgets('Hero 文案逐字来自 D64 ②', (WidgetTester tester) async {
      await pumpRealApp(tester, '/home');

      expect(homeText('从一份简历开始，看见你的职业能力'), findsOneWidget);
      expect(homeText('上传简历'), findsOneWidget);

      // 「你的职业主页」同时是 Header 主标题与 Hero 小标签，「还没有职业分析」
      // 同时是 Hero 主标题与「当前状态」卡标题 —— D64 ② 里本就是这个重复，
      // 不是渲染了两遍。刻意钉住数量，避免被后来者「顺手统一」掉。
      expect(homeText('主页'), findsOneWidget);
      expect(homeText('你的职业主页'), findsNWidgets(2));
      expect(homeText('还没有职业分析'), findsNWidgets(2));
    });

    testWidgets('四张卡片与「第一次分析」引导语逐字', (WidgetTester tester) async {
      await pumpRealApp(tester, '/home');

      // 卡片 1 · 问问 AI（D64 ② 写的是「问问 AI」，带空格；
      // 而 Figma 的 State 03 写的是「问问AI」，不带空格 ——
      // 两者各自逐字，**不要**统一）
      expect(homeText('问问 AI'), findsOneWidget);
      expect(homeText('不知道下一步该提升什么？'), findsOneWidget);
      expect(homeText('和 AI 聊聊你的职业方向'), findsOneWidget);

      // 卡片 2 · 当前状态
      expect(homeText('上传简历并分析一个目标岗位'), findsOneWidget);
      expect(homeText('看见你的能力匹配度'), findsOneWidget);

      // 卡片 3 · 最近成长
      expect(homeText('还没有成长记录'), findsOneWidget);
      expect(homeText('每一次简历更新、技能增加'), findsOneWidget);
      expect(homeText('都会成为你的职业资产'), findsOneWidget);

      // 卡片 4 · 今日一句（三态通用的陪伴卡）
      expect(homeText('今天也可以向前一步'), findsOneWidget);
      expect(homeText('先看见自己，再决定下一步。'), findsOneWidget);

      // 岗位匹配变化区块 → 第一次分析引导
      expect(homeText('开始你的第一次分析'), findsOneWidget);
      expect(
        homeText('找到一个你感兴趣的岗位，把 JD 粘贴进 Careerly。'),
        findsOneWidget,
      );
      expect(homeText('分析第一个岗位 →'), findsOneWidget);

      // 三颗筛选胶囊（Figma 逐字）
      expect(homeText('新建分析'), findsOneWidget);
      expect(homeText('最新匹配变化'), findsOneWidget);
      expect(homeText('查看全部'), findsOneWidget);
    });

    testWidgets('不得出现 Figma 的硬编码假数据（D64 ⑥ / §7）', (
      WidgetTester tester,
    ) async {
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
  });

  // ---------------------------------------------------------------------------
  // State 02 —— 有基线、无岗位（★ 文案为 AI 起草 → D76）
  // ---------------------------------------------------------------------------

  group('Phase 5 · 首页 State 02（已有简历）', () {
    testWidgets('Hero 改为「还没有岗位分析」，主按钮改为「添加目标岗位」', (
      WidgetTester tester,
    ) async {
      await pumpStub(tester, baselineOnly);

      expect(homeText('还没有岗位分析'), findsOneWidget);
      expect(homeText('用一份目标岗位 JD，看见你与它的距离'), findsOneWidget);
      expect(homeText('添加目标岗位'), findsOneWidget);

      // 不再是 State 01 的引导语。
      expect(homeText('还没有职业分析'), findsNothing);
      expect(homeText('上传简历'), findsNothing);
    });

    testWidgets('「当前状态」卡改为「职业基线已建立」（D63 措辞）', (
      WidgetTester tester,
    ) async {
      await pumpStub(tester, baselineOnly);

      expect(homeText('职业基线已建立'), findsOneWidget);
      expect(homeText('还没有职业分析'), findsNothing);
    });

    testWidgets('区块仍停在「第一次分析」引导，尚未进入岗位列表', (
      WidgetTester tester,
    ) async {
      await pumpStub(tester, baselineOnly);

      expect(homeText('开始你的第一次分析'), findsOneWidget);
      expect(homeText('岗位匹配变化'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // State 03 —— Figma 那版首页 + 真实数据
  // ---------------------------------------------------------------------------

  group('Phase 5 · 首页 State 03（已有岗位分析）', () {
    testWidgets('Hero 取最匹配的那条岗位，读数来自数据', (WidgetTester tester) async {
      await pumpStub(tester, analyzed);

      expect(homeText('最匹配岗位'), findsOneWidget);
      expect(homeText('查看分析'), findsOneWidget);
      // 最匹配的那条**同时**出现在 Hero 与下方列表里 —— 这是设计如此，
      // 不是重复渲染（Hero 是「当前最匹配」，列表是全部岗位）。
      expect(homeText('测试岗位 A'), findsNWidgets(2));

      // Hero 的读数是**纯数字**，`%` 是独立的一小号字。
      expect(homeText('61'), findsOneWidget);
      expect(homeText('%'), findsOneWidget);
      expect(homeText('匹配度'), findsOneWidget);
      expect(homeText('▲ 较上次+4%'), findsOneWidget);
    });

    testWidgets('岗位匹配变化列表：排名 / 匹配度 / 变化 Chip', (
      WidgetTester tester,
    ) async {
      await pumpStub(tester, analyzed);

      expect(homeText('岗位匹配变化'), findsOneWidget);

      // 排名 1 / 2 用奖牌（Figma `rankEmoji`）。
      expect(homeText('🥇'), findsOneWidget);
      expect(homeText('🥈'), findsOneWidget);

      expect(homeText('测试岗位 A'), findsNWidgets(2));
      expect(homeText('测试岗位 B'), findsOneWidget);
      expect(homeText('61%'), findsOneWidget);
      expect(homeText('42%'), findsOneWidget);

      // 上升 → `↑ +N%`；持平（`delta == 0`）→ 破折号，与 Figma 一致。
      expect(homeText('↑ +4%'), findsOneWidget);
      expect(homeText('—'), findsOneWidget);
    });

    testWidgets('卡片改由真实摘要填充，取不到就留空', (WidgetTester tester) async {
      await pumpStub(tester, analyzed);

      // 卡片 1 的两行 = `suggestions` 前两条；标题是 Figma 原文（无空格）。
      expect(homeText('问问AI'), findsOneWidget);
      expect(homeText('建议甲'), findsOneWidget);
      expect(homeText('建议乙'), findsOneWidget);

      // 卡片 2 的第一行在 Figma 里是假排名 → 换成真实的分析数量。
      expect(homeText('已分析 2 个目标岗位'), findsOneWidget);
      expect(homeText('点击查看详细分析'), findsOneWidget);

      // 卡片 3 的两行 = `recentGrowth`。
      expect(homeText('最近成长'), findsOneWidget);
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
      // Hero 那一行也随之为空，而不是 `▲ 较上次+0%`。
      expect(homeText('▲ 较上次+0%'), findsNothing);
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
  // 三态共用同一套视觉（D64 ①bis）
  // ---------------------------------------------------------------------------

  group('Phase 5 · 三态共用同一套 Figma 视觉（D64 ①bis）', () {
    /// 结构不变量。
    ///
    /// 「只替换文字内容，不要修改 figma 视觉设计」在代码里的表达是
    /// 「视觉组件不认识 `HomeStage`」。这条测试是它的**外部可观察证据**：
    /// 三个状态下版面骨架逐项相同。
    Future<void> expectSameSkeleton(
      WidgetTester tester, {
      required String label,
    }) async {
      expect(find.byType(HomeHeader), findsOneWidget, reason: '$label · 身份区');
      expect(find.byType(HomeHeroCard), findsOneWidget, reason: '$label · Hero');
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

      // 四张卡 —— 不多不少（视觉层不因状态增删卡片）。
      expect(
        find.descendant(
          of: find.byType(HomeStilCards),
          matching: find.byType(Text),
        ),
        findsNWidgets(_stilCardTextCount),
        reason: '$label · 卡片区文字总数（4 标题 + 7 描述行）',
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
      expect(homeText('还没有岗位分析'), findsOneWidget);
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
  // §9-4 · 筛选行窄屏不溢出
  // ---------------------------------------------------------------------------

  /// 修复前：`_FilterTabs` 三颗胶囊的固有宽合计 **332**
  /// （`padding0 20` + 4 字 ×14 ×2 组，加 `padding0 16` + 4 字 ×14，
  /// 加 `gap 8` ×2），而 320dp 屏扣掉页面左右内边距只剩 280。
  ///
  /// `Row` 里非 flex 子项拿到的是**无界**主轴约束，所以 `_Tab` 内的
  /// `maxLines: 1, overflow: ellipsis` 永远不会触发，只会整行
  /// `RenderFlex overflowed` —— 360dp 溢 12px、320dp 溢 52px。
  ///
  /// ⚠️ 这个缺陷此前躲过了全部用例，因为 `flutter_test` 默认画布是
  /// **800×600**，宽得足以容纳三个标签。下面把「真机窄屏」这个条件
  /// 显式补进回归面。
  group('§9-4 · 筛选行窄屏不溢出', () {
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

    /// 三颗胶囊必须**都在** —— 修法是等比缩小，不是隐藏或省略文字。
    void expectThreeTabs() {
      expect(find.text('新建分析'), findsOneWidget);
      expect(find.text('最新匹配变化'), findsOneWidget);
      expect(find.text('查看全部'), findsOneWidget);
    }

    testWidgets('320dp 屏（可用宽 280）', (WidgetTester tester) async {
      await pumpSection(tester, 280);
      expectThreeTabs();
      expect(
        tester.takeException(),
        isNull,
        reason: '三颗胶囊装不下时应等比缩小，而不是溢出',
      );
    });

    testWidgets('360dp 屏（可用宽 320）', (WidgetTester tester) async {
      await pumpSection(tester, 320);
      expectThreeTabs();
      expect(tester.takeException(), isNull, reason: '360dp 是主流 Android 宽度');
    });

    /// 宽屏**必须逐像素不变** —— 防止把缩放修成「整组居中」。
    ///
    /// `FittedBox` 的默认对齐是居中，会把胶囊整组推到屏幕中间；
    /// 这里钉住「未缩放时仍与 Figma 一样贴左」，
    /// 偏移量即胶囊自身的 `padding: 0 20`。
    testWidgets('宽屏不缩放、仍贴左对齐', (WidgetTester tester) async {
      await pumpSection(tester, 800);
      expectThreeTabs();
      expect(tester.takeException(), isNull);

      final double sectionLeft =
          tester.getTopLeft(find.byType(HomeAnalysisSection)).dx;
      final double labelLeft = tester.getTopLeft(find.text('新建分析')).dx;
      expect(
        labelLeft - sectionLeft,
        20,
        reason: '未缩放时应保持 Figma 的左对齐（偏移 = 胶囊 padding 20）',
      );
    });
  });
}

/// 「问问 AI」2 行 + 「当前状态」2 行 + 「最近成长」2 行 + 「今日一句」1 行
/// = 7 行描述，加上 4 个卡片标题 = 11 个 `Text`。
///
/// ⚠️ 这个数字在**三态里必须相同** —— 它正是「不因状态增删内容块」的证明。
const int _stilCardTextCount = 11;

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
