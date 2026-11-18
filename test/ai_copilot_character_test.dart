import 'package:careerly/features/ai/presentation/widgets/ai_copilot_character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the original pose and responds to a tap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AICopilotCharacter(state: AICopilotMotionState.idle),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.tap(find.byType(AICopilotCharacter));
    await tester.pump();
    expect(find.text('我一直在这里，随时陪你聊聊。'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump();
    expect(find.text('我一直在这里，随时陪你聊聊。'), findsNothing);
  });

  testWidgets('switches the pose for thinking and completion states', (
    WidgetTester tester,
  ) async {
    Widget buildCharacter({
      required AICopilotMotionState state,
      String? completionId,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: AICopilotCharacter(
              key: const ValueKey<String>('copilot'),
              state: state,
              completionId: completionId,
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildCharacter(state: AICopilotMotionState.idle));
    await tester.pump();
    await tester.pumpWidget(
      buildCharacter(state: AICopilotMotionState.thinking),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.pumpWidget(
      buildCharacter(
        state: AICopilotMotionState.idle,
        completionId: 'answer-1',
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('welcome 态用「办公」IP，对话态仍用星云四态素材', (WidgetTester tester) async {
    String assetName(WidgetTester tester) {
      final SvgPicture picture = tester.widget<SvgPicture>(
        find.byType(SvgPicture),
      );
      return (picture.bytesLoader as SvgAssetLoader).assetName;
    }

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AICopilotCharacter(
              state: AICopilotMotionState.idle,
              welcome: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(assetName(tester), contains('careerly-ai-office.svg'));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AICopilotCharacter(state: AICopilotMotionState.idle),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(assetName(tester), contains('careerly-ai-idle.svg'));
  });

  testWidgets('眨眼：闭眼素材短暂替换，且不改变布局', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AICopilotCharacter(
              state: AICopilotMotionState.idle,
              blinkInterval: Duration(milliseconds: 500),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // 静止时只有一张图（闭眼图层不挂载）。
    expect(find.byType(SvgPicture), findsOneWidget);
    final Size sizeBefore = tester.getSize(find.byType(AICopilotCharacter));

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 70));

    // 眨眼过程中叠加闭眼素材，透明度 > 0。
    expect(find.byType(SvgPicture), findsNWidgets(2));
    final Iterable<String> names = tester
        .widgetList<SvgPicture>(find.byType(SvgPicture))
        .map((SvgPicture p) => (p.bytesLoader as SvgAssetLoader).assetName);
    expect(names.any((String name) => name.endsWith('-blink.svg')), isTrue);
    // 阴影层也有一个 Opacity，这里只取闭眼图层的那个。
    final Finder blinkLayer = find.ancestor(
      of: find.byWidgetPredicate(
        (Widget w) =>
            w is SvgPicture &&
            (w.bytesLoader as SvgAssetLoader).assetName.endsWith('-blink.svg'),
      ),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(blinkLayer).opacity, greaterThan(0));

    // 眨眼结束后回到单图，占位尺寸不变（无 Layout shift）。
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.getSize(find.byType(AICopilotCharacter)), sizeBefore);
  });
}
