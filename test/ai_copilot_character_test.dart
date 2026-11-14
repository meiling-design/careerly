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
}
