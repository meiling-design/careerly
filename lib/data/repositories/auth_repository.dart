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
}
