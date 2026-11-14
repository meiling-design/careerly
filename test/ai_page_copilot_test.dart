import 'package:careerly/data/mock/mock_ai_repository.dart';
import 'package:careerly/data/repositories/ai_repository.dart';
import 'package:careerly/design_system/theme/careerly_theme.dart';
import 'package:careerly/features/ai/presentation/ai_page.dart';
import 'package:careerly/features/ai/presentation/widgets/ai_copilot_character.dart';
import 'package:careerly/features/ai/state/ai_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
  testWidgets('shows the Nebula companion on the AI welcome screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: <SingleChildWidget>[
          Provider<AIRepository>(create: (_) => MockAIRepository()),
          ChangeNotifierProvider<AIProvider>(
            create: (context) => AIProvider(context.read<AIRepository>()),
          ),
        ],
        child: MaterialApp(theme: CareerlyTheme.light(), home: const AIPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(AICopilotCharacter), findsOneWidget);
    expect(find.text('你好，今天想聊些什么？'), findsOneWidget);
  });
}
