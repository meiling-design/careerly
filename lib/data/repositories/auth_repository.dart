/// 账号注册 / 登录的数据访问接口。
///
/// 归属：Onboarding（Baseline §4.1 流程第 2 步「注册 / 登录」）。
///
/// ## 两个实现
///
/// | 实现 | 何时生效 | 会做什么 |
/// |---|---|---|
/// | `MockAuthRepository` | 默认（Mock First） | 只模拟一次网络往返，无任何持久化副作用 |
/// | `ApiAuthRepository` | `--dart-define=CAREERLY_REAL_BACKEND=true` | 打真实端点，成功后把 JWT 写进 `ApiClient` 会话 |
/// |  |  | （内存 + `SecureTokenStore`，裁决 **D-B**） |
///
/// ⚠️ **本段曾是「纯 Mock，不接真实鉴权（D52）」** —— 那在
/// `ApiAuthRepository` 落地后就不再成立（注释漂移）。
/// 现在令牌**确实**会被持久化，`ApiClient.restoreSession` 冷启动能恢复身份；
/// 但「已登录则跳过 Onboarding」这条**产品规则**仍未裁决
/// （**D54**，`docs/05_progress/TODO.md` §3.1）—— 路由入口不读会话，
/// 所以能力有了、规则还没有。两件事不要混为一谈。
///
/// ## 字段集（2026-10-04 重新裁决）
///
/// ```text
/// register  名字（必填）· 手机号（必填）· 密码（必填）
/// login     手机号（必填）· 密码（必填）
/// ```
///
/// 这**推翻了 2026-09-21 的 D85**（「身份 = 手机号，无密码」）——
/// 依据是重新导出的 Figma：`OnRegister`（`src/App.tsx` L661-797）
/// 把密码放进了注册表单，`OnLogin`（L455-623）则是一个**独立的登录屏**。
/// 后端同步改造为 bcrypt 校验（`work_agent/app/core/passwords.py`）。
///
/// ### ⚠️ `email` 从接口移除了
///
/// 旧注册表单有「邮箱（选填）」，新稿**没有**这个字段 ——
/// 因此它从本接口、页面、Mock 与 API 实现里一并删除。
/// 后端 `RegisterRequest.email` **仍然保留**（选填，契约不破坏），
/// 只是客户端不再传 —— 这是**契约保留**而不是遗漏。
///
/// ## 为什么是两个方法（`register` / `login`）
///
/// 两条链路的状态机完全相同（都是「提交一次 → 成功 / 失败」），
/// 但请求体与后端端点不同，因此是两个方法而不是一个带开关的方法。
///
/// ## ⚠️ `signInWithOAuth` 是**接缝**，不是能力
///
/// 见该方法的文档。
abstract interface class AuthRepository {
  /// 提交注册信息。
  ///
  /// [name] / [phone] / [password] 均为必填。
  /// 失败时**抛异常**（由 State 层归一化为 `AppError`），不返回错误码。
  Future<void> register({
    required String name,
    required String phone,
    required String password,
  });

  /// 提交登录。
  ///
  /// [password] 端到端真实校验（表端是 bcrypt 哈希）。
  /// 密码错误 → 401 → `INVALID_CREDENTIALS`（不是 422，见后端
  /// `LoginRequest` 的说明：短密码也走「密码不对」）。
  ///
  /// 返回 `void`，语义与 [register] 相同：只有「这次提交成功 / 失败」，
  /// 没有可编造的返回数据（`CLAUDE.md` §7）。
  Future<void> login({required String phone, required String password});

  /// 重置密码 —— 「忘记密码?」链路（2026-11-13 产品侧要求补齐）。
  ///
  /// ## ⚠️ 当前是 **DEV-only** 能力，不是正式找回通道
  ///
  /// 后端 `POST /api/v1/auth/reset-password` 只在 `AUTH_MODE=dev` 时开放；
  /// 正式形态返回 `501 PASSWORD_RESET_UNAVAILABLE`。原因：
  ///
  /// ```text
  /// 密码是 bcrypt 哈希，无法「找回」，只能重置；
  /// DEV 模式下手机号本身就是可直登的凭据，因此不额外降低安全性；
  /// 正式找回需要短信 / 邮箱验证码，属 P5 的独立通道。
  /// ```
  ///
  /// 成功后后端会**吊销全部旧令牌**（token_version + 1），
  /// 其他设备上的会话立即失效。
  ///
  /// 失败时抛异常（与 [register] / [login] 一致），由 State 层归一化为
  /// `AppError`，页面如实展示后端错误码对应的文案。
  Future<void> resetPassword({
    required String phone,
    required String newPassword,
  });

  /// 第三方登录（微信 / QQ）。
  ///
  /// ## ⚠️ **当前必然失败**，而且这是**刻意的**
  ///
  /// 项目**没有任何第三方开放平台的凭据**，也没有对应的 SDK 接入。
  /// 2026-10-04 产品侧裁决：
  ///
  /// ```text
  /// 先建可配置的契约，未配置时明确报错 ——
  /// 而不是让按钮静默失败、更不是假装登录成功。
  /// ```
  ///
  /// 因此本方法**真实调用**后端 `POST /api/v1/auth/oauth/{provider}`，
  /// 后端在两种情况下都返回 501（只是原因不同）：
  ///
  /// ```text
  /// 环境变量没配   OAUTH_NOT_CONFIGURED     501
  /// 配了但未实现   OAUTH_UNAVAILABLE        501  ← 换码流程属 Roadmap P5
  /// 渠道不认识     OAUTH_PROVIDER_UNSUPPORTED 404
  /// ```
  ///
  /// 调用方（页面）必须把这条错误**如实展示**给用户 ——
  /// 这正是「可配置契约」的意义：能力没上线这件事是**可被客户端识别的**，
  /// 而不是一个说不清的失败。
  ///
  /// [provider] 取 `'wechat'` / `'qq'`（后端白名单）。
  Future<void> signInWithOAuth({required String provider});

  /// 退出登录：结束当前会话。
  ///
  /// ## ⚠️ 为什么是 `void` 而不是「调用一个 logout 端点」
  ///
  /// 后端**没有 logout 端点** —— 令牌是无状态 JWT，且服务端**没有吊销表**
  /// （`app/core/security.py` 明确记为缺口）。因此「退出」只能表达为
  /// **客户端丢弃凭据**：清掉内存令牌 + 安全存储，使本机不再持有身份。
  ///
  /// 这**不是**绕过后端，而是当前认证模型的真实边界：
  /// 被丢弃的 refresh token 在有效期内仍可被重放，属已知限制，
  /// 与「正式认证通道（OTP）」一并归后端 P5，不在本层假装解决。
  ///
  /// 返回 `void`，语义同 [register]：只有「退出成功 / 失败」。
  Future<void> logout();

  /// 删除当前账号的职业数据，保留账号与登录会话。
  ///
  /// 后端清理简历、版本、JD、分析结果、匹配记录、能力快照、成长记录、
  /// 相关引擎 session 及可归属文件。返回结果包含清理数量和未能清除的提示；
  /// 此动作不清除 token、不退出登录。
  Future<CareerDataDeletionResult> deleteCareerData();

  /// 注销账号 —— **删除账号本身，不只是结束会话**。
  ///
  /// ## 与 [logout] 的区别（这两件事不能混）
  ///
  /// ```text
  /// logout        结束本机会话。账号还在，换个设备/重登还能进来。
  /// deleteAccount 账号进入注销状态。旧凭据全部失效，无法再登录。
  /// ```
  ///
  /// 后端是**软删除**（`status='deleted'` + 吊销全部令牌），
  /// 数据在 30 天缓冲期后由离线任务物理清除 —— 缓冲期内误删可恢复。
  /// 响应里的 `purge_after_days` 表达了这一点，页面据此如实告知用户，
  /// ❌ **不得**把它写成「立即永久删除」（那是另一个事实）。
  ///
  /// ## 调用方必须做的两件事
  ///
  /// 1. 成功后**清本地凭据** —— 后端已吊销，但本机若还留着 token，
  ///    下次冷启动 `restoreSession` 会恢复出一个**已失效的身份**，
  ///    用户会看到一个「登录着但什么都打不开」的界面。本层（API 实现）
  ///    已清；State 层仍需回到未登录状态，见设置页的调用点。
  /// 2. 强确认。这是**不可逆**操作（缓冲期内可由运营恢复，但用户无法自助恢复），
  ///    不得做成单击即生效。
  ///
  /// 返回 `void`，语义同 [register]：只有「这次注销成功 / 失败」。
  Future<void> deleteAccount();
}

/// 后端职业数据清理结果。
class CareerDataDeletionResult {
  const CareerDataDeletionResult({
    required this.deletedRows,
    required this.deletedFiles,
    required this.orphanArtifacts,
    required this.warnings,
  });

  final int deletedRows;
  final int deletedFiles;
  final int orphanArtifacts;
  final List<String> warnings;

  bool get complete => orphanArtifacts == 0 && warnings.isEmpty;

  factory CareerDataDeletionResult.fromJson(Map<String, dynamic> json) {
    final Object? rows = json['deleted_rows'];
    final Object? files = json['deleted_files'];
    final Object? orphanArtifacts = json['orphan_artifacts'];
    final Object? rawWarnings = json['warnings'];
    if (rows is! int ||
        files is! int ||
        orphanArtifacts is! int ||
        rawWarnings is! List<dynamic> ||
        rawWarnings.any((Object? warning) => warning is! String)) {
      throw const FormatException('Invalid career data deletion response');
    }
    return CareerDataDeletionResult(
      deletedRows: rows,
      deletedFiles: files,
      orphanArtifacts: orphanArtifacts,
      warnings: List<String>.unmodifiable(rawWarnings.cast<String>()),
    );
  }
}
