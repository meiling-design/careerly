/// Careerly Android Back Navigation Rule —— **执行层**。
///
/// 本文件是「返回」这件事在 Careerly 里的**唯一执行点**。
/// 页面不自己写返回逻辑，只声明「我这一页离开前是否需要确认」。
///
/// ## 规则（产品已确认）
///
/// ```text
/// 键盘 / 弹窗 / 抽屉 / 未保存表单：先消费本次 Back（收起 / 关闭 / 确认）
/// 一级页面 · 首页（/home）        ：moveTaskToBack(true) 退到后台
/// 一级页面 · 分析 / AI / 我的      ：先回到首页；首页再 Back 才退后台
/// 二级 / 三级页面                 ：统一支持 Back，pop 回上一个操作上下文
///
/// 顶部返回按钮 ─┐
/// 系统 Back    ├─→ 同一个 Back Action（Navigator.maybePop）
/// Edge Swipe   ─┘
///
/// Back = 当前 Navigation Stack 的 pop = 回到「上一个操作上下文」
///
/// ❌ 任何返回路径都不得调用 finish() / exit(0) / logout() / clearToken()。
/// 首页退后台走 `AppBackPlatform.moveTaskToBack()`（Android `moveTaskToBack`）。
/// ```
///
/// ⚠️ 一级页面的「非首页先回首页」**不在本文件执行** ——
/// 它由 `app/shell/careerly_shell.dart` 的 [PopScope] 拦截
/// （见该文件「Android Back / 边缘右滑行为」）。本文件继续只负责
/// 「pop 之前要不要先问一句」。
///
/// ## 为什么必须走 [careerlyBack]，而不是 `context.pop()`
///
/// go_router 18 的两条 pop 路径**并不等价**（已核对其源码）：
///
/// | 入口 | 实现 | 是否经过 `PopScope` |
/// |---|---|---|
/// | 系统 Back / 预测性返回 | `GoRouterDelegate.popRoute()` → `NavigatorState.maybePop()` | ✅ 会 |
/// | 顶部返回按钮 `context.pop()` | `GoRouterDelegate.pop()` → `NavigatorState.pop()` | ❌ **不会** |
///
/// 也就是说：如果顶部返回按钮继续写 `context.pop()`，
/// 那么「未保存修改」这类离开确认**对顶部按钮完全失效**，
/// 却对系统 Back 生效 —— 同一个动作两种结果，属于明确的交互 Bug。
///
/// [careerlyBack] 把顶部按钮也收敛到 `NavigatorState.maybePop()`，
/// 于是三个入口**落在同一条代码路径**上，[CareerlyBackScope] 的守卫
/// 对三者同时生效。
///
/// ## 关于 Edge Swipe Back（左边缘右滑）
///
/// 不是「整个页面任意位置横滑」，而是**从屏幕左边缘开始**的系统手势 ——
/// 由 Android 手势导航提供，Flutter 侧通过预测性返回（predictive back）
/// 接入（`android:enableOnBackInvokedCallback="true"`，
/// 见 `android/app/src/main/AndroidManifest.xml`）。
///
/// 页面中间的横向滑动（卡片横滑、列表横滑）**不触发** Back ——
/// 它由页面自己的手势识别器处理，与系统边缘手势互不干扰。
/// 这也是**不要自己写 `GestureDetector` 横滑返回**的原因：
/// 自绘横滑会与页面内的横滑组件抢手势。
///
/// ## 与 Router 的关系
///
/// 「哪一页返回哪一页」**不在这里决定**，由 `app_router.dart` 的路由层级
/// 表达（二级嵌在分支内、三级嵌在二级内），Back 只是 `pop`。
/// 本文件只负责「pop 之前要不要先问一句」。
///
/// 新增「我的足迹 → 日期详情」「能力 → 能力详情」这类页面时，
/// 只要按同一层级形状挂进 Router，就自动继承同一套 Back 行为，
/// **不需要**为它们单独设计返回逻辑。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/app_back_platform.dart';
import '../../design_system/components/components.dart';
import '../../design_system/tokens/tokens.dart';
import 'app_routes.dart';

/// 返回前的**第一优先拦截层**：收起软键盘。
///
/// 产品规则（2026-11-15）：存在软键盘时，Back / 侧滑**先收起键盘**，
/// 不触发页面回退。返回值 `true` 表示本次返回已被键盘消费，
/// 调用方应直接结束、不要继续 pop。
///
/// 只认 `MediaQuery.viewInsets.bottom > 0`（真的被软键盘顶起），
/// 不认「有焦点」—— 外接硬件键盘打字时不应吞掉返回。
bool dismissSoftKeyboardIfVisible(BuildContext context) {
  final EdgeInsets insets =
      MediaQuery.maybeViewInsetsOf(context) ?? EdgeInsets.zero;
  if (insets.bottom <= 0) return false;
  FocusManager.instance.primaryFocus?.unfocus();
  return true;
}

/// 执行一次 Careerly Back Action。
///
/// **所有**「返回」入口（顶部按钮、系统 Back、边缘右滑）最终都落在这里。
///
/// 执行顺序与系统 Back 完全一致：
///
/// ```text
/// 1. 软键盘可见        → 只收键盘，本次返回已被消费
/// 2. 当前 Navigator pop → pop 二级 / 三级页面（经过 PopScope 守卫）
/// 3. 分支栈底          → 交给 GoRouter 的 popRoute()
///                        → 分支根页面由 Shell 决定「回首页 / 退后台」
/// ```
///
/// 第 3 步不能省略：一级页面（`/analysis`、`/ai`、`/profile`）位于
/// `StatefulShellRoute` 的分支 Navigator 栈底，`Navigator.maybePop()`
/// 只会返回 `false`，不会触达 Shell 的 [PopScope]。若顶部按钮停在这里，
/// 它在分支根页面上就会变成一颗「静默死键」—— 与系统 Back 语义分叉。
/// 走 [GoRouterDelegate.popRoute] 后，两个入口共用同一条查找顺序
/// （分支 Navigator → 根 Navigator），行为一致。
///
/// 返回 `true` 表示本次返回已被处理（真的 pop 了、收起了键盘、
/// 或弹出了离开确认）。返回 `false` 表示没有任何层消费这次返回。
Future<bool> careerlyBack(BuildContext context, [Object? result]) async {
  // 优先级 1：软键盘。顶部按钮与系统 Back 都必须先收键盘。
  if (dismissSoftKeyboardIfVisible(context)) return true;

  // 优先级 2：当前 Navigator 的 pop（路由 / 守卫 / 页面内部流程）。
  final NavigatorState navigator = Navigator.of(context);
  final GoRouter? router = GoRouter.maybeOf(context);
  if (await navigator.maybePop(result)) return true;

  // 优先级 3：分支栈底交给 GoRouter，由 Shell 执行根页面回退策略。
  if (router == null) return false;
  return router.routerDelegate.popRoute();
}

/// 「离开前先确认」的守卫描述。
///
/// 一个守卫 = 一句问话 + 两个选项。**文案属产品资产**，
/// 调用处给出；本组件只负责呈现与结果。
///
/// 视觉沿用 [CareerlyBottomSheet]（Figma 的确认类弹层）而不是
/// Material `AlertDialog` —— 依据 Baseline §6.5，
/// Careerly 的视觉系统不由 M3 默认样式主导；且「分析中退出确认」
/// 在 Figma 里就是这张弹层，两者保持同一形态。
class CareerlyBackGuard {
  const CareerlyBackGuard({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  /// 未保存修改的离开确认（示例：编辑简历后按 Back）。
  ///
  /// ```text
  /// ┌────────────────┐
  /// │ 是否放弃修改？ │
  /// │ 继续编辑  放弃 │
  /// └────────────────┘
  /// ```
  const CareerlyBackGuard.unsavedChanges({
    String title = '是否放弃修改？',
    String message = '离开后本次修改不会被保存。',
    String confirmLabel = '放弃修改',
    String cancelLabel = '继续编辑',
  }) : this(
         title: title,
         message: message,
         confirmLabel: confirmLabel,
         cancelLabel: cancelLabel,
       );

  /// 分析进行中的离开确认。
  ///
  /// ⚠️ **「离开」不等于「取消分析」** —— 依产品规则，
  /// 分析进行中 Back 不应默认取消任务：确认离开后任务状态保留，
  /// 重新进入分析页可以看到「分析中……」或已完成的结果。
  /// 取消分析是另一件事，需要**显式**的操作入口（`exitAnalysis`）。
  const CareerlyBackGuard.analysisInProgress({
    String title = '是否离开分析？',
    String message = '离开不会中止本次分析，分析会在后台继续；重新回到分析页可以看到最新进度。',
    String confirmLabel = '离开',
    String cancelLabel = '继续分析',
  }) : this(
         title: title,
         message: message,
         confirmLabel: confirmLabel,
         cancelLabel: cancelLabel,
       );

  /// 问句标题。
  final String title;

  /// 说明正文。
  final String message;

  /// 确认离开的按钮文案。
  final String confirmLabel;

  /// 留下继续的按钮文案。
  final String cancelLabel;

  /// 弹出确认弹层，返回用户是否选择「离开」。
  Future<bool> confirm(BuildContext context) async {
    final bool? leave = await CareerlyBottomSheet.show<bool>(
      context,
      tone: CareerlyBottomSheetTone.confirm,
      // ⚠️ 必须用 [Builder] 拿**弹层自己的** context 来 pop。
      //
      // 直接闭包捕获外层 `context`（即页面 context）会解析到**分支 Navigator**，
      // 而弹层是被 `showGeneralDialog` push 到**根 Navigator** 上的 ——
      // 两者不是同一个 Navigator，`pop()` 会把当前页面弹掉、弹层留在屏幕上。
      // （既有「分析中退出确认」是同样的写法，待核实后另行处理。）
      child: Builder(
        builder: (BuildContext sheetContext) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(title, style: AppTypography.analysisSheetTitle),
              const SizedBox(height: 8),
              Text(message, style: AppTypography.analysisSheetBody),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _GuardButton(
                      label: cancelLabel,
                      style: AppTypography.analysisSheetPrimary,
                      background: AppColors.primaryBlue,
                      // 「留下」= 收掉弹层 + 不 pop（返回 false）。
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GuardButton(
                      label: confirmLabel,
                      style: AppTypography.analysisSheetGhost,
                      background: AppColors.analysisSheetGhostFill,
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // 点 scrim / 系统 Back 收掉弹层时结果是 null —— 一律按「留下」处理。
    return leave ?? false;
  }
}

/// 离开确认弹层的按钮（与「分析中退出确认」同款几何）。
class _GuardButton extends StatelessWidget {
  const _GuardButton({
    required this.label,
    required this.style,
    required this.background,
    required this.onPressed,
  });

  final String label;
  final TextStyle style;
  final Color background;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: AppRadius.borderPill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(child: Text(label, style: style)),
        ),
      ),
    );
  }
}

/// Shell 之外的**顶级路由**的 Back 兜底（`/settings`、`/legal/*`）。
///
/// 这些页面没有 [StatefulShellRoute] 的分支保护：如果通过深链 / 调试入口
/// **直接**打开它们，导航栈里可能没有首页。此时 Back 不能直接退出 App，
/// 必须先把首页补到栈底；首页本身才退后台。
///
/// 页内二级页（例如 `/settings/personal-info`）由 go_router 正常 pop，
/// 不需要额外包裹 —— 本组件只负责「顶级路由的栈底语义」。
class CareerlyRootBackScope extends StatelessWidget {
  const CareerlyRootBackScope({
    super.key,
    required this.child,
    this.fallbackToHome = true,
    this.fallbackLocation,
  });

  final Widget child;

  /// 栈底是否把首页补到栈底。
  ///
  /// - 应用内页面（`/settings`、`/legal/*`）→ `true`；
  /// - Onboarding（开屏 / 登录 / 注册）→ `false`：登录前没有「首页」，
  ///   栈底 Back 只退后台，**不能**借机进入需要登录的主界面。
  final bool fallbackToHome;

  /// 栈底且没有上一页时的**流程落点**（优先级高于 [fallbackToHome]）。
  ///
  /// Onboarding 的步骤是一条线性流程：深链 / 调试直接落到「提交简历」时，
  /// 栈里没有「注册」这一页，但语义上的上一屏仍然是注册页。此时
  /// Back 应 go 到 [fallbackLocation]，而不是直接退后台。
  ///
  /// `null` 表示没有流程落点，继续走 [fallbackToHome] / 退后台。
  final String? fallbackLocation;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      // 始终自己处理，才能先收键盘、再决定 pop / go(fallback) / 退后台。
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (dismissSoftKeyboardIfVisible(context)) return;
        _leaveToRoot(
          context,
          result,
          fallbackToHome: fallbackToHome,
          fallbackLocation: fallbackLocation,
        );
      },
      child: child,
    );
  }
}

/// 栈底离开动作：有上一页就 pop；否则走流程落点 / 首页；最后才退后台。
void _leaveToRoot(
  BuildContext context,
  Object? result, {
  bool fallbackToHome = true,
  String? fallbackLocation,
}) {
  final NavigatorState navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop(result);
    return;
  }

  final GoRouter? router = GoRouter.maybeOf(context);
  if (router != null) {
    final String location = router.routeInformationProvider.value.uri.path;

    // 流程落点优先：Onboarding 的「上一步」是业务语义，不是首页。
    if (fallbackLocation != null && fallbackLocation != location) {
      router.go(fallbackLocation);
      return;
    }

    if (fallbackToHome && location.isNotEmpty && location != AppRoutes.home) {
      router.go(AppRoutes.home);
      return;
    }
  }

  AppBackPlatform.moveTaskToBack();
}

/// 只负责**优先级 1（软键盘）**的路由级包装。
///
/// 包在 `app_router.dart` 的每一条二级 / 三级路由上，而不是让每个页面
/// 各写一层 `PopScope`：
///
/// ```text
/// 键盘可见 → canPop = false → Back 只收键盘
/// 键盘隐藏 → canPop = true  → 保持原有 pop 行为（完全透明）
/// ```
///
/// 分支根页面不需要它 —— Shell 自己的 [PopScope] 已先收键盘；
/// Shell 之外的顶级路由由 [CareerlyRootBackScope] 收键盘。
class CareerlyKeyboardBackScope extends StatelessWidget {
  const CareerlyKeyboardBackScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool keyboardVisible =
        (MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0) > 0;

    return PopScope<Object?>(
      canPop: !keyboardVisible,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !keyboardVisible) return;
        dismissSoftKeyboardIfVisible(context);
      },
      child: child,
    );
  }
}

/// 给一棵子树装上「Back 守卫」。
///
/// ```dart
/// // 无守卫的普通二级页 —— 直接 pop（默认行为，一字不用改）
/// CareerlyBackScope(child: page)
///
/// // 有未保存修改的页面
/// CareerlyBackScope(
///   guard: dirty ? const CareerlyBackGuard.unsavedChanges() : null,
///   child: page,
/// )
/// ```
///
/// [guard] 为 `null` 时**完全透明**：`canPop: true`，不拦截、不弹层，
/// 与没有这层包裹时完全一致。因此它可以无脑套在每一页外面。
///
/// ## 为什么放在**路由层**而不是每个页面自己写
///
/// 路由层包一次，三个入口（顶部按钮 / 系统 Back / 边缘右滑）就同时被覆盖；
/// 页面侧只需要回答「我脏不脏」这一个问题（给 [guard] 传值），
/// 不需要知道 Back 从哪来，也不需要自己写 `PopScope`。
///
/// ## 确认之后的「离开」是什么
///
/// ```text
/// 栈里还有上一页      →  pop（二级回一级、三级回二级）
/// 栈底且不是首页      →  go('/home')（首页补到栈底）
/// 栈底且就是首页      →  moveTaskToBack(true)（退后台，不 finish）
/// ```
///
/// 最后一种只发生在**首页根**（或带守卫的栈底页）上 ——
/// 那时没有可 pop 的目标，语义就是「退到后台」，**不是**「退出 App」。
///
/// ⚠️ 非首页的一级页面不会走到这里：Shell 的 [PopScope] 会先把 Back
/// 改成「切回首页」，所以在分析 / AI / 我的根页面按一次 Back 不会退出。
///
/// ⚠️ 这里**不会**调用 `exitAnalysis()` 之类的中断逻辑：
/// 守卫只负责「离开界面」，任务是否继续由任务自己的状态决定
/// （分析任务活在 `AnalysisProvider` 里，不随页面销毁）。
class CareerlyBackScope extends StatefulWidget {
  const CareerlyBackScope({
    super.key,
    required this.child,
    this.guard,
    this.onFlowBack,
  });

  /// 被守卫的子树（通常是一整页）。
  final Widget child;

  /// 离开守卫。为 `null` 表示本页没有「离开前确认」。
  final CareerlyBackGuard? guard;

  /// 页面内部的**流程回退**（优先级 2 / 3），例如：
  ///
  /// ```text
  /// 分析结果      → 回到新建分析 / 历史列表
  /// 历史分析列表  → 回到新建分析
  /// 展开的 JD 表单 → 关闭表单
  /// AI 聊天记录   → 关闭侧栏
  /// ```
  ///
  /// 非 `null` 时本层会拦截 Back（`canPop: false`），回调执行后
  /// **本次返回即被消费**，不会再交给 Shell / 路由层。
  ///
  /// 为 `null` 时本层完全透明：与没有这层包裹时一致。
  final VoidCallback? onFlowBack;

  @override
  State<CareerlyBackScope> createState() => _CareerlyBackScopeState();
}

class _CareerlyBackScopeState extends State<CareerlyBackScope> {
  /// 防止连续 Back 叠出多个确认弹层。
  bool _confirming = false;

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    // 已经 pop 掉了（无守卫 / 无流程回退的正常返回）—— 什么都不用做。
    if (didPop) return;

    // 第一优先：软键盘。收起键盘算「已消费本次返回」，不 pop 页面。
    if (dismissSoftKeyboardIfVisible(context)) return;

    final CareerlyBackGuard? guard = widget.guard;
    if (guard == null) {
      final VoidCallback? onFlowBack = widget.onFlowBack;
      if (onFlowBack != null) {
        onFlowBack();
        return;
      }

      // 本层的 `canPop` 为 true。收到 `didPop == false` 只可能是
      // 同一路由上的**另一个** PopScope 拦截了这次返回 —— 此时必须
      // 保持静默，否则同一次 Back 会被消费两次（叠出两个 pop / 跳转）。
      return;
    }
    if (_confirming) return;

    _confirming = true;
    final bool leave = await guard.confirm(context);
    _confirming = false;

    if (!mounted || !leave) return;
    _leave(result);
  }

  /// 真正离开。
  ///
  /// ```text
  /// 有上一页                 → pop（逐级回退）
  /// 栈底且当前不是首页       → go('/home')（把首页补到栈底）
  /// 栈底且当前就是首页       → moveTaskToBack(true)（退后台，不 finish）
  /// ```
  void _leave(Object? result) => _leaveToRoot(context, result);

  @override
  Widget build(BuildContext context) {
    // 有守卫 / 有流程回退 → 本层消费 Back；否则完全透明。
    final bool handledHere =
        widget.guard != null || widget.onFlowBack != null;

    return PopScope<Object?>(
      // 需要本层处理时先不许 pop，等 `_onPopInvoked` 决定。
      // 否则直接放行，与没有本组件时完全一致。
      canPop: !handledHere,
      onPopInvokedWithResult: _onPopInvoked,
      child: widget.child,
    );
  }
}
