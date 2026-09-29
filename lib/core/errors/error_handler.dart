import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'app_error.dart';

/// 统一错误归一化与日志入口。
///
/// 目的：Repository / Data Source 层可以自由抛异常，
/// 但到达 State 层之前必须被归一化成 [AppError]——
/// 这样 UI 只需要处理有限的错误类型，不需要 `catch (e)` 之后猜。
abstract final class ErrorHandler {
  /// 把任意异常归一化为 [AppError]。
  static AppError normalize(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) return error;

    if (error is SocketException || error is HttpException) {
      return NetworkError(cause: error, stackTrace: stackTrace);
    }

    if (error is TimeoutException) {
      return NetworkError(
        message: '请求超时，请重试',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return ParseError(cause: error, stackTrace: stackTrace);
    }

    return UnknownError(cause: error, stackTrace: stackTrace);
  }

  /// 执行 [action]，把异常归一化为 [AppError] 后交由 [onError]。
  ///
  /// 返回 `null` 表示失败——State 层据此设置 Error 状态。
  static Future<T?> guard<T>(
    Future<T> Function() action, {
    void Function(AppError error)? onError,
  }) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      final AppError appError = normalize(error, stackTrace);
      _log(appError);
      onError?.call(appError);
      return null;
    }
  }

  /// 同步版本。
  static T? guardSync<T>(
    T Function() action, {
    void Function(AppError error)? onError,
  }) {
    try {
      return action();
    } catch (error, stackTrace) {
      final AppError appError = normalize(error, stackTrace);
      _log(appError);
      onError?.call(appError);
      return null;
    }
  }

  static void _log(AppError error) {
    if (kDebugMode) {
      debugPrint('[Careerly][Error] $error');
      if (error.stackTrace != null) {
        debugPrintStack(stackTrace: error.stackTrace);
      }
    }
    // Phase 1 不接入上报 SDK；后续在此接入 Crashlytics / Sentry 等。
  }
}
