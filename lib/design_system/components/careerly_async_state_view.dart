import 'package:flutter/material.dart';

import '../../core/errors/app_error.dart';
import '../../core/state/async_state.dart';
import '../tokens/tokens.dart';

/// 把 [AsyncState] 渲染成 Loading / Empty / Error / Success 四种 UI。
///
/// 依据 Phase 1 §十九与 PRD §15：
/// **核心页面必须支持 Empty / Loading / Success / Error 四种状态**，
/// 尤其是简历上传与解析、分析流程、AI 对话。
///
/// 把这个分支逻辑收敛到一个组件里，避免每个页面各写一遍
/// `if (loading) ... else if (error) ... else if (empty) ...`。
///
/// ```dart
/// CareerlyAsyncStateView<HomeSummary>(
///   state: provider.state,
///   isEmpty: (summary) => summary.isEmpty,
///   onRetry: provider.load,
///   builder: (context, summary) => HomeContent(summary),
/// )
/// ```
class CareerlyAsyncStateView<T> extends StatelessWidget {
  const CareerlyAsyncStateView({
    super.key,
    required this.state,
    required this.builder,
    this.isEmpty,
    this.onRetry,
    this.loadingMessage,
    this.emptyTitle = '暂无内容',
    this.emptyMessage,
    this.emptyAction,
    this.compact = false,
  });

  /// 当前状态。
  final AsyncState<T> state;

  /// 成功且非空时的内容构建器。
  final Widget Function(BuildContext context, T data) builder;

  /// 判断成功数据是否应视为「空」。为 `null` 时永不进入 Empty。
  final bool Function(T data)? isEmpty;

  /// 重试回调。为 `null` 时不展示重试按钮。
  final VoidCallback? onRetry;

  /// Loading 文案。
  final String? loadingMessage;

  /// Empty 标题。
  final String emptyTitle;

  /// Empty 说明。
  final String? emptyMessage;

  /// Empty 状态下的行动入口（例如「开始第一次岗位分析」）。
  final Widget? emptyAction;

  /// 紧凑模式：用于卡片内嵌状态。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AsyncInitial<T>() || AsyncLoading<T>() => _Loading(
        message: switch (state) {
          AsyncLoading<T>(:final String? message) => message ?? loadingMessage,
          _ => loadingMessage,
        },
        progress: switch (state) {
          AsyncLoading<T>(:final double? progress) => progress,
          _ => null,
        },
        compact: compact,
      ),
      AsyncFailure<T>(:final AppError error) => _Error(
        error: error,
        onRetry: onRetry,
        compact: compact,
      ),
      AsyncSuccess<T>(:final T data) =>
        (isEmpty?.call(data) ?? false)
            ? _Empty(
                title: emptyTitle,
                message: emptyMessage,
                action: emptyAction,
                compact: compact,
              )
            : builder(context, data),
    };
  }
}

class _Loading extends StatelessWidget {
  const _Loading({this.message, this.progress, this.compact = false});

  final String? message;
  final double? progress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 24 : 32;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              color: AppColors.primaryBlue,
            ),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message!,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.title,
    this.message,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _StateShell(
      compact: compact,
      icon: Icons.inbox_outlined,
      title: title,
      message: message,
      action: action,
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.error, this.onRetry, this.compact = false});

  final AppError error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _StateShell(
      compact: compact,
      icon: Icons.error_outline,
      iconColor: AppColors.danger,
      title: error.message,
      message: error.detail,
      action: (onRetry != null && error.isRetryable)
          ? TextButton(onPressed: onRetry, child: const Text('重试'))
          : null,
    );
  }
}

/// Empty 与 Error 共用的布局外壳。
class _StateShell extends StatelessWidget {
  const _StateShell({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconColor,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color? iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: compact ? 28 : 40,
              color: iconColor ?? AppColors.textTertiary,
            ),
            SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
            Text(
              title,
              style: compact ? AppTypography.bodySmall : AppTypography.body,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                message!,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
