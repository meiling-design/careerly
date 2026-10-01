import '../models/growth_event.dart';
import '../repositories/growth_repository.dart';
import 'api_client.dart';

/// 成长足迹的真实 API 实现（P2-5）。
///
/// 后端端点（P2-4 已落地，`app/careerly/router.py`）：
///
/// ```text
/// GET /api/v1/growth/events?type=&limit=   → [GrowthEvent]
/// GET /api/v1/growth/timeline?from=&to=    → [GrowthEvent]
/// ```
///
/// 契约要点（BACKEND_API_CONTRACT §2.8）：
/// * `type` 是 **Dart enum 的 `.name`**（experience/skill/capability/
///   matchScore/rank），后端原样下发、绝不翻中文 —— `GrowthEventType.tryParse`
///   直接可解；
/// * 事件由后端「相邻能力快照 diff」派生，本仓储**只做查询**，不在本地
///   合成或过滤事件（避免与后端派生口径分叉）。
class ApiGrowthRepository implements GrowthRepository {
  ApiGrowthRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<GrowthEvent>> fetchEvents({GrowthEventType? type}) async {
    final String path = type == null
        ? '/api/v1/growth/events'
        : '/api/v1/growth/events?type=${type.name}';
    return _fetchList(path);
  }

  @override
  Future<List<GrowthEvent>> fetchTimeline({DateTime? from, DateTime? to}) async {
    final List<String> query = <String>[
      if (from != null) 'from=${Uri.encodeQueryComponent(from.toIso8601String())}',
      if (to != null) 'to=${Uri.encodeQueryComponent(to.toIso8601String())}',
    ];
    final String path = query.isEmpty
        ? '/api/v1/growth/timeline'
        : '/api/v1/growth/timeline?${query.join('&')}';
    return _fetchList(path);
  }

  Future<List<GrowthEvent>> _fetchList(String path) async {
    final dynamic data = await _client.get(path);
    if (data is! List) return const <GrowthEvent>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(GrowthEvent.fromJson)
        .toList(growable: false);
  }
}
