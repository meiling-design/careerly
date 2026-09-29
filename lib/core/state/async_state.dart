import 'package:flutter/foundation.dart';

import '../errors/app_error.dart';

/// Careerly 的通用异步状态。
///
/// 依据 Phase 1 §十九：架构必须能够支持
/// **Loading / Success / Empty / Error** 四种状态。
///
/// PRD §15 与 IA §18 进一步要求：
/// 核心页面必须支持 Empty / Loading / Progress / Success / Error / Disabled。
/// 其中 `Progress` 在本模型里是 [AsyncLoading] 的一种表现（带进度值），
/// `Disabled` 由额度状态推导，不在此层。
///
/// Empty 被建模为 **Success 的一个子情况**（`data` 为空集合），
/// 而不是独立状态——因为「空」永远是某个成功请求的结果，
/// 把它独立出去会让每个 Provider 都要多写一个分支。
/// UI 层通过 [AsyncStateView] 判断 `isEmpty` 决定渲染 Empty State。
@immutable
sealed class AsyncState<T> {
  const AsyncState();

  /// 尚未发起请求。
  const factory AsyncState.initial() = AsyncInitial<T>;

  /// 加载中。[progress] 为 0–1 时表示确定性进度（分析流程），
  /// 为 `null` 时表示不确定进度（转圈）。
  const factory AsyncState.loading({double? progress, String? message}) =
      AsyncLoading<T>;

  /// 成功。[data] 可能为空，由 UI 决定是否渲染 Empty State。
  const factory AsyncState.success(T data) = AsyncSuccess<T>;

  /// 失败。
  const factory AsyncState.failure(AppError error) = AsyncFailure<T>;

  /// 是否处于加载中。
  bool get isLoading => this is AsyncLoading<T>;

  /// 是否已成功（含空数据）。
  bool get isSuccess => this is AsyncSuccess<T>;

  /// 是否失败。
  bool get isFailure => this is AsyncFailure<T>;

  /// 是否尚未发起请求。
  bool get isInitial => this is AsyncInitial<T>;

  /// 成功时的数据，否则 `null`。
  T? get dataOrNull => switch (this) {
    AsyncSuccess<T>(:final T data) => data,
    _ => null,
  };

  /// 失败时的错误，否则 `null`。
  AppError? get errorOrNull => switch (this) {
    AsyncFailure<T>(:final AppError error) => error,
    _ => null,
  };

  /// 用 [mapper] 转换成功值，其余状态原样透传。
  AsyncState<R> map<R>(R Function(T data) mapper) => switch (this) {
    AsyncSuccess<T>(:final T data) => AsyncSuccess<R>(mapper(data)),
    AsyncLoading<T>(:final double? progress, :final String? message) =>
      AsyncLoading<R>(progress: progress, message: message),
    AsyncFailure<T>(:final AppError error) => AsyncFailure<R>(error),
    AsyncInitial<T>() => AsyncInitial<R>(),
  };
}

/// 尚未发起请求。
final class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();
}

/// 加载中。
final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading({this.progress, this.message});

  /// 0–1 的确定性进度；`null` 表示不确定进度。
  final double? progress;

  /// 加载文案（例如分析流程的阶段名）。
  final String? message;
}

/// 成功。
final class AsyncSuccess<T> extends AsyncState<T> {
  const AsyncSuccess(this.data);

  final T data;
}

/// 失败。
final class AsyncFailure<T> extends AsyncState<T> {
  const AsyncFailure(this.error);

  final AppError error;
}
