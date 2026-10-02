import '../models/career_assets.dart';
import '../repositories/career_assets_repository.dart';
import 'api_client.dart';

/// 职业资产的真实 API 实现（P3-5a）。
///
/// 后端端点（P3-1 已落地，`app/careerly/router.py`）：
///
/// ```text
/// GET /api/v1/career/assets → CareerAssets
/// ```
///
/// 契约要点（BACKEND_API_CONTRACT §2）：
/// * 数据由后端从「简历基线 + 最新分析快照」派生 —— 本仓储**只做查询**；
/// * 无数据（尚未分析）时后端返回空数组，本端解析为
///   [CareerAssets] 的空集合形态，与「没有资产是合法状态」一致；
/// * 计数类字段（workCount 等）由 App 从列表派生，后端不下发。
class ApiCareerAssetsRepository implements CareerAssetsRepository {
  ApiCareerAssetsRepository(this._client);

  final ApiClient _client;

  @override
  Future<CareerAssets> fetchAssets() async {
    final dynamic data = await _client.get('/api/v1/career/assets');
    return CareerAssets.fromJson(data as Map<String, dynamic>);
  }
}
