import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// [CareerlyStatRow] 里的一格统计。
class CareerlyStat {
  const CareerlyStat({required this.value, required this.label});

  /// 数字（或任意短值），如 `'4'`。
  final String value;

  /// 标签，如 `'简历版本'`。
  final String label;
}

/// Careerly 三格统计行（数字 + 标签，格与格之间有一条竖分隔线）。
///
/// ```dart
/// CareerlyStatRow(
///   stats: <CareerlyStat>[
///     CareerlyStat(value: '${profile.versions.length}', label: '简历版本'),
///     CareerlyStat(value: '${assets.projectCount}', label: '分析岗位'),
///     CareerlyStat(value: '${assets.analysisCount}', label: '分析次数'),
///   ],
/// )
/// ```
///
/// ## 真值来源
///
/// Figma `ProfilePage` 信息卡的统计行（`src/App.tsx` L3181-3189）。
///
/// | 项 | Figma 真值 |
/// |---|---|
/// | 行容器 | `paddingTop/Bottom: 4`，`alignItems: flex-start` |
/// | 每格 | `flex: 1`，纵向，居中对齐，`gap: 4`，`minWidth: 0` |
/// | 数字 | `16px / w800 / #181a20` |
/// | 标签 | `11px / w600 / #6e717c` |
/// | 分隔线 | 前两格 `position: right: 0 / top: 50%`，`1px × 28`，`rgba(18,18,18,0.082)` |
///
/// ## 分隔线为什么放在「格子内部」而不是「格子之间」
///
/// Figma 把分隔线写成**每格内的绝对定位元素**（`right: 0`），
/// 而不是行上的独立子元素。表现等价（因为 `flex: 1` 无间隙），
/// 但语义不同：线的**垂直位置跟随该格自身高度的一半**。
/// Flutter 侧用 `Stack` + `Alignment.centerRight` 原样复现这一点。
///
/// ## 关于 `minWidth: 0` 与省略号
///
/// Figma 给每格写了 `minWidth: 0`，语义是「允许被压缩」。
/// Flutter 侧对应地把文本设为单行省略 —— 这是**同一意图的平移**，
/// 不是新增视觉规则。
class CareerlyStatRow extends StatelessWidget {
  const CareerlyStatRow({super.key, required this.stats});

  /// 统计格。Figma 是 3 格，但组件不写死数量。
  final List<CareerlyStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _StatRowMetrics.rowVerticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < stats.length; i++)
            Expanded(
              child: Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        stats[i].value,
                        style: AppTypography.profileStatValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: _StatRowMetrics.valueLabelGap),
                      Text(
                        stats[i].label,
                        style: AppTypography.profileStatLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (i < stats.length - 1)
                    const SizedBox(
                      width: _StatRowMetrics.dividerWidth,
                      height: _StatRowMetrics.dividerHeight,
                      child: ColoredBox(color: AppColors.profileStatDivider),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 组件的内部几何。
abstract final class _StatRowMetrics {
  /// Figma：行 `paddingTop/Bottom: 4`。
  static const double rowVerticalPadding = 4;

  /// Figma：每格 `gap: 4`。
  static const double valueLabelGap = 4;

  /// Figma：分隔线 `width: 1`。
  static const double dividerWidth = 1;

  /// Figma：分隔线 `height: 28`。
  static const double dividerHeight = 28;
}
