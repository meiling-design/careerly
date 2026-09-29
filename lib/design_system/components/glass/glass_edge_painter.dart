import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// inset 高光的贴边方向。
enum GlassEdge { top, bottom, left, right }

/// 一层 inset 高光。
///
/// CSS 的 `inset <dx> <dy> 0 <color>` 在 blur / spread 均为 0 时，
/// 就是「沿某条边、向内 N 像素的一条实心色带」，
/// 因此只需要 `(edge, color, thickness)` 三个量即可完整表达。
///
/// 用 record 而不是 class：record 自带结构化相等，
/// 让 [GlassEdgePainter.shouldRepaint] 能逐层比较。
typedef GlassHighlight = ({GlassEdge edge, Color color, double thickness});

/// 绘制 Glass 材质的描边与 inset 高光。
///
/// ## 为什么需要它（Known Issue K5）
///
/// Flutter 的 `BoxShadow` **不支持 `inset`**，而 Figma 的 Glass 材质
/// 主要靠 inset 高光撑起「玻璃厚度」：
///
/// ```css
/// inset 0 1.5px 0 rgba(255,255,255,0.62)   /* 顶部内高光，视觉主导 */
/// inset 0 -1px 0 rgba(255,255,255,0.12)
/// inset 1px 0 0 rgba(255,255,255,0.18)
/// inset -1px 0 0 rgba(255,255,255,0.10)
/// ```
///
/// 依据 Baseline §1.2「Figma 有视觉但 Flutter 没有对应实现方式 → 重新实现，
/// 而不是放弃视觉」，这里用最贴近 CSS 语义的方式重绘：
/// **裁剪到圆角矩形，再沿指定边画一条内缩色带**。
///
/// > ⚠️ 本类由 `CareerlyNavigationBar` 内的同名私有实现泛化而来（Phase 2 批 1）。
/// > 批 3 会把导航栏切到本类，届时两处重复实现合并为一处。
class GlassEdgePainter extends CustomPainter {
  const GlassEdgePainter({
    required this.radius,
    required this.borderColor,
    required this.borderWidth,
    this.highlights = const <GlassHighlight>[],
  });

  /// 圆角半径。要求**四角一致**——Figma 的所有 Glass 面都是均匀圆角。
  final double radius;

  /// 描边颜色。
  final Color borderColor;

  /// 描边宽度。Figma 的 Glass 多为 `0.5` 或 `1`。
  final double borderWidth;

  /// inset 高光层。**由外到内**的顺序不影响结果（各层不重叠）。
  final List<GlassHighlight> highlights;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // 高光：裁剪到形状内，沿边画带。
    if (highlights.isNotEmpty) {
      canvas.save();
      canvas.clipRRect(shape);
      for (final GlassHighlight h in highlights) {
        final Rect band = switch (h.edge) {
          GlassEdge.top => Rect.fromLTWH(0, 0, size.width, h.thickness),
          GlassEdge.bottom => Rect.fromLTWH(
            0,
            size.height - h.thickness,
            size.width,
            h.thickness,
          ),
          GlassEdge.left => Rect.fromLTWH(0, 0, h.thickness, size.height),
          GlassEdge.right => Rect.fromLTWH(
            size.width - h.thickness,
            0,
            h.thickness,
            size.height,
          ),
        };
        canvas.drawRect(band, Paint()..color = h.color);
      }
      canvas.restore();
    }

    // 描边最后画，压在高光之上。
    // 描边以路径为中心线，内缩半个线宽才能让整条线落在形状内。
    if (borderWidth > 0) {
      final double inset = borderWidth / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            inset,
            inset,
            size.width - borderWidth,
            size.height - borderWidth,
          ),
          Radius.circular(radius - inset),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = borderColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GlassEdgePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      !listEquals(oldDelegate.highlights, highlights);
}
