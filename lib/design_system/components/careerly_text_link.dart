import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'careerly_press_feedback.dart';

/// 纯文字链接按钮。
///
/// ## 为什么不是 `CareerlyButton` 的一个 variant
///
/// 依据 `CLAUDE.md` §8.4「变体用参数，不用新组件」的反面：
/// **只有行为真的不同时才拆**。这里的差异正是行为层面的 ——
///
/// ```text
/// CareerlyButton        固定高 48 / 撑满宽度 / 圆角胶囊 / 有底色或渐变 / 有投影
/// CareerlyTextLink      行内文字 / 宽高由文字与父级行内布局决定 / 无底色 / 无投影
/// ```
///
/// 前者是「一个块」，后者是「一句话里的一段」—— 把它塞进
/// `CareerlyButton` 会让那个组件同时承担两种布局语义。
///
/// ## 用到它的地方（三处，均为 2026-10-04 重新导出的 Figma）
///
/// | 位置 | 文案 | 文字角色 |
/// |---|---|---|
/// | 开屏页底部 | 点击登录 | [AppTypography.splashFooterLink] |
/// | 登录页底部 | 点击注册 | [AppTypography.authFooterLink] |
/// | 登录页「忘记密码?」 | 忘记密码? | [AppTypography.authMeta] |
///
/// 三处的字号 / 字重 / 颜色都不同，因此**文字角色由调用方传入**
/// （[style]），本组件只管交互与语义。
///
/// ## 按压反馈
///
/// ⚠️ **Figma 未定义**这三处的按压态（与 `CareerlyButton` 的禁用态是
/// 同一类缺口，见该组件文档）。此处沿用 Figma 在**社交按钮**上已声明的
/// `active:opacity-70`，**未新增任何产品规则**；但因为 Figma 确实没写，
/// 这一点属于 Flutter 侧补齐，验收时不得盖章为「视觉已定稿」。
class CareerlyTextLink extends StatelessWidget {
  const CareerlyTextLink({
    super.key,
    required this.label,
    required this.style,
    this.onPressed,
    this.semanticsLabel,
  });

  /// 链接文字。
  final String label;

  /// 文字角色。**由调用方传入** —— 三处使用的字号 / 颜色各不相同
  /// （见类文档的表格），本组件不替调用方猜。
  final TextStyle style;

  /// 点击回调。为 `null` 时**不响应手势**（但仍渲染文字）。
  final VoidCallback? onPressed;

  /// 无障碍标签。未给时退回 [label]。
  ///
  /// ⚠️ 像「点击注册」这种文案，在同一个 App 里可能出现在多处
  /// （注册页标题、开屏页底部链接），TalkBack 读出来会分不清 ——
  /// 建议调用方给出更具体的描述。
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel ?? label,
      // 文字本身已经会被读屏器读到，避免重复朗读。
      excludeSemantics: true,
      child: CareerlyPressFeedback(
        onTap: onPressed,
        // Figma 的三处文字链都只声明了颜色，没有缩放语义 ——
        // 缩放会带动行内布局抖动，故保持 1.0。
        pressedScale: 1.0,
        pressedOpacity: _TextLinkMetrics.pressedOpacity,
        child: Text(label, style: style),
      ),
    );
  }
}

/// 组件内部常量。
abstract final class _TextLinkMetrics {
  /// 按下不透明度。取值来源见类文档「按压反馈」一节 ——
  /// 复用 Figma 在社交按钮上声明的 `active:opacity-70`，
  /// 不是为文字链新造的值。
  static const double pressedOpacity = 0.7;
}
