import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/data/mock/demo_fixture.dart';
import 'package:careerly/data/mock/mock_config.dart';
import 'package:careerly/data/models/models.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Phase 8 批 2 —— 技能页 / 奖项页 / 能力页（三张职业资产二级页）。
///
/// 覆盖两条轨道：
///
/// ```text
/// 默认（空数据）  →  Empty 态真可达（CLAUDE.md §7：Mock 默认返回空）
/// 演示数据        →  Figma 样例数据下的渲染与导航链路（MockConfig.demoData）
/// ```
///
/// ⚠️ 断言**不写死 Figma 的样例数值**（`12 项` / `3 个`…）——
/// 一律从 [DemoFixture] 派生，避免「测试通过 = 数据被固化」。
/// 尤其技能计数：原型的顶栏写死 `12 项`，而它的数据是 13 项
/// （**待裁决 · D89**）。本页**派生**，因此断言算的是数据，不是原型屏幕上的字。
void main() {
  /// 与其余 Phase 8 用例同一套：不用 `pumpAndSettle`
  /// （页面内含不确定时长的进度指示与错峰动画，`pumpAndSettle` 会等不到静止）。
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

  /// 「我的」→ 资产卡「查看全部」→ 职业资产页。
  Future<void> openCareerAssets(WidgetTester tester) async {
    await openProfile(tester);
    final Finder viewAll = find.text('查看全部').first;
    await tester.ensureVisible(viewAll);
    await tester.pump();
    await tester.tap(viewAll);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
  }

  /// 深链直达某个二级页（用于验证「页面自身」的态，不经列表点入）。
  Future<void> push(WidgetTester tester, String location) async {
    final BuildContext context = tester.element(
      find.byType(CareerlyNavigationBar),
    );
    GoRouter.of(context).push(location);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
  }

  /// 演示数据下全部技能的展平总数（顶栏计数的真值）。
  int expectedSkillCount() => DemoFixture.skillGroups.fold<int>(
    0,
    (int sum, SkillGroup group) => sum + group.skills.length,
  );

  /// 雷达图的绘制器是本页**私有**类，测试只能按类型名识别它 ——
  /// 这是本文件唯一一处与实现细节耦合的断言（换实现时须同步更新）。
  /// 用它是因为雷达图的轴标签是 `TextPainter` **画上去的**，
  /// `find.text` 找不到，只能从「有没有那个 painter」来钉「雷达画了」。
  final Finder radarPainter = find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint &&
        widget.painter.runtimeType.toString().contains('RadarPainter'),
  );

  // ── 技能页 ────────────────────────────────────────────────────────────

  testWidgets('默认空数据：技能页呈现 Empty 态', (WidgetTester tester) async {
    await openProfile(tester);
    await push(tester, AppRoutes.profileSkills);

    expect(find.text('技能'), findsOneWidget);
    expect(find.text('还没有技能'), findsOneWidget);
    // 二级页挂在 profile 分支内 —— 顶栏回退钮与底部导航都在。
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    expect(find.byType(CareerlyNavigationBar), findsOneWidget);
    // ⚠️ Empty ≠ Loading：数据**已取回、只是为空**，顶栏就照实写 `0 项`。
    // 被抑制的是 Loading 期间（那时说 `0 项` 等于把「还没到」说成「没有」）——
    // 与批 1 的工作经历页同一口径（`work_experience_page.dart` 的注释）。
    expect(find.text('0 项'), findsOneWidget);
  });

  testWidgets('演示数据：技能页按分类渲染 Chip，计数由数据派生', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openProfile(tester);
    await push(tester, AppRoutes.profileSkills);

    // 三个分类（Figma `SKILL_CATS`）。
    for (final SkillGroup group in DemoFixture.skillGroups) {
      expect(find.text(group.category), findsOneWidget);
    }
    // 分类下的技能逐个成 Chip。
    expect(find.text(DemoFixture.skillGroups.first.skills.first), findsOneWidget);
    expect(find.text('Prompt Engineering'), findsOneWidget);

    // ⚠️ 顶栏计数 = **展平后**的总数（13），不是原型写死的 `12 项`。
    expect(find.text('${expectedSkillCount()} 项'), findsOneWidget);
    expect(find.text('12 项'), findsNothing);
  });

  // ── 奖项页 ────────────────────────────────────────────────────────────

  testWidgets('默认空数据：奖项页呈现 Empty 态', (WidgetTester tester) async {
    await openProfile(tester);
    await push(tester, AppRoutes.profileAwards);

    expect(find.text('奖项'), findsOneWidget);
    expect(find.text('还没有荣誉成果'), findsOneWidget);
    expect(find.text('0 项'), findsOneWidget); // 同上：Empty 照实写 0。
    expect(find.byType(CareerlyNavigationBar), findsOneWidget);
  });

  testWidgets('演示数据：奖项页渲染荣誉名 / 年份 / 机构 / 说明', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openProfile(tester);
    await push(tester, AppRoutes.profileAwards);

    expect(find.text('${DemoFixture.awards.length} 项'), findsOneWidget);

    // 逐条断言四段文本都在 —— 尤其 `description`：
    // 它此前因为「原型未使用」而没进模型，本页落地后才补回。
    for (final Award award in DemoFixture.awards) {
      expect(find.text(award.name), findsOneWidget);
      expect(find.text(award.year), findsOneWidget);
      expect(find.text(award.org), findsOneWidget);
      expect(find.text(award.description), findsOneWidget);
    }
  });

  // ── 能力页 ────────────────────────────────────────────────────────────

  testWidgets('默认空数据：能力页详情卡骨架常驻（D99）', (WidgetTester tester) async {
    await openProfile(tester);
    await push(tester, AppRoutes.profileCapability);

    expect(find.text('我的能力'), findsOneWidget);
    // 详情卡骨架常驻，卡内显示空文案（D99 规则，2026-09-29）。
    expect(find.text('能力详情'), findsOneWidget);
    expect(
      find.text('还没有能力数据 · 提交简历并完成职业基线后，这里会显示你的职业能力画像'),
      findsOneWidget,
    );
    // 雷达图仍受降级规则约束：0 维度不渲染。
    expect(find.text('能力雷达图'), findsNothing);
  });

  testWidgets('演示数据：能力页渲染雷达卡与能力详情', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openProfile(tester);
    await push(tester, AppRoutes.profileCapability);

    // 雷达卡：标题 + 图例 + 真的画了图。
    expect(find.text('能力雷达图'), findsOneWidget);
    expect(find.text('当前'), findsOneWidget);
    expect(find.text('上次'), findsOneWidget);
    expect(radarPainter, findsOneWidget);

    // 能力详情：5 个维度各自一行。
    expect(find.text('能力详情'), findsOneWidget);
    for (final Capability item in DemoFixture.capabilities) {
      expect(find.text(item.name), findsOneWidget);
      expect(find.text('${item.score}'), findsWidgets);
    }

    // 脚注由 `previousScore → score` 拼出（Figma L3904）。
    final Capability first = DemoFixture.capabilities.first;
    expect(
      find.text('上次 ${first.previousScore} → 现在 ${first.score}'),
      findsOneWidget,
    );

    // 无增量的那一条画「—」，而不是编一个 `+0`。
    final Capability flat = DemoFixture.capabilities.firstWhere(
      (Capability item) => item.delta == 0,
    );
    expect(flat.name, '项目管理');
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('演示数据：能力页不渲染「查看变化」（落点尚未裁决）', (
    WidgetTester tester,
  ) async {
    useDemoData(enabled: true);
    await openProfile(tester);
    await push(tester, AppRoutes.profileCapability);

    // Figma L3884 有一个跳 `cap-change` 的入口，而该页**无路由**
    // （D81：它属「我的 → 成长足迹 → Detail」内部，口径待裁决）。
    // 本页按「落点不存在的入口不渲染」处置 —— 这条断言把它钉住。
    expect(find.text('查看变化 →'), findsNothing);
    expect(find.textContaining('查看变化'), findsNothing);
  });

  // ── 三处落点回接 ──────────────────────────────────────────────────────

  testWidgets('「我的」资产卡：技能与奖项子卡各自进入对应页', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openProfile(tester);

    // 子卡标签在「我的」上各出现一次（Tab 是「职业资产 / 成长足迹 / 我的简历」）。
    final Finder skillTile = find.text('技能');
    await tester.ensureVisible(skillTile);
    await tester.pump();
    await tester.tap(skillTile);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    expect(find.text('${expectedSkillCount()} 项'), findsOneWidget);

    // 回到「我的」（走顶栏回退钮 —— 真实路径，不用 router API 抄近道）。
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    final Finder awardTile = find.text('奖项');
    await tester.ensureVisible(awardTile);
    await tester.pump();
    await tester.tap(awardTile);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    expect(find.text('${DemoFixture.awards.length} 项'), findsOneWidget);
    expect(find.text(DemoFixture.awards.first.name), findsOneWidget);
  });

  testWidgets('职业资产页：专业技能分组的「查看全部」进入技能页', (
    WidgetTester tester,
  ) async {
    useDemoData(enabled: true);
    await openCareerAssets(tester);

    // 展开专业技能分组（点分组卡的计数行）。
    final Finder skillCount = find.text('${expectedSkillCount()} 项技能');
    await tester.ensureVisible(skillCount);
    await tester.pump();
    await tester.tap(skillCount);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    // 展开前只有 4 张卡头胶囊 + 能力画像卡按钮共 5 个「查看全部」；
    // 展开后该面板底部多一个 —— 顺序是「卡头在前、面板在后」，
    // 因此专业技能（第 3 张卡）的落点是 `at(3)`。
    expect(find.text('查看全部'), findsNWidgets(6));
    final Finder panelAction = find.text('查看全部').at(3);
    await tester.ensureVisible(panelAction);
    await tester.pump();
    await tester.tap(panelAction);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    expect(find.text('${expectedSkillCount()} 项'), findsOneWidget);
    expect(find.text(DemoFixture.skillGroups.first.category), findsOneWidget);
  });

  testWidgets('职业资产页：能力画像卡的「查看全部」进入能力页', (
    WidgetTester tester,
  ) async {
    useDemoData(enabled: true);
    await openCareerAssets(tester);

    // 未展开任何分组时，「查看全部」共 5 个 —— 最后一个属能力画像卡。
    expect(find.text('查看全部'), findsNWidgets(5));
    final Finder capabilityAction = find.text('查看全部').last;
    await tester.ensureVisible(capabilityAction);
    await tester.pump();
    await tester.tap(capabilityAction);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    expect(find.text('我的能力'), findsOneWidget);
    expect(radarPainter, findsOneWidget);
  });
}
