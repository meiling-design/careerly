import 'package:flutter/foundation.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/repositories/auth_repository.dart';

/// 提交（注册 / 登录）的生命周期。
///
/// ⚠️ 这里**没有**复用 `AsyncStateNotifier<T>` —— 原因是它需要一个数据载荷
/// `T`，而注册与登录的返回都是 `void`。为了塞进泛型而编造一个 `Account` 模型
/// （返回假 id / 假昵称）会违反 `CLAUDE.md` §7「不编造产品数据」。
///
/// 四态映射（`CLAUDE.md` §5.5）：
///
/// | 枚举 | 页面表现 |
/// |---|---|
/// | [idle] | 表单可编辑，主按钮按页面的可用性规则决定是否可用 |
/// | [submitting] | 主按钮进入 Loading，表单禁用 |
/// | [success] | 跳转下一步 |
/// | [failure] | 展示 [OnboardingProvider.error]，可重试 |
enum OnboardingSubmitStatus { idle, submitting, success, failure }

/// Onboarding 账号页的提交状态。
///
/// 分层：`UI(OnboardingRegisterPage) → State(本类) → Repository(AuthRepository) → Mock`
///
/// ## 职责边界（刻意划窄）
///
/// 本类**只持有提交的生命周期状态**，**不持有表单字段值、也不持有页面形态** ——
/// ```text
/// 姓名 / 手机号 / 邮箱  →  视图状态，由页面的 TextEditingController 持有
/// 注册形态 / 登录形态    →  视图状态，由页面的 _mode 持有
/// ```
/// 把它们搬进来只会制造「controller / 页面 与 provider 谁是真相」的双写问题。
/// 形态只影响**页面渲染哪个表单**与**调用下面哪个方法**，
/// 两条链路的状态机是同一条。
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._repository);

  final AuthRepository _repository;

  OnboardingSubmitStatus _status = OnboardingSubmitStatus.idle;
  AppError? _error;

  /// 当前提交状态。
  OnboardingSubmitStatus get status => _status;

  /// 失败原因。仅在 [status] 为 [OnboardingSubmitStatus.failure] 时非空。
  AppError? get error => _error;

  /// 是否正在提交。UI 据此禁用表单与按钮。
  bool get isSubmitting => _status == OnboardingSubmitStatus.submitting;

  /// 是否提交成功。UI 据此跳转。
  bool get isSuccess => _status == OnboardingSubmitStatus.success;

  /// 提交注册。
  ///
  /// 返回 `true` 表示成功。失败时**不抛异常** ——
  /// 错误已归一化进 [error]，由 UI 渲染，符合四态要求。
  Future<bool> submit({
    required String name,
    required String phone,
    String? email,
  }) {
    return _run(
      () => _repository.register(
        name: name.trim(),
        phone: phone.trim(),
        email: (email == null || email.trim().isEmpty) ? null : email.trim(),
      ),
    );
  }

  /// 提交登录。
  ///
  /// 与 [submit] **同一条状态机** —— 四态、错误归一化、返回值语义都一致，
  /// 差别只有调用的仓库方法与入参（D85：登录是账号页的第二种形态）。
  Future<bool> login({required String phone}) {
    // 无密码 / 验证码：身份字段只有手机号，规则出自 D85，不是这里自拟的。
    return _run(() => _repository.login(phone: phone.trim()));
  }

  /// 回到可编辑状态（用于「重试」，以及**切换注册 / 登录形态**时清掉旧失败态）。
  void reset() => _set(OnboardingSubmitStatus.idle, null);

  /// 走完一次提交：`submitting → success | failure`。
  ///
  /// 两条链路共用，避免「注册修了、登录忘了」这类不对称。
  Future<bool> _run(Future<void> Function() action) async {
    _set(OnboardingSubmitStatus.submitting, null);

    try {
      await action();
    } catch (error, stackTrace) {
      // Repository 层自由抛异常，到这里统一归一化为 AppError。
      _set(OnboardingSubmitStatus.failure, ErrorHandler.normalize(error, stackTrace));
      return false;
    }

    _set(OnboardingSubmitStatus.success, null);
    return true;
  }

  void _set(OnboardingSubmitStatus status, AppError? error) {
    _status = status;
    _error = error;
    notifyListeners();
  }
}
