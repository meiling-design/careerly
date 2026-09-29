import '../repositories/auth_repository.dart';
import 'api_client.dart';

/// 账号注册 / 登录的真实 API 实现（手机号身份，产品裁决 D85）。
///
/// 成功后把 JWT 写入 [ApiClient] 的**内存**会话（尊重 D52：不落盘）。
/// 接口返回 `void` —— 令牌是传输层的实现细节，调用方（State）不需要接触。
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    final dynamic data = await _client.post(
      '/api/v1/auth/register',
      body: <String, dynamic>{
        'phone': phone,
        'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );
    _storeTokens(data);
  }

  @override
  Future<void> login({required String phone}) async {
    final dynamic data = await _client.post(
      '/api/v1/auth/login',
      body: <String, dynamic>{'phone': phone},
    );
    _storeTokens(data);
  }

  void _storeTokens(dynamic data) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    _client.setSession(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String?,
    );
  }
}
