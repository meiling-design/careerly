import '../../../core/state/state.dart';
import '../../../data/models/growth_event.dart';
import '../../../data/repositories/growth_repository.dart';

/// 成长足迹状态。
///
/// 归属（Phase 1 §三，开放项 O2 已裁决）：
/// **「我的」→ 成长足迹 → Detail 内部**。
///
/// ❌ 不增加第四张 Card
/// ❌ 不增加一级导航
/// ❌ 不创建独立 Growth Calendar Page
///
/// 成长日历 / 时间线是 Detail 内部的局部展示，共用本 Provider 的数据，
/// **不构成独立页面的数据源**。
class GrowthProvider extends AsyncStateNotifier<List<GrowthEvent>> {
  GrowthProvider(this._repository);

  final GrowthRepository _repository;

  /// 读取成长足迹列表（月网格日历数据源，日精度）。
  Future<void> load() => execute(() => _repository.fetchEvents());
}

/// 成长时间线状态（成长足迹 Detail 内的时间线列表，月精度）。
///
/// 与 [GrowthProvider] 是**两个数据流**：Figma 里月网格（`GROWTH_EVENTS`）
/// 与时间线（`GROWTH_TIMELINE`）就是两份粒度不同的数据，
/// 合成一个流会让任一为空连带另一块也无法渲染（CLAUDE.md §6.3）。
class GrowthTimelineProvider extends AsyncStateNotifier<List<GrowthEvent>> {
  GrowthTimelineProvider(this._repository);

  final GrowthRepository _repository;

  /// 读取成长时间线。
  Future<void> load() => execute(() => _repository.fetchTimeline());
}
