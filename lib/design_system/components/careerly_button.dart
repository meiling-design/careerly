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

  /// 登录 / 注册 / 开屏页的渐变主按钮（2026-10-04 重新导出的 Figma）。
  ///
  /// ⚠️ **与 [primary] 只差两点，但两点都看得见**：
  ///
  /// ```text
  ///              渐变角度        投影
  /// [primary]    135deg（对角）   0 8px 24px rgba(79,126,245,0.30)
  /// [authPrimary] 172deg（近垂直） 0 8px 12px rgba(79,126,245,0.30)
  /// ```
  ///
  /// Figma 把这两个值在**三处**独立写了一遍（`OnSplash` L439、
  /// `OnLogin` L581、`OnRegister` L764），而 `S.primary`（135deg）
  /// 在同一份稿子里用得更多 —— 两套都是**刻意的**，不是笔误。
  /// 在 48px 高、接近满宽的药丸按钮上，对角渐变与垂直渐变肉眼可辨。
  ///
  /// ⚠️ 命名带 `auth` 是因为它**只服务于账号相关的那三屏**；
  /// 若将来别处也用这套角度 / 投影，应改名并同步这里的说明，
  /// 而**不是**把它当成新的默认主按钮。
  authPrimary,
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
///
/// ⚠️ **已知缺口（未自行修改，待裁决）**：`disabledSurface` 是白色 8%，
/// 是给深色玻璃面板用的；落在本系统的浅色渐变页上等于**没有底色** ——
/// 真机上表现为「按钮整个消失，只剩一行灰字」（登录页空表单的
/// 「点击登录」即此形态）。改用同流程 `OnboardingPrimaryButton` 的
/// `AppColors.disabled` 作底衬也**不成立**：实测该底衬
/// `rgb(159,151,164)` 与 `textDisabled` 文字 `rgb(157,158,171)` 几乎同色，
/// 文字会读不出来。两条既有路径都会坏，**需要产品侧先定「禁用按钮长什么样」**。
///
/// ## ⚠️ `color` 与 `gradient` 必须互斥（2026-10-04 修复）
///
/// `BoxDecoration` 一旦收到**非 null 的 `color`**，渐变就整块不画 ——
/// 连 `Colors.transparent` 也会触发。此前 [CareerlyButtonVariant.primary] /
/// [CareerlyButtonVariant.authPrimary] 写的是 `color: Colors.transparent`，
/// 于是这两个变体**从未真正渲染出渐变**，只剩下 `boxShadow`；
/// 白色文字照常绘制（文字在装饰之上），所以真机表现是
/// 「一团模糊的淡紫斑 + 一行白字」，而不是一颗药丸按钮。
///
/// 受影响范围是所有用这两个变体的位置（开屏「点击注册」、登录「点击登录」、
/// 注册「创建账号」、分析「开始分析」…）。修复方式与
/// `OnboardingPrimaryButton` 一致：走渐变时把 `color` 传 `null`。
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
    final bool isAuthPrimary =
        widget.variant == CareerlyButtonVariant.authPrimary;
    final bool enabled = _isEnabled;

    // 文字样式：从 Token 取角色，再按状态换色（不新建字号 / 字重）。
    //
    // 只有 `secondary` 走 14/w600 的角色，`primary` / `authPrimary` / `neutral`
    // 同为 15/w700（Figma 的 `SecondaryBtn` 与另几者的字号本就不同）。
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
    //
    // ⚠️ 走渐变的两个分支必须把 `background` 传 `null`（**不是**
    // `Colors.transparent`）—— 见类文档「`color` 与 `gradient` 必须互斥」。
    final Color? background;
    final Gradient? gradient;
    final List<BoxShadow> shadow;

    if (!enabled) {
      background = AppColors.disabledSurface;
      gradient = null;
      shadow = AppShadows.none;
    } else if (isPrimary) {
      background = null;
      gradient = AppColors.brandGradient;
      shadow = AppShadows.primaryButton;
    } else if (isAuthPrimary) {
      background = null;
      gradient = AppColors.authPrimaryButtonGradient;
      shadow = AppShadows.authPrimaryButton;
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
    } else if (isPrimary || isAuthPrimary) {
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
