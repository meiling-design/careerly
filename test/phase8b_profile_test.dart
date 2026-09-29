import 'package:careerly/app/app.dart';
import 'package:careerly/app/router/app_routes.dart';
import 'package:careerly/data/mock/demo_fixture.dart';
import 'package:careerly/data/mock/mock_config.dart';
import 'package:careerly/data/models/models.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Phase 8 批 1 —— 「我的」二级页面。
///
/// 覆盖两条轨道：
///
/// ```text
/// 默认（空数据）  →  Empty 态真可达（CLAUDE.md §7：Mock 默认返回空）
/// 演示数据        →  Figma 样例数据下的导航链路（MockConfig.demoData）
/// ```
///
/// ⚠️ 断言**不写死 Figma 的样例数值**（`3 段` / `4 个`…）——
/// 一律从 [DemoFixture] 派生，避免「测试通过 = 数据被固化」。
/// 展开一张分组卡之后，页面上「查看全部」的总数。
///
/// ```text
/// 4 张分组卡的**卡头装饰**胶囊（Figma `ViewAllPill` 是静态 div，无 onClick）
/// 1 张「职业能力画像」卡右上角的按钮（批 2 建页前 onTap = null）
/// 1 个**展开面板底部**的按钮 ← 只有它是本轮的跳转入口
/// ```
///
/// 钉住这个总数是为了让「将来多出一个『查看全部』」立刻可见 ——
/// 否则下面按树序取按钮的写法会**静默点错**。
const int _viewAllTotal = 6;

void main() {
  /// 与 `phase8_profile_test.dart` 同一套：不用 `pumpAndSettle`
  /// （页面内含不确定时长的进度指示，`pumpAndSettle` 会等不到静止）。
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 只换演示数据开关，**保留** [MockConfig.standard] 的四态前提
  /// （延迟 0 只是为了让测试不必等 600ms）。
  void useDemoData({required bool enabled}) {
    MockSettings.config = MockConfig.standard.copyWith(
      latency: Duration.zero,
      demoData: enabled,
    );
  }

  setUp(() => useDemoData(enabled: false));  // ⚠️ 静态开关必须还原 —— 否则同文件后续用例会带着演示数据跑。
  tearDown(() => MockSettings.config = MockConfig.standard);

  /// 只把测试视口**加高**（800×1600），**宽度不动**。
  ///
  /// 默认视口 800×600 装不下「我的」二级页 ——
  /// 一屏之外的元素在 `ListView` 里**根本不会被构建**，
  /// `find.text` 自然也找不到。
  ///
  /// ⚠️ 宽度保持 800 是**有意的**，不是偷懒：
  /// 换成 360（真机宽度）会让**首页**（Phase 5 交付，不在本批范围）
  /// 暴露两处既有溢出 —— 见交付报告「范围外发现」。
  /// 本批不该把范围外的红带进基线。
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

  /// 「我的」→ 点资产卡的「查看全部」→ 职业资产页。
  Future<void> openCareerAssets(WidgetTester tester) async {
    await openProfile(tester);
    final Finder viewAll = find.text('查看全部').first;
    await tester.ensureVisible(viewAll);
    await tester.pump();
    await tester.tap(viewAll);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
  }

  /// 深链直达某个二级页（用于验证「详情页自身」的态，不经列表点入）。
  Future<void> push(WidgetTester tester, String location) async {
    final BuildContext context = tester.element(
      find.byType(CareerlyNavigationBar),
    );
    GoRouter.of(context).push(location);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
  }

  testWidgets('默认空数据：职业资产页骨架常驻（D99）', (WidgetTester tester) async {
    await openCareerAssets(tester);

    expect(find.text('职业资产'), findsOneWidget);
    // 四张分组卡是固定骨架，空数据不消失（D99 规则，2026-09-29）。
    for (final String label in <String>['工作经历', '项目经历', '专业技能', '荣誉成果']) {
      expect(find.text(label), findsOneWidget);
    }
    // 计数如实显示 0。
    expect(find.text('0 段职业经历'), findsOneWidget);
    expect(find.text('0 个项目经历'), findsOneWidget);
    expect(find.text('0 项技能'), findsOneWidget);
    expect(find.text('0 项荣誉记录'), findsOneWidget);
    // 能力卡骨架常驻，卡内显示空文案。
    expect(find.text('职业能力画像'), findsOneWidget);
    expect(
      find.text('还没有能力数据 · 提交简历并完成职业基线后生成画像'),
      findsOneWidget,
    );
    // 整页 Empty 态不复存在。
    expect(find.text('还没有职业资产'), findsNothing);
    // 顶栏回退钮 —— 二级页挂在 profile 分支内，底部导航保留。
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    expect(find.byType(CareerlyNavigationBar), findsOneWidget);
  });

  testWidgets('演示数据：职业资产页展示四个分组卡与展开面板', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openCareerAssets(tester);

    // 四个分组（Figma L3123 的四类资产）。
    for (final String label in <String>['工作经历', '项目经历', '专业技能', '荣誉成果']) {
      expect(find.text(label), findsOneWidget);
    }
    // 计数由数据派生，不是原型里写死的 4 / 6 / 12 / 3。
    expect(
      find.text('${DemoFixture.workExperiences.length} 段职业经历'),
      findsOneWidget,
    );

    // 点分组卡顶部 → 展开面板（同屏只允许展开一张）。
    await tester.tap(find.text('${DemoFixture.workExperiences.length} 段职业经历'));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    expect(find.text(DemoFixture.workExperiences.first.title), findsOneWidget);
  });

  testWidgets('演示数据：工作经历列表 → 详情页三张卡', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openCareerAssets(tester);

    await tester.tap(find.text('${DemoFixture.workExperiences.length} 段职业经历'));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    // ⚠️ 页面上有**两个**「查看全部」，文字一模一样：
    //
    //   ① 卡头那个是**装饰** —— Figma 的 `ViewAllPill` 就是静态 `div`
    //      （L3355-3359，无 onClick；点击落在卡的展开手势上）
    //   ② 展开面板底部那个才是 `<button>`（L3583），点它才跳列表
    //
    // 树序是「卡头在前、面板在后」，因此取 `at(1)`。
    // 先钉住总数，免得哪天多出一个「查看全部」而这条静默点错。
    expect(find.text('查看全部'), findsNWidgets(_viewAllTotal));
    await tester.tap(find.text('查看全部').at(1));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    // 列表页：顶栏计数 + 每条经历一张卡。
    expect(find.text('${DemoFixture.workExperiences.length} 段'), findsOneWidget);
    expect(find.text(DemoFixture.workExperiences.first.period), findsOneWidget);

    final WorkExperience first = DemoFixture.workExperiences.first;
    await tester.tap(find.text(first.period));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    // 详情页：三张卡 + Hero。
    expect(find.text('工作内容'), findsOneWidget);
    expect(find.text('带来的能力提升'), findsOneWidget);
    expect(find.text(first.title), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
  });

  testWidgets('演示数据：项目经历列表 → 详情页三张卡', (WidgetTester tester) async {
    useDemoData(enabled: true);
    await openCareerAssets(tester);

    await tester.tap(find.text('${DemoFixture.projects.length} 个项目经历'));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    // 同上：展开的是**第二张**卡，因此按钮面板排在两处卡头之后 → `at(2)`。
    expect(find.text('查看全部'), findsNWidgets(_viewAllTotal));
    await tester.tap(find.text('查看全部').at(2));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    expect(find.text('${DemoFixture.projects.length} 个'), findsOneWidget);
    await tester.tap(find.text(DemoFixture.projects.first.name));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    expect(find.text('项目背景'), findsOneWidget);
    expect(find.text('项目成果'), findsOneWidget);
    expect(find.text(DemoFixture.projects.first.year), findsOneWidget);
  });

  testWidgets('默认空数据：详情页「找不到这条」而不是空白', (WidgetTester tester) async {
    await openProfile(tester);
    await push(tester, AppRoutes.profileWorkDetail('not-a-real-id'));

    // 详情页与列表页的 Empty 文案**必须不同** ——
    // 「还没有工作经历」（列表为空）与「找不到这段经历」（id 不存在）不是一回事。
    expect(find.text('找不到这段经历'), findsOneWidget);
    expect(find.text('还没有工作经历'), findsNothing);
  });

  testWidgets('会员页：静态交付（无支付），按钮只给提示', (WidgetTester tester) async {
    await openProfile(tester);

    await tester.tap(find.text('Careerly Pro'));
    await tester.pumpAndSettle(const Duration(milliseconds: 350));

    expect(find.text('Pro 权益'), findsOneWidget);
    expect(find.text('开通 Careerly Pro'), findsOneWidget);
    expect(find.text('安全支付 · 随时取消 · 不自动续费'), findsOneWidget);
    // 免费额度 3 次是 Baseline §5 的锁定规则，额度卡应据此渲染。
    expect(find.text('当前免费体验'), findsOneWidget);

    // ⚠️ MVP 不接支付（CLAUDE.md §4 决策 6）—— 点下去是**提示语**，
    // 不是假装下单、也不是毫无反应。
    await tester.tap(find.text('开通 Careerly Pro'));
    await settle(tester);
    expect(find.text('MVP 阶段暂未接入支付，开通流程待产品侧确认'), findsOneWidget);
  });
}
