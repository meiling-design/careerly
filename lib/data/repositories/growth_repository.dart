import '../models/growth_event.dart';

/// 成长足迹数据访问接口。
///
/// 归属（Baseline §3.3 / IA §14）：
/// **「我的」→ 成长足迹 → Detail**。
///
/// ⚠️ 开放项 O2 已裁决（Phase 1 §三）：
/// 成长日历 / 成长时间线属于**成长足迹 Detail 内部**。
/// ❌ 不增加第四张 Card
/// ❌ 不增加一级导航
/// ❌ 不创建独立 Growth Calendar Page
///
/// Phase 1 只定义接口，**不实现成长业务逻辑**（Phase 1 §八明确禁止）。
abstract interface class GrowthRepository {
  /// 读取成长足迹列表。
  ///
  /// [type] 为 `null` 时返回全部类型。
  Future<List<GrowthEvent>> fetchEvents({GrowthEventType? type});

  /// 读取时间线（成长足迹 Detail 内的成长日历 / 时间线使用）。
  ///
  /// 注意：这**不是**为独立页面准备的接口，
  /// 它服务于「我的 → 成长足迹 → Detail」内部的局部展示。
  Future<List<GrowthEvent>> fetchTimeline({
    DateTime? from,
    DateTime? to,
  });
}
