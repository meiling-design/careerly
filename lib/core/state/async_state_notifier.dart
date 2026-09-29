import 'package:flutter/foundation.dart';

import '../errors/app_error.dart';
import '../errors/error_handler.dart';
import 'async_state.dart';

/// 所有 Careerly Provider 的基类。
///
/// 解决的问题：每个 feature 的 ChangeNotifier 都要重复
/// `isLoading / error / data` 三件套、重复 try/catch、重复 notifyListeners。
/// 这里一次性收敛，业务 Provider 只关心「取什么数据」。
///
/// 分层依据（Phase 1 §十六）：
/// `UI → State(本类) → Repository → Data Source (API | Local | Mock)`
///
/// 使用方式：
/// ```dart
/// class HomeProvider extends AsyncStateNotifier<HomeSummary> {
///   HomeProvider(this._repository);
///   final HomeRepository _repository;
///
///   Future<void> load() => execute(() => _repository.fetchSummary());
/// }
/// ```
abstract class AsyncStateNotifier<T> extends ChangeNotifier {
  AsyncState<T> _state = AsyncState<T>.initial();

  /// 当前状态。UI 通过 `context.watch<X>().state` 读取。
  AsyncState<T> get state => _state;

  /// 便捷读取。
  bool get isLoading => _state.isLoading;
  T? get data => _state.dataOrNull;
  AppError? get error => _state.errorOrNull;

  /// 执行一次异步任务，自动驱动 Loading → Success / Failure。
  ///
  /// [task] 抛出的任意异常都会被 [ErrorHandler] 归一化为 [AppError]，
  /// 业务 Provider 不需要写 try/catch。
  @protected
  Future<void> execute(Future<T> Function() task) async {
    _set(AsyncState<T>.loading());
    final T? result = await ErrorHandler.guard(task, onError: _setFailure);
    if (result == null) return;
    _set(AsyncState<T>.success(result));
  }

  /// 手动把状态推进到加载中（带进度），用于分析流程这类长任务。
  @protected
  void setLoading({double? progress, String? message}) {
    _set(AsyncState<T>.loading(progress: progress, message: message));
  }

  /// 手动设置成功值。
  @protected
  void setSuccess(T value) => _set(AsyncState<T>.success(value));

  /// 手动设置失败。
  @protected
  void setFailure(AppError error) => _set(AsyncState<T>.failure(error));

  /// 重置回初始状态。
  @protected
  void setInitial() => _set(AsyncState<T>.initial());

  void _setFailure(AppError error) => _set(AsyncState<T>.failure(error));

  void _set(AsyncState<T> next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
