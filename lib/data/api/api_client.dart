import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/errors/app_error.dart';

/// Careerly 后端 HTTP 客户端。
///
/// ## 契约来源
///
/// 端点与 envelope 形状来自 `docs/careerly/BACKEND_API_CONTRACT.md`（后端仓库），
/// 统一响应封装：
///
/// ```json
/// {"success": true, "data": ..., "error": null, "meta": {...}}
/// {"success": false, "data": null, "error": {"code": "...", "message": "..."}, "meta": {...}}
/// ```
///
/// ## 会话（尊重 D52）
///
/// JWT 只保存在**内存**里（本类的字段）——不引入
/// shared_preferences / secure_storage。App 重启后需要重新登录，
/// 「已登录则跳过 Onboarding」仍是未决项 **D54**，本类不越权解决。
///
/// ## baseUrl 配置
///
/// ```bash
/// flutter run --dart-define=CAREERLY_USE_API=true \
///             --dart-define=CAREERLY_API_BASE_URL=http://10.0.2.2:8000
/// ```
///
/// 默认值 `http://10.0.2.2:8000` 是 **Android 模拟器访问宿主机** 的固定地址；
/// 真机联调时改成局域网 IP（如 `http://192.168.x.x:8000`）。
class ApiClient {
  ApiClient({String? baseUrl, http.Client? httpClient})
      : baseUrl = _normalizeBaseUrl(
          baseUrl ??
              const String.fromEnvironment(
                'CAREERLY_API_BASE_URL',
                defaultValue: 'http://10.0.2.2:8000',
              ),
        ),
        _http = httpClient ?? http.Client();

  /// `CAREERLY_USE_API` 的 dart-define 键名（providers.dart 使用）。
  static const String useApiDefineKey = 'CAREERLY_USE_API';

  /// `CAREERLY_API_BASE_URL` 的 dart-define 键名。
  static const String baseUrlDefineKey = 'CAREERLY_API_BASE_URL';

  /// 编译期传入的「接真实后端」开关；默认 false（保持 Mock First）。
  static const bool useApi = bool.fromEnvironment(useApiDefineKey);

  final String baseUrl;
  final http.Client _http;

  /// 常规请求超时。列表 / 额度 / 简历基线这类轻量端点。
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// 分析请求超时。后端为同步接口（决策 C2），
  /// 实测单次分析约 210s，留足余量。
  static const Duration analysisTimeout = Duration(seconds: 300);

  // ── 会话（内存态，见类注释「尊重 D52」） ──────────────────────────────

  String? _accessToken;
  String? _refreshToken;

  /// 当前是否持有访问令牌。
  bool get hasSession => _accessToken != null;

  /// 写入会话（register / login / refresh 成功后调用）。
  void setSession({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
  }

  /// 清除会话（401 不可恢复或登出时调用）。
  void clearSession() {
    _accessToken = null;
    _refreshToken = null;
  }

  // ── HTTP verbs ──────────────────────────────────────────────────────

  /// GET 并解 envelope，返回 `data`。
  Future<dynamic> get(String path, {Duration? timeout}) {
    return _send('GET', path, timeout: timeout ?? defaultTimeout);
  }

  /// POST（JSON body）并解 envelope，返回 `data`。
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      timeout: timeout ?? defaultTimeout,
    );
  }

  /// PUT（JSON body）并解 envelope，返回 `data`。
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) {
    return _send(
      'PUT',
      path,
      body: body,
      timeout: timeout ?? defaultTimeout,
    );
  }

  // ── 发送 + envelope 解包 + 错误归一化 ───────────────────────────────

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required Duration timeout,
    bool retriedAfterRefresh = false,
  }) async {
    final http.Response response = await _rawSend(method, path, body, timeout);

    Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } catch (e) {
      throw ParseError(
        detail: '响应不是合法 JSON envelope（HTTP ${response.statusCode}）',
        cause: e,
        source: 'api',
      );
    }

    if (envelope['success'] == true) {
      return envelope['data'];
    }

    // ── 失败分支 ──
    final AppError error = _mapError(envelope, response.statusCode);

    // 401 且持有 refresh token → 刷新一次并重试原请求（只重试一次，防死循环）。
    if (error is AuthError && !retriedAfterRefresh && _refreshToken != null) {
      final bool refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(
          method,
          path,
          body: body,
          timeout: timeout,
          retriedAfterRefresh: true,
        );
      }
    }
    throw error;
  }

  Future<http.Response> _rawSend(
    String method,
    String path,
    Map<String, dynamic>? body,
    Duration timeout,
  ) async {
    final Uri uri = Uri.parse('$baseUrl$path');
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };

    final Future<http.Response> future = switch (method) {
      'GET' => _http.get(uri, headers: headers),
      'POST' => _http.post(uri, headers: headers, body: jsonEncode(body)),
      'PUT' => _http.put(uri, headers: headers, body: jsonEncode(body)),
      _ => throw ArgumentError('unsupported method: $method'),
    };

    try {
      return await future.timeout(timeout);
    } on TimeoutException catch (e) {
      throw NetworkError(
        message: '请求超时，请检查网络后重试',
        detail: '$method $path 超过 ${timeout.inSeconds}s',
        cause: e,
      );
    } on SocketException catch (e) {
      throw NetworkError(
        message: '无法连接服务器，请检查网络与后端服务',
        detail: '$method $path: ${e.message}',
        cause: e,
      );
    } on http.ClientException catch (e) {
      throw NetworkError(detail: '$method $path: ${e.message}', cause: e);
    }
  }

  /// 尝试用 refresh token 换新令牌。失败则清除会话并返回 false。
  Future<bool> _tryRefresh() async {
    final String? token = _refreshToken;
    if (token == null) return false;
    try {
      final http.Response response = await _http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/refresh'),
            headers: const <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{'refresh_token': token}),
          )
          .timeout(defaultTimeout);
      final Map<String, dynamic> envelope =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (envelope['success'] == true) {
        final Map<String, dynamic> data =
            envelope['data'] as Map<String, dynamic>;
        setSession(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String?,
        );
        return true;
      }
    } catch (_) {
      // 刷新失败统一走下方清会话分支。
    }
    clearSession();
    return false;
  }

  /// 后端错误码 → AppError 分类（对应 app_error.dart 的错误表）。
  static AppError _mapError(Map<String, dynamic> envelope, int statusCode) {
    final Map<String, dynamic> error =
        (envelope['error'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final String code = error['code'] as String? ?? 'UNKNOWN';
    final String message = error['message'] as String? ?? '请求失败';

    // 额度耗尽（403 QUOTA_EXCEEDED，details 里带 quota 快照）。
    if (code == 'QUOTA_EXCEEDED') {
      final Map<String, dynamic>? details =
          error['details'] as Map<String, dynamic>?;
      final Map<String, dynamic>? quota =
          details?['quota'] as Map<String, dynamic>?;
      final int total = (quota?['total'] as num?)?.toInt() ?? 3;
      final int used = (quota?['used'] as num?)?.toInt() ?? total;
      return QuotaError(
        message: message,
        remaining: (total - used).clamp(0, total),
        detail: code,
      );
    }

    // 认证失败（401：token 失效 / 手机号未注册）。
    if (statusCode == 401) {
      return AuthError(message: message, detail: code);
    }

    // 输入 / 解析类（422：无简历基线、JD 为空、校验失败）。
    if (statusCode == 422 || code == 'VALIDATION_ERROR') {
      return ParseError(message: message, detail: code, source: 'api');
    }

    // AI 引擎失败（502 ANALYSIS_FAILED）或未产出（ANALYSIS_EMPTY 已由 422 覆盖）。
    if (statusCode >= 500 || code == 'ANALYSIS_FAILED') {
      return AIError(message: message, detail: code);
    }

    // 其余（404 等）——带状态码的网络错误，允许重试。
    return NetworkError(message: message, detail: code, statusCode: statusCode);
  }

  static String _normalizeBaseUrl(String raw) {
    final String trimmed = raw.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  /// 释放底层 http.Client（providers 的 dispose 调用）。
  void dispose() => _http.close();
}
