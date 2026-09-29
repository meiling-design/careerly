/// Careerly Android Back Navigation Rule —— **执行层**。
///
/// 本文件是「返回」这件事在 Careerly 里的**唯一执行点**。
/// 页面不自己写返回逻辑，只声明「我这一页离开前是否需要确认」。
///
/// ## 规则（产品已确认）
///
/// ```text
/// 一级页面（首页 / 分析 / AI / 我的）：由 Bottom Navigation 管理，
///                                     不使用页面级 Back，不返回更前的一级页面
/// 二级 / 三级页面                    ：统一支持 Back
///
/// 顶部返回按钮 ─┐
/// 系统 Back    ├─→ 同一个 Back Action（Navigator.maybePop）
/// Edge Swipe   ─┘
///
/// Back = 当前 Navigation Stack 的 pop = 回到「上一个操作上下文」
/// ```
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
import 'package:flutter/services.dart';

import '../../design_system/components/components.dart';
import '../../design_system/tokens/tokens.dart';

/// 执行一次 Careerly Back Action。
///
/// **所有**「返回」入口（顶部按钮、系统 Back、边缘右滑）最终都落在这里。
///
/// 用 [NavigatorState.maybePop] 而不是 [NavigatorState.pop]：
/// `maybePop` 会先询问当前路由的 `popDisposition`（即 `PopScope`），
/// 使 [CareerlyBackScope] 的离开确认对**顶部按钮**同样生效。
///
/// 返回 `true` 表示本次返回已被处理（真的 pop 了，或被守卫拦下等待确认）。
/// 返回 `false` 表示当前已经是导航栈底 —— 一级页面的系统 Back 就是这个情形，
/// 交给 Android 默认处理（退到后台 / 退出），**不**改写成「回到首页」。
Future<bool> careerlyBack(BuildContext context, [Object? result]) {
  return Navigator.of(context).maybePop(result);
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
/// 栈里还有上一页  →  pop（二级回一级、三级回二级）
/// 已经是栈底      →  SystemNavigator.pop()（交给 Android，退到后台）
/// ```
///
/// 后者只发生在**一级页面**上（例如「分析进行中」的离开确认）——
/// 那时没有可 pop 的目标，语义就是「退出 / 退到后台」，
/// 与规则里「一级页面 = 退出/系统默认处理」一致。
///
/// ⚠️ 这里**不会**调用 `exitAnalysis()` 之类的中断逻辑：
/// 守卫只负责「离开界面」，任务是否继续由任务自己的状态决定
/// （分析任务活在 `AnalysisProvider` 里，不随页面销毁）。
class CareerlyBackScope extends StatefulWidget {
  const CareerlyBackScope({super.key, required this.child, this.guard});

  /// 被守卫的子树（通常是一整页）。
  final Widget child;

  /// 离开守卫。为 `null` 表示本页可以直接返回。
  final CareerlyBackGuard? guard;

  @override
  State<CareerlyBackScope> createState() => _CareerlyBackScopeState();
}

class _CareerlyBackScopeState extends State<CareerlyBackScope> {
  /// 防止连续 Back 叠出多个确认弹层。
  bool _confirming = false;

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    // 已经 pop 掉了（无守卫的正常返回）—— 什么都不用做。
    if (didPop) return;

    final CareerlyBackGuard? guard = widget.guard;
    if (guard == null) {
      // `canPop` 为 true 时 didPop 必为 true，这里只是防御性分支。
      _leave(result);
      return;
    }
    if (_confirming) return;

    _confirming = true;
    final bool leave = await guard.confirm(context);
    _confirming = false;

    if (!mounted || !leave) return;
    _leave(result);
  }

  /// 真正离开：有上一页就 pop，没有（栈底）就交给 Android。
  void _leave(Object? result) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(result);
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool guarded = widget.guard != null;

    return PopScope<Object?>(
      // 有守卫 → 先不许 pop，等 `_onPopInvoked` 问完再说。
      // 无守卫 → 直接放行，与没有本组件时完全一致。
      canPop: !guarded,
      onPopInvokedWithResult: _onPopInvoked,
      child: widget.child,
    );
  }
}
