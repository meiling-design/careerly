import 'package:flutter/material.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

/// Onboarding 顶部的「返回键 + 进度条」。
///
/// 真值来源：Figma `OnboardingProgress`（`src/App.tsx` L428-457）。
///
/// ```text
/// flex items-center gap-[29px] px-6 py-[10px]
/// ├── 44×44 Glass 圆钮（rgba(255,255,255,0.55) + blur(12px)），内嵌 17×17 返回箭头
/// └── flex-1 进度条（height 7，填充 172deg 渐变）
/// ```
///
/// ## 归属：feature-local，**不进 design-system**
///
/// 它是**页面级复合体**（Glass 圆钮 + 进度条 + 布局间距），
/// 不是可被任意项目复用的原子件；且当前只被 Onboarding 内部使用
/// （注册 / 价值介绍 / 提交简历 / 解析 / 确认 五步）。
/// 按 `CLAUDE.md` §8.4 的判定标准「有没有 Careerly 业务语义」——
/// 它有（引导流程步骤），但它同时**只服务于一个 feature**，
/// 提到 design-system 会让它成为无人复用的空壳。
///
/// 进度条本体是 design-system 组件 [CareerlyProgress]，
/// 本文件只负责「返回键 + 间距 + 组合」。
///
/// ⚠️ **未做的部分**：Figma 的 Glass 圆钮有 4 层 `inset box-shadow` 高光，
/// Flutter 的 `BoxShadow` 不支持 inset。当前只落了外阴影
/// （[AppShadows.onboardingBackPill]）+ 半透明底 + 边框近似，
/// **未做完整的 Glass 边缘高光**。这与导航栏 `GlassSurface` 的处理先例一致，
/// 但**观感需要视觉验证**。
class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.step,
    required this.total,
    required this.onBack,
  });

  /// 当前步骤（从 1 开始）。
  final int step;

  /// 总步数。
  final int total;

  /// 返回回调。
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // Figma: `Math.round((step / total) * 100)` —— 同样先取整再转比例，
    // 保证与设计稿的百分比数字逐位一致（7 / 4 与 1.75 会渲染出不同的宽度）。
    final int percent = total <= 0 ? 0 : ((step / total) * 100).round();
    final double value = percent / 100;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _HeaderMetrics.horizontalPadding,
        vertical: _HeaderMetrics.verticalPadding,
      ),
      child: Row(
        children: <Widget>[
          _BackPill(onTap: onBack),
          const SizedBox(width: _HeaderMetrics.gap),
          Expanded(
            child: CareerlyProgress(
              value: value,
              semanticsLabel: '引导流程进度',
            ),
          ),
        ],
      ),
    );
  }
}

/// 44×44 的 Glass 圆钮返回键。
class _BackPill extends StatelessWidget {
  const _BackPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '返回',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: _HeaderMetrics.backButtonSize,
          height: _HeaderMetrics.backButtonSize,
          decoration: BoxDecoration(
            color: AppColors.onboardingGlassFill,
            borderRadius: AppRadius.borderPill,
            boxShadow: AppShadows.onboardingBackPill,
          ),
          child: const Center(
            child: Icon(
              // Figma 用的是自绘 SVG（24 viewBox 的 `M15 18L9 12L15 6`），
              // 语义等同 Material 的 chevron_left，故不另建图标资源。
              Icons.chevron_left,
              size: _HeaderMetrics.backIconSize,
              color: AppColors.onboardingBackIcon,
            ),
          ),
        ),
      ),
    );
  }
}

/// 组件的内部几何。
///
/// 与 `_ButtonMetrics` / `_NavMetrics` / `_ProgressMetrics` 同理：
/// 这些是**组件内部比例**，不是页面级可调项，故留在文件内，
/// 不进入 `AppSpacing`。
abstract final class _HeaderMetrics {
  /// Figma `OnboardingProgress`：`px-6 py-[10px]`。
  static const double horizontalPadding = 24;
  static const double verticalPadding = 10;

  /// Figma：返回键与进度条之间 `gap-[29px]`。
  static const double gap = 29;

  /// Figma：返回键 `width: 44, height: 44`。
  static const double backButtonSize = 44;

  /// Figma 的箭头 SVG 是 `17×17` 画布内一个 24 viewBox 的路径。
  /// Material 的 `chevron_left` 字形自带内边距，取 24 才能得到相近的视觉大小。
  static const double backIconSize = 24;
}
