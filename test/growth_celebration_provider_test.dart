import 'package:careerly/features/profile/state/growth_celebration_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GrowthCelebrationProvider', () {
    test('keeps milestones queued until consumed in FIFO order', () {
      final GrowthCelebrationProvider provider = GrowthCelebrationProvider();
      addTearDown(provider.dispose);

      provider.record(GrowthMilestone.careerBaselineEstablished);
      final int firstId = provider.nextPending!.id;
      expect(provider.nextRecordAnimation, isNull);
      provider.record(GrowthMilestone.jobAnalysisCompleted);

      expect(
        provider.nextPending!.milestone,
        GrowthMilestone.careerBaselineEstablished,
      );
      expect(
        provider.nextRecordAnimation!.milestone,
        GrowthMilestone.jobAnalysisCompleted,
      );

      provider.consume(firstId);
      expect(
        provider.nextPending!.milestone,
        GrowthMilestone.jobAnalysisCompleted,
      );
      expect(provider.nextRecordAnimation!.id, isNot(firstId));
      final int secondId = provider.nextPending!.id;
      expect(secondId, greaterThan(firstId));

      provider.consume(firstId);
      expect(provider.nextPending!.id, secondId);

      provider.consume(secondId);
      expect(provider.nextPending, isNull);
      expect(provider.nextRecordAnimation!.id, secondId);

      provider.consumeRecordAnimation(secondId);
      expect(provider.nextRecordAnimation, isNull);
    });

    test('ignores repeated consumption of an already consumed milestone', () {
      final GrowthCelebrationProvider provider = GrowthCelebrationProvider();
      addTearDown(provider.dispose);

      provider.record(GrowthMilestone.jobAnalysisCompleted);
      final int id = provider.nextPending!.id;
      provider.consume(id);
      provider.consume(id);

      expect(provider.nextPending, isNull);
    });
  });
}
