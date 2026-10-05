import 'package:flutter/material.dart';

import '../../../../design_system/tokens/tokens.dart';

/// 44×44 的 Glass 圆钮返回键。
///
/// ## 归属：feature-local，**不进 design-system**
///
/// 它与 `OnboardingProgressHeader` 是同一个复合体的一半 ——
/// 当前只被 Onboarding 的页面使用（注册页的进度条头部、登录页的独立返回键）。
/// 提到 design-system 会让它成为只有两个调用点的空壳，
/// 判定标准见 `CLAUDE.md` §8.4。
///
/// ## 两处用法的差异（**只有填充浓度**）
///
/// | 用在哪 | 填充 | Figma |
/// |---|---|---|
/// | 注册 / 提交简历等页的进度条头部 | `rgba(255,255,255,0.55)` | `OnboardingProgress` L641 |
/// | 登录页（本文件新增的用法） | `rgba(255,255,255,0.45)` | `OnLogin` L490 |
///
/// 尺寸（44）、圆角（胶囊）、箭头（`#0088FF` / 24）、外阴影（`0 8px 15px
/// rgba(0,0,0,0.02)`）**两处完全相同**，故收敛为一个组件 + 一个 [fill] 参数
/// （§8.4「变体用参数，不用新组件」）。
///
/// ⚠️ 深浅两档**不是可随便挑的配色** —— 它是 Figma 在不同底色上的两次
/// 独立声明，调用方按自己所在的页面取值，不要「统一」成同一个。
///
/// ## ⚠️ 未做的部分
///
/// Figma 的 Glass 圆钮有 4 层 `inset box-shadow` 高光，Flutter 的
/// `BoxShadow` **不支持 inset**。当前只落了外阴影
/// （[AppShadows.onboardingBackPill]）+ 半透明底，**没有边框**，
/// 也**未做完整的 Glass 边缘高光**。这与导航栏 `GlassSurface` 的处理先例一致
/// （见 Baseline §1.2「Figma 有视觉效果但 Flutter 没有对应实现方式 → 重新实现」），
/// 但**观感需要视觉验证**。
class BackPill extends StatelessWidget {
  const BackPill({
    super.key,
    required this.onTap,
    this.fill = AppColors.onboardingGlassFill,
  });

  /// 点击回调。
  final VoidCallback onTap;

  /// 填充色。默认是进度条头部那档 `0.55`；登录页传 [AppColors.authGlassFill]。
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '返回',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: BackPillMetrics.size,
          height: BackPillMetrics.size,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.borderPill,
            boxShadow: AppShadows.onboardingBackPill,
          ),
          child: const Center(
            child: Icon(
              // Figma 用的是自绘 SVG（24 viewBox 的 `M15 18L9 12L15 6`），
              // 语义等同 Material 的 chevron_left，故不另建图标资源。
              Icons.chevron_left,
              size: BackPillMetrics.iconSize,
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
/// 与 `_ButtonMetrics` / `_NavMetrics` / `_HeaderMetrics` 同理：
/// 这些是**组件内部比例**，不是页面级可调项，故留在文件内。
///
/// 公开（非 `_` 前缀）是因为 [BackPill] 现在有**两个调用点**
/// （进度条头部与登录页），后者需要按同样的数值做绝对定位与对齐。
abstract final class BackPillMetrics {
  /// Figma：`width: 44, height: 44`。
  static const double size = 44;

  /// Figma 的箭头 SVG 是 `17×17` 画布内一个 24 viewBox 的路径。
  /// Material 的 `chevron_left` 字形自带内边距，取 24 才能得到相近的视觉大小。
  static const double iconSize = 24;
}
