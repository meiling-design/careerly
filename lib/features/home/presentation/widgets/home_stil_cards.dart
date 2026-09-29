import 'package:flutter/material.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../home_content.dart';

/// 首页 2×2 卡片区。
///
/// 真值来源：Figma `HomePage` L1103-1131（数据在 L994-1023）。
///
/// ```text
/// 容器   Column(gap 5)
/// 每行   Row(gap 5, height 180)  → 单卡 宽 (350−5)/2 = 172.5 · 高 180
/// 卡片   r28 · padding 18 · rgba(255,255,255,0.68) · 描边 1.5px rgba(255,255,255,0.25)
///        · 0 8px 20px rgba(155,177,201,0.25)
/// 内部   Column(space-between)  →  图标底板 / 文字 / 右下箭头
/// 底板   48×48 · r14 · 90deg 渐变（四张各不相同）· 20×20 白色描边字形
/// ```
///
/// ## ⚠️ 这不是 Glass 材质
///
/// Figma 这四张卡的底是 `rgba(255,255,255,0.68)`，**没有 `backdrop-filter`**
/// —— 与 `S.glass`（`GlassSurface`）同底色但**没有模糊**。
/// 故这里用 [DecoratedBox] 而非 [GlassSurface]：用 Glass 会多出一层
/// 设计稿没有的模糊，属于「修改视觉设计」，违反 D64 ①bis。
///
/// ## ⚠️ 「今日一句」卡不可点
///
/// Figma 里该卡的 `onClick` 是 `undefined`（`cursor: default`），
/// 故不给按压反馈。它在三态里都是同一张陪伴卡。
class HomeStilCards extends StatelessWidget {
  const HomeStilCards({
    super.key,
    required this.cards,
    this.onOpenAi,
    this.onOpenAnalysis,
    this.onOpenGrowth,
  });

  final List<HomeStilCardData> cards;

  /// 「问问AI」卡的点击目标（AI Tab）。
  final VoidCallback? onOpenAi;

  /// 「当前状态」卡的点击目标（分析 Tab）。
  final VoidCallback? onOpenAnalysis;

  /// 「最近成长」卡的点击目标。
  ///
  /// ⚠️ Figma 是 `go('cap-change')`（能力变化页）—— 按 IA §2.2
  /// 该页属于「我的 → 成长足迹」内部。当前落到「我的」Tab，
  /// 见 [HomeCardTarget.growth] 与 **待裁决 · D81**。
  final VoidCallback? onOpenGrowth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < cards.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : _StilMetrics.rowGap,
            ),
            child: SizedBox(
              height: _StilMetrics.cardHeight,
              child: Row(
                children: <Widget>[
                  Expanded(child: _card(cards[i])),
                  const SizedBox(width: _StilMetrics.columnGap),
                  Expanded(
                    child: i + 1 < cards.length
                        ? _card(cards[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _card(HomeStilCardData data) {
    // 目标由数据给出（不是从标题反推）—— 同一张卡在三态里去同一个地方。
    final VoidCallback? onTap = switch (data.target) {
      null => null,
      HomeCardTarget.ai => onOpenAi,
      HomeCardTarget.analysis => onOpenAnalysis,
      HomeCardTarget.growth => onOpenGrowth,
    };

    final Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.homeCardFill,
        borderRadius: AppRadius.borderXxl,
        boxShadow: AppShadows.homeStilCard,
      ),
      child: CustomPaint(
        // 描边用 foregroundPainter：Figma 把它画成一层覆盖在卡片之上的
        // 独立层（`position:absolute; inset:0`），压在内容之上。
        // 用 `Border` 会占掉内容区 1.5px，与设计稿的内边距不一致。
        foregroundPainter: const _StilCardEdgePainter(),
        child: Padding(
          padding: const EdgeInsets.all(_StilMetrics.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Figma：底板 `alignSelf: center` —— 在左对齐的卡片里水平居中。
              Align(
                alignment: Alignment.topCenter,
                child: _IconBadge(
                  size: _StilMetrics.badgeSize,
                  background: data.iconBackground,
                  icon: data.icon,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.title,
                    style: AppTypography.homeCardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: _StilMetrics.titleGap),
                  for (int i = 0; i < data.lines.length; i++)
                    Text(
                      data.lines[i],
                      style: AppTypography.onSurfaceVariant(
                        data.isQuote
                            ? AppTypography.homeCardDesc.copyWith(
                                fontWeight: FontWeight.w400,
                              )
                            : AppTypography.homeCardDesc,
                        // 高亮只作用于**最后一行**（Figma 逐卡的取值）；
                        // 单行的「今日一句」卡因此整行高亮。
                        i == data.lines.length - 1 && data.lineAccent != null
                            ? data.lineAccent!
                            : AppColors.homeCardDesc,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Icon(
                  // Figma 是自绘的双向斜箭头路径（`arrowUR`）。
                  // 用 Material 字形近似，同 D58 / **D72** 的处置。
                  Icons.open_in_full,
                  size: _StilMetrics.arrowSize,
                  color: AppColors.homeCardTitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return surface;
    return CareerlyPressFeedback(onTap: onTap, child: surface);
  }
}

/// 渐变图标底板。
class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.size,
    required this.background,
    required this.icon,
  });

  final double size;
  final LinearGradient background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: background,
        borderRadius: AppRadius.borderSm,
      ),
      child: Center(
        child: Icon(
          icon,
          size: _StilMetrics.glyphSize,
          color: AppColors.textInverse,
        ),
      ),
    );
  }
}

/// 卡片描边层：`1.5px solid rgba(255,255,255,0.25)` + 圆角 28。
class _StilCardEdgePainter extends CustomPainter {
  const _StilCardEdgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadius.xxl),
    ).deflate(_StilMetrics.borderWidth / 2);

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _StilMetrics.borderWidth
        ..color = AppColors.homeCardBorder,
    );
  }

  @override
  bool shouldRepaint(_StilCardEdgePainter oldDelegate) => false;
}

/// 本区块的内部几何（Figma 原值）。
abstract final class _StilMetrics {
  /// Figma：每行 `height: 180`。
  static const double cardHeight = 180;

  /// Figma：`gap: 5`（行与列都是 5）。
  static const double rowGap = 5;
  static const double columnGap = 5;

  /// Figma：卡片 `padding: 18`。
  static const double cardPadding = 18;

  /// Figma：描边 `1.5px`。
  static const double borderWidth = 1.5;

  /// Figma：图标底板 `48×48`，圆角 `14`。
  static const double badgeSize = 48;

  /// Figma：底板内 SVG 为 `20×20`。
  static const double glyphSize = 20;

  /// Figma：标题与描述之间 `margin-bottom: 4`。
  static const double titleGap = 4;

  /// Figma：箭头 `16×16`。
  static const double arrowSize = 16;
}
