import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/data/mock/demo_fixture.dart';
import 'package:careerly/data/mock/mock_config.dart';
import 'package:careerly/design_system/components/careerly_card.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:careerly/design_system/tokens/tokens.dart';
import 'package:careerly/features/profile/state/growth_celebration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Phase 8 批 3 / 8A —— 成长足迹二级页：周日历条 + 月网格日历 + 当天事件区 + 时间线。
///
/// 规格来源：Figma `GrowthRecordPage`（`src/App.tsx` L3973-4114）
/// + `GrowthCalendar`（L2989-3086）。类型映射 = **D91 裁决**
/// （5 类模型 → Figma 4 套配色 + rank 第 5 套暂定色 D96）。
///
/// ## 🔴 Phase 8A 产品规则（2026-09-28）—— 本文件的**核心不变量**
///
/// ```text
/// ✅ 日历是默认存在的核心页面结构 —— 永远渲染
/// ✅ 即使没有任何事件，也必须显示完整日历 + 对应的当天空状态
/// ❌ 不得根据 Event 是否存在来决定是否渲染 Calendar
/// ```
///
/// 因此 `空数据：日历照常渲染…` 这条用例是本页**最重要**的断言 ——
/// 它钉住的是「有人把日历重新塞回 Empty 门禁后面」这类回归。
/// 同类的还有 `点选无事件的日期也可选中…`（旧实现禁止点空日期）。
///
/// ⚠️ 断言**不写死 Figma 样例数值** —— 日期、事件数一律从
/// [DemoFixture] / `DateTime.now()` 派生，避免「测试通过 = 数据被固化」。
void main() {
  /// 与其余 Phase 8 用例同一套：不用 `pumpAndSettle`
  /// （页面含不确定时长的进度指示，会等不到静止）。
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 只换演示数据开关，**保留** [MockConfig.standard] 的四态前提。
  void useDemoData({required bool enabled}) {
    MockSettings.config = MockConfig.standard.copyWith(
      latency: Duration.zero,
      demoData: enabled,
    );
  }

  setUp(() => useDemoData(enabled: false)); // ⚠️ 静态开关必须还原。
  tearDown(() => MockSettings.config = MockConfig.standard);

  /// 只把测试视口**加高**（800×1600），**宽度不动**。
  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> openProfile(WidgetTester tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(const CareerlyApp());
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(CareerlyNavigationBar),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is Semantics && widget.properties.label == '我的',
        ),
      ),
    );
    await settle(tester);
  }

  /// 深链直达成长记录二级页（不经「我的」入口卡点入）。
  Future<void> openGrowthRecord(WidgetTester tester) async {
    await openProfile(tester);
    final BuildContext context = tester.element(
      find.byType(CareerlyNavigationBar),
    );
    GoRouter.of(context).push(AppRoutes.profileGrowthRecord);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
  }

  // ── 派生工具（与页面同一口径，不写死样例值） ──────────────────────────

  /// 演示数据里**最新**的事件日。
  DateTime latestEventDate() {
    final List<DateTime> dates =
        DemoFixture.growthCalendarEvents
            .map((e) => e.occurredAt)
            .whereType<DateTime>()
            .toList()
          ..sort();
    return dates.last;
  }

  /// 演示数据事件所在月（Figma 样例集中在单一月份）。
  DateTime eventMonth() {
    final DateTime at = latestEventDate();
    return DateTime(at.year, at.month);
  }

  /// 页面 `_dayInMonth` 的同口径：月内同日，越界夹到月末。
  DateTime sameDayIn(DateTime month, int day) {
    final int lastDay = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(month.year, month.month, day.clamp(1, lastDay));
  }

  /// `周X` 标签（周一起始，与页面渲染同一口径）。
  String weekdayLabel(DateTime date) =>
      <String>['一', '二', '三', '四', '五', '六', '日'][date.weekday - 1];

  /// 当日事件区标题。
  String dayHeader(DateTime date) =>
      '${date.month}月${date.day}日 · 周${weekdayLabel(date)}';

  /// 月网格卡 —— 用「月份标题」定位，避开「我的」主页背后同类型的卡
  /// （`IndexedStack` 会保活主页）。周条也有同文月份标签，但不在卡内。
  Finder gridCard(String monthTitle) => find.ancestor(
    of: find.text(monthTitle),
    matching: find.byType(CareerlyCard),
  );

  /// 月网格卡内的月份切换箭头。
  Finder gridIcon(String monthTitle, IconData icon) =>
      find.descendant(of: gridCard(monthTitle), matching: find.byIcon(icon));

  /// 月网格卡内的某日格子。
  Finder gridDay(String monthTitle, int day) =>
      find.descendant(of: gridCard(monthTitle), matching: find.text('$day'));

  // ── 🔴 Phase 8A 核心不变量：日历与事件解耦 ───────────────────────────

  testWidgets('空数据：日历照常渲染，当天给出空状态（Phase 8A 解耦）', (WidgetTester tester) async {
    await openGrowthRecord(tester);

    final DateTime now = DateTime.now();
    final String title = '${now.year}年${now.month}月';

    // 顶栏仍在。
    expect(find.text('成长记录'), findsOneWidget);
    expect(find.text('每一次变化，都是成长的痕迹。'), findsOneWidget);

    // 🔴 没有事件 —— 但日历**必须在**：月份标题 + 月网格卡 + 今天选中。
    expect(gridCard(title), findsOneWidget);
    expect(find.text('一'), findsWidgets); // 网格表头
    expect(find.text('全部记录'), findsOneWidget); // 时间线区块标题

    // 当天事件区恒渲染，并给出当天空状态。
    expect(find.text(dayHeader(now)), findsOneWidget);
    expect(find.text('今天还没有足迹'), findsOneWidget);
    expect(find.text('完成一次职业分析，这里会留下你的成长记录。'), findsOneWidget);

    // 时间线为空 —— 只影响它自己。
    expect(find.text('暂无成长时间线'), findsOneWidget);

    // 旧的全页 Empty 文案已移除（它会把日历一起吃掉）。
    expect(find.text('还没有成长记录'), findsNothing);

    // 二级页挂在 profile 分支内 —— 底部导航保留。
    expect(find.byType(CareerlyNavigationBar), findsOneWidget);
  });

  // ── 周日历条 ─────────────────────────────────────────────────────────

  testWidgets('周日历条：渲染本周七天，今天为渐变圆', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openGrowthRecord(tester);

    final DateTime now = DateTime.now();

    // 月份标签 = 当前年月（Figma 用 `new Date()`，动态）。
    expect(find.text('${now.year}年${now.month}月'), findsWidgets);

    // 七个星期标签（周日起始）。
    for (final String label in <String>['日', '一', '二', '三', '四', '五', '六']) {
      expect(find.text(label), findsWidgets);
    }

    // 「今天」的日期数字出现在周条里，且其圆带渐变。
    expect(find.text('${now.day}'), findsWidgets);
    // 精确匹配「今天圆」的渐变 —— IndexedStack 保活的「我的」主页背后
    // 还有别的渐变圆（头像 / AI 入口球），按「有渐变」找会误命中。
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
            (widget.decoration! as BoxDecoration).gradient ==
                AppColors.growthTodayCircleGradient,
      ),
      findsOneWidget,
    );
  });

  // ── 月网格日历 ───────────────────────────────────────────────────────

  testWidgets('月网格：默认定位今天（今天定位，不再预选最近事件日）', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openGrowthRecord(tester);

    final DateTime now = DateTime.now();

    // 展示月 = 当前月；选中日 = 今天。
    expect(gridCard('${now.year}年${now.month}月'), findsOneWidget);
    expect(find.text(dayHeader(now)), findsOneWidget);

    // 图例 5 项短名（D91 映射；「排名」只在图例出现 —— 原型无 rank 事件）。
    for (final String label in <String>['项目', '简历', '能力', '分析']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('排名'), findsOneWidget);

    // 已在今天 —— 不显示「今天」快捷定位。
    expect(find.text('今天'), findsNothing);
  });

  testWidgets('月网格：月份切换 + 选中日跟随 + 今天定位（Flutter 侧补充交互）', (
    WidgetTester tester,
  ) async {
    useDemoData(enabled: true);
    await openGrowthRecord(tester);

    final DateTime now = DateTime.now();
    final String currentTitle = '${now.year}年${now.month}月';
    final DateTime prev = DateTime(now.year, now.month - 1);

    // 切到上个月。
    await tester.tap(gridIcon(currentTitle, Icons.chevron_left));
    await tester.pump();

    // 选中日**跟随**展示月（否则当天事件区会指向网格里看不见的日期）。
    final DateTime prevDay = sameDayIn(prev, now.day);
    expect(gridCard('${prev.year}年${prev.month}月'), findsOneWidget);
    expect(find.text(dayHeader(prevDay)), findsOneWidget);
    // 该月无事件 —— 给出空状态，但**日期区没有消失**。
    expect(find.text('这一天还没有足迹'), findsOneWidget);
    expect(find.text('今天还没有足迹'), findsNothing);

    // 离开今天后出现「今天」快捷定位；点它回到当前月 + 今天。
    expect(find.text('今天'), findsOneWidget);
    await tester.tap(find.text('今天'));
    await tester.pump();

    expect(gridCard(currentTitle), findsOneWidget);
    expect(find.text(dayHeader(now)), findsOneWidget);
    expect(find.text('今天还没有足迹'), findsOneWidget);
    // 已回到今天 —— 快捷入口收起。
    expect(find.text('今天'), findsNothing);
  });

  testWidgets('月网格：点选有事件的日期显示当天事件', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openGrowthRecord(tester);

    final DateTime now = DateTime.now();
    final DateTime em = eventMonth();
    final int delta = (em.year - now.year) * 12 + (em.month - now.month);

    // 导航到演示数据所在月（delta 由数据派生，不写死）。
    String title = '${now.year}年${now.month}月';
    for (int i = 0; i < delta.abs(); i++) {
      final int offset = delta < 0 ? -(i + 1) : (i + 1);
      await tester.tap(
        gridIcon(title, delta < 0 ? Icons.chevron_left : Icons.chevron_right),
      );
      await tester.pump();
      final DateTime month = DateTime(now.year, now.month + offset);
      title = '${month.year}年${month.month}月';
    }
    expect(gridCard(title), findsOneWidget);

    // 点选该月的一个事件日。
    final DateTime target = latestEventDate();
    final String targetTitle = DemoFixture.growthCalendarEvents
        .firstWhere((e) => e.occurredAt == target)
        .title;
    final Finder cell = gridDay(title, target.day);
    await tester.ensureVisible(cell);
    await tester.pump();
    await tester.tap(cell);
    await tester.pump();

    expect(find.text(dayHeader(target)), findsOneWidget);
    // 当天事件卡渲染事件标题（fixture 即原型抄本）。
    expect(find.text(targetTitle), findsWidgets);
    // 有事件时不再出空状态。
    expect(find.text('这一天还没有足迹'), findsNothing);
  });

  testWidgets('月网格：点选无事件的日期也可选中，并给出当天空状态', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openGrowthRecord(tester);

    final DateTime now = DateTime.now();
    final String title = '${now.year}年${now.month}月';

    // 当月第一个既无事件、又不是今天的日子。
    final Set<int> eventDays = DemoFixture.growthCalendarEvents
        .map((e) => e.occurredAt)
        .whereType<DateTime>()
        .where((DateTime d) => d.year == now.year && d.month == now.month)
        .map((DateTime d) => d.day)
        .toSet();
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int idleDay = 1;
    while (idleDay < daysInMonth &&
        (eventDays.contains(idleDay) || idleDay == now.day)) {
      idleDay++;
    }
    final DateTime target = DateTime(now.year, now.month, idleDay);

    final Finder cell = gridDay(title, idleDay);
    await tester.ensureVisible(cell);
    await tester.pump();
    await tester.tap(cell);
    await tester.pump();

    // 🔴 旧实现禁止点选空日期；现在必须能选中，并给出当天空状态。
    expect(find.text(dayHeader(target)), findsOneWidget);
    expect(find.text('这一天还没有足迹'), findsOneWidget);
    expect(find.text('今天还没有足迹'), findsNothing);
  });

  // ── 成长时间线（两者都保留：当天事件区 + 全部记录） ──────────────────

  testWidgets('成长时间线：按 Figma 规格渲染徽章 / 日期 / 描述', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openGrowthRecord(tester);

    // 区块标题 —— 用于与「当天事件区」区分。
    expect(find.text('全部记录'), findsOneWidget);

    // 月精度日期标签（Figma `'2026.08'.replace('.', '/')`）。
    for (final event in DemoFixture.growthTimeline) {
      final DateTime at = event.occurredAt!;
      final String label = '${at.year}/${at.month.toString().padLeft(2, '0')}';
      expect(find.text(label), findsWidgets);
    }

    // 描述逐字来自原型（fixture 即原型抄本）。
    for (final event in DemoFixture.growthTimeline) {
      if (event.description != null) {
        expect(find.text(event.description!), findsOneWidget);
      }
    }
  });

  testWidgets('成长时间线：徽章短名覆盖 fixture 实际出现的类型', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openGrowthRecord(tester);

    // fixture 里出现的类型：experience / capability / skill / matchScore
    // → 徽章短名 项目 / 能力 / 简历 / 分析（图例+徽章同源，故 findsWidgets）。
    // rank 在 fixture 中不存在 —— 徽章不渲染，只在图例里出现一次。
    final Set<String> expectedShortLabels = <String>{'项目', '能力', '简历', '分析'};
    for (final String label in expectedShortLabels) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('排名'), findsOneWidget);
  });

  testWidgets('完成岗位分析后在成长足迹播放庆祝动效并独立消费', (WidgetTester tester) async {
    await openGrowthRecord(tester);

    final BuildContext context = tester.element(
      find.byType(CareerlyNavigationBar),
    );
    final GrowthCelebrationProvider celebrations =
        Provider.of<GrowthCelebrationProvider>(context, listen: false);
    celebrations.record(GrowthMilestone.jobAnalysisCompleted);
    await tester.pump();
    await tester.pump();

    expect(find.text('太棒了！又向前一步 ✨'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pump(const Duration(milliseconds: 5200));
    await tester.pump();

    expect(find.text('太棒了！又向前一步 ✨'), findsNothing);
    expect(celebrations.nextRecordAnimation, isNull);
    expect(
      celebrations.nextPending?.milestone,
      GrowthMilestone.jobAnalysisCompleted,
    );
  });
}
