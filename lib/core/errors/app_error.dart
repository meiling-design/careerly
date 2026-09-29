import 'package:flutter/foundation.dart';

/// Careerly 统一错误类型。
///
/// 依据 Phase 1 §十九，架构必须能够支持 Loading / Success / Empty / Error 四种状态，
/// 且 Error 必须是**可分类**的——因为不同错误对应不同的用户动作：
///
/// | 错误类型 | 典型来源 | 用户可做的动作 |
/// |---|---|---|
/// | [NetworkError] | 无网络、超时、5xx | 重试 |
/// | [ParseError] | 简历解析失败、JD 解析失败 | 重新上传 / 重新粘贴 |
/// | [AIError] | LLM 调用失败、额度耗尽 | 重试 / 升级会员 |
/// | [QuotaError] | 免费分析次数用尽 | 升级会员 |
/// | [AuthError] | 未登录、登录态过期 | 重新登录 |
/// | [UnknownError] | 未归类的异常 | 重试 |
///
/// 硬规则（PRD §15）：分析失败必须显示失败原因并提供重试；
/// JD 解析失败必须提示重新粘贴，且**不计入分析次数**。
@immutable
sealed class AppError implements Exception {
  const AppError({
    required this.message,
    this.detail,
    this.cause,
    this.stackTrace,
    this.isRetryable = true,
  });

  /// 面向用户的可读文案（中文）。UI 直接展示这一条。
  final String message;

  /// 面向上层/日志的技术细节，不直接展示给用户。
  final String? detail;

  /// 原始异常。
  final Object? cause;

  final StackTrace? stackTrace;

  /// 该错误是否允许用户重试。
  final bool isRetryable;

  /// 错误类型标识，用于日志与上报。
  String get type;

  /// 由任意异常构造合适的 [AppError]。
  static AppError from(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) return error;
    return UnknownError(cause: error, stackTrace: stackTrace);
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('$type: $message');
    if (detail != null) buffer.write(' ($detail)');
    if (cause != null) buffer.write(' caused by: $cause');
    return buffer.toString();
  }
}

/// 网络层错误。页面应提供「重试」。
final class NetworkError extends AppError {
  const NetworkError({
    super.message = '网络连接失败，请检查网络后重试',
    super.detail,
    super.cause,
    super.stackTrace,
    super.isRetryable = true,
    this.statusCode,
  });

  /// HTTP 状态码（若有）。
  final int? statusCode;

  @override
  String get type => 'NetworkError';
}

/// 解析错误：简历解析、JD 解析、结构化输出解析。
///
/// PRD §15：解析失败不计入分析次数。
final class ParseError extends AppError {
  const ParseError({
    super.message = '内容解析失败，请检查后重新提交',
    super.detail,
    super.cause,
    super.stackTrace,
    super.isRetryable = true,
    this.source,
  });

  /// 解析对象标识，例如 `resume` / `jd`。
  final String? source;

  @override
  String get type => 'ParseError';
}

/// AI 调用错误。
final class AIError extends AppError {
  const AIError({
    super.message = 'AI 暂时无法响应，请稍后重试',
    super.detail,
    super.cause,
    super.stackTrace,
    super.isRetryable = true,
  });

  @override
  String get type => 'AIError';
}

/// 额度不足。
///
/// PRD §16 / Baseline §5：额度不足时禁用「开始分析」并提供升级入口。
/// 这不是「失败」，而是**已知的、需要引导的状态**，因此默认不可重试。
final class QuotaError extends AppError {
  const QuotaError({
    super.message = '分析次数已用完',
    super.detail,
    super.cause,
    super.stackTrace,
    super.isRetryable = false,
    this.required = 1,
    this.remaining = 0,
  });

  /// 本次需要的额度。
  final int required;

  /// 当前剩余额度。
  final int remaining;

  @override
  String get type => 'QuotaError';
}

/// 认证错误。
final class AuthError extends AppError {
  const AuthError({
    super.message = '登录状态已失效，请重新登录',
    super.detail,
    super.cause,
    super.stackTrace,
    super.isRetryable = false,
  });

  @override
  String get type => 'AuthError';
}

/// 未归类的错误。
final class UnknownError extends AppError {
  const UnknownError({
    super.message = '出了点问题，请稍后重试',
    super.detail,
    super.cause,
    super.stackTrace,
    super.isRetryable = true,
  });

  @override
  String get type => 'UnknownError';
}
