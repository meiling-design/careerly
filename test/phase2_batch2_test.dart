import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/design_system/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Careerly Phase 2 批 2 组件测试。
///
/// 覆盖 `CareerlyProgress` / `CareerlyToast` / `CareerlyBottomSheet`。
///
/// 断言取向与批 1 一致：**能真的发现回归**，而不是「渲染不抛异常」。
/// 本批尤其要钉死三件容易在后续被「顺手简化」掉的事：
///
/// 1. 进度填充用的是 `progressGradient`（172deg），**不是** `brandGradient`（135deg）
/// 2. 进度填充左端有 `-4px` 外扩（Figma 的固有细节，不是笔误）
/// 3. BottomSheet 面板**只有顶部圆角**
void main() {
  Widget host(Widget child) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );
  }

  // ---------------------------------------------------------------------------
  // CareerlyProgress
  // ---------------------------------------------------------------------------

  group('CareerlyProgress', () {
    /// 取进度条填充条。
    ///
    /// 按 `width != null` 取：`Stack` 里另有一个 `Positioned.fill` 的轨道，
    /// 而 `Positioned.fill` 会把 `left/top/right/bottom` 都设成 `0.0`
    /// （**不是** `null`），所以只能用「显式给了 width」来区分。
    Positioned fillOf(WidgetTester tester) {
      return tester.widget<Positioned>(
        find.byWidgetPredicate(
          (Widget w) => w is Positioned && w.width != null,
          description: '进度填充条',
        ),
      );
    }

    testWidgets('填充宽度 = value × 轨道宽（含左端外扩）', (WidgetTester tester) async {
      const double trackWidth = 200;
      const double value = 0.4;

      await tester.pumpWidget(
        host(
          const SizedBox(
            width: trackWidth,
            child: CareerlyProgress(value: value),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Positioned fill = fillOf(tester);

      expect(fill.left, -4, reason: 'Figma 的 left:-4px 外扩必须还原');
      expect(
        fill.width,
        closeTo(value * trackWidth + 4, 0.01),
        reason: '宽度必须是 calc(pct% + 4px)，画错比例等于进度显示错误',
      );
    });

    testWidgets('入场从 0 开始（对应 Figma .bar-grow）', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const SizedBox(width: 200, child: CareerlyProgress(value: 1.0))),
      );

      // 首帧尚未推进动画。
      await tester.pump();
      expect(
        fillOf(tester).width,
        closeTo(4, 0.01),
        reason: '第一帧应停在 0% —— 直接满格说明入场动画丢了',
      );

      await tester.pumpAndSettle();
      expect(fillOf(tester).width, closeTo(204, 0.01));
    });

    testWidgets('填充用 progressGradient，而不是 brandGradient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const SizedBox(width: 200, child: CareerlyProgress(value: 0.5))),
      );
      await tester.pumpAndSettle();

      final DecoratedBox box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(CareerlyProgress),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );

      expect(
        (box.decoration as BoxDecoration).gradient,
        AppColors.progressGradient,
      );
      expect(
        AppColors.progressGradient,
        isNot(AppColors.brandGradient),
        reason: '进度渐变是 172deg，与品牌的 135deg 不可互换',
      );
    });

    testWidgets('value 越界被夹取，不抛异常', (WidgetTester tester) async {
      for (final double value in <double>[1.8, -0.5]) {
        await tester.pumpWidget(
          host(SizedBox(width: 200, child: CareerlyProgress(value: value))),
        );
        await tester.pumpAndSettle();

        final double width = fillOf(tester).width!;
        expect(width, greaterThanOrEqualTo(4));
        expect(width, lessThanOrEqualTo(204));
      }
    });

    testWidgets('无障碍播报百分比', (WidgetTester tester) async {
      // 必须在本测试体内释放 —— `addTearDown` 跑在
      // framework 的「句柄是否已释放」校验**之后**。
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        host(const SizedBox(width: 200, child: CareerlyProgress(value: 0.42))),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(CareerlyProgress)),
        isSemantics(value: '42%'),
      );

      handle.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // CareerlyToast
  // ---------------------------------------------------------------------------

  group('CareerlyToast', () {
    /// 宿主：一个能触发 Toast 的按钮。
    Widget toastHost({
      String message = '已保存',
      IconData? icon,
      Duration duration = const Duration(milliseconds: 800),
    }) {
      return MaterialApp(
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => CareerlyToast.show(
                  context,
                  message: message,
                  icon: icon,
                  duration: duration,
                ),
                child: const Text('触发'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('弹出后文案可见', (WidgetTester tester) async {
      await tester.pumpWidget(toastHost());
      await tester.tap(find.text('触发'));
      await tester.pump();
      await tester.pump();

      expect(find.text('已保存'), findsOneWidget);
    });

    testWidgets('到达停留时长后自动消失', (WidgetTester tester) async {
      await tester.pumpWidget(toastHost());
      await tester.tap(find.text('触发'));
      await tester.pump();
      await tester.pump();
      expect(find.text('已保存'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(
        find.text('已保存'),
        findsNothing,
        reason: 'Toast 是瞬态内容，必须自行消失，否则会永久盖住页面',
      );
    });

    testWidgets('传入图标时渲染图标', (WidgetTester tester) async {
      await tester.pumpWidget(toastHost(icon: Icons.check_rounded));
      await tester.tap(find.text('触发'));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('是 liveRegion（读屏用户不能错过瞬态提示）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(toastHost());
      await tester.tap(find.text('触发'));
      await tester.pump();
      await tester.pump();

      final Semantics semantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.byType(CareerlyToast),
              matching: find.byType(Semantics),
            )
            .first,
      );

      expect(semantics.properties.liveRegion, isTrue);
    });

    testWidgets('不拦截其下方内容的点击', (WidgetTester tester) async {
      await tester.pumpWidget(toastHost());
      await tester.tap(find.text('触发'));
      await tester.pump();
      await tester.pump();

      expect(
        find.ancestor(
          of: find.byType(CareerlyToast),
          matching: find.byType(IgnorePointer),
        ),
        findsWidgets,
        reason: 'Toast 覆盖在页面底部，命中测试必须放行',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // CareerlyBottomSheet
  // ---------------------------------------------------------------------------

  group('CareerlyBottomSheet', () {
    Widget sheetHost({
      CareerlyBottomSheetTone tone = CareerlyBottomSheetTone.confirm,
      bool barrierDismissible = true,
      bool showHandle = true,
    }) {
      return MaterialApp(
        // 循环测多个 tone 时，key 变化会重建整棵树 ——
        // 否则上一轮已打开的弹层还挂在 Navigator 上，第二次点击打不开。
        key: UniqueKey(),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => CareerlyBottomSheet.show<void>(
                  context,
                  tone: tone,
                  barrierDismissible: barrierDismissible,
                  showHandle: showHandle,
                  child: const Text('弹层内容'),
                ),
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      );
    }

    /// 面板的裁剪器（`CareerlyBottomSheet` 内最外层的 `ClipRRect`）。
    BorderRadius panelRadius(WidgetTester tester) {
      final ClipRRect clip = tester.widget<ClipRRect>(
        find
            .descendant(
              of: find.byType(CareerlyBottomSheet),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      // 组件传入的恒为具体 `BorderRadius`；`resolve` 顺带断言了这一点。
      return clip.borderRadius.resolve(TextDirection.ltr);
    }

    testWidgets('弹出后内容可见，且带自绘 scrim', (WidgetTester tester) async {
      await tester.pumpWidget(sheetHost());
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      expect(find.text('弹层内容'), findsOneWidget);
      expect(
        find.byType(BackdropFilter),
        findsWidgets,
        reason: 'scrim 需要 backdrop blur —— 纯色 barrier 无法表达 Figma 的模糊',
      );
    });

    testWidgets('面板只有顶部圆角', (WidgetTester tester) async {
      await tester.pumpWidget(sheetHost());
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      final BorderRadius radius = panelRadius(tester);

      expect(radius.topLeft, const Radius.circular(AppRadius.xl));
      expect(
        radius.bottomLeft,
        Radius.zero,
        reason: 'BottomSheet 贴底，底角必须为直角',
      );
      expect(radius.bottomRight, Radius.zero);
    });

    testWidgets('action 档取 28 圆角（AppRadius.sheet 只覆盖这一档）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        sheetHost(tone: CareerlyBottomSheetTone.action),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      expect(panelRadius(tester).topLeft, const Radius.circular(AppRadius.xxl));
    });

    testWidgets('三种 tone 都能渲染且互不串扰', (WidgetTester tester) async {
      for (final CareerlyBottomSheetTone tone
          in CareerlyBottomSheetTone.values) {
        await tester.pumpWidget(sheetHost(tone: tone));
        await tester.tap(find.text('打开'));
        await tester.pumpAndSettle();

        expect(find.text('弹层内容'), findsOneWidget, reason: 'tone=${tone.name}');
        expect(panelRadius(tester).bottomLeft, Radius.zero);
      }
    });

    testWidgets('showHandle:false 时不渲染把手', (WidgetTester tester) async {
      await tester.pumpWidget(sheetHost(showHandle: false));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      expect(find.text('弹层内容'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CareerlyBottomSheet),
          matching: find.byType(SizedBox),
        ),
        findsNothing,
        reason: '关掉把手后，面板内不应再有把手占位',
      );
    });

    testWidgets('点击 scrim 关闭', (WidgetTester tester) async {
      await tester.pumpWidget(sheetHost());
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(find.text('弹层内容'), findsOneWidget);

      // 面板贴底，屏幕顶部必然是 scrim。
      await tester.tapAt(const Offset(400, 50));
      await tester.pumpAndSettle();

      expect(find.text('弹层内容'), findsNothing);
    });

    testWidgets('barrierDismissible:false 时点击 scrim 不关闭', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(sheetHost(barrierDismissible: false));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(400, 50));
      await tester.pumpAndSettle();

      expect(
        find.text('弹层内容'),
        findsOneWidget,
        reason: '确认类弹层常常必须强制用户做出选择',
      );
    });
  });
}
