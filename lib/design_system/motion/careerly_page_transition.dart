import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Careerly 页面转场的**唯一实现**。
///
/// 真值来源：Figma `src/index.css` L137-162。
/// 四条关键帧与四个类逐位对应：
///
/// ```text
/// .page-tab      200ms  translateY(  8px) → 0   一级导航切换
/// .page-push     260ms  translateX( 20px) → 0   二级进入
/// .page-pop      240ms  translateX(-20px) → 0   返回（作用在**被揭开的页**上）
/// .page-onboard  300ms  translateX( 24px) → 0   Onboarding 步骤
/// ```
///
/// 四条曲线的 `cubic-bezier(0.25, 0.46, 0.45, 0.94)` 是 Figma **明写的**，
/// 即 [AppMotion.standard]。
/// （早先误判为「spec 只给文字描述」，见 [AppMotion.pageCurve] 的更正说明。）
///
/// ## 为什么落在 `design_system/motion/` 而不是 `app/router/`
///
/// 同一条转场有两个消费方：
/// 1. `app/router/page_transitions.dart` —— go_router 的 `CustomTransitionPage`
/// 2. `design_system/theme/careerly_theme.dart` —— `PageTransitionsTheme`
///
/// 第 2 个在 design_system 内，**不能反向依赖 `app/`**。
/// 实现因此落在 design_system，两个消费方各自调用 —— 避免同一条转场
/// 被抄成三份（这正是 Phase 3 审计发现的 B-7）。
///
/// ## 位移是**绝对像素**，不是比例
///
/// Figma 给的是 `8px` / `20px` / `24px`；
/// 而 [SlideTransition] 的 `Offset` 收的是**子元素尺寸的比例**。
/// 早先按「假定 320px 宽 / 400px 高」硬除分母 ——
/// 在 390 宽的机器上 `20px` 会渲染成 24.4px。
/// 这里改为用 [LayoutBuilder] 拿真实约束换算。
abstract final class CareerlyPageTransition {
  /// 按 [kind] 构造转场。
  ///
  /// [animation] 是**本页**的进入动画；
  /// [secondaryAnimation] 是本页**被上层覆盖**时的动画 ——
  /// Figma 的 `.page-pop` 作用的正是后者（被揭开的那一页从 `-20px` 归零）。
  static Widget build({
    required CareerlyTransitionKind kind,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Animation<double> incoming = CurvedAnimation(
          parent: animation,
          curve: AppMotion.pageCurve,
          reverseCurve: AppMotion.pageCurve.flipped,
        );

        return FadeTransition(
          opacity: incoming,
          child: SlideTransition(
            // 被上层覆盖 / 揭开时的位移。
            position: Tween<Offset>(
              begin: Offset.zero,
              end: kind.coveredOffset(constraints),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: AppMotion.standard,
              ),
            ),
            child: SlideTransition(
              // 本页自己的进入位移。
              position: Tween<Offset>(
                begin: kind.beginOffset(constraints),
                end: Offset.zero,
              ).animate(incoming),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// 转场形态。
///
/// 只列**真正被使用**的两种：
/// - [push] —— 二级页面（`app/router` 的四个一级分支根页）
/// - [onboarding] —— Onboarding 步骤页
///
/// ⚠️ `tab` 不在此列：一级导航切换发生在 [StatefulShellRoute] 的
/// `IndexedStack` 内部，**不经过路由转场**，由 `CareerlyShell` 直接驱动动画。
enum CareerlyTransitionKind {
  /// 二级页面进入 / 返回。Figma `.page-push` / `.page-pop`。
  push,

  /// Onboarding 步骤。Figma `.page-onboard`。
  onboarding;

  /// 本页作为上层进入时的起点位移（比例）。
  Offset beginOffset(BoxConstraints constraints) {
    return switch (this) {
      CareerlyTransitionKind.push => Offset(
        _fractionOfWidth(constraints, AppMotion.pageSlideOffset),
        0,
      ),
      CareerlyTransitionKind.onboarding => Offset(
        _fractionOfWidth(constraints, AppMotion.pageOnboardingOffset),
        0,
      ),
    };
  }

  /// 本页作为下层、被覆盖或揭开时的位移终点（比例）。
  ///
  /// ⚠️ **与 Figma 有一处刻意偏差**：Figma 在 push 时**不移动**下层页
  /// （React 里它是直接卸载的），只在 pop 时让被揭开的页从 `-20px` 滑入。
  /// Flutter 的 [secondaryAnimation] 是**对称**的（覆盖 0→1、揭开 1→0），
  /// 无法只响应其中一个方向。
  ///
  /// 这里选择保留对称位移，理由是 Baseline §6.6 明令
  /// 「返回：与进入形成**相反关系**，不允许瞬移或重新淡入整页」——
  /// 只做单侧会让 pop 失去反向关系。
  /// 已登记 **待裁决 · D62**（`docs/05_progress/TODO.md` §3.1）。
  Offset coveredOffset(BoxConstraints constraints) {
    return switch (this) {
      // push 时下层页轻微左移，pop 时滑回原位 —— 与上层的 20px 形成反向关系。
      CareerlyTransitionKind.push => Offset(
        _fractionOfWidth(constraints, AppMotion.pagePopOffset),
        0,
      ),
      // Onboarding 是「替换」而非「入栈」（全 app 无 `context.push`），
      // 不存在下层页，不需要位移。
      CareerlyTransitionKind.onboarding => Offset.zero,
    };
  }
}

/// `px` → 占父级宽度的比例。
///
/// 约束无界或为零时退回 `0`（不位移），避免除零与 `Infinity`。
double _fractionOfWidth(BoxConstraints constraints, double px) {
  final double width = constraints.maxWidth;
  if (!width.isFinite || width <= 0) return 0;
  return px / width;
}
