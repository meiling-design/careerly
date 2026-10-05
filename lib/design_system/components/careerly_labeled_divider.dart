import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// 中间带文案的分隔线（`——— 文案 ———`）。
///
/// 真值来源：2026-10-04 重新导出的 Figma ——
/// `OnLogin`（`src/App.tsx` L588-592）与 `OnRegister`（L769-773）。
///
/// ```text
/// flex items-center gap-[25px]   ← 登录页
/// flex items-center gap-[13px]   ← 注册页
/// ├── h-px flex-1  #c9bcd5
/// ├── 文案（16 / w400 / lh 1.4 / #bdb0cc，nowrap）
/// └── h-px flex-1  #c9bcd5
/// ```
///
/// ## 为什么两页的间距不同却只做一个组件
///
/// 依据 `CLAUDE.md` §8.4 的「变体用参数」：两处的**行为完全相同**
/// （同一段静态布局），只有「线 ↔ 文案」的间距不同，
/// 因此用 [labelGap] 参数表达，而不是拆成两个组件，
/// 也不是把两个值硬塞成同一个 —— 见 [labelGap] 的说明。
///
/// ## 文案
///
/// 两页的文案**由调用方传入**，因为它们在 Figma 里本就不同：
///
/// | 页面 | 文案 |
/// |---|---|
/// | 登录页 | `sign in with`（**没有** `Or`） |
/// | 注册页 | `Or sign up with` |
///
/// ⚠️ 登录页少了 `Or` 且是全小写，这是设计稿原样，**不要顺手补齐**。
/// 两页还有一处不对称：注册页把社交按钮写成「Or sign up with」，
/// 而按钮本身是「登录」还是「注册」的语义，这里保持原样不解读。
class CareerlyLabeledDivider extends StatelessWidget {
  const CareerlyLabeledDivider({
    super.key,
    required this.label,
    required this.labelGap,
  });

  /// 分隔线中间的文案。
  final String label;

  /// 「线 ↔ 文案」的横向间距。
  ///
  /// ⚠️ **两页取值不同，故不给默认值**（给了默认值就意味着另一页必然是错的）：
  ///
  /// ```text
  /// 登录页  25   Figma `gap-[25px]`
  /// 注册页  13   Figma `gap-[13px]`
  /// ```
  ///
  /// 两个值都**不在** 8pt 刻度上，同 `AppSpacing.buttonStack` 的处置：
  /// 不就地取整，由调用方按页面私有常量传入。
  final double labelGap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: _Rule()),
        SizedBox(width: labelGap),
        // Figma 是 `whiteSpace: nowrap` —— 文案绝不被压缩或折行。
        Text(
          label,
          style: AppTypography.authDividerLabel,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
        SizedBox(width: labelGap),
        const Expanded(child: _Rule()),
      ],
    );
  }
}

/// 分隔线本体：`h-px`，颜色 `#c9bcd5`。
///
/// 用 [SizedBox] + [ColoredBox] 而不是 `Divider` ——
/// Figma 写的是 `height: 1px` 的**实心块**，而 Material `Divider`
/// 自带 `thickness` / `indent` 等默认值与主题耦合，属于「M3 默认样式」，
/// 按 §8.4「与 Material 3 的边界」不采用。
class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _DividerMetrics.lineHeight,
      child: ColoredBox(color: AppColors.authDividerLine),
    );
  }
}

/// 组件内部常量。
abstract final class _DividerMetrics {
  /// Figma：`h-px` = 1。
  static const double lineHeight = 1;
}
