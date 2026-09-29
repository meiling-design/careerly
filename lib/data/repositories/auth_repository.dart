/// 账号注册 / 登录的数据访问接口。
///
/// 归属：Onboarding（Baseline §4.1 流程第 2 步「注册 / 登录」）。
///
/// ## ⚠️ 范围：纯 Mock，不接真实鉴权（D52）
///
/// ```text
/// ✅ 只做：把表单提交这一步走通「UI → State → Repository → Mock」链路
/// ❌ 不接真实鉴权服务
/// ❌ 不引入本地存储依赖（不写 shared_preferences / secure_storage）
/// ❌ 不保存会话 —— 因此「已登录则跳过 Onboarding」这件事**现在无法表达**
/// ```
///
/// 最后一条不是遗漏，是**产品决策的未决项**：
/// 「App 启动进入 Onboarding 还是首页」依赖会话持久化，
/// 本轮 Mock 范围外，已登记 **待裁决 · D54**（`docs/05_progress/TODO.md` §3.1）。
///
/// ## 为什么是两个方法（`register` / `login`）
///
/// 2026-09-21 产品侧裁决 **D85**：登录**不是**独立页面，
/// 而是账号页（[AppRoutes.onboardingRegister]）的**第二种形态**。
/// 因此本接口补齐 `login` —— 页面形态变了，**数据访问的口子跟着开**，
/// 而不是预建「以后可能用到」的方法（`CLAUDE.md` §6.5）。
///
/// ```text
/// register  姓名（必填）· 手机号（必填）· 邮箱（选填）
/// login     手机号（必填）—— 字段集为 D85 的产品裁决，非 Flutter 侧自拟
/// ```
///
/// ## ⚠️ 两条链路共用同一个身份字段（手机号）
///
/// 登录**没有**密码 / 验证码字段 —— Figma 无登录屏，PRD / IA 也没有定义凭据形态，
/// 因此 D85 取**最小**规则：身份 = 手机号。
/// 未来若产品侧要求密码或验证码，改的是这一层 + 账号页，不是调用方。
abstract interface class AuthRepository {
  /// 提交注册信息。
  ///
  /// [name] 与 [phone] 为必填，[email] 选填。
  /// 失败时**抛异常**（由 State 层归一化为 `AppError`），不返回错误码。
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  });

  /// 提交登录。
  ///
  /// ⚠️ **不校验任何凭据** —— 本层只有手机号一个入参，
  /// Mock 实现只模拟「一次网络往返」，不判断账号是否存在
  /// （那么做会凭空造出「账号不存在」这个产品规则）。
  ///
  /// 返回 `void`，语义与 [register] 相同：只有「这次提交成功 / 失败」，
  /// 没有可编造的返回数据（`CLAUDE.md` §7）。
  Future<void> login({required String phone});
}
