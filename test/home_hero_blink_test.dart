import 'package:careerly/features/home/presentation/home_content.dart';
import 'package:careerly/features/home/presentation/widgets/home_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const HomeHeroContent content = HomeHeroContent(
    label: '深夜了',
    title: 'Alex',
    meta: '看见能力，也看见前进的自己~',
    actionLabel: '新建分析',
  );

  Finder blinkSvg() => find.byWidgetPredicate(
    (Widget w) =>
        w is SvgPicture &&
        (w.bytesLoader as SvgAssetLoader).assetName.endsWith(
          'home-welcome-blink.svg',
        ),
  );

  testWidgets('首页 IP 眨眼：闭眼素材短暂叠加，且不改变布局', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            child: HomeHeroCard(
              content: content,
              blinkInterval: Duration(milliseconds: 300),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // 静止时没有闭眼图层。
    expect(blinkSvg(), findsNothing);
    final Size sizeBefore = tester.getSize(find.byType(HomeHeroCard));

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 70));

    // 眨眼过程中叠加闭眼素材，透明度 > 0。
    expect(blinkSvg(), findsOneWidget);
    final Finder blinkLayer = find.ancestor(
      of: blinkSvg(),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(blinkLayer).opacity, greaterThan(0));

    // 眨眼结束后闭眼图层消失，占位尺寸不变（无 Layout shift）。
    await tester.pump(const Duration(milliseconds: 200));
    expect(blinkSvg(), findsNothing);
    expect(tester.getSize(find.byType(HomeHeroCard)), sizeBefore);
  });

  testWidgets('首页 IP 眨眼：系统关闭动效时不眨眼', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              child: HomeHeroCard(
                content: content,
                blinkInterval: Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 70));
    expect(blinkSvg(), findsNothing);
  });
}
