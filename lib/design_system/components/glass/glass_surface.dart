import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../tokens/tokens.dart';
import '../careerly_press_feedback.dart';
import 'glass_edge_painter.dart';
import 'glass_filters.dart';

/// Careerly Glass 材质的两种标准变体。
///
/// 真值来源：`src/App.tsx` 行 25–34 的 `S` 对象。
enum GlassVariant {
  /// `S.glass` —— 标准 Glass 卡片。
  ///
  /// `rgba(255,255,255,0.68)` · 描边 `1px rgba(255,255,255,0.55)` ·
  /// `blur(24px)` · `0 8px 32px rgba(79,126,245,0.08)`
  standard,

  /// `S.glassLight` —— 轻量 Glass（小图标按钮、次级容器）。
  ///
  /// `rgba(255,255,255,0.45)` · 描边 `1px rgba(255,255,255,0.4)` ·
  /// `blur(16px)` · `0 4px 16px rgba(79,126,245,0.05)`
  light,
}

/// Careerly 的 Glass 材质基元 —— **整个视觉体系的地基**。
///
/// 卡片、底部导航、Bottom Sheet、AI 输入条等一切「半透明玻璃面」
/// 都由它派生，避免各页面自行拼 `BackdropFilter` + 描边。
///
/// ```dart
/// GlassSurface(
///   padding: const EdgeInsets.all(AppSpacing.mdLg),
///   child: Text('岗位匹配变化', style: AppTypography.subtitle),
/// )
/// ```
///
/// ## 它解决了什么
///
/// Figma 的 Glass 材质由三部分组成，三者在 Flutter 里都不是开箱即用的：
///
/// | Figma | Flutter | 本组件的处理 |
/// |---|---|---|
/// | `backdrop-filter: blur(24px)` | 需 `BackdropFilter` + 裁剪 | 内建，见 [GlassFilters] |
/// | 多层 `inset box-shadow` | **`BoxShadow` 不支持 inset** | [GlassEdgePainter] 重绘 |
/// | 0.5–1px 半透明白描边 | 需 `CustomPaint` 才能压在高光之上 | [GlassEdgePainter] 一并绘制 |
///
/// ## 关于 `highlights`
///
/// `S.glass` / `S.glassLight` 本身**没有** inset 高光，因此默认为空。
/// 需要高光的场景（AI 对话卡、底部导航、选中态药丸）显式传入，
/// 例如 `inset 0 1.5px 0 rgba(255,255,255,0.90)`：
///
/// ```dart
/// GlassSurface(
///   highlights: <GlassHighlight>[
///     (edge: GlassEdge.top, color: Color(0xE6FFFFFF), thickness: 1.5),
///   ],
///   child: ...,
/// )
/// ```
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.variant = GlassVariant.standard,
    this.radius = AppRadius.xl,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.highlights = const <GlassHighlight>[],
    this.shadow,
    this.borderWidth = _defaultBorderWidth,
  });

  /// Figma 的 Glass 描边统一为 `1px`。
  static const double _defaultBorderWidth = 1;

  /// 玻璃面内容。
  final Widget child;

  /// 材质变体。
  final GlassVariant variant;

  /// 圆角半径。
  ///
  /// 取 `double` 而非 `BorderRadius`：Figma 的所有 Glass 面都是**均匀圆角**，
  /// 而 inset 高光需要按单一半径裁剪，非均匀圆角无法正确表达。
  final double radius;

  /// 内容内边距。为 `null` 时不额外包裹 `Padding`。
  final EdgeInsetsGeometry? padding;

  /// 固定宽度。为 `null` 时由内容与父级约束决定。
  final double? width;

  /// 固定高度。为 `null` 时由内容决定。
  final double? height;

  /// 点击回调。为 `null` 时不可点击、也不显示按压反馈。
  final VoidCallback? onTap;

  /// inset 高光层。默认为空（与 `S.glass` 一致）。
  final List<GlassHighlight> highlights;

  /// 投影覆盖。为 `null` 时按 [variant] 取默认值
  /// （[GlassVariant.standard] → `AppShadows.glass`，
  /// [GlassVariant.light] → `AppShadows.glassLight`）。
  final List<BoxShadow>? shadow;

  /// 描边宽度。
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final bool isStandard = variant == GlassVariant.standard;

    final Color fill = isStandard
        ? AppColors.glassFill
        : AppColors.glassFillLight;
    final Color border = isStandard
        ? AppColors.glassBorder
        : AppColors.glassBorderLight;
    final List<BoxShadow> effectiveShadow = shadow ??
        (isStandard ? AppShadows.glass : AppShadows.glassLight);
    final ui.ImageFilter filter = isStandard
        ? GlassFilters.standard
        : GlassFilters.light;

    final BorderRadius borderRadius = BorderRadius.circular(radius);

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    Widget surface = DecoratedBox(
      // ⚠️ 投影必须留在 ClipRRect **之外**：放进去会被圆角裁剪一起切掉。
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: effectiveShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: filter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: borderRadius,
            ),
            child: CustomPaint(
              // 描边 + inset 高光。必须用 foregroundPainter，
              // 否则会被后画的 fill 盖住。
              foregroundPainter: GlassEdgePainter(
                radius: radius,
                borderColor: border,
                borderWidth: borderWidth,
                highlights: highlights,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );

    if (width != null || height != null) {
      surface = SizedBox(width: width, height: height, child: surface);
    }

    if (onTap != null) {
      surface = CareerlyPressFeedback(onTap: onTap, child: surface);
    }

    return surface;
  }
}
