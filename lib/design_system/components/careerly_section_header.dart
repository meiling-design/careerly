import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Careerly 区块标题行（左标题 + 右侧文字动作）。
///
/// ```dart
/// CareerlySectionHeader(
///   title: '我的职业成长',
///   actionLabel: '查看全部 →',
///   onAction: () => context.push(AppRoutes.profileGrowthRecord),
/// )
/// ```
///
/// ## 真值来源
///
/// Figma `ProfilePage` 的「我的职业成长」标题行（`src/App.tsx` L3253-3256）。
///
/// | 项 | Figma 真值 |
/// |---|---|
/// | 行 | `justify-content: space-between`，`align-items: center` |
/// | 标题 | `16px / w700 / line-height 24px / #111827` |
/// | 动作 | `12px / w400 / line-height 18px / #4f7ef5` |
/// | 标题与内容的间距 | `margin-bottom: 12` |
///
/// ⚠️ Figma 的 `px-5 mb-4`（左右 20 / 下 16）写在外层容器上，
/// **不属于本组件** —— 那是调用方的页面留白，由调用方决定。
///
/// ## 关于「查看全部 →」的箭头
///
/// 箭头是**文案的一部分**（Figma 直接写在字符串里：`查看全部 →`），
/// 不是独立图标。因此这里也把它当文案，不做图标拼装。
///
/// ## 关于按压反馈
///
/// Figma 在该 `<button>` 上**没有**声明任何 `active:` 反馈
/// （对比同屏的卡片按钮都写了 `active:scale-[0.98]`）。
/// 因此这里只做点击响应，**不添加**缩放反馈 —— 不替设计稿补它没画的东西。
class CareerlySectionHeader extends StatelessWidget {
  const CareerlySectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.bottomSpacing = _SectionHeaderMetrics.bottomSpacing,
  });

  /// 区块标题。
  final String title;

  /// 右侧动作文案。为 `null` 时只渲染标题。
  final String? actionLabel;

  /// 右侧动作回调。为 `null` 时动作**不可点**（仍渲染，用于占位）。
  final VoidCallback? onAction;

  /// 标题行下方的间距。Figma 真值为 `12`。
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final String? label = actionLabel;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(title, style: AppTypography.profileSectionTitle)),
          if (label != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(label, style: AppTypography.profileSectionAction),
            ),
        ],
      ),
    );
  }
}

/// 组件的内部几何。
abstract final class _SectionHeaderMetrics {
  /// Figma：标题行 `margin-bottom: 12`。
  static const double bottomSpacing = 12;
}
