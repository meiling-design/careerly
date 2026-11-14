import 'package:flutter/material.dart';

import '../../../../data/models/models.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import 'resume_preview_sections.dart';

/// 历史版本卡 —— 左滑露出「设为当前 / 删除」。Figma `SwipeableResumeCard`
/// （`src/App.tsx` L4438-4545）。
///
/// ```text
/// 卡片本体  半透明白 0.90 + blur 24 + radius 16
///          图标块 44×44（当前版本品牌浅底 / 归档版本中性底）
///          → 「Resume {v}」14/w700 + 「归档」胶囊
///          → 「更新于 {date}」
/// 左滑露出  设为当前（品牌渐变 135deg，136.47deg 近似）· 删除（#FF3B30）
///           两个各占一半、总宽 160
/// ```
///
/// ## 三处按真实数据收敛的地方（Figma 是写死的示例值）
///
/// | 项 | Figma | 这里 |
/// |---|---|---|
/// | 标题 | `Resume V3` | [ResumeVersion.label]（本项目的 label **就是**版本名） |
/// | 副行 | `2026.08.27 · 新增 AI Agent 项目` | 只有日期 —— 「本次变化」数据层没有 |
/// | 右列 | `86%` + 最高匹配 | **整块不渲染** —— 没有匹配度字段 |
///
/// 三者都是**缺数据**而不是缺实现，理由与 [ResumeDetailPage] 类文档一致：
/// 不编造产品数据（`CLAUDE.md` §7）。
class ResumeSwipeCard extends StatefulWidget {
  const ResumeSwipeCard({
    super.key,
    required this.version,
    required this.onTap,
    required this.onSetCurrent,
    required this.onDelete,
  });

  final ResumeVersion version;

  /// 打开该版本的详情。
  final VoidCallback onTap;

  /// 「设为当前」。为 `null` 时该动作不可用（本条已是当前版本）。
  final VoidCallback? onSetCurrent;

  /// 「删除」。
  final VoidCallback? onDelete;

  @override
  State<ResumeSwipeCard> createState() => _ResumeSwipeCardState();
}

class _ResumeSwipeCardState extends State<ResumeSwipeCard> {
  /// 卡片左移的距离，取值 `[-REVEAL, 0]`。
  double _offset = 0;

  /// 拖动结束后是否走吸附动画。
  ///
  /// 拖动过程中必须**跟手**（无动画），松手才做 250ms 吸附 ——
  /// 否则手指还没抬起，卡片就自己在追。
  bool _animating = true;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _animating = false;
      _offset = (_offset + details.delta.dx).clamp(-_SwipeMetrics.reveal, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _animating = true;
      // Figma：`currentOffsetRef.current < -REVEAL/2` 才吸附到露出态。
      _offset = _offset < -_SwipeMetrics.reveal / 2
          ? -_SwipeMetrics.reveal
          : 0;
    });
  }

  void _close() => setState(() {
    _animating = true;
    _offset = 0;
  });

  @override
  Widget build(BuildContext context) {
    final bool revealed = _offset.abs() > 1;

    return ClipRRect(
      // Figma 外层 `rounded-2xl` + `overflow-hidden`。
      borderRadius: AppRadius.borderMd,
      child: Stack(
        children: <Widget>[
          // 露出的两个动作 —— 贴在右侧、占满整卡高度。
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _SwipeMetrics.reveal,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _RevealAction(
                        label: '设为当前',
                        icon: Icons.check,
                        gradient: AppColors.brandGradient,
                        onTap: widget.onSetCurrent == null
                            ? null
                            : () {
                                _close();
                                widget.onSetCurrent!();
                              },
                      ),
                    ),
                    Expanded(
                      child: _RevealAction(
                        label: '删除',
                        icon: Icons.delete_outline,
                        fill: AppColors.danger,
                        onTap: widget.onDelete == null
                            ? null
                            : () {
                                _close();
                                widget.onDelete!();
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            // 已露出时点卡片直接收回，不必再滑一次。
            onTap: revealed ? _close : widget.onTap,
            child: AnimatedContainer(
              duration: _animating ? AppMotion.swipeSnap : Duration.zero,
              curve: AppMotion.standard,
              transform: Matrix4.translationValues(_offset, 0, 0),
              child: _ResumeCardFace(version: widget.version),
            ),
          ),
        ],
      ),
    );
  }
}

/// 卡片本体。
class _ResumeCardFace extends StatelessWidget {
  const _ResumeCardFace({required this.version});

  final ResumeVersion version;

  @override
  Widget build(BuildContext context) {
    final bool current = version.isCurrent;

    return ClipRRect(
      borderRadius: AppRadius.borderMd,
      child: BackdropFilter(
        filter: GlassFilters.blur(_SwipeMetrics.cardBlur),
        child: Container(
          // Figma `p-4` + `gap-3`。
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.resumeGlassCardFill,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: _SwipeMetrics.tileSize,
                height: _SwipeMetrics.tileSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // Figma：**当前**版本用品牌浅底，归档版本用中性底。
                  color: current
                      ? AppColors.brandPillFill
                      : AppColors.resumeDocTileNeutralFill,
                  borderRadius: BorderRadius.circular(_SwipeMetrics.tileRadius),
                ),
                child: Icon(
                  // Figma 是自绘的文档描边 SVG；依 D58 用 Material 字形近似。
                  Icons.description_outlined,
                  size: _SwipeMetrics.tileIcon,
                  color: current
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            // 本项目的 label 本身就是版本名，不再加「Resume」前缀
                            // （与简历历史横幅同一处置）。
                            version.label,
                            style: AppTypography.profileListCardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!current) ...<Widget>[
                          const SizedBox(width: AppSpacing.xs),
                          const _ArchivePill(),
                        ],
                      ],
                    ),
                    if (version.uploadedAt != null) ...<Widget>[
                      const SizedBox(height: _SwipeMetrics.subGap),
                      Text(
                        formatResumeDate(version.uploadedAt!),
                        style: AppTypography.profileSmallMeta,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 「归档」胶囊 —— 只出现在非当前版本上。
class _ArchivePill extends StatelessWidget {
  const _ArchivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _SwipeMetrics.archivePaddingH,
        vertical: _SwipeMetrics.archivePaddingV,
      ),
      decoration: const BoxDecoration(
        color: AppColors.resumeArchivePillFill,
        borderRadius: AppRadius.borderPill,
      ),
      child: const Text('归档', style: AppTypography.resumeArchivePillLabel),
    );
  }
}

/// 左滑露出的一个动作。
class _RevealAction extends StatelessWidget {
  const _RevealAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.gradient,
    this.fill,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, gradient: gradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: _SwipeMetrics.actionIcon, color: AppColors.textInverse),
            const SizedBox(height: _SwipeMetrics.actionIconGap),
            Text(label, style: AppTypography.resumeSwipeActionLabel),
          ],
        ),
      ),
    );
  }
}

/// 组件内部几何（Figma 逐条内联给出）。
abstract final class _SwipeMetrics {
  /// Figma `const REVEAL = 160`（L4439）。
  static const double reveal = 160;

  /// Figma `blur(24px)`。
  static const double cardBlur = 24;

  /// Figma：图标块 `44×44` / `borderRadius: 13`。
  static const double tileSize = 44;
  static const double tileRadius = 13;

  /// Figma：块内文档 SVG 为 `18×18`。
  static const double tileIcon = 18;

  /// Figma `mt-1`（标题与副行之间）。
  static const double subGap = 4;

  /// Figma：胶囊 `padding: 2px 8px`。
  static const double archivePaddingH = 8;
  static const double archivePaddingV = 2;

  /// Figma：动作按钮里的图标 `18×18`。
  static const double actionIcon = 18;

  /// Figma `mt-0.5`。
  static const double actionIconGap = 2;
}
