import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// 自绘勾选框（16×16 方框 + 对勾 + 右侧文案）。
///
/// ## 为什么不用 Material 的 `Checkbox`
///
/// 真值来源：2026-10-04 重新导出的 Figma `OnLogin`
/// （`src/App.tsx` L555-569）：
///
/// ```text
/// <label class="flex items-center gap-px">
///   <input type="checkbox" class="sr-only">        ← 原生 input 被隐藏
///   <span 16×16 · border-radius 3 · 1px solid #57457c · color #57457c · 11px
///         内容：勾选时 '✓'，未勾选时空字符串
///   文案 13 / w400 / #352459
/// </label>
/// ```
///
/// 也就是说 Figma **不是**在用原生勾选框，而是自绘了一个方框 +
/// 一个文字对勾。Material `Checkbox` 的默认视觉（圆角 2 的填充方块、
/// ripple、`CheckboxTheme` 的尺寸约束）与它对不上，
/// 且按 §8.4「与 Material 3 的边界」不应让 M3 默认样式主导视觉。
///
/// ## 交互范围
///
/// Figma 把方框与文案一起包进 `<label>` —— 也就是说**点文案也算点击**。
/// 本组件保持这一点：整个 [Row] 都可点。
///
/// ## ⚠️ 未知项（Figma 未定义，**不得盖章为视觉已定稿**）
///
/// ```text
/// 勾选后的填充色   Figma 只给了描边与对勾色（#57457c），**没有填充色** ——
///                 方框在勾选前后都是透明底，只多一个 '✓'。此处照做，
///                 不自行补填充（补了就是新造视觉）。
/// 按下 / 聚焦态    Figma 未定义，此处不做任何反馈
///                 （这是唯一一处刻意「什么都不加」的控件：
///                 自绘方框上的缩放会与 16×16 的极小尺寸冲突）。
/// 禁用态           Figma 未定义；当前业务上也不需要（「记住我」永远可点），
///                 故本组件**不提供** `enabled` 参数 —— 不留没人用的分支。
/// ```
class CareerlyCheckbox extends StatelessWidget {
  const CareerlyCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  /// 是否勾选。
  final bool value;

  /// 勾选状态变化回调。传 `null` 即为只读展示。
  final ValueChanged<bool>? onChanged;

  /// 右侧文案（Figma：「记住我」）。
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // 用 `checked` 而不是 `toggled`：读屏器对复选框的标准播报是
      // 「已勾选 / 未勾选」，`Checkbox` 语义会被 TalkBack 识别为可切换控件。
      checked: value,
      enabled: onChanged != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Box(checked: value),
            // Figma：`gap-px` = 1px。不是 AppSpacing 的任何一档。
            const SizedBox(width: _CheckboxMetrics.labelGap),
            Text(label, style: AppTypography.authMeta),
          ],
        ),
      ),
    );
  }
}

/// 16×16 的方框本体。
class _Box extends StatelessWidget {
  const _Box({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _CheckboxMetrics.boxSize,
      height: _CheckboxMetrics.boxSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_CheckboxMetrics.radius),
        border: Border.all(
          color: AppColors.authCheckboxInk,
          width: _CheckboxMetrics.borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          // Figma：`{remember ? '✓' : ''}` —— 未勾选时是空串，不是隐藏的图标。
          checked ? _CheckboxMetrics.glyph : '',
          style: AppTypography.authCheckboxGlyph,
        ),
      ),
    );
  }
}

/// 组件内部常量。
abstract final class _CheckboxMetrics {
  /// Figma：`width: 16, height: 16`。
  static const double boxSize = 16;

  /// Figma：`border: 1px solid #57457c`。
  static const double borderWidth = 1;

  /// Figma：`borderRadius: 3`。
  ///
  /// ⚠️ **刻意不放进 `AppRadius`** —— 它是这个 16×16 方框的内部圆角，
  /// 不是页面级可复用的档位（`AppRadius` 最小档是 12）。
  /// 同 [_CheckboxMetrics.labelGap] 的处置。
  static const double radius = 3;

  /// Figma：方框与文案之间 `gap-px` = 1px。
  ///
  /// ⚠️ 这个值**刻意不放进 `AppSpacing`** —— 1px 是这里的排版细节，
  /// 不是页面级可调的间距（4 / 8 / 12 … 的刻度里也不该出现 1）。
  static const double labelGap = 1;

  /// Figma 直接写的字面量 `'✓'`（U+2713）。
  static const String glyph = '✓';
}
