import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/app_back_platform.dart';
import '../../design_system/components/components.dart';
import '../../design_system/tokens/tokens.dart';
import '../router/app_routes.dart';
import '../router/back_navigation.dart';

/// Careerly App Shell。
///
/// 依据 Phase 1 §十四，Shell 需要支持：
/// - SafeArea
/// - Content area
/// - Custom Bottom Navigation
/// - 当前 Tab 状态
/// - Tab 切换
/// - Android Back 基础行为
/// - 页面 Transition Architecture
///
/// ## 实现方式
///
/// 使用 go_router 的 `StatefulShellRoute.indexedStack`：
/// 每个一级导航是一个独立的 `StatefulShellBranch`，
/// 用 `IndexedStack` 保持各 Tab 的页面状态（滚动位置、输入内容不丢）。
///
/// 这对 Careerly 是必需的——
/// 「分析」页用户可能正在粘贴 JD，切到「我的」再切回来不应该丢失内容。
///
/// ## Android Back / 边缘右滑行为（2026-11-14 产品侧更新）
///
/// ```text
/// 分支内有二级页面  →  先 pop 二级页面（Back = 回到上一个操作上下文）
/// 一级页面 · 首页   →  moveTaskToBack(true) 退到后台（不 finish）
/// 一级页面 · 其他   →  先回到「首页」；在首页再次 Back 才退到后台
/// ```
///
/// 这是对旧规则（「一级页面之间不互相返回」）的**产品侧更新**。
/// 执行位置在本 Shell 的 [PopScope]：
///
/// - 所有**一级页面根**：`canPop: false`，系统 Back / 边缘右滑被拦截后
///   - 首页 → [AppBackPlatform.moveTaskToBack]（Android 退后台）；
///   - 分析 / AI / 我的 → `goBranch(0)` 切回首页；
/// - 分支内的二级 / 三级页面：`canPop: true`，由 go_router 先把
///   分支 Navigator 的页面 pop 掉，轮不到 Shell 这一层；
/// - 拦截前先收软键盘（`dismissSoftKeyboardIfVisible`）。
///
/// ❌ 返回路径中**不得**调用 `finish()` / `exit(0)` / `logout()` /
/// `clearToken()`。退后台不等于退出登录，也不清理任务状态。
///
/// 统一的 Back Action 与离开确认守卫见
/// `app/router/back_navigation.dart`；页面返回入口一律走 `careerlyBack()`，
/// 不写 `context.pop()`（后者绕过 `PopScope`）。
class CareerlyShell extends StatefulWidget {
  const CareerlyShell({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  /// go_router 注入的分支导航控制器。
  final StatefulNavigationShell navigationShell;

  /// 当前完整路径（来自 [GoRouterState.uri.path]）。
  ///
  /// 用于判断「当前是否停在某个一级页面的根上」——
  /// 只有根页面才触发「非首页先回首页」的拦截；
  /// 分支内的二级页仍按原规则 pop。
  final String currentLocation;

  /// 四个一级页面的根路径。
  static const Set<String> branchRoots = <String>{
    AppRoutes.home,
    AppRoutes.analysis,
    AppRoutes.ai,
    AppRoutes.profile,
  };

  /// 底部导航目的地。
  ///
  /// 顺序必须与 [AppRoutes.shellBranches] 完全一致。
  ///
  /// ## AI 在列表中的位置与实际渲染位置**不同**
  ///
  /// 四个一级导航的**顺序**是 AI 排第 3（首页 / 分析 / AI / 我的），
  /// 但 Figma 的 BottomNav 把 AI 画在**玻璃条之外的右侧**，
  /// 而不是夹在「分析」和「我的」中间。
  ///
  /// [CareerlyNavigationBar] 会按 [CareerlyNavDestination.isSpecial]
  /// 把它从玻璃条中分流出去，所以**这里保持自然顺序即可**，
  /// 不需要为了视觉把 AI 挪到列表末尾。
  static const List<CareerlyNavDestination> destinations =
      <CareerlyNavDestination>[
        CareerlyNavDestination.standard(
          label: '首页',
          glyph: CareerlyNavGlyph.home,
        ),
        CareerlyNavDestination.standard(
          label: '分析',
          glyph: CareerlyNavGlyph.analysis,
        ),
        CareerlyNavDestination.ai(),
        CareerlyNavDestination.standard(
          label: '我的',
          glyph: CareerlyNavGlyph.profile,
        ),
      ];

  @override
  State<CareerlyShell> createState() => _CareerlyShellState();
}

class _CareerlyShellState extends State<CareerlyShell>
    with SingleTickerProviderStateMixin {
  /// 一级导航切换动画。
  ///
  /// ⚠️ 初值 `1.0` 而不是 `0.0` —— 首帧不能播动画，
  /// 否则 App 启动时会看到首页「从下往上淡入」一次。
  /// 只有 [didUpdateWidget] 检测到**真的切了 Tab** 才 `forward(from: 0)` 重播。
  late final AnimationController _tabController = AnimationController(
    vsync: this,
    duration: AppMotion.tabSwitch,
    value: 1,
  );

  @override
  void didUpdateWidget(CareerlyShell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _tabController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSelect(int index) {
    // goBranch 而不是 go：保留该分支原有的导航栈与页面状态。
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 一级页面的根才由 Shell 拦截：
    //   首页根      → 退到后台（moveTaskToBack，不 finish）
    //   非首页根    → 切回首页
    // 分支内的二级页保持 canPop: true，由 go_router 先 pop 掉。
    final bool atBranchRoot = CareerlyShell.branchRoots.contains(
      widget.currentLocation,
    );
    final bool atHomeRoot = widget.currentLocation == AppRoutes.home;

    return PopScope<Object?>(
      canPop: !atBranchRoot,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !atBranchRoot) return;

        // 第一优先：软键盘。收起键盘 = 本次 Back 已被消费。
        if (dismissSoftKeyboardIfVisible(context)) return;

        if (atHomeRoot) {
          // 产品红线：首页再次 Back 只退到后台。
          // ❌ 不调用 SystemNavigator.pop()（Android 上等于 finish()）。
          AppBackPlatform.moveTaskToBack();
          return;
        }

        widget.navigationShell.goBranch(0);
      },
      child: Scaffold(
        // 背景渐变由 CareerlyApp 根节点绘制，这里保持透明。
        backgroundColor: Colors.transparent,
        // 底部导航是**浮层**，不能用 `Scaffold.bottomNavigationBar`
        // —— 那个位置会占据文档流高度，把导航渲染成一根通栏底栏，
        // 与 Figma「居中玻璃胶囊 + 条外 AI 球」的结构不符。
        body: Stack(
          children: <Widget>[
            // 内容区。
            //
            // 一级页面根（首页 / 分析 / AI / 我的）**全高滚动**，内容可以从
            // 悬浮导航下方穿过 —— 与 Figma 根布局一致：导航是绝对定位浮层，
            // 页面滚动容器自己带 `pb-24`，而不是把视口裁短。
            // 若在这里裁短视口，卡片顶边会停在裁切线上，看起来像一条横贯
            // 屏幕的「框架」把内容和导航分开。
            //
            // 分支内二级 / 三级页面仍保留 96 底部避让：这些页面在 Figma 里
            // 本不显示底部导航，当前实现统一显示，至少不能让内容压到导航下面。
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: atBranchRoot
                      ? 0
                      : AppConstants.navigationBarContentInset,
                ),
                child: _TabTransition(
                  controller: _tabController,
                  child: widget.navigationShell,
                ),
              ),
            ),

            // 导航浮层：贴底、通栏定位，内部整组居中。
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CareerlyNavigationBar(
                destinations: CareerlyShell.destinations,
                currentIndex: widget.navigationShell.currentIndex,
                onSelect: _onSelect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 一级导航切换的内容动画（Figma `.page-tab`）。
///
/// ```text
/// 200ms · cubic-bezier(0.25,0.46,0.45,0.94) · opacity 0→1 · translateY(8px)→0
/// ```
///
/// ## 为什么必须写在 Shell 层，而不是路由转场里
///
/// 四个一级 Tab 由 [StatefulShellRoute.indexedStack] 承载：
/// 切换走的是 `IndexedStack` 换索引，**不产生路由压栈**，
/// 因此 `CustomTransitionPage` 的 `transitionsBuilder` **根本不会被触发**。
/// Phase 3 审计确认：此前 Tab 切换是**零动画硬切**（B-1）。
///
/// ## 为什么用 [Transform.translate] 而不是 [SlideTransition]
///
/// Figma 给的是**绝对像素** `8px`；而 [SlideTransition] 收的是
/// 子元素尺寸的比例。这里直接给像素，省掉一次换算与它带来的取整误差。
class _TabTransition extends StatelessWidget {
  const _TabTransition({required this.controller, required this.child});

  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double t = AppMotion.pageCurve.transform(controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * AppMotion.tabContentOffset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
