import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'careerly_press_feedback.dart';
import 'glass/glass.dart';

/// Careerly 卡片变体。
///
/// 真值来源：`src/App.tsx` 行 139–141 的 `Card` 组件，
/// 以及各页面内联的卡片样式。
enum CareerlyCardVariant {
  /// 标准 Glass 卡片 —— 应用内**绝大多数**卡片。
  ///
  /// Figma `Card`：`rounded-3xl`（24px）+ `S.glass`。
  glass,

  /// 轻量 Glass 卡片（`S.glassLight`）。
  ///
  /// 用于次级容器、时间线卡片、设置分组。
  glassLight,

  /// 品牌渐变卡片 —— 首页 Hero、分析结果摘要、职业资产。
  ///
  /// Figma：`S.primary` 渐变 + 品牌色投影。
  brand,

  /// 纯白实底卡片（无玻璃）。
  ///
  /// Figma 的 `#f1f2f6` 类浅色块与白色信息卡。
  surface,
}

/// Careerly 卡片。
///
/// ```dart
/// CareerlyCard(
///   padding: const EdgeInsets.all(AppSpacing.mdLg),
///   onTap: () => _openDetail(),
///   child: Text('岗位匹配变化', style: AppTypography.subtitle),
/// )
/// ```
///
/// ## 为什么卡片要包一层 `GlassSurface`
///
/// Figma 的卡片 = 圆角 + Glass 材质 + 内边距，
/// 其中 Glass 材质在 Flutter 里需要 `BackdropFilter` + inset 高光重绘
/// （见 [GlassSurface] 与 Known Issue K5）。
/// 把这段固定组合收敛到本组件，业务页面就只需要关心**内容**。
///
/// ## 与 Material `Card` 的关系
///
/// 依据 Baseline §6.5，Careerly 不使用 Material `Card` 的默认视觉
/// （阴影 / surfaceTint / 外边距）。`CardTheme` 只作为兜底存在。
class CareerlyCard extends StatelessWidget {
  const CareerlyCard({
    super.key,
    required this.child,
    this.variant = CareerlyCardVariant.glass,
    this.radius = AppRadius.xl,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.width,
    this.height,
    this.highlights = const <GlassHighlight>[],
    this.shadow,
  });

  /// 卡片内容。
  final Widget child;

  /// 视觉变体。
  final CareerlyCardVariant variant;

  /// 圆角。Figma 的 `rounded-3xl` 即 `AppRadius.xl`（24）。
  final double radius;

  /// 内边距。Figma 的 `p-4` 即 `AppSpacing.md`（16）。
  final EdgeInsetsGeometry padding;

  /// 点击回调。为 `null` 时卡片不可点击、无按压反馈。
  final VoidCallback? onTap;

  /// 固定宽度。
  final double? width;

  /// 固定高度。
  final double? height;

  /// inset 高光层（仅 Glass 变体有效）。
  final List<GlassHighlight> highlights;

  /// 投影覆盖。为 `null` 时按 [variant] 取默认值。
  ///
  /// **对全部四种变体有效**：
  /// glass / glassLight → 透传给 `GlassSurface`；
  /// brand / surface → 直接用于自身的 `BoxDecoration`。
  ///
  /// ⚠️ Figma 的**品牌渐变卡片**每种用略有差异的投影
  /// （`0 8px 24px @0.25` / `0 16px 40px @0.28` / `0 20px 48px @0.28`），
  /// 目前尚未归纳成 Token。需要精确还原时由此参数传入，
  /// 待 Phase 5 / Phase 8 明确用到的档位后再收敛。
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case CareerlyCardVariant.glass:
        return GlassSurface(
          variant: GlassVariant.standard,
          radius: radius,
          padding: padding,
          width: width,
          height: height,
          onTap: onTap,
          highlights: highlights,
          shadow: shadow,
          child: child,
        );

      case CareerlyCardVariant.glassLight:
        return GlassSurface(
          variant: GlassVariant.light,
          radius: radius,
          padding: padding,
          width: width,
          height: height,
          onTap: onTap,
          highlights: highlights,
          shadow: shadow,
          child: child,
        );

      case CareerlyCardVariant.brand:
        return _SolidCard(
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadow ?? AppShadows.brand,
          ),
          radius: radius,
          padding: padding,
          width: width,
          height: height,
          onTap: onTap,
          child: child,
        );

      case CareerlyCardVariant.surface:
        return _SolidCard(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadow ?? AppShadows.sm,
          ),
          radius: radius,
          padding: padding,
          width: width,
          height: height,
          onTap: onTap,
          child: child,
        );
    }
  }
}

/// 非 Glass 变体的公共外壳：圆角裁剪 + 内边距 + 尺寸 + 按压反馈。
class _SolidCard extends StatelessWidget {
  const _SolidCard({
    required this.child,
    required this.decoration,
    required this.radius,
    required this.padding,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final BoxDecoration decoration;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Widget card = DecoratedBox(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (width != null || height != null) {
      card = SizedBox(width: width, height: height, child: card);
    }

    return CareerlyPressFeedback(onTap: onTap, child: card);
  }
}
