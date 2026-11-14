import '../repositories/auth_repository.dart';
import 'mock_config.dart';

/// [AuthRepository] 的 Mock 实现。
///
/// ## 行为
///
/// ```text
/// 正常：等待 MockConfig.latency（默认 600ms）→ 返回成功
/// 失败：MockConfig.failNext == true → 抛 NetworkError
/// ```
///
/// ## ⚠️ 为什么这里「返回成功」不算编造产品数据
///
/// `CLAUDE.md` §7 禁止 Mock 编造产品数据（如匹配度、假用户名）。
/// 注册与登录的返回值都是 **`void`** —— 没有任何被捏造的字段，
/// 只有「这次提交成功 / 失败」这一件事，而它**必须**有一个值，
/// 否则 UI 的 Loading / Disabled / Error 三态无法被走到。
///
/// ## ⚠️ 登录**不做**「密码是否正确 / 账号是否存在」的判断
///
/// 自 2026-10-04 起 [login] 有了 `password` 入参，但本层**仍然不校验**它 ——
/// Mock 里**没有账号表**，凭空返回「手机号或密码不正确」会造出一条
/// 没有出处（Figma / PRD / IA 均无）的产品规则，而且这条规则
/// 会在真实后端接上后**悄悄消失**（Mock 说错、真机说对）。
/// 因此两条链路在此处**行为完全相同**：
/// 等待一次延迟，然后按 [MockConfig.failNext] 决定成功或失败。
///
/// 想看真实的密码校验行为，请对 `ApiAuthRepository` 跑
/// `test/real_backend_integration_test.dart`（需真实后端）。
///
/// 会话本身**不在此处保存**（见 [AuthRepository] 的实现对照表）。
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({MockConfig? config})
    : _config = config ?? MockSettings.config;

  final MockConfig _config;

  @override
  Future<void> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    // 只模拟「一次网络往返」，不产生任何持久化副作用。
    //
    // ⚠️ 密码**刻意不参与**任何计算，也不写进任何输出 ——
    // 不要为了让 Mock「看起来更真」而把它存下来或打出来。
    await _config.simulate();
  }

  @override
  Future<void> login({required String phone, required String password}) async {
    // 同上 —— 注册 / 登录在 Mock 层的差别**只有入参**（见类文档）。
    await _config.simulate();
  }

  /// 重置密码 —— 与注册 / 登录同一条 Mock 语义：只模拟一次网络往返。
  ///
  /// ⚠️ Mock 层**没有账号表**，因此不判断「手机号是否存在」「新密码是否满足
  /// 规则」—— 那些是后端与真实数据的行为，编一套只会在接真实后端后消失。
  @override
  Future<void> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    await _config.simulate();
  }

  /// 第三方登录 —— Mock 层**同样如实失败**。
  ///
  /// 这里有一个真实的风险：Mock 模式下一按微信就成功，会让
  /// 「社交登录已经能用」变成一个**只有 Mock 才存在的假象**。
  /// 因此 Mock 也照抛同一个语义的错误，与后端 501 行为对齐。
  ///
  /// ⚠️ 抛的是 `UnimplementedError` 这种原始异常而不是 `ApiError` 家族 ——
  /// 因为「未配置」这条错误**只有真实后端能给出**（它需要读环境变量）。
  /// 在 Mock 里编一个 `AppError` 会让错误归一化路径看起来已经验证过，
  /// 而实际上验证的是编造的那条。页面把它显示成通用失败即可。
  @override
  Future<void> signInWithOAuth({required String provider}) async {
    await _config.simulate();
    throw UnimplementedError(
      '第三方登录（$provider）未实现：Mock 模式下不模拟成功。'
      '真实行为见后端 POST /api/v1/auth/oauth/{provider}（未配置时 501）。',
    );
  }

  @override
  Future<void> logout() async {
    // Mock 层**没有会话可清**（令牌是传输层的实现细节，见 AuthRepository 的实现对照表）。
    // 只模拟「一次网络往返」，让 UI 的 Loading / Error 两态仍可被走到。
    await _config.simulate();
  }

  /// 只模拟职业数据清理，不产生持久化副作用。
  @override
  Future<CareerDataDeletionResult> deleteCareerData() async {
    await _config.simulate();
    return const CareerDataDeletionResult(
      deletedRows: 0,
      deletedFiles: 0,
      orphanArtifacts: 0,
      warnings: <String>[],
    );
  }

  /// 注销账号 —— Mock 层同样只模拟一次网络往返。
  ///
  /// ⚠️ 这里有一个**只有 Mock 才存在**的假象需要点明：真实实现会调后端
  /// 软删除并吊销令牌，Mock 层没有账号也没有会话，因此**什么都没发生**。
  /// 页面在 Mock 下走完流程会回到登录页，看起来「注销成功了」——
  /// 那只是 UI 流程通了，不代表删除能力已验证。
  ///
  /// 真实删除行为的验证在：
  /// ```text
  /// 后端   work_agent/tests/test_release_security_baseline.py
  ///        （注销后 access / refresh 立即失效、无法重新登录）
  /// 级联   work_agent/tests/test_account_purge.py
  ///        （数据一间不留，且不误删别人的）
  /// ```
  @override
  Future<void> deleteAccount() async {
    await _config.simulate();
  }
}
