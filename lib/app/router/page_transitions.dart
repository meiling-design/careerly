import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/motion/careerly_page_transition.dart';
import '../../design_system/tokens/tokens.dart';

/// Careerly 的 go_router 页面转场工厂。
///
/// 依据 Baseline §6.6（**不使用 M3 默认转场**）：
///
/// ```text
/// 一级导航切换   →  淡入 + 内容轻微上移，180–260ms
/// 二级页面进入   →  右侧轻微进入 (translationX 16–24px)，240–300ms
/// 返回           →  与进入形成相反关系，不允许瞬移或重新淡入整页
/// Onboarding     →  Progressive Flow，280–320ms
/// ```
///
/// 转场的**视觉实现只有一份**，在
/// [CareerlyPageTransition]（`design_system/motion/`）——
/// 因为 `CareerlyTheme` 的 `PageTransitionsTheme` 也需要同一条转场，
/// 而它不能反向依赖 `app/`。本文件只负责把它包成 go_router 的
/// [CustomTransitionPage]。
///
/// ⚠️ **一级导航切换不在这里**：它发生在 [StatefulShellRoute] 的
/// `IndexedStack` 内部，不经过路由转场，由 `CareerlyShell` 直接驱动。
abstract final class CareerlyPageTransitions {
  /// 二级页面：右侧进入 20px，返回时反向（Figma `.page-push` / `.page-pop`）。
  ///
  /// 时长 260ms / 240ms，曲线 `cubic-bezier(0.25,0.46,0.45,0.94)`。
  static CustomTransitionPage<T> slide<T>({
    required LocalKey key,
    required Widget child,
    String? name,
  }) {
    return _page<T>(
      key: key,
      name: name,
      child: child,
      kind: CareerlyTransitionKind.push,
      duration: AppMotion.pagePush,
      reverseDuration: AppMotion.pagePop,
    );
  }

  /// Onboarding 步骤：**水平**进入 24px（Figma `.page-onboard`，300ms）。
  ///
  /// ⚠️ Phase 3 更正：早先这里用的是 `fadeUp`（**垂直** 上移），
  /// 而 Figma 的 `_onboard-in` 是 `translateX(24px)` —— **轴向错了**。
  static CustomTransitionPage<T> onboarding<T>({
    required LocalKey key,
    required Widget child,
    String? name,
  }) {
    return _page<T>(
      key: key,
      name: name,
      child: child,
      kind: CareerlyTransitionKind.onboarding,
      duration: AppMotion.pageOnboarding,
      reverseDuration: AppMotion.pageOnboarding,
    );
  }

  static CustomTransitionPage<T> _page<T>({
    required LocalKey key,
    required Widget child,
    required CareerlyTransitionKind kind,
    required Duration duration,
    required Duration reverseDuration,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      child: child,
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              CareerlyPageTransition.build(
                kind: kind,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              ),
    );
  }
}
