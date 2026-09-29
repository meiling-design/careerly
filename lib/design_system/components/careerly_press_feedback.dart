import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// 给可点击表面加上按压反馈（缩放 + 可选的不透明度变化）。
///
/// ## 为什么需要它
///
/// Figma Make 是 **React 静态原型**，天生无法表达按压态
/// （见 Baseline §1.3「设计稿负责视觉，Flutter 负责真实交互逻辑」）。
/// 但按压反馈是触摸端的真实需求，因此由 Flutter 侧补齐，
/// 取值沿用 Figma 在其他组件上已定义的按压参数。
///
/// 应用内既有的按压语言：
///
/// | 组件 | scale | 来源 |
/// |---|---|---|
/// | 底部导航 Tab | 0.96 | `AppMotion.pressScale` |
/// | AI 浮球 | 0.94 | `AppMotion.pressScaleOrb` |
/// | 可复用按钮 | 0.97 | `PrimaryBtn` / `SecondaryBtn` |
/// | Glass 卡片 | 0.96 | 沿用导航 Tab |
///
/// ⚠️ 与 `CareerlyButton` 的关系：按钮的按下态还包含
/// **不透明度**变化（0.92 / 0.85），因此按钮自带实现；
/// 本组件服务于卡片这类「只有缩放」的表面。
class CareerlyPressFeedback extends StatefulWidget {
  const CareerlyPressFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = AppMotion.pressScale,
    this.pressedOpacity = 1.0,
    this.duration = AppMotion.button,
  });

  /// 子内容。
  final Widget child;

  /// 点击回调。为 `null` 时不响应手势，也不做任何包裹。
  final VoidCallback? onTap;

  /// 按下时的缩放比例。
  final double pressedScale;

  /// 按下时的不透明度。
  final double pressedOpacity;

  /// 反馈动画时长。
  final Duration duration;

  @override
  State<CareerlyPressFeedback> createState() => _CareerlyPressFeedbackState();
}

class _CareerlyPressFeedbackState extends State<CareerlyPressFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // 不可点击时不引入任何额外层级。
    if (widget.onTap == null) return widget.child;

    Widget child = widget.child;

    if (widget.pressedOpacity != 1.0) {
      child = AnimatedOpacity(
        opacity: _pressed ? widget.pressedOpacity : 1.0,
        duration: widget.duration,
        curve: AppMotion.standard,
        child: child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: AppMotion.standard,
        child: child,
      ),
    );
  }
}
