import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Careerly 页面容器。
///
/// 职责：
/// 1. 统一页面内边距
/// 2. 处理 SafeArea（Android 状态栏 / 导航栏）
/// 3. 提供统一的轻量标题栏（不用 Material `AppBar` 的默认视觉）
///
/// ## 背景渐变由谁绘制
///
/// 由 **App 根节点**（`CareerlyApp` 的 `MaterialApp.router.builder`）绘制一次，
/// 见 `lib/app/app.dart`。
///
/// 为什么不在这里画：本容器既用于 Shell 内的 Tab 页（上方有状态栏、下方有导航栏），
/// 也用于 Shell 外的全屏页。若两边各画一次，
/// 同一个渐变会被按不同尺寸拉伸两次，在导航栏上沿出现可见色带。
///
/// 因此本容器**保持透明**，让根节点的渐变透出来。
class CareerlyScaffold extends StatelessWidget {
  const CareerlyScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions = const <Widget>[],
    this.leading,
    this.applySafeArea = true,
    this.padding,
    this.showAppBar = true,
    this.resizeToAvoidBottomInset = true,
  });

  /// 页面内容。
  final Widget child;

  /// 标题。为 `null` 时标题栏只保留 actions（例如「我的」只放齿轮图标）。
  final String? title;

  /// 标题栏右侧操作。
  final List<Widget> actions;

  /// 标题栏左侧。
  final Widget? leading;

  /// 是否应用 SafeArea。
  final bool applySafeArea;

  /// 内容内边距。为 `null` 时使用 [AppSpacing.pageInsets]。
  final EdgeInsetsGeometry? padding;

  /// 是否显示标题栏。无标题且无 actions 时不占位。
  final bool showAppBar;

  /// 键盘弹出时是否收缩。PRD §15 要求处理键盘场景。
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final bool hasAppBar = showAppBar && (title != null || actions.isNotEmpty);

    Widget content = Padding(
      padding: padding ?? AppSpacing.pageInsets,
      child: child,
    );

    if (hasAppBar) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _CareerlyAppBar(
            title: title,
            actions: actions,
            leading: leading,
          ),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: applySafeArea ? SafeArea(child: content) : content,
    );
  }
}

/// Careerly 标题栏。
///
/// 不使用 Material `AppBar` 的默认视觉（阴影 / surfaceTint / 固定高度），
/// 只保留其布局职责。
class _CareerlyAppBar extends StatelessWidget {
  const _CareerlyAppBar({
    this.title,
    this.actions = const <Widget>[],
    this.leading,
  });

  final String? title;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title!,
                    style: AppTypography.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
