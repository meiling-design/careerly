import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show immutable;
import 'package:http/http.dart' as http;

import '../../core/errors/app_error.dart';
import 'token_store.dart';

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
/// ## 会话（裁决 **D-B**：安全持久化，D52 作废）
///
/// JWT 同时存在于**内存**（本类字段，请求时读取）与 **TokenStore**
/// （Android Keystore / iOS Keychain，冷启动后恢复）。
///
/// ```text
/// register / login  → setSession()    内存 + 落盘
/// App 冷启动        → restoreSession()  读盘 → 内存
/// 登出 / refresh 失效 → clearSession()   内存 + 删盘
/// ```
///
/// 为什么不再是纯内存：D52 下每次冷启动都是「新用户」，成长时间轴与
/// 「我的足迹」失去主体。详见 `token_store.dart` 的说明。
///
/// ⚠️ 「已登录则跳过 Onboarding 直接进首页」仍是未决项 **D54** ——
/// 本类只负责**恢复凭据**，不越权决定启动落在哪一屏。
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
  ApiClient({String? baseUrl, http.Client? httpClient, TokenStore? tokenStore})
      : baseUrl = _normalizeBaseUrl(
          baseUrl ??
              const String.fromEnvironment(
                'CAREERLY_API_BASE_URL',
                defaultValue: 'http://10.0.2.2:8000',
              ),
        ),
        _http = httpClient ?? http.Client(),
        // 默认内存：单测与「明确不持久化」的场景不受 D-B 影响。
        // 生产装配（main.dart）显式传入 SecureTokenStore。
        _tokenStore = tokenStore ?? InMemoryTokenStore();

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

  /// 简历资产提交（`POST /api/v1/resume`）超时。
  ///
  /// 后端在**同一个请求内同步**跑 ResumeAgent（LLM 抽取，图片还要 OCR），
  /// 比列表 / 额度这类端点慢得多；用 30s 默认值会误报超时。
  /// 与分析同理，这只是 Flutter 侧的实现取值，不是产品规则。
  static const Duration resumeParseTimeout = Duration(seconds: 120);

  // ── 会话（内存态 + 持久化，见类注释「裁决 D-B」） ────────────────────

  String? _accessToken;
  String? _refreshToken;
  final TokenStore _tokenStore;

  /// 当前是否持有访问令牌。
  bool get hasSession => _accessToken != null;

  /// 写入会话（register / login / refresh 成功后调用）。
  ///
  /// 异步：同时落盘到 TokenStore。调用方**必须** await，
  /// 否则冷启动恢复可能读到旧值。
  Future<void> setSession({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
    await _tokenStore.save(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// 清除会话（登出，或 401 且 refresh 失败时调用）。
  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    await _tokenStore.clear();
  }

  /// **冷启动恢复**：把已持久化的令牌读回内存。
  ///
  /// 返回 true 表示恢复成功（调用方可据此跳过登录）。
  /// 只恢复凭据、**不**决定启动落在哪一屏 —— 那是 D54。
  Future<bool> restoreSession() async {
    final Tokens? restored = await _tokenStore.read();
    if (restored == null || !restored.isValid) return false;
    _accessToken = restored.accessToken;
    _refreshToken = restored.refreshToken;
    return true;
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

  /// POST `multipart/form-data` 并解 envelope，返回 `data`。
  ///
  /// 简历资产入口（`POST /api/v1/resume`）用它上传文件 / 图片，
  /// 或用 [fields] 传粘贴的文本 —— 后端该端点只收 multipart。
  ///
  /// ⚠️ **不要手动设置 `Content-Type`** —— multipart 的 `boundary` 由
  /// `http.MultipartRequest` 生成，手写成 `application/json` 会让后端
  /// 解析不出任何字段。本方法刻意不碰该请求头。
  ///
  /// ⚠️ 传入的是 [HttpMultipartFile]（原始字节）而不是 `http.MultipartFile`
  /// —— 后者 `finalize()` 只能调用一次，而本类在 401 后会重试一次原请求。
  Future<dynamic> postMultipart(
    String path, {
    Map<String, String> fields = const <String, String>{},
    List<HttpMultipartFile> files = const <HttpMultipartFile>[],
    Duration? timeout,
  }) {
    return _send(
      'POST',
      path,
      multipartFields: fields,
      multipartFiles: files,
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
    Map<String, String>? multipartFields,
    List<HttpMultipartFile>? multipartFiles,
    required Duration timeout,
    bool retriedAfterRefresh = false,
  }) async {
    final http.Response response = await _rawSend(
      method,
      path,
      body,
      timeout,
      multipartFields: multipartFields,
      multipartFiles: multipartFiles,
    );

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
          multipartFields: multipartFields,
          multipartFiles: multipartFiles,
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
    Duration timeout, {
    Map<String, String>? multipartFields,
    List<HttpMultipartFile>? multipartFiles,
  }) async {
    final Uri uri = Uri.parse('$baseUrl$path');

    // 除 Content-Type 外的公共头（multipart 的 boundary 由请求体生成，
    // 不能手写 —— 见 postMultipart 的说明）。
    final Map<String, String> commonHeaders = <String, String>{
      'Accept': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };

    final Future<http.Response> future;
    if (multipartFields != null || multipartFiles != null) {
      final http.MultipartRequest request = http.MultipartRequest(method, uri)
        ..headers.addAll(commonHeaders)
        ..fields.addAll(multipartFields ?? const <String, String>{});
      for (final HttpMultipartFile file
          in multipartFiles ?? const <HttpMultipartFile>[]) {
        // 每次发送都重建 —— MultipartFile.finalize() 只能调用一次，
        // 复用同一个实例会在 401 重试时抛 StateError。
        request.files.add(
          http.MultipartFile.fromBytes(
            file.field,
            file.bytes,
            filename: file.filename,
          ),
        );
      }
      future = _http.send(request).then(http.Response.fromStream);
    } else {
      final Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        ...commonHeaders,
      };
      future = switch (method) {
        'GET' => _http.get(uri, headers: headers),
        'POST' => _http.post(uri, headers: headers, body: jsonEncode(body)),
        'PUT' => _http.put(uri, headers: headers, body: jsonEncode(body)),
        _ => throw ArgumentError('unsupported method: $method'),
      };
    }

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
        await setSession(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String?,
        );
        return true;
      }
    } catch (_) {
      // 刷新失败统一走下方清会话分支。
    }
    await clearSession();
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

/// `multipart/form-data` 上传的一份文件内容。
///
/// 只持有**原始字节**，不持有 `http.MultipartFile`：后者的 `finalize()`
/// 只能调用一次，而 [ApiClient] 在 401 后会重试一次原请求
/// —— 复用同一实例会在第二次发送时抛 `StateError`。
/// 每次发送时用这里的字节重建，重试因此是安全的。
@immutable
class HttpMultipartFile {
  const HttpMultipartFile({
    required this.field,
    required this.filename,
    required this.bytes,
  });

  /// 表单字段名（后端 `UploadFile` 参数名，如 `file`）。
  final String field;

  /// 传给后端的文件名（后端据此判断扩展名）。
  final String filename;

  /// 文件内容。
  final List<int> bytes;
}
