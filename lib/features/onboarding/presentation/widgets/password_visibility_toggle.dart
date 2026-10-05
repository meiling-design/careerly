import 'package:flutter/material.dart';

import '../../../../design_system/tokens/tokens.dart';

/// 密码输入框右侧的「显示 / 隐藏密码」眼睛按钮。
///
/// 真值来源：2026-10-04 重新导出的 Figma ——
/// `OnLogin`（`src/App.tsx` L542-549）与 `OnRegister`（L748-755）。
/// 两处**逐位一致**：一个 `22×12` 的 SVG，定位在输入框内
/// `right: 15px`、垂直居中。
///
/// ## 为什么不进 design-system
///
/// 它只是一个图标按钮，且**只被登录 / 注册两个输入框使用** ——
/// 既是 feature-local，也不承载任何 Careerly 产品语义。
/// 按 `CLAUDE.md` §8.4 的判定标准，它是**页面内小组件**。
/// `CareerlyInput.suffix` 插槽本来就是为这种「页面自己补的小附件」准备的。
///
/// ## ⚠️ 图标与颜色都是**近似实现**
///
/// ```text
/// 图标    Figma 是自有 SVG（22×12 的「眼睛」），仓库里没有该资产，
///         且 §8.3 禁止自行下载资源 → 用 Material 的
///         visibility / visibility_off 近似
/// 颜色    Figma 的 SVG 自带填色，本实现拿不到，也**没有**任何 Token
///         是为它定义的。取 [AppColors.textTertiary] ——
///         依据 D46 的先例（占位符色在 Figma 中同样未定义，取 textTertiary）
/// ```
///
/// ⚠️ 这两点都是补齐而不是设计值，**不得盖章为视觉已定稿**。
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.visible,
    required this.onPressed,
  });

  /// 当前密码是否**明文可见**。
  final bool visible;

  /// 点击回调（切换 [visible]）。
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // Figma 的 `aria-label` 就是这两个字符串，逐字照抄。
      label: visible ? '隐藏密码' : '显示密码',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: _ToggleMetrics.iconSize,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// 组件内部几何。
abstract final class _ToggleMetrics {
  /// Material 的眼睛字形自带内边距，取 20 才接近 Figma 那个
  /// `22×12`（扁而宽）的视觉占位。
  static const double iconSize = 20;
}
