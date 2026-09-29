import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Careerly 线性进度条（确定型）。
///
/// ```dart
/// CareerlyProgress(value: 0.4)                  // 40%
/// CareerlyProgress(value: quota.usedRatio)
/// ```
///
/// ## 真值来源
///
/// Figma `OnboardingProgress`（`src/App.tsx` L428-457）—— 引导流程顶部的进度条。
///
/// | 项 | Figma 真值 |
/// |---|---|
/// | 轨道高 | `7` |
/// | 轨道圆角 | `9999`（pill） |
/// | 轨道色 | `rgba(79,126,245,0.12)` |
/// | 填充渐变 | `linear-gradient(172deg, #4F7EF5 → #A77BE6)` |
/// | 填充定位 | `left: -4px`，宽 `calc(pct% + 4px)` |
/// | 值变化动画 | `transition: all 500ms` |
/// | 入场动画 | `.bar-grow`：`from { width: 0% }`，`600ms` |
///
/// ## 关于 `left: -4px` / `calc(pct% + 4px)`
///
/// 这是 Figma 的一个**固有设计细节**，不是笔误：填充条左端**外扩 4px**，
/// 再被轨道的圆角裁剪吃掉 —— 使填充条的左圆角与轨道左内缘齐平。
/// Flutter 侧用「外层 `ClipRRect` + 填充条负偏移」原样还原，
/// 而不是简化成「从 0 开始画」（依据 CLAUDE.md §3.1：
/// Figma 有视觉而 Flutter 无现成实现方式时，**重新实现**，不放弃视觉）。
///
/// ## ⚠️ 时长偏差（**待裁决 · D31** —— 见 `docs/05_progress/` 待裁决清单 §3.1）
///
/// Figma 给了**两个**时长：值变化 `500ms`、入场 `.bar-grow` `600ms`。
/// 本组件统一使用 [AppMotion.reveal]（`550ms`）—— 它落在同一档
/// 「重大结果揭示 400–700ms」内，且是两者之间值。
///
/// **偏差**：值变化 +50ms / 入场 -50ms。**未自行新增 Token**。
///
/// ## 只支持确定型（有意为之）
///
/// Figma 中**不存在**不确定型（indeterminate）进度条的任何视觉定义。
/// 因此本组件**要求** [value] 非空 —— 不确定型请继续使用
/// `CareerlyAsyncStateView` 的 Loading 态。
/// 若产品侧需要不确定型，需先由设计侧给出视觉。
class CareerlyProgress extends StatelessWidget {
  const CareerlyProgress({
    super.key,
    required this.value,
    this.height = _ProgressMetrics.trackHeight,
    this.duration = AppMotion.reveal,
    this.trackColor,
    this.gradient,
    this.semanticsLabel,
  });

  /// 进度值，范围 `0.0`–`1.0`。超出范围会被夹取。
  final double value;

  /// 轨道高度。Figma 真值为 `7`。
  final double height;

  /// 值变化 / 入场动画时长。
  final Duration duration;

  /// 轨道颜色。为 `null` 时取 [AppColors.progressTrack]。
  final Color? trackColor;

  /// 填充渐变。为 `null` 时取 [AppColors.progressGradient]。
  final Gradient? gradient;

  /// 无障碍标签。为 `null` 时只播报百分比。
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 1.0);
    final Color effectiveTrack = trackColor ?? AppColors.progressTrack;
    final Gradient effectiveGradient = gradient ?? AppColors.progressGradient;

    return Semantics(
      label: semanticsLabel,
      value: '${(clamped * 100).round()}%',
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // 进度条必须有确定的可用宽度 —— 与 Material 的
          // LinearProgressIndicator 同一约束。
          final double trackWidth = constraints.maxWidth;

          return TweenAnimationBuilder<double>(
            // 首次构建：0 → value（对应 Figma `.bar-grow`）。
            // 值变化：从当前值平滑到新值（对应 `transition: width 500ms`）。
            tween: Tween<double>(begin: 0, end: clamped),
            duration: duration,
            curve: AppMotion.standard,
            builder: (BuildContext context, double t, Widget? _) {
              return ClipRRect(
                borderRadius: AppRadius.borderPill,
                child: SizedBox(
                  width: trackWidth,
                  height: height,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: ColoredBox(color: effectiveTrack),
                      ),
                      Positioned(
                        left: -_ProgressMetrics.capOverlap,
                        top: 0,
                        bottom: 0,
                        width: t * trackWidth + _ProgressMetrics.capOverlap,
                        child: DecoratedBox(
                          decoration: BoxDecoration(gradient: effectiveGradient),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// 组件的内部几何。
///
/// 与 `_ButtonMetrics` / `_NavMetrics` 同理：这些是**组件内部比例**，
/// 不是页面级可调项，因此留在组件文件内，不进入 `AppSpacing`。
abstract final class _ProgressMetrics {
  /// Figma `OnboardingProgress`：轨道 `height: 7`。
  static const double trackHeight = 7;

  /// Figma：填充条 `left: -4px`（左端外扩量）。
  static const double capOverlap = 4;
}
