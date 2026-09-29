import 'package:flutter/material.dart';

import '../../../../design_system/tokens/tokens.dart';

/// 首页顶部身份区。
///
/// 真值来源：Figma `HomePage` L1030-1045。
///
/// ```text
/// 小标签 主页 · 12px / w400 / lh18 / #6B7280
/// 主标题 <名字> 的职业主页 · 22px / w700 / lh27.5 / #111827
/// 头像   44×44 · r16 · 品牌渐变 · 0 4px 7px rgba(79,126,245,0.35)
///        右上角 12×12 绿点 · 1.217px 白描边
/// ```
///
/// ## ⚠️ 头像里的字形
///
/// Figma 写的是字母 `A`（取自硬编码的假名 `Alex`）。
/// `HomeSummary` 目前**没有**用户姓名字段，取不到真名 ——
/// 因此这里用**注册页已建立的同一套占位处理**（品牌渐变底 +
/// 人像字形，见 [AppColors.onAvatarGlyph] / **D58**），
/// **不回落**到 Figma 的假名首字母。
///
/// 缺口登记 **待裁决 · D76**（`docs/05_progress/TODO.md` §3.1）。
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.title});

  /// 主标题整句（「<名字> 的职业主页」）。
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('主页', style: AppTypography.homeLabel),
              Text(
                title,
                style: AppTypography.homePageTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const _AvatarBadge(),
      ],
    );
  }
}

/// 头像 + 在线绿点。
class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // 绿点会溢出头像本体（Figma：`top: -2; right: -2`），
      // 因此外层尺寸要各留出 2px，否则会被父级约束裁掉。
      width: _HomeHeaderMetrics.avatarSize + _HomeHeaderMetrics.dotOverflow,
      height: _HomeHeaderMetrics.avatarSize + _HomeHeaderMetrics.dotOverflow,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: _HomeHeaderMetrics.avatarSize,
              height: _HomeHeaderMetrics.avatarSize,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: AppRadius.borderMd,
                boxShadow: AppShadows.homeAvatar,
              ),
              child: const Center(
                // 见类文档：没有真名时用既有的人像占位，不搬 Figma 的 `A`。
                child: Icon(
                  Icons.person,
                  size: _HomeHeaderMetrics.avatarGlyphSize,
                  color: AppColors.onAvatarGlyph,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: _HomeHeaderMetrics.dotSize,
              height: _HomeHeaderMetrics.dotSize,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.homeAvatarRing,
                  width: _HomeHeaderMetrics.dotBorderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 本区块的内部几何（Figma 原值）。
abstract final class _HomeHeaderMetrics {
  /// Figma：头像 `44×44`，圆角 `16`。
  static const double avatarSize = 44;

  /// 人像字形尺寸 —— Flutter 侧近似值（Figma 此处是字母而非图标）。
  static const double avatarGlyphSize = 22;

  /// Figma：绿点 `12×12`。
  static const double dotSize = 12;

  /// Figma：绿点描边 `1.217px solid white`。
  static const double dotBorderWidth = 1.217;

  /// 绿点相对头像的外溢量（Figma `top: -2; right: -2`）。
  static const double dotOverflow = 2;
}
