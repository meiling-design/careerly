import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Careerly 按钮变体。
///
/// 真值来源：`src/App.tsx` 行 142–169 的 `PrimaryBtn` / `SecondaryBtn`。
enum CareerlyButtonVariant {
  /// 品牌渐变主按钮。`S.primary` 135deg 蓝→紫。
  primary,

  /// 品牌色浅底次按钮。
  secondary,

  /// 白底中性按钮。Figma `OnSplash` 的「点击注册」（`App.tsx` L415-424）：
  /// 纯白底 + `#6B7280` 文字 + `0 4px 2px rgba(186,185,188,0.24)`。
  ///
  /// ⚠️ **与 [secondary] 不是同一形态**：[secondary] 是品牌**浅蓝底 + 蓝字**
  /// （Figma 可复用组件 `SecondaryBtn`），本变体是**白底 + 中性灰字**。
  /// 两者底色与文字色都不同，故并存为两个变体而不是合并。
  neutral,
}

/// Careerly 按钮。
///
/// ```dart
/// CareerlyButton(label: '开始分析', onPressed: _start)
/// CareerlyButton(
///   label: '稍后再说',
///   variant: CareerlyButtonVariant.secondary,
///   onPressed: _later,
/// )
/// ```
///
/// ## 与 Material 按钮的关系
///
/// 依据 Baseline §6.5，Careerly 使用自绘按钮，
/// **不使用** `ElevatedButton` / `OutlinedButton` 的默认视觉。
/// `CareerlyTheme` 中的 Material 按钮主题只作为兜底
/// （第三方组件、Material 内建弹窗里的按钮），不服务于业务页面。
///
/// ## 状态
///
/// | 状态 | 表现 |
/// |---|---|
/// | 默认 | 见 [CareerlyButtonVariant] |
/// | 按下 | `scale(0.97)` + 不透明度下降，120ms |
/// | 不可用 | `onPressed == null`：弱底 + 灰字 + 无投影、无按压反馈 |
///
/// ⚠️ **不可用态是 Flutter 侧补齐的**：Figma 只在输入为空时改了文字颜色，
/// 并未定义按钮的禁用视觉。但 PRD §15 / 四态要求明确要求 Disabled 可表达，
/// 且「满强度渐变却点不动」是真实的可用性问题。
/// 因此这里用既有 Token（`disabledSurface` / `textDisabled`）补齐，
/// **未新增任何产品规则**。
class CareerlyButton extends StatefulWidget {
  const CareerlyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CareerlyButtonVariant.primary,
    this.icon,
    this.width = double.infinity,
  });

  /// 按钮文字。
  final String label;

  /// 点击回调。为 `null` 时按钮为不可用态。
  final VoidCallback? onPressed;

  /// 视觉变体。
  final CareerlyButtonVariant variant;

  /// 可选的左侧图标。
  ///
  /// Figma 的 `PrimaryBtn` 没有图标，这是为业务场景预留的扩展位；
  /// 尺寸与颜色自动跟随变体。
  final IconData? icon;

  /// 宽度。Figma 的按钮为 `w-full`，故默认撑满可用宽度。
  final double width;

  @override
  State<CareerlyButton> createState() => _CareerlyButtonState();
}

/// 按钮的内部几何与状态取值。
///
/// 与 `_NavMetrics` 同理：这些是**组件内部比例**，不是页面级可调项，
/// 因此留在组件文件内，不进入 `AppSpacing` / `AppMotion`。
abstract final class _ButtonMetrics {
  /// Figma `PrimaryBtn` / `SecondaryBtn`：`height: 48`。
  static const double height = 48;

  /// Figma：`transform: scale(0.97)`。
  ///
  /// 注意与 `AppMotion.pressScale`（0.96，底部导航 Tab）**不是同一个值**。
  static const double pressScale = 0.97;

  /// Figma `PrimaryBtn` 按下不透明度。
  static const double pressedOpacityPrimary = 0.92;

  /// Figma `SecondaryBtn` 按下不透明度。
  static const double pressedOpacitySecondary = 0.85;

  /// 白底中性按钮的按下不透明度。
  ///
  /// ⚠️ Figma 只给了 `OnSplash`「点击注册」的静态样式，**未定义按下状态**
  /// （与下方禁用态是同一类缺口）。此处沿用 primary 的 0.92，
  /// **未新增任何产品规则**。
  static const double pressedOpacityNeutral = pressedOpacityPrimary;

  /// 图标尺寸。
  static const double iconSize = 20;

  /// 图标与文字间距。
  static const double iconGap = AppSpacing.xs;

  /// 左右内边距。
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
  );
}

class _CareerlyButtonState extends State<CareerlyButton> {
  bool _pressed = false;

  bool get _isEnabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_isEnabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = widget.variant == CareerlyButtonVariant.primary;
    final bool isNeutral = widget.variant == CareerlyButtonVariant.neutral;
    final bool enabled = _isEnabled;

    // 文字样式：从 Token 取角色，再按状态换色（不新建字号 / 字重）。
    //
    // 只有 `secondary` 走 14/w600 的角色，`primary` 与 `neutral` 同为
    // 15/w700（Figma 的 `SecondaryBtn` 与另两者的字号本就不同）。
    final TextStyle baseText = widget.variant == CareerlyButtonVariant.secondary
        ? AppTypography.buttonSecondary
        : AppTypography.buttonPrimary;

    // `neutral` 的文字色是中性灰（Figma `#6B7280`），而非角色自带的白色。
    final Color restingColor = isNeutral
        ? AppColors.textSecondary
        : baseText.color ?? AppColors.textPrimary;
    final Color labelColor = enabled ? restingColor : AppColors.textDisabled;
    final TextStyle textStyle = AppTypography.onSurfaceVariant(
      baseText,
      labelColor,
    );

    // 底色与投影。
    final Color background;
    final Gradient? gradient;
    final List<BoxShadow> shadow;

    if (!enabled) {
      background = AppColors.disabledSurface;
      gradient = null;
      shadow = AppShadows.none;
    } else if (isPrimary) {
      background = Colors.transparent;
      gradient = AppColors.brandGradient;
      shadow = AppShadows.primaryButton;
    } else if (isNeutral) {
      background = AppColors.surface;
      gradient = null;
      shadow = AppShadows.neutralButton;
    } else {
      background = AppColors.primaryBlueSurface;
      gradient = null;
      shadow = AppShadows.none;
    }

    final double pressedOpacity;
    if (!enabled) {
      pressedOpacity = 1.0;
    } else if (isPrimary) {
      pressedOpacity = _ButtonMetrics.pressedOpacityPrimary;
    } else if (isNeutral) {
      pressedOpacity = _ButtonMetrics.pressedOpacityNeutral;
    } else {
      pressedOpacity = _ButtonMetrics.pressedOpacitySecondary;
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          Icon(widget.icon, size: _ButtonMetrics.iconSize, color: labelColor),
          const SizedBox(width: _ButtonMetrics.iconGap),
        ],
        // 文字过长时收缩而不是溢出。
        Flexible(
          child: Text(
            widget.label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    content = Padding(padding: _ButtonMetrics.padding, child: content);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          // Figma 真值：`transform 120ms cubic-bezier(0.25,0.46,0.45,0.94)`。
          //
          // ⚠️ 当前取 `AppMotion.micro`（100ms），与 Figma 的 120ms 存在 **20ms 偏差**
          // （**待裁决 · D19**）：
          // `AppMotion` 没有 120ms 档，而 100ms 落在 micro 的自述区间（80–120ms）内。
          // 是否补一档 120ms **待产品侧裁决** —— 未自行新增 Token。
          scale: _pressed ? _ButtonMetrics.pressScale : 1.0,
          duration: AppMotion.micro,
          curve: AppMotion.standard,
          child: AnimatedOpacity(
            // Figma 真值：`opacity 120ms ease`。时长偏差同上。
            opacity: _pressed ? pressedOpacity : 1.0,
            duration: AppMotion.micro,
            curve: AppMotion.standard,
            child: SizedBox(
              width: widget.width,
              height: _ButtonMetrics.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  gradient: gradient,
                  borderRadius: AppRadius.button,
                  boxShadow: shadow,
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
