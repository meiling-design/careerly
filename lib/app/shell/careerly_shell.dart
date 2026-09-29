import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../design_system/components/components.dart';
import '../../design_system/tokens/tokens.dart';

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
/// ## Android Back 行为（产品规则已确认 · CLAUDE.md §5.6）
///
/// ```text
/// 分支内有二级页面  →  先 pop 二级页面（Back = 回到上一个操作上下文）
/// 分支根页面        →  退出 App / 系统默认处理
/// ```
///
/// ❌ **不做**「非首个 Tab 按返回先回到首页」—— 产品已裁决：
/// 一级页面之间不互相返回（Phase 1 备注的 Phase 3 调优项作废）。
///
/// 统一的 Back Action 与离开确认守卫见
/// `app/router/back_navigation.dart`；页面返回入口一律走 `careerlyBack()`，
/// 不写 `context.pop()`（后者绕过 `PopScope`）。
class CareerlyShell extends StatefulWidget {
  const CareerlyShell({super.key, required this.navigationShell});

  /// go_router 注入的分支导航控制器。
  final StatefulNavigationShell navigationShell;

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
    return Scaffold(
      // 背景渐变由 CareerlyApp 根节点绘制，这里保持透明。
      backgroundColor: Colors.transparent,
      // 底部导航是**浮层**，不能用 `Scaffold.bottomNavigationBar`
      // —— 那个位置会占据文档流高度，把导航渲染成一根通栏底栏，
      // 与 Figma「居中玻璃胶囊 + 条外 AI 球」的结构不符。
      body: Stack(
        children: <Widget>[
          // 内容区：为浮起的导航预留底部避让（Figma 内容区 `pb-24`）。
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.navigationBarContentInset,
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
