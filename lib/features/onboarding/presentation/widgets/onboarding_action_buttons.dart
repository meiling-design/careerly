import 'package:flutter/material.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

/// Onboarding 流程底部的**内联**动作按钮。
///
/// ## 为什么不复用 `CareerlyButton`
///
/// Figma 里 Onboarding 各屏的主按钮都是**内联写法**
/// （`OnRegister` L549 / `OnResume` L791 / `OnConfirm` L974），
/// 与可复用的 `PrimaryBtn` 组件**不是同一套数值**：
///
/// | 项 | Onboarding 内联 | `PrimaryBtn`（`CareerlyButton` primary） |
/// |---|---|---|
/// | 渐变 | `172deg`（[AppColors.brandGradientDown]） | `135deg`（[AppColors.brandGradient]） |
/// | 投影 | `0 8px 12px`（[AppShadows.button]） | `0 8px 24px`（[AppShadows.primaryButton]） |
///
/// 依 `CLAUDE.md` §3.1「Figma 已明确设计细节 → 采纳 Figma」，
/// 这里**逐位实现 Figma 的内联形态**，而不是拿 `CareerlyButton` 近似。
///
/// ⚠️ **代价：同一流程内两种按钮并存。**
/// 注册页（Phase 4 批 1）用的是 `CareerlyButton` primary，
/// 即它渲染的是 `135deg`。
/// 这是**已登记的偏差**，见 `docs/05_progress/TODO.md` §3.1 · **D71**；
/// 产品侧裁决后，其中一种实现会被删除、另一种统一全流程。
///
/// > 本文件属 **feature-local**（同 [OnboardingProgressHeader]），
/// > 只服务 Onboarding，不进 design-system，故不加 `Careerly` 前缀。
///
/// ## 未定义的态
///
/// Figma **没有**给这两个按钮定义不可用态与按压态
/// （与 `CareerlyButton` 的 D16 缺口同类）。此处取既有 Token 补齐：
/// 不可用走 [AppColors.disabled]（`rgba(17,24,39,0.38)`，即
/// `AppColors` 中既有的按钮禁用底衬，**不是** `disabledSurface` —— 后者是
/// 给深色的玻璃面板用的白色 8%，落在本页浅色渐变上几乎不可见）
/// + [AppColors.textDisabled]，
/// 按压走 [CareerlyPressFeedback] 的通用参数（[AppMotion.pressScale]）。
/// **未新增任何产品规则。**

/// 品牌渐变主按钮（Figma 内联形态）。
///
/// Figma：`height: 48 · borderRadius: 99 · linear-gradient(…)
/// · 0 8px 12px rgba(79,126,245,0.28) · 15px / w700 / white`。
///
/// ⚠️ **渐变角度在两屏之间不同**（Figma 原值，非笔误）：
///
/// | 屏 | Figma 渐变 | 本组件取值 |
/// |---|---|---|
/// | `on-resume`「选择文件」 | `172deg` | [AppColors.brandGradientDown]（默认） |
/// | `on-confirm`「进入 Careerly」 | `135deg` 且首色 `#5B7CF6` | [AppColors.confirmGradient]（由 [gradient] 传入） |
///
/// 依 §6.4「变体用参数，不用新组件」，这里开一个 [gradient] 参数，
/// 不另建按钮组件。
class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient = AppColors.brandGradientDown,
  });

  final String label;

  /// 为 `null` 时按钮进入不可用态。
  final VoidCallback? onPressed;

  /// 品牌渐变。默认 [AppColors.brandGradientDown]（`172deg`）。
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color labelColor = enabled
        ? AppColors.textInverse
        : AppColors.textDisabled;

    return CareerlyPressFeedback(
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: _ActionMetrics.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? gradient : null,
            color: enabled ? null : AppColors.disabled,
            borderRadius: AppRadius.button,
            boxShadow: enabled ? AppShadows.button : AppShadows.none,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.onSurfaceVariant(
                AppTypography.buttonPrimary,
                labelColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// 白底品牌描边按钮（Figma 内联形态）。
///
/// Figma（`OnResume`「粘贴简历文本」）：
/// `height: 48 · borderRadius: 99 · background: white
/// · border: 1.5px solid rgba(79,126,245,0.35) · 15px / w400 / #4F7EF5`。
class OnboardingOutlineButton extends StatelessWidget {
  const OnboardingOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;

  /// 为 `null` 时按钮进入不可用态。
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return CareerlyPressFeedback(
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: _ActionMetrics.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled ? AppColors.surface : AppColors.disabled,
            borderRadius: AppRadius.button,
            border: Border.all(
              color: enabled
                  ? AppColors.brandBorderSoft
                  : AppColors.divider,
              width: _ActionMetrics.outlineBorderWidth,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.onSurfaceVariant(
                AppTypography.onboardingOutlineAction,
                enabled ? AppColors.primaryBlue : AppColors.textDisabled,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// 按钮的内部几何。
///
/// 与 `_ButtonMetrics` 同理：组件内部比例，不进入 `AppSpacing`。
abstract final class _ActionMetrics {
  /// Figma：`height: 48`。
  static const double height = 48;

  /// Figma：`border: 1.5px solid rgba(79,126,245,0.35)`。
  static const double outlineBorderWidth = 1.5;
}
