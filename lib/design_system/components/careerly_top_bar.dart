import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// 二级页顶栏的两种形态。
///
/// ⚠️ **这是参数而不是两个组件** —— 依 `CLAUDE.md` §8.4
/// 「变体用参数，不用新组件」。两者行为相同（返回 + 居中标题 + 可选右侧内容），
/// 差异只在几何与字号。
enum CareerlyTopBarStyle {
  /// 「‹ 返回」文字按钮 + `15px` 居中标题。
  ///
  /// Figma `TopBar`（`src/App.tsx` L170-190）——
  /// 工作经历 / 项目经历两个列表页在用。
  backLabel,

  /// 玻璃圆返回钮 + `22px` 居中标题。
  ///
  /// Figma `CareerAssetsPage` 头部（L3482-3491）——
  /// 职业资产页在用，标题字号明显更大。
  glassCircle,
}

/// Careerly 二级页顶栏。
///
/// ```dart
/// CareerlyTopBar(title: '工作经历', trailing: Text('4 段'))
/// CareerlyTopBar(
///   title: '职业资产',
///   style: CareerlyTopBarStyle.glassCircle,
/// )
/// ```
///
/// ## 真值来源
///
/// | 项 | [CareerlyTopBarStyle.backLabel] | [CareerlyTopBarStyle.glassCircle] |
/// |---|---|---|
/// | 容器 | `px-5 py-3`（水平 20 / 垂直 12） | `height 56` + `px-5 pt-4 pb-2` |
/// | 返回钮 | 文字「返回」`14/w600/#4F7EF5` + 18×18 箭头 `strokeWidth 2.5` | 44×44 圆，`rgba(255,255,255,0.7)` + `blur(8)` |
/// | 返回钮描边 | 无 | `1px rgba(220,220,240,0.5)` |
/// | 返回钮图标色 | `#4F7EF5` | `#0088FF` |
/// | 标题 | `15/w700/#111827`，绝对居中 | `22/w700/#1E1F22`，绝对居中 |
///
/// ## 与 `CareerlyScaffold` 的关系（**待裁决 · K15**）
///
/// 本组件与 `CareerlyScaffold` 的 app bar **职责重叠**。
/// 本轮**不改** `CareerlyScaffold` —— 它与批 1 / 批 2 一同挂在
/// **未验收欠账**里，改它会让「验收对象」与「已交付物」不一致
/// （`D30` / `D74` 的既有先例：不修改已交付未验收的共享代码）。
///
/// 重叠风险已登记 **K15**（`docs/05_progress/TODO.md`），
/// 建议在批 1 + 批 2 合并验收通过后再合并两者。
///
/// ## 关于图标
///
/// Figma 画的是**雪佛龙**（`M15 18L9 12L15 6`），不是 Material 的实心箭头。
/// 依 **D58** 先例（不新建图标资源，用 Material 字形近似），
/// 这里取 [Icons.arrow_back_ios_new] —— 它是 Material 里最接近该雪佛龙的字形。
class CareerlyTopBar extends StatelessWidget {
  const CareerlyTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.style = CareerlyTopBarStyle.backLabel,
  });

  /// 居中标题。
  final String title;

  /// 返回回调。为 `null` 时**不渲染返回钮**（本页是流程起点）。
  final VoidCallback? onBack;

  /// 右侧内容（如「4 段」计数）。为 `null` 时留空占位，保证标题仍然居中。
  final Widget? trailing;

  /// 顶栏形态，默认 [CareerlyTopBarStyle.backLabel]。
  final CareerlyTopBarStyle style;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      CareerlyTopBarStyle.backLabel => _buildBackLabel(),
      CareerlyTopBarStyle.glassCircle => _buildGlassCircle(),
    };
  }

  /// Figma `TopBar`（L170-190）。
  ///
  /// 标题在 Figma 里是 `absolute left-1/2 -translate-x-1/2` ——
  /// **相对整个容器居中**，而不是在返回钮与右侧内容之间居中。
  /// 因此这里用 [Stack]，不能用 `Row` + `Spacer`。
  Widget _buildBackLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _TopBarMetrics.inset,
        vertical: _TopBarMetrics.backLabelVertical,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: _BackLabelButton(onTap: onBack!),
            ),
          Text(title, style: AppTypography.profileTopBarTitle),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }

  /// Figma `CareerAssetsPage` 头部（L3482-3491）。
  ///
  /// ⚠️ 容器高 `56` 是**固定值**（Figma `style={{ height: 56 }}`），
  /// 不是内容撑开 —— 玻璃圆钮高 `44` 会超出 `pt-4 pb-2` 的留白，
  /// 靠固定高度裁掉。
  Widget _buildGlassCircle() {
    return SizedBox(
      height: _TopBarMetrics.glassCircleHeight,
      child: Padding(
        padding: const EdgeInsets.only(
          left: _TopBarMetrics.inset,
          right: _TopBarMetrics.inset,
          top: _TopBarMetrics.glassCircleTop,
          bottom: _TopBarMetrics.glassCircleBottom,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: _GlassBackButton(onTap: onBack!),
              ),
            Text(title, style: AppTypography.profilePageTitle),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ),
      ),
    );
  }
}

/// 「‹ 返回」文字按钮。Figma `TopBar` L173-185。
class _BackLabelButton extends StatelessWidget {
  const _BackLabelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _TopBarMetrics.backLabelButtonVertical,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.arrow_back_ios_new,
              size: _TopBarMetrics.backLabelIcon,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: _TopBarMetrics.backLabelIconGap),
            Text('返回', style: AppTypography.profileTopBarBack),
          ],
        ),
      ),
    );
  }
}

/// 玻璃圆返回钮。Figma `CareerAssetsPage` L3483-3489。
class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: _TopBarMetrics.glassBackBlur,
            sigmaY: _TopBarMetrics.glassBackBlur,
          ),
          child: Container(
            width: _TopBarMetrics.glassBackSize,
            height: _TopBarMetrics.glassBackSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.profileBackButtonFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.profileBackButtonBorder,
                width: _TopBarMetrics.glassBackBorderWidth,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: _TopBarMetrics.glassBackIcon,
              color: AppColors.profileBackIconInk,
            ),
          ),
        ),
      ),
    );
  }
}

/// 组件的内部几何。
///
/// 与 `_ButtonMetrics` / `_ProgressMetrics` 同理：这些是**组件内部比例**，
/// 不是页面级可调项，因此留在组件文件内，不进入 `AppSpacing`。
abstract final class _TopBarMetrics {
  /// Figma：`px-5` = 左右各 20。
  static const double inset = 20;

  /// Figma：`py-3` = 上下各 12。
  static const double backLabelVertical = 12;

  /// Figma：返回钮 `py-1` = 上下各 4。
  static const double backLabelButtonVertical = 4;

  /// Figma：返回箭头 `18×18`。
  static const double backLabelIcon = 18;

  /// Figma：`gap-1.5` = 6。
  static const double backLabelIconGap = 6;

  /// Figma：容器 `height: 56`。
  static const double glassCircleHeight = 56;

  /// Figma：`pt-4` = 16。
  static const double glassCircleTop = 16;

  /// Figma：`pb-2` = 8。
  static const double glassCircleBottom = 8;

  /// Figma：玻璃圆钮 `44×44`。
  static const double glassBackSize = 44;

  /// Figma：`1px` 描边。
  static const double glassBackBorderWidth = 1;

  /// Figma：`blur(8px)` —— 注意与「我的」主页齿轮钮的 `blur(16px)` **不是同一个值**。
  static const double glassBackBlur = 8;

  /// Figma：返回箭头 `17×17`。
  static const double glassBackIcon = 17;
}
