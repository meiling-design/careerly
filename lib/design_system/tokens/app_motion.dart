import 'package:flutter/animation.dart';

/// Careerly 动效 Token。
///
/// 来源：`docs/.../src/imports/pasted_text/careerly-app-motion-spec.md` §27，
/// 以及 Baseline §6.4 / §6.6。
///
/// **绝对规则：不要每个页面随意设置动画时间。**
/// 所有动画时长与曲线必须来自本文件。
abstract final class AppMotion {
  // ---------------------------------------------------------------------------
  // 六档时长（motion-spec §27）
  // ---------------------------------------------------------------------------

  /// 微交互：图标颜色变化、选中态描边。80–120ms
  static const Duration micro = Duration(milliseconds: 100);

  /// 通用按压反馈时长（`CareerlyPressFeedback` 的默认值，服务卡片 / Chip）。
  /// 120–200ms
  ///
  /// ⚠️ **`CareerlyButton` 不使用本档。** Figma 的按钮 transition 是 `120ms`，
  /// 与本档的 160ms 不符；按钮当前取 [micro]（100ms）。
  /// 详见 `careerly_button.dart` 中的说明。
  static const Duration button = Duration(milliseconds: 160);

  /// 小元件：Chip 切换、Tab 指示条、卡片内元素。180–240ms
  static const Duration smallComponent = Duration(milliseconds: 210);

  /// 二级页面进入（旧名，等价于 [pagePush]）。
  ///
  /// ⚠️ 保留此名只为不破坏既有引用（`widget_test.dart` 断言其落在 240–320ms）。
  /// **Phase 3 起请直接使用四条具名时长**，它们才是 Figma 的原值。
  static const Duration pageTransition = pagePush;

  // --- Figma 明写的四条转场时长（`src/index.css` L159-162）--------------------
  //
  // ⚠️ **D49 更正（2026-09-18）**
  // 早先本文件把页面转场曲线标为「归纳值 · spec 只给文字描述」。
  // 该判断**对页面转场不成立**：Figma 的 `index.css` 给出了四条转场的
  // 时长、曲线、位移轴与位移量，逐位可查。四条曲线全部是
  // `cubic-bezier(0.25,0.46,0.45,0.94)`，即 [standard]。
  //
  // 此前四条转场共用 [pageTransition]（280ms），除 tab 外全部偏离原值。

  /// 一级导航切换：Figma `.page-tab` = `200ms`，`translateY(8px) → 0`。
  static const Duration tabSwitch = Duration(milliseconds: 200);

  /// 二级页面进入：Figma `.page-push` = `260ms`，`translateX(20px) → 0`。
  static const Duration pagePush = Duration(milliseconds: 260);

  /// 返回：Figma `.page-pop` = `240ms`，`translateX(-20px) → 0`。
  static const Duration pagePop = Duration(milliseconds: 240);

  /// Onboarding 步骤：Figma `.page-onboard` = `300ms`，`translateX(24px) → 0`。
  static const Duration pageOnboarding = Duration(milliseconds: 300);

  /// 模态 / Bottom Sheet 弹出。300–400ms
  static const Duration sheet = Duration(milliseconds: 350);

  /// 重大结果揭示：匹配度分数、分析报告生成完成。400–700ms
  static const Duration reveal = Duration(milliseconds: 550);

  /// 简历版本卡左滑后的吸附回弹。
  ///
  /// Figma `SwipeableResumeCard`（`src/App.tsx` L4455）：
  /// `transition: transform 0.25s cubic-bezier(0.25,0.46,0.45,0.94)`
  /// —— 时长 `0.25s`，缓动即 [standard]。两者都逐位取自 Figma。
  static const Duration swipeSnap = Duration(milliseconds: 250);

  // ---------------------------------------------------------------------------
  // 语义别名（Phase 1 §二十要求至少预留 fast / normal / slow）
  // ---------------------------------------------------------------------------

  static const Duration fast = micro;
  static const Duration normal = smallComponent;
  static const Duration slow = reveal;

  /// 底部导航选中态滑动药丸的 morph 时长。
  /// Figma `BottomNav`: `transition: left 280ms`。
  static const Duration navPill = Duration(milliseconds: 280);

  /// 卡片重排（「我的」Tab → Card reorder）。IA §12：250–350ms。
  static const Duration cardReorder = Duration(milliseconds: 300);

  /// 列表项错峰进入的单项间隔。
  ///
  /// ⚠️ **暂定值 · 待视觉验证，且与 spec 有偏差**
  /// —— motion-spec 明写错峰延迟为 **`50–80ms`**，
  /// 而本值是 **40ms，落在区间之外**。
  ///
  /// 处理：**未自行改值**（改它属于视觉决策），登记为 **待裁决 · D36**。
  /// 当前**尚无引用点**（0 处），改动无风险。
  static const Duration stagger = Duration(milliseconds: 40);

  // ---------------------------------------------------------------------------
  // Onboarding「建立职业基线」时间线（Phase 4 批 2）
  //
  // 真值来源：Figma `OnParsing`（`src/App.tsx` L808-845）。
  //
  // ⚠️ **这一节与上方六档时长性质不同**：
  // 六档是「一类交互该多快」的**通用规则**，可跨页面复用；
  // 本节是一条**具体时间线**的节拍 —— 改一个数，这段动画就不再是
  // 设计稿的那段动画。因此不并入六档，也不做「收敛」。
  // ---------------------------------------------------------------------------

  /// 时间线的单个节拍：本步耗时 + 本步结束时的总进度。
  ///
  /// 之所以把「耗时」与「进度终点」绑在一个对象里，是因为 Figma 正是
  /// 这样写的（`STEPS[i].dur` 与 `STEPS[i].pEnd` 一一对应）；
  /// 拆成两个平行列表容易在增删步骤时错位。
  static const List<AppMotionBeat> baselineBeats = <AppMotionBeat>[
    AppMotionBeat(duration: Duration(milliseconds: 1200), endPercent: 20),
    AppMotionBeat(duration: Duration(milliseconds: 1800), endPercent: 50),
    AppMotionBeat(duration: Duration(milliseconds: 2000), endPercent: 75),
    AppMotionBeat(duration: Duration(milliseconds: 1200), endPercent: 90),
    AppMotionBeat(duration: Duration(milliseconds: 800), endPercent: 100),
  ];

  /// 时间线的起始百分比。Figma `pct` 初值 `1`（不是 0）。
  static const int baselineStartPercent = 1;

  /// 时间线百分比的缓动指数。
  ///
  /// Figma 原文：`eased = 1 - Math.pow(1 - frac, 2.2)`，即幂次为 `2.2`
  /// 的 ease-out。**不是** `Curves.easeOut` 之类内建曲线 —— 指数不同。
  static const double baselineEaseExponent = 2.2;

  /// 相邻两步之间的停顿。Figma `setTimeout(..., 300)`。
  static const Duration baselineStepPause = Duration(milliseconds: 300);

  /// 最后一步结束后、自动进入下一页前的停留。
  /// Figma `setTimeout(() => go('on-confirm'), 700)`。
  static const Duration baselineAdvance = Duration(milliseconds: 700);

  /// 步骤内进度条的宽度过渡。Figma `transition: width 0.1s linear`。
  static const Duration baselineStepProgress = Duration(milliseconds: 100);

  /// 光晕球的呼吸循环。Figma `.ai-orb` / `.ai-halo` = `3.6s`。
  static const Duration orbLoop = Duration(milliseconds: 3600);

  /// 第二层光晕相对第一层的相位延迟。Figma `.ai-halo-2` = `1.4s`。
  static const Duration orbHaloDelay = Duration(milliseconds: 1400);

  /// 完成后光晕球的定形动画。Figma `.ai-orb-complete` = `0.7s`。
  static const Duration orbComplete = Duration(milliseconds: 700);

  // ---------------------------------------------------------------------------
  // 分析「AI 正在分析」时间线（Phase 6）
  //
  // 真值来源：Figma `AnalysisProcessing`（`src/App.tsx` L1864-1923）。
  //
  // ⚠️ 与上方 `baseline*` 一节**同性质**：它是一条**具体时间线**的节拍，
  // 不是「一类交互该多快」的通用档位 —— 因此同样不并入六档、不做收敛。
  //
  // 与 `baselineBeats` 的关系：**两份是独立的时间线**，数值不同
  // （本屏 1300/1500/2400/1200/900，on-parsing 是 1200/1800/2000/1200/800），
  // 不能互相替代。
  //
  // ⚠️ 光晕球的呼吸 / 定形（[orbLoop] / [orbHaloDelay] / [orbComplete] 及
  // 三条曲线）**两屏共用同一组 CSS 类**（`.ai-orb` / `.ai-halo` /
  // `.ai-orb-complete`），故直接复用上方那一节，**不另立一份**。
  // ---------------------------------------------------------------------------

  /// 分析时间线的单个节拍。Figma `STEPS[i].duration` + `STEPS[i].pctEnd`。
  static const List<AppMotionBeat> analysisBeats = <AppMotionBeat>[
    AppMotionBeat(duration: Duration(milliseconds: 1300), endPercent: 20),
    AppMotionBeat(duration: Duration(milliseconds: 1500), endPercent: 40),
    AppMotionBeat(duration: Duration(milliseconds: 2400), endPercent: 75),
    AppMotionBeat(duration: Duration(milliseconds: 1200), endPercent: 90),
    AppMotionBeat(duration: Duration(milliseconds: 900), endPercent: 100),
  ];

  /// 分析进度百分比的初值。Figma `useState(1)` —— **不是 0**。
  static const int analysisStartPercent = 1;

  /// 分析进度的缓动指数。Figma：`1 - Math.pow(1 - frac, 2.2)`。
  ///
  /// ⚠️ **与 [baselineEaseExponent] 同值（2.2），是刻意的重复而非笔误** ——
  /// 两条时间线各自独立，共用常量会让「改一条影响另一条」。
  /// 若日后确认二者恒等，可合并为一条通用 `timelineEaseExponent`（另立裁决）。
  static const double analysisEaseExponent = 2.2;

  /// 分析进度的刷新间隔。Figma `tickMs = 40`。
  static const Duration analysisTick = Duration(milliseconds: 40);

  /// 时间线走完后、跳到结果页之前的停留。Figma `setTimeout(onDone, 900)`。
  static const Duration analysisAdvance = Duration(milliseconds: 900);

  /// 时间线走完后、定格为「分析完成」前的停顿。
  /// Figma `setTimeout(() => setDone(true), 500)`（最后一步结束后的 else 分支）。
  static const Duration analysisSettle = Duration(milliseconds: 500);

  /// 当前任务行的文字换色过渡。Figma `transition: color 350ms`。
  static const Duration analysisTaskLine = Duration(milliseconds: 350);

  /// 当前步进度条的宽度过渡。Figma `transition: width 300ms ease-out`。
  static const Duration analysisStepBar = Duration(milliseconds: 300);

  /// 步骤徽标 / 连接线 / 文字的换色过渡。Figma `transition: ... 400ms`。
  static const Duration analysisStepState = Duration(milliseconds: 400);

  /// 当前步徽标的脉冲环周期。Figma `.ai-step-pulse` = `1.5s`。
  static const Duration analysisStepPulse = Duration(milliseconds: 1500);

  /// 脉冲环的最大扩散半径。Figma `box-shadow: 0 0 0 7px ...`。
  static const double analysisStepPulseSpread = 7;

  // ---------------------------------------------------------------------------
  // 曲线
  // ---------------------------------------------------------------------------

  /// 标准缓动：加减速平缓，用于多数状态变化。
  /// 原值 `cubic-bezier(0.25, 0.46, 0.45, 0.94)`。
  static const Curve standard = Cubic(0.25, 0.46, 0.45, 0.94);

  /// 强调缓动：带轻微回弹，用于底部导航选中态流动。
  /// 原值 `cubic-bezier(0.34, 1.2, 0.64, 1)`。
  static const Curve emphasized = Cubic(0.34, 1.2, 0.64, 1);

  // ⚠️ **以下曲线里，[enter] / [exit] / [cardCurve] 仍是归纳值（待裁决 · D49）**
  //    （集中登记见 `CURRENT_STATUS.md` §3.6）
  //
  // Figma 只给了**两条** concrete 曲线（见上 [standard] / [emphasized]），
  // motion-spec 对其余场景**只写文字描述**（「ease-out / smooth easing」），
  // 没有给 `cubic-bezier` 数值。下述三条是 Flutter 侧按文字描述挑的
  // Material 内建曲线，**不是 Figma 原值**。
  //
  // 影响面：[enter] / [exit] 各 2 处 · [cardCurve] 0 处。

  /// 进入缓动：元素出现。**归纳值**。
  static const Curve enter = Curves.easeOutCubic;

  /// 退出缓动：元素消失。**归纳值**。
  static const Curve exit = Curves.easeInCubic;

  /// 线性：进度条、加载旋转。
  static const Curve linear = Curves.linear;

  /// 光晕球的呼吸曲线。Figma `.ai-orb`：`cubic-bezier(0.45,0.05,0.55,0.95)`。
  static const Curve orbLoopCurve = Cubic(0.45, 0.05, 0.55, 0.95);

  /// 光晕扩散层的曲线。Figma `.ai-halo`：`ease-out`。
  ///
  /// CSS 的 `ease-out` 即 `cubic-bezier(0, 0, 0.58, 1)`，
  /// 与 Flutter 的 [Curves.easeOut] **逐位相同**，故直接取用。
  static const Curve orbHaloCurve = Curves.easeOut;

  /// 光晕球定形（完成）的曲线。
  /// Figma `.ai-orb-complete`：`cubic-bezier(0.34,1.56,0.64,1)` —— **带超调**。
  ///
  /// ⚠️ 与 [emphasized]（`0.34,1.2,0.64,1`）**不是同一条** ——
  /// 本曲线的第二控制点是 `1.56`，回弹更明显。
  static const Curve orbCompleteCurve = Cubic(0.34, 1.56, 0.64, 1);

  /// 页面转场缓动。
  ///
  /// **不是归纳值**：Figma `index.css` L159-162 的四条转场类
  /// （`.page-tab` / `.page-push` / `.page-pop` / `.page-onboard`）
  /// 全部明写 `cubic-bezier(0.25, 0.46, 0.45, 0.94)`，即 [standard]。
  ///
  /// ⚠️ Phase 3 起本值由 [Curves.easeOutCubic] 更正为 [standard]
  /// —— 见 [pagePush] 上方的 D49 更正说明。
  static const Curve pageCurve = standard;

  /// 卡片重排缓动（IA §12：平滑、不过度弹跳）。**归纳值**，当前 0 处引用。
  static const Curve cardCurve = Curves.easeInOutCubic;

  // ---------------------------------------------------------------------------
  // 转场位移量（Baseline §6.6）
  // ---------------------------------------------------------------------------

  /// 二级页面进入时的水平位移。Figma `.page-push` = `translateX(20px)`。
  static const double pageSlideOffset = 20.0;

  /// 返回时**被揭开的那一页**的水平位移。
  /// Figma `.page-pop` = `translateX(-20px) → 0`。
  static const double pagePopOffset = -20.0;

  /// Onboarding 步骤的水平位移。
  /// Figma `.page-onboard` = `translateX(24px) → 0`。
  static const double pageOnboardingOffset = 24.0;

  /// 一级导航切换时内容的上移量。
  /// Figma `.page-tab` = `translateY(8px) → 0`。
  ///
  /// ⚠️ Phase 3 起由 `10.0` 更正为 `8.0`（Figma 原值）。
  static const double tabContentOffset = 8.0;

  /// 通用按压缩放比例（底部导航 Tab / `CareerlyCard` / `CareerlyChip`）。
  ///
  /// ⚠️ **不适用于 `CareerlyButton`** —— Figma 的按钮是 `scale(0.97)`，
  /// 与本节各档都不同，见 `careerly_button.dart` 的 `_ButtonMetrics.pressScale`。
  static const double pressScale = 0.96;

  /// 底部导航 AI 浮球的按下缩放比例。
  /// Figma `BottomNav`: AI 球为 `scale(0.94)`，比普通 Tab 的 0.96 更深。
  static const double pressScaleOrb = 0.94;

  /// 分析页顶部切换器分段的按下缩放比例。
  ///
  /// Figma `AnalysisHome`（`src/App.tsx` L1525）：`active:scale-[0.97]`。
  ///
  /// ⚠️ 与 [pressScale]（`0.96`）**只差 0.01**，但**不是笔误**：
  /// Figma 在不同组件上各写各的（导航 / 卡片 `0.96`，本切换器 `0.97`），
  /// 与 [pressScaleOrb] 同理 —— 每处按 Figma 原值取值，不做「收敛」。
  static const double pressScaleSegment = 0.97;

  /// 空 / 错误状态内容出现时的上移量。
  static const double stateContentOffset = 12.0;

  // ---------------------------------------------------------------------------
  // 便捷构建
  // ---------------------------------------------------------------------------

  /// 统一动画时长入口，避免页面直接写字面量。
  static AnimationController controller(
    TickerProvider vsync, {
    Duration duration = normal,
    double value = 0.0,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
      value: value,
    );
  }

  /// 页面转场曲线动画。
  static Animation<double> pageAnimation(Animation<double> parent) =>
      CurvedAnimation(parent: parent, curve: pageCurve);
}

/// 一条时间线的一个节拍。
///
/// 只服务于 [AppMotion.baselineBeats] —— 见该字段上方对「节拍 vs 通用档位」
/// 的区分说明。放在 Token 文件里而不是页面里，是因为它是**动画时长**，
/// 依 `CLAUDE.md` §8.2 不得在业务页面硬编码。
class AppMotionBeat {
  const AppMotionBeat({required this.duration, required this.endPercent});

  /// 本步耗时。Figma `STEPS[i].dur`。
  final Duration duration;

  /// 本步结束时，整条时间线到达的百分比。Figma `STEPS[i].pEnd`。
  final int endPercent;
}
