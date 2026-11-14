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

/// 注销账号的生命周期（发布基线 K19）。
///
/// ## 为什么不复用 [AuthLogoutStatus]
///
/// 两者状态**形状**相同（提交 → 成功 / 失败），但共用一个字段会串台：
/// 「退出登录」成功后 `status == success`，紧接着打开注销页就会读到一个
/// 属于**上一次操作**的 success。形状相同不等于同一个状态 ——
/// `CLAUDE.md` §8.4 的「变体用参数」说的是**视觉变体**，
/// 而这里两个流程的**生命周期互相独立**，因此是两个字段。
///
/// 行为差异（也是它们不能被当成同一件事的原因）：
///
/// ```text
/// logout        结束本机会话      失败重试即可，账号无损
/// deleteAccount 销毁账号本身      不可逆；确认层必须更重
/// ```
enum AuthDeleteAccountStatus { idle, submitting, success, failure }

/// 保留账号的职业数据清理生命周期。
enum AuthDeleteCareerDataStatus { idle, submitting, success, failure }

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

  AuthDeleteAccountStatus _deleteStatus = AuthDeleteAccountStatus.idle;
  AppError? _deleteError;
  AuthDeleteCareerDataStatus _careerDataStatus =
      AuthDeleteCareerDataStatus.idle;
  AppError? _careerDataError;
  CareerDataDeletionResult? _careerDataResult;

  /// 当前退出状态。
  AuthLogoutStatus get status => _status;

  /// 失败原因。仅在 [status] 为 [AuthLogoutStatus.failure] 时非空。
  AppError? get error => _error;

  /// 是否正在退出。UI 据此禁用按钮。
  bool get isLoggingOut => _status == AuthLogoutStatus.submitting;

  /// 当前注销状态。
  AuthDeleteAccountStatus get deleteStatus => _deleteStatus;

  /// 注销失败原因。仅在 [deleteStatus] 为 [AuthDeleteAccountStatus.failure] 时非空。
  AppError? get deleteError => _deleteError;

  /// 是否正在注销。UI 据此禁用按钮（四态 Disabled）。
  bool get isDeletingAccount =>
      _deleteStatus == AuthDeleteAccountStatus.submitting;

  AuthDeleteCareerDataStatus get careerDataStatus => _careerDataStatus;
  AppError? get careerDataError => _careerDataError;
  CareerDataDeletionResult? get careerDataResult => _careerDataResult;
  bool get isDeletingCareerData =>
      _careerDataStatus == AuthDeleteCareerDataStatus.submitting;

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

  /// 注销账号。返回 `true` 表示后端已受理（账号进入注销状态）。
  ///
  /// ## ⚠️ 返回 `true` **不等于**数据已经被删除
  ///
  /// 后端是软删除：账号立刻不可登录、旧凭据立刻失效，
  /// 但数据在 30 天缓冲期后才被物理清除（`work_agent/app/core/account_purge.py`）。
  /// 页面据此如实告知，❌ 不得把 `true` 渲染成「数据已永久删除」。
  ///
  /// 成功后**必须由调用方导航回登录页** —— 本方法只负责状态，
  /// 不碰路由（与 [logout] 同处置：State 层不决定「回到哪」）。
  Future<bool> deleteAccount() async {
    _setDelete(AuthDeleteAccountStatus.submitting, null);

    try {
      await _repository.deleteAccount();
    } catch (error, stackTrace) {
      _setDelete(
        AuthDeleteAccountStatus.failure,
        ErrorHandler.normalize(error, stackTrace),
      );
      return false;
    }

    _setDelete(AuthDeleteAccountStatus.success, null);
    return true;
  }

  /// 清理职业数据但保留账号和当前会话。
  Future<bool> deleteCareerData() async {
    _setCareerData(AuthDeleteCareerDataStatus.submitting, null, null);

    try {
      final CareerDataDeletionResult result =
          await _repository.deleteCareerData();
      _setCareerData(AuthDeleteCareerDataStatus.success, null, result);
      return true;
    } catch (error, stackTrace) {
      _setCareerData(
        AuthDeleteCareerDataStatus.failure,
        ErrorHandler.normalize(error, stackTrace),
        null,
      );
      return false;
    }
  }

  /// 回到可操作状态（用于失败后重试）。
  void reset() => _set(AuthLogoutStatus.idle, null);

  /// 注销失败后回到可操作状态。与 [reset] 分开 —— 两者状态字段独立。
  void resetDeleteAccount() => _setDelete(AuthDeleteAccountStatus.idle, null);

  void resetDeleteCareerData() =>
      _setCareerData(AuthDeleteCareerDataStatus.idle, null, null);

  void _set(AuthLogoutStatus status, AppError? error) {
    _status = status;
    _error = error;
    notifyListeners();
  }

  void _setDelete(AuthDeleteAccountStatus status, AppError? error) {
    _deleteStatus = status;
    _deleteError = error;
    notifyListeners();
  }

  void _setCareerData(
    AuthDeleteCareerDataStatus status,
    AppError? error,
    CareerDataDeletionResult? result,
  ) {
    _careerDataStatus = status;
    _careerDataError = error;
    _careerDataResult = result;
    notifyListeners();
  }
}
