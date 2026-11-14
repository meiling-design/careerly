import 'package:careerly/features/home/presentation/home_content.dart';
import 'package:careerly/features/home/presentation/widgets/home_hero_card.dart';
import 'package:careerly/features/profile/state/growth_celebration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('plays the celebration and reports completion once', (
    WidgetTester tester,
  ) async {
    final HomeHeroContent content = HomeHeroContent(
      label: '职业主页',
      title: '成长一步',
      meta: '',
      actionLabel: '继续',
      action: HomeHeroAction.viewAnalysis,
    );
    final GrowthCelebration celebration = GrowthCelebration(
      id: 1,
      milestone: GrowthMilestone.jobAnalysisCompleted,
    );
    final List<int> completed = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeHeroCard(
            content: content,
            celebration: celebration,
            onCelebrationFinished: completed.add,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('太棒了！又向前一步 ✨'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump();

    expect(completed, <int>[celebration.id]);
    expect(find.text('太棒了！又向前一步 ✨'), findsNothing);
  });

  testWidgets('reduced motion consumes celebration without animating', (
    WidgetTester tester,
  ) async {
    final HomeHeroContent content = HomeHeroContent(
      label: '职业主页',
      title: '成长一步',
      meta: '',
      actionLabel: '继续',
      action: HomeHeroAction.viewAnalysis,
    );
    final GrowthCelebration celebration = GrowthCelebration(
      id: 2,
      milestone: GrowthMilestone.careerBaselineEstablished,
    );
    final List<int> completed = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: HomeHeroCard(
              content: content,
              celebration: celebration,
              onCelebrationFinished: completed.add,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(completed, <int>[celebration.id]);
    expect(find.text('太棒了！又向前一步 ✨'), findsNothing);
  });
}
