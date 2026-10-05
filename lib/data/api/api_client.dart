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
  ///
  /// ⚠️ 2026-10-03 实测：`qwen3.5-plus` 是**推理模型**，单份简历解析
  /// 端到端 **173–199s**（独立探针 199.2s）。原值 120s 恒短于后端真实
  /// 耗时 —— 客户端总是先超时，用户在上传页看到失败，而后端约 1 分钟后
  /// 才把 profile 写进 `careerly.db`，于是「上传了但没建立职业资产」。
  /// 提到与分析同档的 300s。
  static const Duration resumeParseTimeout = Duration(seconds: 300);

  /// 岗位链接抓取（`POST /api/v1/analysis/jobs/parse-url`）超时。
  ///
  /// 后端在**同一个请求内**跑爬虫，静态站秒级、SPA 站要起 Playwright
  /// 且逐个适配器试过去，比列表 / 额度慢得多；30s 默认值在慢站点上会
  /// 误报超时，而超时后重试等于再爬一次。取值与分析同理 ——
  /// Flutter 侧的实现选择，不是产品规则。
  static const Duration jobUrlParseTimeout = Duration(seconds: 90);

  /// AI 回答流（`POST /api/v1/ai/messages`）的**空闲超时**。
  ///
  /// 约束的是「两个事件之间」的间隔，**不是整条流的时长** —— 回答很长时
  /// 总时长可以远超它，只要服务端一直在吐字就不该被判超时。
  /// 取值需覆盖首字延迟（推理模型要先想再答），属 Flutter 侧实现选择，
  /// 不是产品规则。
  static const Duration aiStreamIdleTimeout = Duration(seconds: 60);

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

  /// DELETE 并解 envelope，返回 `data`。
  ///
  /// 目前只有一处用到：删除历史简历版本
  /// （`DELETE /api/v1/resume/versions/{id}`）。
  Future<dynamic> delete(String path, {Duration? timeout}) {
    return _send('DELETE', path, timeout: timeout ?? defaultTimeout);
  }

  /// POST 并**逐帧**解析 `text/event-stream`（AI 回答流专用）。
  ///
  /// ```text
  /// POST /api/v1/ai/messages
  ///   ↓  开流前失败（HTTP != 200）→ 普通 envelope → 抛 AppError
  ///   ↓  data: {"type":"start"}        → yield
  ///   ↓  data: {"type":"delta", ...}   → yield …（多次）
  ///   ↓  data: {"type":"done"}         → yield
  ///   ↓  data: {"type":"error", ...}   → 抛 AppError
  /// ```
  ///
  /// 与 [post] 最大的差别是**不解 envelope**：流一旦开始，HTTP 状态码就已经
  /// 发出去了，没法再改成 403 / 404 —— 错误因此分两处（见上），但本方法把
  /// 两处都归成抛出的 [AppError]，调用方只需一个 `try/catch`。
  ///
  /// ⚠️ 不做 401 刷新重试。流式请求重试意味着把整段回答重放一遍，
  /// 代价远高于普通请求；令牌失效请由调用方重新进入页面。
  Stream<Map<String, dynamic>> postSse(
    String path, {
    Map<String, dynamic>? body,
    Duration? timeout,
    Duration? idleTimeout,
  }) async* {
    final Uri uri = Uri.parse('$baseUrl$path');
    final http.Request request = http.Request('POST', uri)
      ..headers.addAll(<String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'text/event-stream',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      })
      ..body = jsonEncode(body ?? const <String, dynamic>{});

    final http.StreamedResponse response = await _openStream(
      request,
      timeout ?? defaultTimeout,
      'POST $path',
    );

    // 开流前失败：服务端还没写任何帧，状态码依然有效 → 仍走普通 envelope。
    if (response.statusCode != 200) {
      final String raw = await response.stream.bytesToString();
      throw _envelopeError(raw, response.statusCode);
    }

    final Duration idle = idleTimeout ?? aiStreamIdleTimeout;
    final Stream<String> lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .timeout(idle);

    try {
      await for (final String line in lines) {
        final Map<String, dynamic>? frame = _sseFrame(line);
        if (frame == null) continue;
        if (frame['type'] == 'error') {
          throw AIError(
            message: frame['message'] as String? ?? 'AI 回复中断，请重试',
            detail: frame['code'] as String? ?? 'AI_FAILED',
          );
        }
        yield frame;
      }
    } on TimeoutException catch (e) {
      throw NetworkError(
        message: 'AI 响应中断，请重试',
        detail: 'POST $path 事件间超过 ${idle.inSeconds}s 无数据',
        cause: e,
      );
    }
  }

  /// 解析一行 SSE；返回 `null` 表示这行不携带数据。
  ///
  /// 只处理 `data:` 单行 —— Careerly 的 AI 流每帧就是一个单行 JSON
  /// （`app/careerly/router.py::_sse`），`json.dumps` 会把换行转义掉，
  /// 因而不存在「一个事件跨多行 data」的情况。
  ///
  /// 非法 / 半截帧**跳过而不是中断**：一个坏帧不该让用户已经看到半句的
  /// 回答整个作废。
  static Map<String, dynamic>? _sseFrame(String line) {
    if (!line.startsWith('data:')) return null; // 空行（帧分隔）/ `:` 注释
    final String payload = line.substring(5).trim();
    if (payload.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// 把「开流前的失败响应」解成 [AppError]（与 [_send] 的失败分支同源）。
  static AppError _envelopeError(String raw, int statusCode) {
    try {
      return _mapError(jsonDecode(raw) as Map<String, dynamic>, statusCode);
    } catch (e) {
      return NetworkError(
        message: 'AI 服务返回了无法解析的响应',
        detail: 'HTTP $statusCode',
        statusCode: statusCode,
        cause: e,
      );
    }
  }

  /// 建立连接（拿到响应头即返回，响应体仍可继续流式读取）。
  ///
  /// 传输层异常在这里统一归一化成 [NetworkError]。
  Future<http.StreamedResponse> _openStream(
    http.BaseRequest request,
    Duration timeout,
    String label,
  ) async {
    try {
      return await _http.send(request).timeout(timeout);
    } on TimeoutException catch (e) {
      throw NetworkError(
        message: '请求超时，请检查网络后重试',
        detail: '$label 超过 ${timeout.inSeconds}s',
        cause: e,
      );
    } on SocketException catch (e) {
      throw NetworkError(
        message: '无法连接服务器，请检查网络与后端服务',
        detail: '$label: ${e.message}',
        cause: e,
      );
    } on http.ClientException catch (e) {
      throw NetworkError(detail: '$label: ${e.message}', cause: e);
    }
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

    // 额度耗尽（403，details 里带 quota 快照）。
    //
    // 两个额度池用的是不同错误码：分析额度 `QUOTA_EXCEEDED`、
    // AI 对话额度 `AI_QUOTA_EXCEEDED`（两者独立，见契约 §0.5.8）。
    // 客户端的处理是同一种 —— 展示剩余额度 + 升级入口，不可重试。
    if (code == 'QUOTA_EXCEEDED' || code == 'AI_QUOTA_EXCEEDED') {
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

    // 第三方登录不可用（`OAUTH_NOT_CONFIGURED` / `OAUTH_UNAVAILABLE` 501，
    // `OAUTH_PROVIDER_UNSUPPORTED` 404）。
    //
    // ⚠️ **必须放在下面那条 `statusCode >= 500` 之前**，否则 501 会被
    // 归成 [AIError]（「AI 引擎失败」）—— 而微信 / QQ 登录按钮失败与
    // AI 引擎毫无关系，用户会看到一句文不对题的提示。
    //
    // ⚠️ 也**刻意不归成 [AuthError]**：`ApiClient` 对 [AuthError] 有一条
    // 特殊处理（见下方 `error is AuthError && !retriedAfterRefresh` 那段）——
    // 它会尝试刷新令牌，刷新失败则 `clearSession()`。
    // 于是「用户点了一下还没开通的微信登录」会被升级成**强制退出登录**。
    // 这两条错误描述的是「服务端这个能力没有」，不是「你的凭据不对」，
    // 故取中性的 [NetworkError]（保留服务端原文 message，不触发任何重试分支）。
    if (code.startsWith('OAUTH_')) {
      return NetworkError(message: message, detail: code, statusCode: statusCode);
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
