import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/career_assets_provider.dart';
import 'profile_assets_loader.dart';

/// 能力页 —— 「我的」→ 职业资产 → 能力。
///
/// 真值来源：Figma `CapabilityPage`（`src/App.tsx` L3865-3908）。
///
/// ```text
/// TopBar「我的能力」（右侧无计数）              L3868
/// 列表 px-5 pb-6 space-y-4                     L3869
///   ├ Card p-5：能力雷达图                      L3871-3873
///   │    标题行（15/w700 + 图例「当前 / 上次」）  L3873-3878
///   │    RadarChart 220×220（居中）             L3879
///   └ Card p-5：能力详情                        L3881-3907
///        标题行（15/w700 + 「查看变化 →」）       L3883-3885
///        每条能力：名 + 分值 + 增量胶囊            L3886-3889
///                   双层条（上次 / 当前）          L3897-3902
///                   脚注「上次 80 → 现在 85」      L3904
/// ```
///
/// ## 归属
///
/// IA §13「职业资产 → 能力」/ §21「能力 → 我的」。
///
/// ⚠️ 与**成长足迹**（[AppRoutes.profileGrowthRecord]）不是一回事：
/// 本页是**当前快照**（分值 + 相对上次的增量），成长足迹是**事件时间线**。
/// 两者数据源不同（本页读 `CareerAssets.capabilities`），**不互相推导**。
///
/// ## ⚠️ 与 Figma 的两处**有意偏离**（验收时须逐条对照）
///
/// | # | Figma | 本页 | 依据 |
/// |---|---|---|---|
/// | 1 | 能力详情卡右上角有「查看变化 →」，跳 `cap-change` | **不渲染该入口** | `cap-change`（能力变化页）**无路由** —— 依 **D81** 它属于「我的 → 成长足迹 → Detail」内部，且其口径仍 **待裁决**（`TODO.md` §3.1）。与职业资产页两张分组卡的「查看全部」同一处置：**落点不存在的入口不渲染**，而不是留一个死链 |
/// | 2 | 条目错峰展开（`animationDelay` 100 + i×80ms / 200 + i×80ms） | 双层条**同时**展开 | 错峰依赖 `AppMotion.stagger` —— 它是**待裁决值**（**D36**：40ms 落在 spec 的 50–80ms 之外）且**全库 0 处引用**。本轮不把它引入新页面；已交付的项目 / 工作经历列表同样未做错峰进入 |
///
/// ## ⚠️ 动画时长的一处**归纳**（非偏离）
///
/// Figma 的 `bar-grow` 是 **600ms**（`src/index.css` L193）。
/// 本页用 [AppMotion.reveal]（**550ms**，其声明区间为 400–700ms）——
/// 与 `AppRadius` / `AppMotion` 的既定做法一致：**原型数值重新归纳进阶梯，
/// 不 1:1 抄**。差值 50ms，验收时如需逐位一致，改 Token 一处即可。
///
/// ## 雷达图的降级规则（**不是** Figma 里的东西，是本页补的边界）
///
/// 少于 **3** 个维度时**不渲染**雷达卡 —— 2 个轴画出来是一条线、
/// 1 个轴是一个点，都不构成「雷达图」。此时只剩能力详情卡，
/// 页面仍然成立。见 [_CapabilityContent.hasRadar]。
class CapabilityPage extends StatefulWidget {
  const CapabilityPage({super.key});

  @override
  State<CapabilityPage> createState() => _CapabilityPageState();
}

class _CapabilityPageState extends State<CapabilityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ensureCareerAssetsLoaded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final CareerAssetsProvider provider = context.watch<CareerAssetsProvider>();

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(title: '我的能力', onBack: () => careerlyBack(context)),
          Expanded(
            child: CareerlyAsyncStateView<CareerAssets>(
              state: provider.state,
              onRetry: provider.load,
              loadingMessage: '正在读取能力数据',
              // D99 规则落地（2026-09-29 产品侧确认）：空数据不进入整页 Empty，
              // 能力详情卡骨架常驻、卡内换空文案；雷达图仍受少于 3 轴
              // 不渲染的降级规则约束（0 值雷达是视觉误导）。
              builder: (BuildContext context, CareerAssets assets) =>
                  _CapabilityContent(items: assets.capabilities),
            ),
          ),
        ],
      ),
    );
  }
}

/// 能力页正文：雷达卡 + 能力详情卡。
class _CapabilityContent extends StatelessWidget {
  const _CapabilityContent({required this.items});

  final List<Capability> items;

  /// 是否渲染雷达卡。理由见 [CapabilityPage] 类顶的降级规则。
  bool get hasRadar => items.length >= _CapabilityMetrics.radarMinAxes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _CapabilityMetrics.inset,
        0,
        _CapabilityMetrics.inset,
        _CapabilityMetrics.bottom,
      ),
      children: <Widget>[
        if (hasRadar) ...<Widget>[
          _RadarCard(items: items),
          const SizedBox(height: _CapabilityMetrics.cardGap),
        ],
        _CapabilityDetailCard(items: items),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 能力雷达图卡
// ---------------------------------------------------------------------------

/// 雷达图卡。Figma L3871-3880。
class _RadarCard extends StatelessWidget {
  const _RadarCard({required this.items});

  final List<Capability> items;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_CapabilityMetrics.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  '能力雷达图',
                  style: AppTypography.profileCapabilityCardTitle,
                ),
              ),
              const SizedBox(width: _CapabilityMetrics.titleLegendGap),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const _LegendItem(
                    color: AppColors.primaryBlue,
                    label: '当前',
                  ),
                  const SizedBox(width: _CapabilityMetrics.legendGap),
                  const _LegendItem(
                    color: AppColors.profileRadarLegendPrev,
                    label: '上次',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: _CapabilityMetrics.titleChartGap),
          Center(child: _CapabilityRadar(items: items)),
        ],
      ),
    );
  }
}

/// 图例的一项：12×2 的圆头短线 + 10px 标签。Figma L3876-3877。
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: _CapabilityMetrics.legendLineWidth,
          height: _CapabilityMetrics.legendLineHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.borderPill,
          ),
        ),
        const SizedBox(width: _CapabilityMetrics.legendLineGap),
        Text(label, style: AppTypography.profileRadarLegendLabel),
      ],
    );
  }
}

/// 能力雷达图本体。Figma `RadarChart`（`src/App.tsx` L337-356）。
///
/// ```text
/// 画布     220×220，圆心 (110,110)，半径 76
/// 网格     4 层多边形（25% / 50% / 75% / 100%）
/// 辐条     圆心 → 每个轴的外圈端点
/// 上次     多边形，填充 8% 紫、描边 30% 紫、1.5px
/// 当前     多边形，渐变填充 + 渐变描边、2px
/// 顶点     白底 + 品牌蓝描边、半径 4
/// 标签     轴名，位于 1.24r 处，9.5px / w600
/// ```
///
/// ## 两个 Flutter 侧的处置
///
/// | # | 项 | 处置 |
/// |---|---|---|
/// | 1 | 缺 `previousScore` 的轴 | 该轴的上次值**退回当前值**（画成与当前重合），而不是丢进 0 —— 丢 0 会让多边形塌向圆心，视觉上等于「上次是零能力」 |
/// | 2 | 渐变的作用域 | SVG 的 `objectBoundingBox` 是**每条 path 各自的包围盒**，Flutter 的 `createShader` 收的是一个矩形；这里传**整个画布**（220×220）。多边形接近满幅，两种口径的可见差异 < 1px |
///
/// 它是**本页私有**的，没有进 `design_system`：目前**只有这一个消费方**，
/// 且它的入参是 [Capability]（业务模型）。若出现第二个消费方，
/// 再按 `CLAUDE.md` §8.4 决定它属 primitive 还是产品级共享组件。
class _CapabilityRadar extends StatelessWidget {
  const _CapabilityRadar({required this.items});

  final List<Capability> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _CapabilityMetrics.radarSize,
      height: _CapabilityMetrics.radarSize,
      child: CustomPaint(painter: _RadarPainter(items: items)),
    );
  }
}

/// 雷达图的绘制。
class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.items});

  final List<Capability> items;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.length < _CapabilityMetrics.radarMinAxes) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    // 半径按画布短边等比换算 —— Figma 是 220 画布里的 76。
    final double radius =
        size.shortestSide *
        (_CapabilityMetrics.radarRadius / _CapabilityMetrics.radarSize);
    final int axes = items.length;

    /// 第 [index] 个轴的角度。Figma 从正上方开始（`- Math.PI / 2`）顺时针铺开。
    double angleOf(int index) =>
        index * 2 * math.pi / axes - math.pi / 2;

    /// 某轴在比例 [ratio]（0–1）处的坐标。
    Offset pointAt(int index, double ratio) => Offset(
      center.dx + radius * ratio * math.cos(angleOf(index)),
      center.dy + radius * ratio * math.sin(angleOf(index)),
    );

    Path polygonOf(List<double> ratios) {
      final Path path = Path();
      for (int i = 0; i < ratios.length; i++) {
        final Offset p = pointAt(i, ratios[i]);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      return path..close();
    }

    // ── 网格：4 层同心多边形 ─────────────────────────────────────────
    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _CapabilityMetrics.gridStrokeWidth
      ..color = AppColors.profileRadarGridStroke;
    for (final double ratio in _CapabilityMetrics.radarGridRatios) {
      canvas.drawPath(
        polygonOf(List<double>.filled(axes, ratio)),
        gridPaint,
      );
    }

    // ── 辐条 ────────────────────────────────────────────────────────
    final Paint spokePaint = Paint()
      ..strokeWidth = _CapabilityMetrics.spokeStrokeWidth
      ..color = AppColors.profileRadarSpokeStroke;
    for (int i = 0; i < axes; i++) {
      canvas.drawLine(center, pointAt(i, 1), spokePaint);
    }

    // ── 上次（在底层）────────────────────────────────────────────────
    final Paint prevStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _CapabilityMetrics.prevStrokeWidth
      ..color = AppColors.profileRadarPrevStroke;
    final Paint prevFill = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.profileRadarPrevFill;
    final Path prevPath = polygonOf(<double>[
      for (final Capability item in items)
        (item.previousScore ?? item.score).clamp(0, 100) / 100,
    ]);
    canvas.drawPath(prevPath, prevFill);
    canvas.drawPath(prevPath, prevStroke);

    // ── 当前（在上层）────────────────────────────────────────────────
    final Shader currentShader = AppColors.profileRadarCurrentGradient
        .createShader(Offset.zero & size);
    final Paint currentStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _CapabilityMetrics.currentStrokeWidth
      ..shader = currentShader;
    final Paint currentFill = Paint()
      ..style = PaintingStyle.fill
      ..shader = currentShader;
    final List<double> currentRatios = <double>[
      for (final Capability item in items) item.ratio,
    ];
    final Path currentPath = polygonOf(currentRatios);
    canvas.drawPath(currentPath, currentFill);
    canvas.drawPath(currentPath, currentStroke);

    // ── 顶点圆点 ────────────────────────────────────────────────────
    final Paint vertexFill = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.textInverse;
    final Paint vertexStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _CapabilityMetrics.vertexStrokeWidth
      ..color = AppColors.primaryBlue;
    for (int i = 0; i < axes; i++) {
      final Offset vertex = pointAt(i, currentRatios[i]);
      canvas.drawCircle(
        vertex,
        _CapabilityMetrics.vertexRadius,
        vertexFill,
      );
      canvas.drawCircle(
        vertex,
        _CapabilityMetrics.vertexRadius,
        vertexStroke,
      );
    }

    // ── 轴标签 ──────────────────────────────────────────────────────
    for (int i = 0; i < axes; i++) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: items[i].name,
          style: AppTypography.profileRadarAxisLabel,
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final Offset anchor = pointAt(i, _CapabilityMetrics.radarLabelRatio);
      painter.paint(
        canvas,
        anchor - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  /// 轴名与分值变了就要重画。
  ///
  /// [Capability] 的 `==` 只比 `name` + `score`（模型侧的定义），
  /// 因此「只改了 `previousScore`」这种情况**不会**触发重画 ——
  /// 与「上半层是当前值」一致：上次值只影响底层多边形，
  /// 而本项目的 Mock 每次 `load` 都会重建整个 [CareerAssets]，
  /// 页面走的是重建而不是原地改字段。
  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      !listEquals(oldDelegate.items, items);
}

// ---------------------------------------------------------------------------
// 能力详情卡
// ---------------------------------------------------------------------------

/// 能力详情卡。Figma L3881-3907。
class _CapabilityDetailCard extends StatelessWidget {
  const _CapabilityDetailCard({required this.items});

  final List<Capability> items;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_CapabilityMetrics.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ⚠️ Figma 这里还有一个「查看变化 →」（L3884，跳 `cap-change`）——
          // **本页不渲染**，理由见类顶偏离表第 1 条。
          const Text(
            '能力详情',
            style: AppTypography.profileCapabilityCardTitle,
          ),
          const SizedBox(height: _CapabilityMetrics.titleRowsGap),
          // 空数据：骨架常驻、换文案（D99 规则，2026-09-29）——
          // 文案沿用原整页 Empty 的口径，只是收进卡内。
          if (items.isEmpty)
            const Text(
              '还没有能力数据 · 提交简历并完成职业基线后，这里会显示你的职业能力画像',
              style: AppTypography.profileSmallMeta,
            )
          else
            for (int i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 0 : _CapabilityMetrics.rowGap,
              ),
              child: _CapabilityRow(item: items[i]),
            ),
        ],
      ),
    );
  }
}

/// 一条能力。Figma L3886-3905。
class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.item});

  final Capability item;

  @override
  Widget build(BuildContext context) {
    final int? previous = item.previousScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item.name,
                style: AppTypography.profileCapabilityName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: _CapabilityMetrics.nameScoreGap),
            Text('${item.score}', style: AppTypography.profileCapabilityScore),
            const SizedBox(width: _CapabilityMetrics.scoreChipGap),
            _DeltaChip(delta: item.delta),
          ],
        ),
        const SizedBox(height: _CapabilityMetrics.rowBarGap),
        _CapabilityBar(item: item),
        // 没有「上次」就不写这行 —— 脚注整句依赖两端都有值，
        // 缺一端会变成「上次 0 → 现在 85」这种**编造**出来的对照。
        if (previous != null) ...<Widget>[
          const SizedBox(height: _CapabilityMetrics.barFootnoteGap),
          Text(
            '上次 $previous → 现在 ${item.score}',
            style: AppTypography.profileCapabilityFootnote,
          ),
        ],
      ],
    );
  }
}

/// 增量胶囊。Figma L3888-3891。
///
/// 正增量 → 绿底绿字 `+N`；**无增量 → 灰底「—」**（Figma 用 `delta === 0` 判断）。
/// 负增量在原型里不存在（[Capability.delta] 是 `int`，模型未约束符号）——
/// 这里按「非正即平」处理成「—」，**不**编一个红色的 `-N` 样式出来。
class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = delta > 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _CapabilityMetrics.chipPaddingH,
        vertical: _CapabilityMetrics.chipPaddingV,
      ),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.successSurface
            : AppColors.profileCapabilityFlatChipFill,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        isPositive ? '+$delta' : '—',
        style: isPositive
            ? AppTypography.profileCapabilityDeltaChip
            : AppTypography.profileCapabilityFlatChip,
      ),
    );
  }
}

/// 双层能力条：轨道 + 「上次」填充 + 「当前」渐变填充。Figma L3897-3902。
///
/// ## 为什么是两层而不是两条
///
/// Figma 把「上次」与「当前」两条**叠在同一条轨道上**（两个绝对定位的
/// `div`，同高、同左对齐），因此上次值高于当前值时会露出一截紫色 ——
/// 那是**退步**的视觉表达。拆成上下两条会丢掉这个语义。
///
/// 填充宽度用 `FractionallySizedBox` 表达百分比，而不是先算像素 ——
/// 这样条宽随卡片宽度变化时比例始终正确。
class _CapabilityBar extends StatelessWidget {
  const _CapabilityBar({required this.item});

  final Capability item;

  @override
  Widget build(BuildContext context) {
    final int? previous = item.previousScore;

    return ClipRRect(
      borderRadius: AppRadius.borderPill,
      child: SizedBox(
        height: _CapabilityMetrics.barHeight,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: ColoredBox(
                color: AppColors.profileCapabilityDetailTrack,
              ),
            ),
            if (previous != null)
              Positioned.fill(
                child: _BarFill(
                  ratio: previous.clamp(0, 100) / 100,
                  color: AppColors.profileCapabilityPrevBar,
                ),
              ),
            Positioned.fill(
              child: _BarFill(
                ratio: item.ratio,
                gradient: AppColors.brandGradient,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 从 0 展开到 [ratio] 的一段填充。
///
/// 对应 Figma 的 `_bar-grow`（`width: 0% → 目标值`，
/// 时长见 [CapabilityPage] 类顶的「归纳」说明）。
class _BarFill extends StatelessWidget {
  const _BarFill({required this.ratio, this.color, this.gradient});

  /// 目标宽度比例，`0.0`–`1.0`。
  final double ratio;

  /// 纯色填充。[gradient] 与它二选一。
  final Color? color;

  /// 渐变填充。
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    // 填充体是 builder 之外的 `child` —— 它不随动画重建，
    // 每帧只重算 `widthFactor`。
    final Widget fill = gradient != null
        ? DecoratedBox(decoration: BoxDecoration(gradient: gradient))
        : ColoredBox(color: color ?? const Color(0x00000000));

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: ratio),
      duration: AppMotion.reveal,
      curve: AppMotion.standard,
      builder: (BuildContext context, double value, Widget? child) =>
          FractionallySizedBox(
            // 左对齐：条的填充从**左端**长出来，而不是从中间向两边展开。
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1),
            child: child,
          ),
      child: fill,
    );
  }
}

/// 能力页的内部几何（Figma 逐条内联给出）。
///
/// ⚠️ **颜色 / 字号 / 字体族 / 圆角 / 动画时长一律走 Token**
/// （`CLAUDE.md` §8.2 的硬规则），本类只放宽高与内边距。
///
/// 唯一的例外说明：雷达图的半径 / 网格比例 / 顶点半径是**绘制参数**，
/// 与 `_SplashMetrics` 里的几何同性质 —— 它们是画布内部的坐标，不是 UI 尺寸。
abstract final class _CapabilityMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double cardGap = 16;

  static const double cardPadding = 20;

  // ── 雷达卡（Figma L3873-3879）────────────────────────────────────
  static const double titleLegendGap = 12;
  static const double legendGap = 12;
  static const double legendLineWidth = 12;
  static const double legendLineHeight = 2;
  static const double legendLineGap = 4;
  static const double titleChartGap = 8;

  /// 雷达画布 `220×220`、半径 `76`（`RadarChart` L338）。
  static const double radarSize = 220;
  static const double radarRadius = 76;

  /// 轴标签落在 `1.24r` 处（`RadarChart` L354）。
  static const double radarLabelRatio = 1.24;

  /// 4 层网格：25% / 50% / 75% / 100%（`RadarChart` L349）。
  static const List<double> radarGridRatios = <double>[0.25, 0.5, 0.75, 1];

  /// 少于 3 个轴不成图（见 [CapabilityPage] 的降级规则）。
  static const int radarMinAxes = 3;

  static const double gridStrokeWidth = 1;
  static const double spokeStrokeWidth = 1;
  static const double prevStrokeWidth = 1.5;
  static const double currentStrokeWidth = 2;
  static const double vertexRadius = 4;
  static const double vertexStrokeWidth = 2;

  // ── 能力详情卡（Figma L3883-3904）────────────────────────────────
  static const double titleRowsGap = 16;
  static const double rowGap = 16;
  static const double nameScoreGap = 8;
  static const double scoreChipGap = 8;
  static const double rowBarGap = 8;

  /// 增量胶囊 `px-1.5 py-0.5`（Figma L3888）。
  static const double chipPaddingH = 6;
  static const double chipPaddingV = 2;

  /// 能力条高 `h-2`（8）。
  static const double barHeight = 8;

  /// 条与脚注 `mt-1`（4）（Figma L3904）。
  static const double barFootnoteGap = 4;
}
