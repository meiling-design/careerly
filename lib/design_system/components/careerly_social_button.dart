import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'careerly_press_feedback.dart';

/// 「微信 / QQ」这类第三方登录按钮。
///
/// 真值来源：2026-10-04 重新导出的 Figma ——
/// `OnLogin`（`src/App.tsx` L595-610）与 `OnRegister`（L776-791）。
/// 两处**逐位一致**。
///
/// ```text
/// height: 53 · border-radius: 10 · border: 1px solid #c5b7d5
/// flex items-center justify-center gap-[15px]
/// ├── 图标 25×25
/// └── 渠道名（16 / w400，颜色随渠道变）
/// ```
///
/// ## 为什么不是 `CareerlyButton` 的一个 variant
///
/// 依据 `CLAUDE.md` §8.4「只有行为真的不同才拆」。与 `CareerlyButton` 相比：
///
/// ```text
/// CareerlyButton       固定高 48 / 胶囊圆角 / 有底色或渐变 / 有投影 / 文字居中
/// CareerlySocialButton 固定高 53 / 圆角 10 / **透明底 + 1px 描边** / 无投影
///                      / 品牌图标 + 文字**成组**居中（gap 15，不是撑满）
/// ```
///
/// 差别不止是配色：圆角形态（胶囊 vs 10）、是否有投影、内部排布
/// （单文字撑满 vs 图标 + 文字成组）都不同，塞进一个 variant
/// 会让 `CareerlyButton` 的分支覆盖到形态互斥的两套。
///
/// ## ⚠️ 图标是**调用方传入的 Widget**
///
/// Figma 用的是两个自有 SVG（`public/assets/cea01.svg` 微信、
/// `e9944.svg` QQ）。**Careerly 的 Flutter 仓库里没有这两个资产**，
/// 且 `CLAUDE.md` §8.3 明令**不得自行从网络下载**字体 / 资源。
///
/// 因此本组件不内置任何品牌图标，也不假装有 ——
/// 图标由调用方给出（见 `onboarding_login_page.dart` 顶部的说明，
/// 当前用 Material 近似图标并已登记为待裁决项）。
///
/// ## 状态
///
/// | 状态 | 表现 |
/// |---|---|
/// | 默认 | 透明底 + 描边 + 图标 + 渠道名 |
/// | 按下 | `opacity: 0.70`（Figma `active:opacity-70`），无缩放 |
/// | 不可用 | 描边与文字同时退到 [AppColors.textDisabled] |
///
/// ⚠️ **不可用态是 Flutter 侧补齐的**：Figma 未定义。
/// 之所以仍然要做，是因为这两个按钮在**未配置 OAuth 凭据**时
/// 会真实调用后端并失败（见 `router_auth.py` 的
/// `OAUTH_NOT_CONFIGURED`）—— 请求在途时必须能表达「点不动了」。
class CareerlySocialButton extends StatelessWidget {
  const CareerlySocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.labelColor,
    this.onPressed,
  });

  /// 渠道名（「微信」/「QQ」）。
  final String label;

  /// 渠道图标。
  ///
  /// ⚠️ **尺寸由调用方控制**（Figma 原值 25×25），本组件不替它设尺寸 ——
  /// 因为图标可能是 `Icon`、`Image` 或自绘 `CustomPaint`，三者设尺寸的
  /// 方式不同，猜错了就是静默的画错。
  final Widget icon;

  /// 渠道名颜色。Figma 两处不同：微信 `#1872cf`、QQ `#363333`。
  ///
  /// ⚠️ 它不是文字角色自带的颜色 —— 字号 / 字重两处相同，
  /// 只有颜色变，所以由参数传入而不是拆两个角色
  /// （符合 §8.4「变体用参数」）。
  final Color labelColor;

  /// 点击回调。为 `null` 时进入不可用态。
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: CareerlyPressFeedback(
        onTap: onPressed,
        // Figma 只写了 `active:opacity-70`，没有缩放。
        pressedScale: 1.0,
        pressedOpacity: _SocialMetrics.pressedOpacity,
        child: Container(
          height: _SocialMetrics.height,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderAuthField,
            border: Border.all(
              color: enabled ? AppColors.authFieldBorder : AppColors.divider,
              width: _SocialMetrics.borderWidth,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              const SizedBox(width: _SocialMetrics.iconGap),
              Text(
                label,
                style: AppTypography.onSurfaceVariant(
                  AppTypography.authSocialLabel,
                  enabled ? labelColor : AppColors.textDisabled,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 组件内部常量。
abstract final class _SocialMetrics {
  /// Figma：`height: 53`。
  ///
  /// ⚠️ 与 `CareerlyButton` 的 48、`CareerlyInput.outlined` 的 52
  /// 是三个不同的原值，不可互相套用。
  static const double height = 53;

  /// Figma：`border: 1px solid #c5b7d5`。
  static const double borderWidth = 1;

  /// Figma：`gap-[15px]`（图标与渠道名之间）。
  static const double iconGap = 15;

  /// Figma：`active:opacity-70`。
  static const double pressedOpacity = 0.7;
}
