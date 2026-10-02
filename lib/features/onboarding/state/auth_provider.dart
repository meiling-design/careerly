import 'package:flutter/foundation.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/repositories/auth_repository.dart';

/// 退出登录的生命周期。
///
/// ⚠️ 与 `OnboardingSubmitStatus` **刻意不合并**：注册 / 登录是「进入 App」，
/// 退出是「离开 App」，两者的 UI 落点、导航目标、失败重试语义都不同
/// （`CLAUDE.md` §8.4：变体用参数，形态不同才拆）。
///
/// | 枚举 | 页面表现 |
/// |---|---|
/// | [idle] | 「退出登录」按钮可用 |
/// | [submitting] | 按钮禁用，避免重复触发 |
/// | [success] | 跳转登录页 |
/// | [failure] | 展示 [AuthProvider.error]，可重试 |
enum AuthLogoutStatus { idle, submitting, success, failure }

/// 会话级状态。
///
/// 分层：`UI(SettingsPage) → State(本类) → Repository(AuthRepository) → ApiClient`
///
/// ## 为什么现在才建它（`CLAUDE.md` §6.3）
///
/// `providers.dart` 此前写着「等到真的需要『当前用户是谁』时再建 AuthProvider，
/// 届时它才是死代码的反面」。在此之前 Flutter 侧**没有任何**结束会话的入口，
/// 建了就是空 Provider（§6.3 明令禁止）。退出登录是第一个真实用例，
/// 因此本类**只**承载退出这一件事，不预建 `currentUser` / `isLoggedIn` 等
/// 尚无数据源的字段。
///
/// ## 会话真相在哪
///
/// 令牌的持有者是 [ApiClient]（内存 + 安全存储），**不是本类** ——
/// 本类只表达「这次退出操作的状态」，避免制造第二个会话真相源。
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AuthLogoutStatus _status = AuthLogoutStatus.idle;
  AppError? _error;

  /// 当前退出状态。
  AuthLogoutStatus get status => _status;

  /// 失败原因。仅在 [status] 为 [AuthLogoutStatus.failure] 时非空。
  AppError? get error => _error;

  /// 是否正在退出。UI 据此禁用按钮。
  bool get isLoggingOut => _status == AuthLogoutStatus.submitting;

  /// 退出登录。返回 `true` 表示成功。
  ///
  /// 与 `OnboardingProvider` 同型：失败**不抛异常**，错误已归一化进 [error]，
  /// 由 UI 渲染（`CLAUDE.md` §5.5 四态）。
  Future<bool> logout() async {
    _set(AuthLogoutStatus.submitting, null);

    try {
      await _repository.logout();
    } catch (error, stackTrace) {
      _set(AuthLogoutStatus.failure, ErrorHandler.normalize(error, stackTrace));
      return false;
    }

    _set(AuthLogoutStatus.success, null);
    return true;
  }

  /// 回到可操作状态（用于失败后重试）。
  void reset() => _set(AuthLogoutStatus.idle, null);

  void _set(AuthLogoutStatus status, AppError? error) {
    _status = status;
    _error = error;
    notifyListeners();
  }
}
