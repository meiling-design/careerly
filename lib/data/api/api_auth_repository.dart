import '../repositories/auth_repository.dart';
import 'api_client.dart';

/// 账号注册 / 登录的真实 API 实现（手机号 + 密码，2026-10-04 裁决）。
///
/// 成功后把 JWT 写入 [ApiClient] 会话 —— 内存 + 安全持久化（裁决 **D-B**），
/// 因此冷启动后 [ApiClient.restoreSession] 能恢复身份。
/// 接口返回 `void` —— 令牌是传输层的实现细节，调用方（State）不需要接触。
///
/// ⚠️ **密码只在这一次请求里出现** —— 它不进日志、不落任何本地存储。
/// 后端收到后立刻 bcrypt 哈希（`work_agent/app/core/passwords.py`），
/// 落库的是哈希；本层不做任何缓存，页面 dispose 时 controller 即被释放。
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<void> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final dynamic data = await _client.post(
      '/api/v1/auth/register',
      // ⚠️ 不传 `email`：新稿注册表单没有这个字段（接口文档「契约保留」一节）。
      body: <String, dynamic>{
        'phone': phone,
        'name': name,
        'password': password,
      },
    );
    await _storeTokens(data);
  }

  @override
  Future<void> login({required String phone, required String password}) async {
    final dynamic data = await _client.post(
      '/api/v1/auth/login',
      body: <String, dynamic>{'phone': phone, 'password': password},
    );
    await _storeTokens(data);
  }

  /// 第三方登录 —— **当前必然抛错，且这是刻意的**。
  ///
  /// 见 [AuthRepository.signInWithOAuth] 的说明：后端一律返回 501 +
  /// 可识别的错误码，本方法把它**原样抛出**，由页面如实展示。
  /// 这里**不做**任何「降级为成功」或静默吞掉的处理 ——
  /// 那会让「能力未上线」变成用户眼里的「点了没反应」。
  ///
  /// 请求体里的 `code` 是后端 `OAuthRequest` 的必填字段。
  /// 真实的换码流程（拿授权码去换 token）属 Roadmap P5 ——
  /// 在它落地前，这里传的是一个**占位值**：请求注定在服务端被
  /// `OAUTH_NOT_CONFIGURED` 挡下，不会有任何东西拿这个 `code` 去做事。
  @override
  Future<void> signInWithOAuth({required String provider}) async {
    await _client.post(
      '/api/v1/auth/oauth/$provider',
      body: const <String, dynamic>{'code': _placeholderAuthCode},
    );
  }

  /// 退出登录 = **客户端丢弃凭据**（后端无 logout 端点，见接口注释）。
  ///
  /// [ApiClient.clearSession] 同时清内存令牌与安全存储，
  /// 因此退出后冷启动 [ApiClient.restoreSession] 不会再恢复出身份。
  @override
  Future<void> logout() => _client.clearSession();

  /// [signInWithOAuth] 请求体里 `code` 的占位值。
  ///
  /// 后端 `OAuthRequest.code` 是必填（`min_length=1`），不给就是 422 ——
  /// 那会**掩盖**掉真正想暴露的 `OAUTH_NOT_CONFIGURED`（501）。
  /// 用这个明显的占位串而不是随机数，是为了让服务端日志里一眼能看出
  /// 「这是个还没接线的调用」，而不是像一次真实的授权码泄漏。
  static const String _placeholderAuthCode = 'not-implemented';

  Future<void> _storeTokens(dynamic data) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return _client.setSession(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String?,
    );
  }
}
