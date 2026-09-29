import 'package:careerly/design_system/components/components.dart';
import 'package:careerly/design_system/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Careerly Phase 2 批 1 组件测试。
///
/// 覆盖 `GlassSurface` / `CareerlyButton` / `CareerlyCard` / `CareerlyChip`。
///
/// 重点是**能真的发现回归**的断言：
/// 交互是否生效、禁用态是否真的禁用、各变体是否都能渲染（不抛异常）。
void main() {
  /// 组件需要一个提供 Directionality / TextTheme 的宿主。
  Widget host(Widget child) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('GlassSurface', () {
    testWidgets('渲染子内容，并套用 BackdropFilter', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const GlassSurface(child: Text('玻璃内容')),
        ),
      );

      expect(find.text('玻璃内容'), findsOneWidget);
      expect(
        find.byType(BackdropFilter),
        findsOneWidget,
        reason: 'GlassSurface 必须做 backdrop 模糊，否则只是半透明色块',
      );
    });

    testWidgets('可点击时响应点击', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          GlassSurface(
            onTap: () => taps++,
            child: const SizedBox(width: 120, height: 60),
          ),
        ),
      );

      await tester.tap(find.byType(GlassSurface));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('light 变体同样可渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const GlassSurface(
            variant: GlassVariant.light,
            child: Text('轻量玻璃'),
          ),
        ),
      );

      expect(find.text('轻量玻璃'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('CareerlyButton', () {
    testWidgets('可用时触发回调', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          CareerlyButton(label: '开始分析', onPressed: () => taps++),
        ),
      );

      expect(find.text('开始分析'), findsOneWidget);

      await tester.tap(find.byType(CareerlyButton));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('onPressed 为 null 时不触发任何回调', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const CareerlyButton(label: '开始分析')),
      );

      // 不可用态文字应为灰化的 textDisabled（Figma 的空输入按钮文字色）。
      final Text label = tester.widget<Text>(find.text('开始分析'));
      expect(label.style?.color, AppColors.textDisabled);

      // 点击不应抛异常，也不应改变任何状态。
      await tester.tap(find.byType(CareerlyButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('两种变体都能渲染', (WidgetTester tester) async {
      for (final CareerlyButtonVariant variant in CareerlyButtonVariant.values) {
        await tester.pumpWidget(
          host(CareerlyButton(label: '按钮', variant: variant, onPressed: () {})),
        );
        expect(find.text('按钮'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('CareerlyCard', () {
    testWidgets('四种变体都能渲染', (WidgetTester tester) async {
      for (final CareerlyCardVariant variant in CareerlyCardVariant.values) {
        await tester.pumpWidget(
          host(
            CareerlyCard(
              variant: variant,
              child: const Text('卡片内容'),
            ),
          ),
        );

        expect(
          find.text('卡片内容'),
          findsOneWidget,
          reason: '变体 $variant 未正确渲染内容',
        );
        expect(tester.takeException(), isNull, reason: '变体 $variant 抛异常');
      }
    });

    testWidgets('可点击卡片响应点击', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          CareerlyCard(
            onTap: () => taps++,
            child: const SizedBox(width: 120, height: 60),
          ),
        ),
      );

      await tester.tap(find.byType(CareerlyCard));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('glass 变体尊重 shadow 覆盖（不再静默丢弃）', (
      WidgetTester tester,
    ) async {
      // 回归：glass / glassLight 分支曾完全不传 shadow，
      // 调用方传值会被无声丢弃且不报错。
      const List<BoxShadow> custom = <BoxShadow>[
        BoxShadow(color: Color(0xFF123456), blurRadius: 7),
      ];

      await tester.pumpWidget(
        host(
          const CareerlyCard(
            shadow: custom,
            child: SizedBox(width: 120, height: 60),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.byType(GlassSurface),
        findsOneWidget,
        reason: 'glass 变体应渲染为 GlassSurface',
      );

      // GlassSurface 最外层的 DecoratedBox 承载投影（投影在 ClipRRect 之外）。
      final DecoratedBox outer = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(GlassSurface),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );

      expect(
        (outer.decoration as BoxDecoration).boxShadow,
        custom,
        reason: 'glass 变体必须把 shadow 透传给 GlassSurface',
      );
    });
  });

  group('CareerlyChip', () {
    testWidgets('全部色调都能渲染', (WidgetTester tester) async {
      for (final CareerlyChipTone tone in CareerlyChipTone.values) {
        await tester.pumpWidget(
          host(CareerlyChip(label: '标签', tone: tone)),
        );

        expect(find.text('标签'), findsOneWidget, reason: '色调 $tone 未渲染');
        expect(tester.takeException(), isNull, reason: '色调 $tone 抛异常');
      }
    });

    testWidgets('两种尺寸都能渲染', (WidgetTester tester) async {
      for (final CareerlyChipSize size in CareerlyChipSize.values) {
        await tester.pumpWidget(
          host(CareerlyChip(label: '标签', size: size)),
        );
        expect(find.text('标签'), findsOneWidget);
      }
    });
  });

  group('Phase 2 语义色 Token', () {
    test('底色透明度与 Figma 原值一致', () {
      // Figma 原值：0.08 / 0.10 / 0.12 / 0.20。
      expect(AppColors.primaryBlueSurface.a, closeTo(0.08, 0.005));
      expect(AppColors.primaryPurpleSurface.a, closeTo(0.10, 0.005));
      expect(AppColors.successSurface.a, closeTo(0.12, 0.005));
      expect(AppColors.warningSurface.a, closeTo(0.12, 0.005));
      expect(AppColors.dangerSurface.a, closeTo(0.10, 0.005));
      expect(AppColors.neutralSurface.a, closeTo(0.10, 0.005));
      expect(AppColors.onBrandSurface.a, closeTo(0.20, 0.005));
    });

    test('不可用文字色 = textTertiary @ 60%', () {
      expect(AppColors.textDisabled.a, closeTo(0.6, 0.005));
      expect(
        AppColors.textDisabled.toARGB32() & 0x00FFFFFF,
        AppColors.textTertiary.toARGB32() & 0x00FFFFFF,
        reason: 'Figma 的 rgba(156,163,175,0.6) 就是 textTertiary 降到 60%',
      );
    });

    test('组件级 Typography 角色已建立', () {
      // 15 / bold —— Figma PrimaryBtn
      expect(AppTypography.buttonPrimary.fontSize, 15);
      expect(AppTypography.buttonPrimary.fontWeight, FontWeight.w700);
      // 14 / semibold —— Figma SecondaryBtn
      expect(AppTypography.buttonSecondary.fontSize, 14);
      expect(AppTypography.buttonSecondary.fontWeight, FontWeight.w600);
      // Chip
      expect(AppTypography.chipSmall.fontSize, 11);
      expect(AppTypography.chipMedium.fontSize, 12);
    });

    test('主按钮投影与 Figma PrimaryBtn 一致', () {
      expect(AppShadows.primaryButton.length, 1);
      final BoxShadow s = AppShadows.primaryButton.first;
      expect(s.blurRadius, 24);
      expect(s.offset, const Offset(0, 8));
      expect(s.color.a, closeTo(0.30, 0.005));
    });
  });
}
