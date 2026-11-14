import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../data/models/home_summary.dart';
import '../home_content.dart';

/// 首页「匹配变化操作 + 岗位匹配变化」区块。
///
/// 真值来源：Figma `HomePage` L1133-1179。
///
/// ```text
/// 操作行  两颗 h38 / r100 / 14px w700 按钮
///         最新匹配变化  #111827 底 + 白字 · 滚动到列表
///         查看全部      白底 + 1px #e4e7ec · 跳转分析页
/// 卡片    r24 · rgba(255,255,255,0.68) · 1.217px rgba(255,255,255,0.55)
///         · blur(24px) · 0 8px 32px rgba(79,126,245,0.08) · padding 20
/// 列表    marginTop 16 · 行 gap 12 · 行间 1px 分隔线（marginTop 12 / marginLeft 40）
///         + 14px 空档 · 排名列宽 28
/// ```
///
/// ## 这个是**真** Glass
///
/// 与 2×2 卡片不同（那张没有 `backdrop-filter`），本卡 Figma 明确写了
/// `backdropFilter: blur(24px)`，与 `S.glass` 完全一致 —— 故直接用
/// [GlassSurface]，只把描边宽度改成 Figma 的 `1.217`。
///
/// ## 两态共用同一张卡
///
/// State 01 / 02 渲染「开始你的第一次分析」引导，
/// State 03 渲染岗位列表 —— 卡片外壳、圆角、内边距完全相同，
/// 只有内部内容不同（D64 ①bis：只替换文字内容）。
class HomeAnalysisSection extends StatelessWidget {
  const HomeAnalysisSection({
    super.key,
    required this.content,
    this.onNewAnalysis,
    this.onJumpToChanges,
    this.onViewAll,
    this.changesKey,
  });

  final HomeSectionContent content;

  /// State 01 / 02 引导行的点击回调（分析 Tab）。
  final VoidCallback? onNewAnalysis;

  /// 滚动到岗位匹配变化列表。
  final VoidCallback? onJumpToChanges;

  /// 「查看全部」的点击回调（分析 Tab）。
  final VoidCallback? onViewAll;

  /// 「岗位匹配变化」卡片的滚动定位目标。
  final Key? changesKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double controlsWidth = math.min(
              _SectionMetrics.controlsMaxWidth,
              math.max(0, constraints.maxWidth - _SectionMetrics.controlsInset),
            );
            return Center(
              child: SizedBox(
                width: controlsWidth,
                child: _MatchControls(
                  onJumpToChanges: onJumpToChanges,
                  onViewAll: onViewAll,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: _SectionMetrics.tabsGap),
        GlassSurface(
          key: changesKey,
          radius: AppRadius.xl,
          // Figma 这一张卡写的是 `1.217px`（其余 Glass 面写 `1px`）——
          // 保持原值，不收敛到默认的 1。
          borderWidth: _SectionMetrics.cardBorderWidth,
          padding: const EdgeInsets.all(_SectionMetrics.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(content.title, style: AppTypography.homeSectionTitle),
              const SizedBox(height: _SectionMetrics.titleGap),
              if (content.isFirstAnalysis)
                _FirstAnalysisPrompt(content: content, onTap: onNewAnalysis)
              else
                _JobList(matches: content.matches!),
            ],
          ),
        ),
      ],
    );
  }
}

/// Figma 首页列表上方的两个操作按钮。
class _MatchControls extends StatelessWidget {
  const _MatchControls({this.onJumpToChanges, this.onViewAll});

  final VoidCallback? onJumpToChanges;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _MatchControlButton(
            label: '最新匹配变化',
            iconPath: 'assets/images/home/home-match-changes.svg',
            iconWidth: _SectionMetrics.matchIconWidth,
            filled: true,
            onTap: onJumpToChanges,
          ),
        ),
        const SizedBox(width: _SectionMetrics.controlsGap),
        Expanded(
          child: _MatchControlButton(
            label: '查看全部',
            iconPath: 'assets/images/home/home-view-all.svg',
            iconWidth: _SectionMetrics.viewAllIconWidth,
            filled: false,
            onTap: onViewAll,
          ),
        ),
      ],
    );
  }
}

class _MatchControlButton extends StatelessWidget {
  const _MatchControlButton({
    required this.label,
    required this.iconPath,
    required this.iconWidth,
    required this.filled,
    this.onTap,
  });

  final String label;
  final String iconPath;
  final double iconWidth;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget button = Container(
      height: _SectionMetrics.tabHeight,
      decoration: BoxDecoration(
        color: filled ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.borderPill,
        border: filled
            ? null
            : Border.all(
                color: AppColors.homeTabBorder,
                width: _SectionMetrics.tabBorderWidth,
              ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgPicture.asset(
                iconPath,
                width: iconWidth,
                height: _SectionMetrics.controlIconSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: _SectionMetrics.controlIconGap),
              Text(
                label,
                style: AppTypography.onSurfaceVariant(
                  AppTypography.homeTabLabel,
                  filled ? AppColors.textInverse : AppColors.textPrimary,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return button;
    return CareerlyPressFeedback(onTap: onTap, child: button);
  }
}

/// State 01 / 02：第一次分析引导。
class _FirstAnalysisPrompt extends StatelessWidget {
  const _FirstAnalysisPrompt({required this.content, this.onTap});

  final HomeSectionContent content;

  /// 行动行的点击目标 —— 进入分析 Tab 添加目标岗位。
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(content.body!, style: AppTypography.homeEmptyBody),
        const SizedBox(height: _SectionMetrics.promptGap),
        if (content.actionLabel != null)
          CareerlyPressFeedback(
            onTap: onTap,
            child: Text(
              content.actionLabel!,
              style: AppTypography.homeEmptyAction,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// State 03：岗位匹配变化列表。
class _JobList extends StatelessWidget {
  const _JobList({required this.matches});

  final List<MatchChange> matches;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      // 不编造行 —— 没有数据时只留标题，不留空壳行。
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < matches.length; i++) ...<Widget>[
          _JobRow(rank: i + 1, job: matches[i]),
          if (i < matches.length - 1) ...<Widget>[
            Container(
              height: _SectionMetrics.dividerHeight,
              margin: const EdgeInsets.only(
                top: _SectionMetrics.dividerTop,
                left: _SectionMetrics.dividerLeft,
              ),
              color: AppColors.homeJobDivider,
            ),
            const SizedBox(height: _SectionMetrics.dividerBottomGap),
          ],
        ],
      ],
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.rank, required this.job});

  final int rank;
  final MatchChange job;

  @override
  Widget build(BuildContext context) {
    final int? delta = job.delta;
    final bool improved = delta != null && delta > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: _SectionMetrics.rankWidth,
          child: Text(
            _rankLabel(rank),
            style: AppTypography.homeJobRank,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: _SectionMetrics.rowGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      job.jobTitle,
                      style: AppTypography.homeJobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: _SectionMetrics.scoreGroupGap),
                  // 匹配度：渐变文字（`background-clip: text` 的 Flutter 等价物）。
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) =>
                        AppColors.homeMatchTextGradient.createShader(bounds),
                    child: Text(
                      '${job.score}%',
                      style: AppTypography.homeJobScore,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: _SectionMetrics.chipGap),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _SectionMetrics.chipPaddingH,
                      vertical: _SectionMetrics.chipPaddingV,
                    ),
                    decoration: BoxDecoration(
                      color: improved
                          ? AppColors.successSurface
                          : AppColors.neutralSurface,
                      borderRadius: AppRadius.borderPill,
                    ),
                    // Figma：`delta > 0` 显示 `↑ +N%`，否则显示破折号 ——
                    // `delta == 0` 与「没有可比较的上一次」（本模型的 `null`）
                    // 都落到破折号，与设计稿一致。
                    child: Text(
                      improved ? '↑ +$delta%' : '—',
                      style: AppTypography.onSurfaceVariant(
                        AppTypography.homeJobDelta,
                        improved ? AppColors.success : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _SectionMetrics.barTop),
              _MatchBar(score: job.score),
            ],
          ),
        ),
      ],
    );
  }
}

/// `0–100` 的比例条。Figma：轨道高 6 / 圆角 99 / `rgba(229,231,235,0.8)`。
class _MatchBar extends StatelessWidget {
  const _MatchBar({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    // 依 `CLAUDE.md` §5.3：匹配度是 0–100。越界值只夹取显示宽度，
    // **不**改写分数本身（分数由数据层保证）。
    final double factor = (score / 100).clamp(0.0, 1.0);

    return Container(
      height: _SectionMetrics.barHeight,
      decoration: const BoxDecoration(
        color: AppColors.homeMatchTrack,
        borderRadius: AppRadius.borderPill,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: factor,
          heightFactor: 1,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.homeMatchBarGradient,
              borderRadius: AppRadius.borderPill,
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma `rankEmoji`：前三名给奖牌，其余给序号。
String _rankLabel(int rank) {
  switch (rank) {
    case 1:
      return '🥇';
    case 2:
      return '🥈';
    case 3:
      return '🥉';
    default:
      return '$rank';
  }
}

/// 本区块的内部几何（Figma 原值）。
abstract final class _SectionMetrics {
  /// Figma 的控制区宽度为屏宽减 72px，最大 330px；外围已有 20px 边距。
  static const double controlsMaxWidth = 330;
  static const double controlsInset = 32;
  static const double controlsGap = 16;
  static const double controlIconGap = 8;
  static const double matchIconWidth = 17.5;
  static const double viewAllIconWidth = 18;
  static const double controlIconSize = 18;

  /// Figma：筛选胶囊 `height: 38`。
  static const double tabHeight = 38;

  /// Figma：胶囊描边 `1px`。
  static const double tabBorderWidth = 1;

  /// Figma：筛选行与卡片之间 —— 页面 `space-y-4` 的 `16`。
  static const double tabsGap = 16;

  /// Figma：卡片 `padding: 20`。
  static const double cardPadding = 20;

  /// Figma：卡片描边 `1.217px`。
  static const double cardBorderWidth = 1.217;

  /// Figma：标题与列表之间 `marginTop: 16`。
  static const double titleGap = 16;

  /// Figma：空态引导语与行动行之间 —— Flutter 侧取值（Figma 无此态）。
  static const double promptGap = 12;

  /// Figma：行内 `gap: 12`。
  static const double rowGap = 12;

  /// Figma：排名列 `width: 28`。
  static const double rankWidth = 28;

  /// Figma：标题行右组的 `paddingLeft: 8`。
  static const double scoreGroupGap = 8;

  /// Figma：`gap: 8`（匹配度与变化 Chip 之间）。
  static const double chipGap = 8;

  /// Figma：Chip `padding: 2px 8px`。
  static const double chipPaddingH = 8;
  static const double chipPaddingV = 2;

  /// Figma：标题行与进度条之间 `marginBottom: 6`。
  static const double barTop = 6;

  /// Figma：进度条 `height: 6`。
  static const double barHeight = 6;

  /// Figma：分隔线 `height: 1`。
  static const double dividerHeight = 1;

  /// Figma：分隔线 `marginTop: 12; marginLeft: 40`。
  static const double dividerTop = 12;
  static const double dividerLeft = 40;

  /// Figma：分隔线之后的 `14px` 空档。
  static const double dividerBottomGap = 14;
}
