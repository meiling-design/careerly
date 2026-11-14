import 'package:careerly/app/app.dart';
import 'package:careerly/app/shell/careerly_shell.dart';
import 'package:careerly/core/constants/app_constants.dart';
import 'package:careerly/data/models/quota_state.dart';
import 'package:careerly/design_system/components/careerly_navigation_bar.dart';
import 'package:careerly/design_system/tokens/tokens.dart';
import 'package:careerly/features/analysis/presentation/analysis_page.dart';
import 'package:careerly/features/home/presentation/home_page.dart';
import 'package:careerly/features/profile/presentation/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Careerly Phase 1 冒烟测试。
///
/// 验证 Phase 1 §二十五 的验收项中**可以在单测里验证**的部分：
/// App Launch / Router / Shell / Navigation / Tab State / Theme。
///
/// 真机相关项（SafeArea、Android Back、小屏）见 `docs/phase_1_report.md` §20。
void main() {
  /// Mock 数据层的默认延迟是 600ms，测试里需要推进假时钟把它走完。
  Future<void> settleMock(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  /// 点击底部导航的某个一级入口。
  ///
  /// Figma 的三个标准 Tab **只有图标、没有文字**，因此不能用 `find.text` 定位。
  /// 改用组件已经声明的 `Semantics(label:)`。
  ///
  /// ⚠️ 这里匹配的是 `Semantics` **Widget 的属性**，而不是语义树节点：
  /// `Semantics` 默认 `container: false`，只向上层节点附加标注、**不自建节点**，
  /// 因此 `find.bySemanticsLabel` 找不到它。
  ///
  /// 顺带验证了一条无障碍要求：纯图标 Tab 仍然具备可访问名称。
  Future<void> tapNavDestination(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(CareerlyNavigationBar),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is Semantics && widget.properties.label == label,
        ),
      ),
    );
    await settleMock(tester);
  }

  /// 把 AI 页「聊天记录」抽屉的滑入 / 滑出动画推完。
  ///
  /// 抽屉是 `AnimatedPositioned`，**从状态变化后的下一帧才开始动画** ——
  /// 单发一次 `pump(350ms)` 只够让动画起步，面板仍停在屏幕外，
  /// 紧接着的 `tap` 于是落在空处（flutter_test 只打警告，不会让用例变红，
  /// 这正是这个用例此前长期「红灯但归因不明」的原因之一）。
  /// 所以要先 `pump()` 起一帧，再 `pump(350ms)` 把 300ms 走完。
  Future<void> pumpDrawer(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  group('App Shell', () {
    testWidgets('启动后展示 Careerly Shell 与四个一级导航', (WidgetTester tester) async {
      await tester.pumpWidget(const CareerlyApp());
      await settleMock(tester);

      expect(find.byType(CareerlyNavigationBar), findsOneWidget);

      // 一级导航只有 4 个（PRD §6：永远不加第 5 个）。
      expect(
        CareerlyShell.destinations.length,
        4,
        reason: '一级导航必须恰好是 首页 / 分析 / AI / 我的',
      );
      expect(
        CareerlyShell.destinations
            .map((CareerlyNavDestination d) => d.label)
            .toList(growable: false),
        <String>['首页', '分析', 'AI', '我的'],
      );

      // AI 是特殊入口，不是普通 Tab（Baseline §6.5 / 决策 9）。
      expect(CareerlyShell.destinations[2].isSpecial, isTrue);
      expect(
        CareerlyShell.destinations
            .where((CareerlyNavDestination d) => !d.isSpecial)
            .length,
        3,
        reason: 'AI 之外应恰好有 3 个标准 Tab',
      );

      // Figma `BottomNav`（`src/App.tsx` 行 235–334）：
      // 三个标准 Tab 是**纯图标**（`<Icon active={active}/>`，72×50，图标 22×22），
      // **不渲染文字标签** —— 标签只存在于 Semantics 中（供无障碍使用）。
      //
      // ⚠️ 必须限定在导航栏内断言：页面 AppBar 的标题同样是「首页」「分析」「我的」。
      for (final String label in <String>['首页', '分析', '我的']) {
        expect(
          find.descendant(
            of: find.byType(CareerlyNavigationBar),
            matching: find.text(label),
          ),
          findsNothing,
          reason: 'Figma 的 Tab 是纯图标，「$label」不应出现在导航栏内',
        );
      }

      // 唯一带文字标签的入口是**玻璃条之外**的 AI 球（`✦` + 「AI」）。
      expect(
        find.descendant(
          of: find.byType(CareerlyNavigationBar),
          matching: find.text('✦'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(CareerlyNavigationBar),
          matching: find.text('AI'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('默认落在首页', (WidgetTester tester) async {
      await tester.pumpWidget(const CareerlyApp());
      await settleMock(tester);

      // 路由初始位置。
      //
      // ⚠️ 断言**页面类型**而不是页面文案：首页在 Phase 5 之后不再有
      // `CareerlyScaffold` 的 AppBar 标题（Figma 首页没有标题栏，
      // 顶部是它自己的身份区），而页内文案会随三态变化（D64）。
      // 路由冒烟测试关心的是「落在哪个页面」，不是「页面上写了什么」。
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('可以切换到「分析」，并保留分支状态', (WidgetTester tester) async {
      await tester.pumpWidget(const CareerlyApp());
      await settleMock(tester);

      await tapNavDestination(tester, '分析');

      // ⚠️ 断言**页面类型**而不是页面文案，理由同「默认落在首页」：
      // 分析页在 Phase 6 已由 Phase 1 的 route placeholder 换成真实实现，
      // 占位文案 `分析 · 看见距离` 不复存在（见 CHANGELOG Session 012）。
      expect(find.byType(AnalysisPage), findsOneWidget);

      // 额度读数来自 MockAnalysisRepository → QuotaState.free。
      expect(
        find.textContaining('剩余 3 / 3 次'),
        findsOneWidget,
        reason: 'Baseline §5：免费用户 3 次完整分析',
      );
    });

    testWidgets('可以切换到「我的」', (WidgetTester tester) async {
      await tester.pumpWidget(const CareerlyApp());
      await settleMock(tester);

      await tapNavDestination(tester, '我的');

      // ⚠️ 断言**页面类型**而不是页面文案，理由同「默认落在首页」与
      // 「可以切换到『分析』」：`我的` 在 Phase 8 已由 Phase 1 的
      // route placeholder 换成真实实现，占位文案 `我的 · 沉积积累`
      // 不复存在。路由冒烟测试关心的是「落在哪个页面」。
      expect(find.byType(ProfilePage), findsOneWidget);

      // 设置唯一入口：右上角齿轮（PRD §12 / IA §16）。
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('可以切换到 AI', (WidgetTester tester) async {
      await tester.pumpWidget(const CareerlyApp());
      await settleMock(tester);

      await tapNavDestination(tester, 'AI');

      expect(find.text('Career Copilot'), findsOneWidget);
      expect(find.text('你可以问我'), findsOneWidget);
      expect(find.text('输入你想问的问题...'), findsOneWidget);
      expect(find.text('你好，今天想聊些什么？'), findsOneWidget);
      expect(find.text('ALEX'), findsNothing);
      expect(find.textContaining('82%'), findsNothing);
      expect(find.textContaining('86%'), findsNothing);
      expect(
        find.byTooltip('聊天记录'),
        findsOneWidget,
        reason: 'Figma AI 欢迎页右侧提供聊天记录入口',
      );

      const String suggestion = '帮我解释最近一次岗位分析结果';
      await tester.ensureVisible(find.text(suggestion));
      await tester.tap(find.text(suggestion));
      await tester.pump();
      expect(
        find.text('有分析时参考最近一次分析；否则提供通用建议'),
        findsOneWidget,
        reason: '会话提示应准确说明最近分析与通用顾问的上下文规则',
      );
      expect(find.text(suggestion), findsNWidgets(3));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // 点「聊天记录」= 展开抽屉。
      await tester.tap(find.byTooltip('聊天记录'));
      await pumpDrawer(tester);
      expect(find.text('新建对话'), findsOneWidget);
      expect(find.text('聊天记录'), findsOneWidget);

      // 聊天记录里这张会话卡片，标题取**首条**消息、预览行取**最后一条**消息
      // （`AIConversation.titleFrom` / `AIConversation.preview`）。
      // 上面 pump 2s 已经让 Mock 回复落地，预览行显示的是 **AI 的回复**
      // 而不是这句提问 —— 所以提问文本只剩「用户气泡」+「会话标题」两处。
      // 这个 3 是 AI 尚未回复时的旧口径（Chat 接真实回复前写下），已过时。
      expect(find.text(suggestion), findsNWidgets(2));

      // ⚠️ 抽屉展开后，「关闭」按钮与顶栏「聊天记录」按钮**落在同一坐标**
      // （面板右缘与屏幕右缘对齐）—— 所以此处必须显式点「关闭聊天记录」，
      // 再点「聊天记录」等于又把它关回去。
      await tester.tap(find.byTooltip('关闭聊天记录'));
      await pumpDrawer(tester);
      await tester.tap(find.byTooltip('聊天记录'));
      await pumpDrawer(tester);
      await tester.tap(find.text('新建对话'));
      await pumpDrawer(tester);
      expect(find.text('你可以问我'), findsOneWidget);

      await tester.tap(find.byTooltip('聊天记录'));
      await pumpDrawer(tester);
      final Finder historyPreview = find.text(suggestion).last;
      await tester.tap(
        find
            .ancestor(of: historyPreview, matching: find.byType(InkWell))
            .first,
      );
      await pumpDrawer(tester);
      // 选中历史会话 → 回到该会话：提问文本仍是「用户气泡」+「会话标题」两处。
      expect(find.text(suggestion), findsNWidgets(2));
      expect(
        find.text('有分析时参考最近一次分析；否则提供通用建议'),
        findsOneWidget,
      );
    });
  });

  group('Design Tokens', () {
    test('AppMotion 六档时长满足 motion-spec §27 区间', () {
      expect(AppMotion.micro.inMilliseconds, inInclusiveRange(80, 120));
      expect(AppMotion.button.inMilliseconds, inInclusiveRange(120, 200));
      expect(
        AppMotion.smallComponent.inMilliseconds,
        inInclusiveRange(180, 240),
      );
      expect(
        AppMotion.pageTransition.inMilliseconds,
        inInclusiveRange(240, 320),
      );
      expect(AppMotion.sheet.inMilliseconds, inInclusiveRange(300, 400));
      expect(AppMotion.reveal.inMilliseconds, inInclusiveRange(400, 700));
    });

    test('Typography 声明了 Noto Sans SC', () {
      expect(AppTypography.fontFamily, 'Noto Sans SC');
      expect(AppTypography.display.fontFamily, 'Noto Sans SC');
      expect(AppTypography.body.fontFamily, 'Noto Sans SC');
    });

    test('背景渐变有三个停靠点（Figma S.bg）', () {
      expect(AppColors.backgroundGradient.colors.length, 3);
      expect(AppColors.backgroundGradient.stops?.length, 3);
    });
  });

  group('QuotaState', () {
    test('免费用户初始为 3 次且可分析', () {
      expect(QuotaState.free.total, AppConstants.freeAnalysisQuota);
      expect(QuotaState.free.total, 3);
      expect(QuotaState.free.remaining, 3);
      expect(QuotaState.free.canAnalyze, isTrue);
    });

    test('扣减与回滚（分析失败回滚额度）', () {
      final QuotaState used = QuotaState.free.consume();
      expect(used.remaining, 2);
      expect(used.rollback().remaining, 3);

      final QuotaState exhausted = QuotaState.free
          .consume()
          .consume()
          .consume();
      expect(exhausted.remaining, 0);
      expect(exhausted.canAnalyze, isFalse);
      expect(exhausted.isExhausted, isTrue);
    });
  });
}
