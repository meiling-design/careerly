import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'careerly_press_feedback.dart';

/// Careerly Chip 的语义色调。
///
/// 真值来源：`src/App.tsx` 中各类 Chip / Badge 的 `background` + 文字色，
/// 底色统一为「语义色 + 低透明度」，已固化在 `AppColors` 的
/// `*Surface` 系列 Token 中。
enum CareerlyChipTone {
  /// 中性灰。无变化、归档、次要标注。
  neutral,

  /// 品牌蓝。岗位标签、项目类型、"当前简历"。
  brand,

  /// 品牌紫。技能标签、附加岗位。
  purple,

  /// 成功绿。正向变化、高匹配。
  success,

  /// 警示橙。关键 Gap、奖项年份。
  warning,

  /// 错误红。负向变化。
  danger,

  /// 深色实底。选中态 Chip / Tab，Figma 的 `#373B4D`。
  dark,

  /// 渐变或深色**底之上**的白色半透 Chip。
  onBrand,
}

/// Chip 尺寸。
enum CareerlyChipSize {
  /// 小号：`11px / semibold`，内边距 `8 × 2`。
  small,

  /// 中号：`12px / medium`，内边距 `12 × 4`。
  medium,
}

/// Careerly Chip / 标签 / 徽标。
///
/// ```dart
/// CareerlyChip(label: '产品经理', tone: CareerlyChipTone.brand)
/// CareerlyChip(label: '关键 Gap', tone: CareerlyChipTone.warning)
/// CareerlyChip(label: '较上次 ↑ 8%', tone: CareerlyChipTone.success)
/// ```
///
/// ## 关于「涨跌徽标」
///
/// Figma 的 `TrendBadge` 按 delta 的正负自动选色调
/// （`>0` 绿 / `=0` 灰 / `<0` 红）。
/// 那是**业务判断**而不是视觉规则，因此不在这里内建：
/// 调用方按 delta 选 [CareerlyChipTone] 即可。
///
/// ## 与 Material `Chip` 的关系
///
/// 依据 Baseline §6.5，不使用 Material `Chip` 的默认视觉
/// （checkmark / 高度 / 内边距）。`ChipTheme` 只作为兜底存在。
class CareerlyChip extends StatelessWidget {
  const CareerlyChip({
    super.key,
    required this.label,
    this.tone = CareerlyChipTone.neutral,
    this.size = CareerlyChipSize.small,
    this.icon,
    this.onTap,
  });

  /// 标签文字。
  final String label;

  /// 语义色调。
  final CareerlyChipTone tone;

  /// 尺寸。
  final CareerlyChipSize size;

  /// 可选的前置图标。
  final IconData? icon;

  /// 点击回调。为 `null` 时 Chip 为纯展示。
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final CareerlyChipColors colors = _colorsFor(tone);

    final TextStyle base = size == CareerlyChipSize.small
        ? AppTypography.chipSmall
        : AppTypography.chipMedium;
    final TextStyle textStyle = AppTypography.onSurfaceVariant(
      base,
      colors.foreground,
    );

    final EdgeInsets padding = size == CareerlyChipSize.small
        ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4);

    final double iconSize = size == CareerlyChipSize.small ? 11 : 13;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: iconSize, color: colors.foreground),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Text(label, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );

    content = Padding(padding: padding, child: content);

    return CareerlyPressFeedback(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: AppRadius.borderPill,
        ),
        child: content,
      ),
    );
  }
}

/// 一个色调的前景 / 背景取值。
typedef CareerlyChipColors = ({Color background, Color foreground});

/// 色调 → 颜色。
///
/// 底色一律取自 `AppColors` 的 `*Surface` Token，
/// 不在组件里拼 `withOpacity`。
CareerlyChipColors _colorsFor(CareerlyChipTone tone) {
  return switch (tone) {
    CareerlyChipTone.neutral => (
      background: AppColors.neutralSurface,
      foreground: AppColors.textSecondary,
    ),
    CareerlyChipTone.brand => (
      background: AppColors.primaryBlueSurface,
      foreground: AppColors.primaryBlue,
    ),
    CareerlyChipTone.purple => (
      background: AppColors.primaryPurpleSurface,
      foreground: AppColors.primaryPurple,
    ),
    CareerlyChipTone.success => (
      background: AppColors.successSurface,
      foreground: AppColors.success,
    ),
    CareerlyChipTone.warning => (
      background: AppColors.warningSurface,
      foreground: AppColors.warning,
    ),
    CareerlyChipTone.danger => (
      background: AppColors.dangerSurface,
      foreground: AppColors.danger,
    ),
    CareerlyChipTone.dark => (
      background: AppColors.surfaceDark,
      foreground: AppColors.textInverse,
    ),
    CareerlyChipTone.onBrand => (
      background: AppColors.onBrandSurface,
      foreground: AppColors.textInverse,
    ),
  };
}
