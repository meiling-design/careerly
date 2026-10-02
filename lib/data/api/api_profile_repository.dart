import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import 'api_client.dart';

/// 「我的」身份资料的真实 API 实现（P3-5a）。
///
/// 后端端点（P3-3 已落地，`app/careerly/router.py`）：
///
/// ```text
/// GET /api/v1/profile → UserProfile
/// ```
///
/// 契约要点（BACKEND_API_CONTRACT §2）：
/// * 数据来源 auth.db users 表（注册时填写的姓名 + 手机号）；
/// * `handle` 是**脱敏后**的手机号（`139****0002`），完整号码不下发。
class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._client);

  final ApiClient _client;

  @override
  Future<UserProfile> fetchUserProfile() async {
    final dynamic data = await _client.get('/api/v1/profile');
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }
}
