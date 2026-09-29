import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../home_content.dart';

/// 首页 Hero 卡。
///
/// 真值来源：Figma `HomePage` L1047-1101。
///
/// ```text
/// 卡片   190 高 · r36 · 151.5deg 品牌渐变 · 0 20px 48px rgba(79,126,245,0.28)
///        overflow: hidden（装饰圆与弧线被裁切 —— 是设计意图，不是裁错）
/// 装饰   圆1 144×144 @ left230/top141 · 圆2 206×206 @ left-24/top-38
///        弧线 173×173 @ left190/top-17
/// 左侧   小标签 → 主标题 → 说明行 → 深色小按钮
/// 右侧   大号读数 + 单位 + 标签 + 变化行
/// ```
///
/// ## ⚠️ 三态共用同一套几何，只有文字不同（D64 ①bis）
///
/// 本组件**不认识** [HomeStage] —— 它只渲染传入的 [HomeHeroContent]。
/// 因此「只替换文字内容，不要修改 figma 视觉设计」在结构上成立：
/// 视觉层没有可以分叉的地方。
///
/// ## ⚠️ 右侧读数区在 State 01 / 02 **整体不渲染**
///
/// 那两态没有匹配度可言。依 `CLAUDE.md` §7「不编造产品数据」，
/// 这里**不**用 `0` / `--` / `暂无` 占位，而是整块不画 ——
/// 装饰弧线**照常保留**（它与分数本就不成比例，是纯装饰）。
/// 处置登记 **待裁决 · D77**。
///
/// ## ⚠️ 一处与 Figma 不同的取值：右侧读数改为贴右
///
/// Figma 用 `left: 238; width: 97` 绝对定位，右边界 335 —— 在 390 宽设计稿
/// 的 350 卡片内正好留 15px。但窄机型（360dp → 卡片 320）会**溢出 15px**，
/// 被 `overflow: hidden` 裁掉读数。
///
/// 因此这里改锚**右边界**（`right: 15`）：在设计宽度下位置**逐位相同**
/// （350 − 15 − 97 = 238），窄屏则自动内收。
/// 登记 **待裁决 · D77**。
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key, required this.content, this.onAction});

  final HomeHeroContent content;

  /// 「查看分析」/「上传简历」的点击回调。
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _HeroMetrics.height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.homeHeroGradient,
          borderRadius: AppRadius.borderHero,
          boxShadow: AppShadows.homeHero,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderHero,
          child: Stack(
            children: <Widget>[
              const Positioned(
                left: _HeroMetrics.circleSmallLeft,
                top: _HeroMetrics.circleSmallTop,
                child: _HeroCircle(
                  size: _HeroMetrics.circleSmallSize,
                  color: AppColors.homeHeroCircleFaint,
                ),
              ),
              const Positioned(
                left: _HeroMetrics.circleLargeLeft,
                top: _HeroMetrics.circleLargeTop,
                child: _HeroCircle(
                  size: _HeroMetrics.circleLargeSize,
                  color: AppColors.homeHeroCircleSoft,
                ),
              ),
              const Positioned(
                left: _HeroMetrics.arcLeft,
                top: _HeroMetrics.arcTop,
                width: _HeroMetrics.arcSize,
                height: _HeroMetrics.arcSize,
                child: CustomPaint(painter: _HeroArcPainter()),
              ),
              Positioned(
                left: _HeroMetrics.contentLeft,
                top: _HeroMetrics.contentTop,
                width: _HeroMetrics.contentWidth,
                child: _HeroLeftColumn(content: content, onAction: onAction),
              ),
              // 见类文档：没有匹配度数据时整块不渲染。
              if (content.score != null)
                Positioned(
                  right: _HeroMetrics.scoreRight,
                  top: _HeroMetrics.scoreTop,
                  width: _HeroMetrics.scoreWidth,
                  child: _HeroScoreBlock(content: content),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 纯色装饰圆。
class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// 左侧：小标签 → 主标题 → 说明行 → 按钮。
class _HeroLeftColumn extends StatelessWidget {
  const _HeroLeftColumn({required this.content, required this.onAction});

  final HomeHeroContent content;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              content.label,
              style: AppTypography.homeHeroLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: _HeroMetrics.labelGap),
            // ⚠️ Figma 把岗位名拆成 `AI `（Roboto）与 `产品经理`（Noto）
            // 两个 span，只是字体族差异。依 §8.3（中文统一 Noto Sans SC），
            // 这里**整句走中文字体族**，不按字符混排两族。
            Text(
              content.title,
              style: AppTypography.homeHeroTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (content.meta.isNotEmpty) ...<Widget>[
              const SizedBox(height: _HeroMetrics.metaGap),
              // ⚠️ Figma 此处是「时钟图标 + 日期」。
              // State 01 / 02 的该槽位是说明句（无日期、无时钟），
              // 故图标只在有日期语义时才有意义 —— 见 **D77**。
              Text(
                content.meta,
                style: AppTypography.homeHeroMeta,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        const SizedBox(height: _HeroMetrics.blockGap),
        _HeroActionButton(label: content.actionLabel, onPressed: onAction),
      ],
    );
  }
}

/// 卡内的深色小按钮。
class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CareerlyPressFeedback(
      onTap: onPressed,
      child: Container(
        height: _HeroMetrics.actionHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.borderPill,
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style: AppTypography.homeHeroButton,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// 右侧读数区：大号分数 + `%` + 标签 + 变化行。
class _HeroScoreBlock extends StatelessWidget {
  const _HeroScoreBlock({required this.content});

  final HomeHeroContent content;

  @override
  Widget build(BuildContext context) {
    final int score = content.score!;
    final int? delta = content.scoreDelta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: _HeroMetrics.scoreLineHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // Figma 给数字与 `%` 都写了绝对定位的微调量
              // （`top: -0.16` / `left: -0.18` 与 `left: 74.9`），
              // 那是原型的排版补偿。这里用基线对齐表达同一效果。
              Text('$score', style: AppTypography.homeHeroScore),
              Positioned(
                left: _HeroMetrics.scoreUnitLeft,
                bottom: 0,
                child: const Text('%', style: AppTypography.homeHeroScoreUnit),
              ),
            ],
          ),
        ),
        const Text('匹配度', style: AppTypography.homeHeroScoreLabel),
        // Figma：`▲ 较上次+8%`（「较上次」与「+8%」之间无空格）。
        // 变化量缺失时**不渲染这一行** —— 同样不编造 `+0%`。
        if (delta != null)
          Text('▲ 较上次${delta > 0 ? '+' : ''}$delta%',
              style: AppTypography.homeHeroDelta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

/// Hero 卡的装饰弧线。
///
/// Figma 是两条 SVG 路径（`arcTrack` / `arcFill`），本质是**同一个圆环**：
///
/// ```text
/// 轨道  完整圆环 · 外半径 86.5 / 内半径 17.3 · #F1F3F9 @0.95
/// 填充  同一圆环 · 从 12 点起**顺时针 252°** · 水平渐变 #A39EFA → #F7A8D8
/// ```
///
/// Flutter 没有「圆环 + 扇区」的现成画法，用**粗描边的圆弧**等价表达：
/// 半径取内外半径的中值 `(86.5 + 17.3) / 2 = 51.9`，线宽取 `86.5 − 17.3 = 69.2`。
///
/// ⚠️ 252° 与读数 `86` **不成比例**（252 / 360 = 70%）——
/// 原稿如此，**不得据分数反推角度**。
class _HeroArcPainter extends CustomPainter {
  const _HeroArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius =
        (_HeroMetrics.arcOuterRadius + _HeroMetrics.arcInnerRadius) / 2;
    final double stroke =
        _HeroMetrics.arcOuterRadius - _HeroMetrics.arcInnerRadius;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.homeHeroArcTrack;
    canvas.drawCircle(center, radius, track);

    final Paint fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = AppColors.homeHeroArcGradient.createShader(
        Offset.zero & size,
      );

    // Flutter 的 0 弧度在 3 点方向、顺时针为正；
    // Figma 的弧从 12 点起 —— 即 -90°。
    canvas.drawArc(
      rect,
      -math.pi / 2,
      _HeroMetrics.arcSweepDegrees * math.pi / 180,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(_HeroArcPainter oldDelegate) => false;
}

/// Hero 卡的内部几何（Figma 原值）。
abstract final class _HeroMetrics {
  /// Figma：卡片 `height: 190`。
  static const double height = 190;

  /// Figma：装饰圆1 `left: 230; top: 141; 144×144`。
  static const double circleSmallLeft = 230;
  static const double circleSmallTop = 141;
  static const double circleSmallSize = 144;

  /// Figma：装饰圆2 `left: -24; top: -38; 206×206`。
  static const double circleLargeLeft = -24;
  static const double circleLargeTop = -38;
  static const double circleLargeSize = 206;

  /// Figma：弧线容器 `left: 190; top: -17; 173×173`。
  static const double arcLeft = 190;
  static const double arcTop = -17;
  static const double arcSize = 173;

  /// 弧线内外半径（取自 `arcTrack` / `arcFill` 的几何）。
  static const double arcOuterRadius = 86.5;
  static const double arcInnerRadius = 17.3;

  /// 弧线扫过的角度。Figma 原值 —— 与读数无关，见 [_HeroArcPainter]。
  static const double arcSweepDegrees = 252;

  /// Figma：左侧内容 `left: 23; top: 31; width: 160`。
  static const double contentLeft = 23;
  static const double contentTop = 31;
  static const double contentWidth = 160;

  /// Figma：左侧内层 `gap: 8`。
  static const double labelGap = 8;

  /// 主标题与说明行之间 —— Flutter 侧取值（Figma 未给，见 D77）。
  static const double metaGap = 4;

  /// Figma：内层与按钮之间 `gap: 19`。
  static const double blockGap = 19;

  /// Figma：按钮 `height: 30; padding 0 16`。
  static const double actionHeight = 30;

  /// Figma：右侧读数区 `left: 238; width: 97`（此处改锚右边界，见类文档）。
  static const double scoreWidth = 97;
  static const double scoreRight = 350 - 238 - 97;
  static const double scoreTop = 34;

  /// Figma：数字容器 `height: 57`。
  static const double scoreLineHeight = 57;

  /// Figma：`%` 的 `left: 74.9`。
  static const double scoreUnitLeft = 74.9;
}
