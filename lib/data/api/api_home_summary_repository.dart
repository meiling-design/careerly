import '../models/home_summary.dart';
import '../repositories/home_repository.dart';
import 'api_client.dart';

/// 首页摘要的真实 API 实现（P3-5a）。
///
/// 后端端点（P3-2 已落地，`app/careerly/router.py`）：
///
/// ```text
/// GET /api/v1/home/summary → HomeSummary
/// ```
///
/// 契约要点（BACKEND_API_CONTRACT §2）：
/// * 建议（suggestions）来自最新分析的真实 Gap，后端不编造；
/// * `dailyContent` 无真实来源，后端下发 `null`；
/// * 首次分析前 `hasBaseline=false`、各列表为空 —— 首页应渲染引导态。
class ApiHomeSummaryRepository implements HomeRepository {
  ApiHomeSummaryRepository(this._client);

  final ApiClient _client;

  @override
  Future<HomeSummary> fetchSummary() async {
    final dynamic data = await _client.get('/api/v1/home/summary');
    return HomeSummary.fromJson(data as Map<String, dynamic>);
  }
}
