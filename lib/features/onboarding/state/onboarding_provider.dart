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

/// 注册页 / 登录页的提交状态。
///
/// 分层：`UI(OnboardingRegisterPage | OnboardingLoginPage)
///        → State(本类) → Repository(AuthRepository) → Mock | API`
///
/// ## 为什么登录页**复用它**而不是新建 `LoginProvider`
///
/// 两条链路的状态机**完全相同**：四态、错误归一化、`Future<bool>` 返回值、
/// `reset()` 语义 —— 差别只有调用的仓库方法与入参。
/// 新建一个类只会得到两个同构的 `ChangeNotifier`，
/// 正是 `CLAUDE.md` §6.3「不预建空 Provider」要避免的那类重复。
///
/// ⚠️ 代价是**同一次会话里只能有一条链路在跑** —— 因为两页不会同时存在
/// （各自的 `initState` 都会 `reset()`，且路由上互斥），所以这不是问题。
///
/// ## 职责边界（刻意划窄）
///
/// 本类**只持有提交的生命周期状态**，**不持有表单字段值** ——
/// ```text
/// 名字 / 手机号 / 密码 / 记住我   →  视图状态，由页面的 controller 与 bool 持有
/// ```
/// 把它们搬进来只会制造「controller / 页面 与 provider 谁是真相」的双写问题。
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
  /// [password] 为必填 —— 新稿的注册表单有三个必填项（名字 / 手机号 / 密码），
  /// 密码不再是「选填」。**密码不做 `trim()`**：首尾空格是密码的一部分，
  /// 剪掉会让用户的密码与他自己以为的不一致（只有名字需要 trim）。
  ///
  /// 返回 `true` 表示成功。失败时**不抛异常** ——
  /// 错误已归一化进 [error]，由 UI 渲染，符合四态要求。
  Future<bool> submit({
    required String name,
    required String phone,
    required String password,
  }) {
    return _run(
      () => _repository.register(
        name: name.trim(),
        phone: phone.trim(),
        password: password,
      ),
    );
  }

  /// 提交登录。
  ///
  /// 与 [submit] **同一条状态机** —— 四态、错误归一化、返回值语义都一致。
  Future<bool> login({required String phone, required String password}) {
    return _run(
      () => _repository.login(phone: phone.trim(), password: password),
    );
  }

  /// 第三方登录（微信 / QQ）。
  ///
  /// 与上面两个**同样走 `_run`**，因此失败会落进同一条错误展示路径 ——
  /// 这正是「可配置契约」要求的**可见行为**：后端返回的
  /// 「微信登录尚未配置，请使用手机号注册或登录」会如实出现在页面上。
  ///
  /// ⚠️ 成功后**不代表已登录** —— 后端目前一律 501，成功分支是为将来的
  /// 真实换码流程预留的（届时它同样会写入会话，无需改这里）。
  Future<bool> signInWithOAuth({required String provider}) {
    return _run(() => _repository.signInWithOAuth(provider: provider));
  }

  /// 回到可编辑状态（用于「重试」，以及页面进入时清掉上一次的失败态）。
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
