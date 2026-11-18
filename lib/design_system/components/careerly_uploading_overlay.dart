import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// 简历上传 / 解析进行中的全屏遮罩提示。
///
/// ```dart
/// Stack(
///   children: <Widget>[
///     page,
///     if (provider.isUploading)
///       const Positioned.fill(child: CareerlyUploadingOverlay()),
///   ],
/// )
/// ```
///
/// ## 为什么需要它
///
/// 后端 `POST /api/v1/resume` 在**同一个请求内**同步跑简历解析（LLM，
/// 图片还要 OCR），实测 173–199s（见 `ApiClient.resumeParseTimeout`）。
/// 在此之前页面只是把按钮置灰，用户看不出「还在上传」还是「卡死了」。
///
/// 本组件给出一层明确的忙等反馈：遮罩 + 持续旋转的上传图标 + 文案。
/// 遮罩同时**拦住重复提交**（`ModalBarrier` 不可关闭）。
///
/// ## ⚠️ 视觉是 Flutter 侧补齐的
///
/// Figma 没有「上传中」状态（与 `onboarding_resume_page.dart` 的
/// **D70** 是同一处缺口）。这里只用项目已有 Token 组合，不新造视觉语言：
///
/// | 项 | 取值 |
/// |---|---|
/// | 遮罩 | [AppColors.sheetScrimOverlay]（浮层 / Dialog 型 scrim） |
/// | 面板 | [AppColors.surface] + [AppRadius.borderXl] + [AppShadows.brand] |
/// | 图标底板 | [AppColors.brandGradient]，与上传卡图标底板同源 |
/// | 旋转周期 | [AppMotion.uploadLoop]（⚠️ 暂定值 · 待视觉验证） |
///
/// ## 无障碍
///
/// 开启「减少动态效果」时不再旋转，只保留静态图标与文案；
/// 文案通过 `liveRegion` 读出。
class CareerlyUploadingOverlay extends StatefulWidget {
  const CareerlyUploadingOverlay({
    super.key,
    this.title = '正在上传简历',
    this.message = 'AI 正在解析你的简历，可能需要几分钟，请稍候',
  });

  /// 主标题。
  final String title;

  /// 说明文案。
  final String message;

  @override
  State<CareerlyUploadingOverlay> createState() =>
      _CareerlyUploadingOverlayState();
}

class _CareerlyUploadingOverlayState extends State<CareerlyUploadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.uploadLoop,
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      liveRegion: true,
      label: '${widget.title}。${widget.message}',
      child: Stack(
        children: <Widget>[
          const ModalBarrier(
            dismissible: false,
            color: AppColors.sheetScrimOverlay,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _UploadingMetrics.maxWidth,
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderXl,
                    boxShadow: AppShadows.brand,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _LoopingUploadBadge(
                          controller: _controller,
                          animate: !_reduceMotion,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 圆形渐变底板 + 持续旋转的上传图标。
///
/// 只旋转**图标**，不旋转底板 —— 底板的渐变旋转会改变色相走向，
/// 看起来像整个块在转，而不是「上传在循环」。
class _LoopingUploadBadge extends StatelessWidget {
  const _LoopingUploadBadge({required this.controller, required this.animate});

  final Animation<double> controller;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    const Widget icon = Icon(
      Icons.upload_rounded,
      size: _UploadingMetrics.iconSize,
      color: AppColors.textInverse,
    );

    return Container(
      width: _UploadingMetrics.badgeSize,
      height: _UploadingMetrics.badgeSize,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: BoxShape.circle,
        boxShadow: AppShadows.button,
      ),
      child: Center(
        child: animate
            ? RotationTransition(turns: controller, child: icon)
            : icon,
      ),
    );
  }
}

/// 组件内部几何。
abstract final class _UploadingMetrics {
  /// 面板最大宽度。与 `CareerlyProblemDialog` 的阅读宽度同一档。
  static const double maxWidth = 300;

  /// 图标底板直径。
  static const double badgeSize = 64;

  /// 上传图标尺寸。
  static const double iconSize = 30;
}
