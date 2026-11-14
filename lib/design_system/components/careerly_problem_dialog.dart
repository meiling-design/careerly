import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/tokens.dart';
import 'careerly_button.dart';

/// Careerly 的「出问题了」提示框。
///
/// 2026-11-14 产品侧指定：程序崩溃 / 未捕获异常时，弹出「休息」形象的 IP，
/// 同时给出可读的提示消息与一个关闭按钮。
///
/// ```dart
/// CareerlyProblemDialog(
///   message: error.message,
///   onDismiss: CrashReporter.clear,
/// )
/// ```
///
/// ## 为什么是居中弹窗而不是 `CareerlyBottomSheet`
///
/// 这是**不可预期**的故障提示，不是「确认 / 操作」类业务弹层：
/// 它需要立刻抓住注意力、且不依赖页面自身的滚动上下文。
/// 因此固定在屏幕中央，并铺一层一次性遮罩。
///
/// ## 动效
///
/// 进入 = 透明度 + `0.92 → 1` 缩放（`AppMotion.pagePush`，260ms）。
/// 没有循环动画 —— 故障态不应该继续动，避免用户误以为还在加载。
class CareerlyProblemDialog extends StatelessWidget {
  const CareerlyProblemDialog({
    super.key,
    required this.message,
    required this.onDismiss,
    this.title = '出了点小状况',
    this.actionLabel = '我知道了',
  });

  /// 面向用户的可读文案（通常来自 `AppError.message`）。
  final String message;

  /// 关闭按钮回调。
  final VoidCallback onDismiss;

  /// 标题。
  final String title;

  /// 关闭按钮文案。
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: ColoredBox(
        color: _ProblemMetrics.scrim,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: _ProblemMetrics.horizontalInset,
              vertical: AppSpacing.lg,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: AppMotion.pagePush,
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double progress, Widget? child) {
                return Opacity(
                  opacity: progress,
                  child: Transform.scale(
                    scale: 0.92 + 0.08 * progress,
                    child: child,
                  ),
                );
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _ProblemMetrics.maxWidth,
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderXl,
                    boxShadow: AppShadows.brand,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.mdLg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SvgPicture.asset(
                          _ProblemMetrics.illustrationAsset,
                          width: _ProblemMetrics.illustrationWidth,
                          height: _ProblemMetrics.illustrationHeight,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.label.copyWith(
                            fontSize: 17,
                            height: 24 / 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 13,
                            height: 20 / 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.mdLg),
                        CareerlyButton(
                          label: actionLabel,
                          onPressed: onDismiss,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 组件内部的固定取值。
abstract final class _ProblemMetrics {
  /// 故障态 IP：「休息」形象（`careerly-assets/svg/休息.svg`）。
  ///
  /// viewBox 392.862×195.828 ≈ 2.0:1，因此宽高按 2:1 取。
  static const String illustrationAsset =
      'assets/images/nebula/careerly-rest.svg';
  static const double illustrationWidth = 160;
  static const double illustrationHeight = 80;

  /// 弹窗最大宽度。与 Careerly 其他居中面板保持一致的阅读宽度。
  static const double maxWidth = 340;

  /// 与按钮 / 卡片的左右留白一致（24），保证小屏不贴边。
  static const double horizontalInset = AppSpacing.lg;

  /// 遮罩：比 BottomSheet 的 confirm 档更重，突出「不可继续操作」。
  static const Color scrim = Color(0x730F1428);
}
