import 'package:careerly/app/app.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  Future<void> openProfile(WidgetTester tester) async {
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

  testWidgets('我的页面展示三个 Tab、成长区块与设置入口', (WidgetTester tester) async {
    await openProfile(tester);

    // 三个 Tab（`CLAUDE.md` §5.4）—— 每个标签在页面上出现两次：
    // Tab 胶囊一次，对应卡片标题一次。
    expect(find.text('职业资产'), findsWidgets);
    expect(find.text('成长足迹'), findsWidgets);
    expect(find.text('我的简历'), findsWidgets);
    expect(find.text('我的职业成长'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // ── 结构边界（本轮按 IA 收口，见 D86）────────────────────────────
    // Figma 的 5 Tab / 2 张卡里，这两项**不实现**：
    //   历史分析卡 → 只属于「分析」（§2.2）
    //   设置卡     → 唯一入口是右上角齿轮（IA §16）
    expect(find.text('历史分析'), findsNothing);
    expect(find.text('设置'), findsNothing);
    // 旧版自造的「职业资产中心」文案卡在 Figma 里不存在，已删除。
    expect(find.text('职业资产中心'), findsNothing);
  });

  testWidgets('点击成长足迹入口卡进入成长记录二级页', (WidgetTester tester) async {
    await openProfile(tester);

    // 入口卡（含空态副标题）整张可点 —— 点副标题即命中卡片本体。
    final Finder growthEntry = find.text('还没有成长记录').first;
    await tester.ensureVisible(growthEntry);
    await tester.pump();
    await tester.tap(growthEntry);
    // 用 settle（pump 1s）而非 pumpAndSettle：二级页 initState 会触发
    // fetchTimeline 的 600ms 模拟延迟，pumpAndSettle 会停在过渡动画结束、
    // 残留 pending Timer。
    await settle(tester);
    // 批 3 起成长记录页并行加载**两个**数据流（月网格 + 时间线），
    // Mock 延迟 600ms —— 补一拍把两条链路的模拟延迟都走完，
    // 否则 teardown 时会报「Timer is still pending」。
    await tester.pump(const Duration(seconds: 1));

    // ⚠️ 交互形态在本轮变了：成长足迹 Detail 从**页内 switch 分支**
    // 改成**独立路由页**（`docs/plans` 批 1），因此断言随之更新 ——
    // 标题变成该页自己的顶栏标题「成长记录」，且带回退钮。
    expect(find.text('成长记录'), findsOneWidget);
    // Phase 8A（2026-09-28）：**日历不再被空数据门禁吃掉** ——
    // 从入口卡进来必须直接看到完整日历 + 当天空状态
    // （旧断言此处找的全页文案「还没有成长记录」已随之移除）。
    expect(find.text('今天还没有足迹'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    // 二级页挂在 profile 分支内，底部导航**保留**。
    expect(find.byType(CareerlyNavigationBar), findsOneWidget);
  });

  testWidgets('右上角齿轮进入设置二级页面', (WidgetTester tester) async {
    await openProfile(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('AI 与通知'), findsOneWidget);
    expect(find.text('AI 回答风格'), findsOneWidget);
    expect(find.byType(CareerlyNavigationBar), findsNothing);
  });
}
