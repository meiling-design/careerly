import 'package:flutter/foundation.dart';

enum GrowthMilestone { careerBaselineEstablished, jobAnalysisCompleted }

@immutable
class GrowthCelebration {
  const GrowthCelebration({required this.id, required this.milestone});

  final int id;
  final GrowthMilestone milestone;
}

/// Queues UI celebrations only after a real career milestone succeeds.
class GrowthCelebrationProvider extends ChangeNotifier {
  final List<GrowthCelebration> _pending = <GrowthCelebration>[];
  final List<GrowthCelebration> _pendingRecordAnimations =
      <GrowthCelebration>[];
  int _nextId = 0;

  GrowthCelebration? get nextPending =>
      _pending.isEmpty ? null : _pending.first;

  GrowthCelebration? get nextRecordAnimation =>
      _pendingRecordAnimations.isEmpty ? null : _pendingRecordAnimations.first;

  void record(GrowthMilestone milestone) {
    final GrowthCelebration celebration = GrowthCelebration(
      id: ++_nextId,
      milestone: milestone,
    );
    _pending.add(celebration);
    if (milestone == GrowthMilestone.jobAnalysisCompleted) {
      _pendingRecordAnimations.add(celebration);
    }
    notifyListeners();
  }

  void consume(int id) {
    if (_pending.isEmpty || _pending.first.id != id) return;
    _pending.removeAt(0);
    notifyListeners();
  }

  void consumeRecordAnimation(int id) {
    if (_pendingRecordAnimations.isEmpty ||
        _pendingRecordAnimations.first.id != id) {
      return;
    }
    _pendingRecordAnimations.removeAt(0);
    notifyListeners();
  }
}
