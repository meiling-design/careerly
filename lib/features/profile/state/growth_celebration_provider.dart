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
  int _nextId = 0;

  GrowthCelebration? get nextPending =>
      _pending.isEmpty ? null : _pending.first;

  void record(GrowthMilestone milestone) {
    _pending.add(GrowthCelebration(id: ++_nextId, milestone: milestone));
    notifyListeners();
  }

  void consume(int id) {
    if (_pending.isEmpty || _pending.first.id != id) return;
    _pending.removeAt(0);
    notifyListeners();
  }
}
