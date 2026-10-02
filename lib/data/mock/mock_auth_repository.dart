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
/// ## ⚠️ 登录**不做**「账号是否存在」的判断
///
/// [login] 只有一个入参（手机号），本层**无从判断**凭据是否正确 ——
/// 凭空返回「账号不存在」会造出一条没有出处（Figma / PRD / IA 均无）
/// 的产品规则。因此两条链路在此处**行为完全相同**：
/// 等待一次延迟，然后按 [MockConfig.failNext] 决定成功或失败。
///
/// 会话本身**不在此处保存**（见 [AuthRepository] 的范围说明）。
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({MockConfig? config})
    : _config = config ?? MockSettings.config;

  final MockConfig _config;

  @override
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    // 只模拟「一次网络往返」，不产生任何持久化副作用。
    await _config.simulate();
  }

  @override
  Future<void> login({required String phone}) async {
    // 同上 —— 注册 / 登录在 Mock 层的差别**只有入参**。
    await _config.simulate();
  }

  @override
  Future<void> logout() async {
    // Mock 层**没有会话可清**（令牌是传输层的实现细节，见 AuthRepository 的范围说明）。
    // 只模拟「一次网络往返」，让 UI 的 Loading / Error 两态仍可被走到。
    await _config.simulate();
  }
}
