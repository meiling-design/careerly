import '../models/growth_event.dart';
import '../repositories/growth_repository.dart';
import 'demo_fixture.dart';
import 'mock_config.dart';

/// [GrowthRepository] 的 Mock 实现。
///
/// ⚠️ **默认返回空列表**，让成长足迹走 Empty State。
///
/// `MockConfig.demoData == true` 时返回 [DemoFixture.growthCalendarEvents] /
/// [DemoFixture.growthTimeline] —— Figma 原型样例数据（D91 类型映射），
/// 仅供视觉走查，见 `demo_fixture.dart` 顶部说明。
///
/// 注意归属（Phase 1 §三，O2 已裁决）：
/// 成长日历 / 时间线属于 **「我的」→ 成长足迹 → Detail 内部**，
/// 这些 Mock 数据是给 Detail 用的，**不是**给独立页面用的。
class MockGrowthRepository implements GrowthRepository {
  MockGrowthRepository({MockConfig? config})
    : _config = config ?? MockSettings.config;

  final MockConfig _config;

  @override
  Future<List<GrowthEvent>> fetchEvents({GrowthEventType? type}) async {
    await _config.simulate();
    if (!_config.demoData) return const <GrowthEvent>[];
    // 月网格日历数据源（Figma `GROWTH_EVENTS`，日精度）。
    return DemoFixture.growthCalendarEvents;
  }

  @override
  Future<List<GrowthEvent>> fetchTimeline({
    DateTime? from,
    DateTime? to,
  }) async {
    await _config.simulate();
    if (!_config.demoData) return const <GrowthEvent>[];
    // 成长时间线数据源（Figma `GROWTH_TIMELINE`，月精度）。
    return DemoFixture.growthTimeline;
  }
}
