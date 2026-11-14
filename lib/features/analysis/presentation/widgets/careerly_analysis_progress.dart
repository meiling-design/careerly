import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../app/router/back_navigation.dart';
import '../../../../data/models/analysis_task.dart';
import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';

/// 「AI 正在分析」复合组件（Phase 6 补做 · D28）。
///
/// 真值来源：Figma `AnalysisProcessing`（`src/App.tsx` L1864-2118）。
/// 结构：标题栏（返回钮 + 标题）→ 上下文胶囊 → 光晕球 → 大百分比 →
/// 当前任务行 → 5 步时间线卡（Glass 卡）→ 「退出分析」→ 退出确认
/// Bottom Sheet（[CareerlyBottomSheetTone.confirm]，即 D27 归纳的变体 A）。
///
/// ## 两种驱动模式（P1-1b，2026-10-05）
///
/// 由 [progress] 是否为 `null` 决定，**不是**一个可配置开关 ——
/// 能不能拿到真实进度，取决于数据源背后有没有真的 agent：
///
/// ```text
/// progress == null        本地时钟模式（Mock）
///   5 步节拍取 AppMotion.analysisBeats，与 Figma 逐位一致。
///   整个时间线 7.3s 走完并定形「分析完成」。
///
/// progress != null        真实进度模式（真实后端）
///   步号来自后端（引擎 8 节点 → 产品 5 步，映射见后端 router.py）。
///   组件只在当前步内推进百分比，推到该步 endPercent 后**停住等**
///   下一个节点；本步耗时仍沿用 Figma 的节拍时长作为**节奏**，
///   但不再是「限时跑完」。**永不自行定形** —— 完成与否由任务终态决定。
/// ```
///
/// ⚠️ 本地时钟模式那 7.3s 是**原型节奏**，不是分析时长。实测引擎单是
/// `routing` 一个节点就可能跑 100 秒以上（契约 C2：10–210s）。真实进度
/// 模式的存在就是为了不把原型节奏误当成真实流程（原缺陷：页面在 7.3s
/// 显示「分析完成」，而请求还在飞）。
///
/// ## 数据时钟（两种模式共用）
///
/// [AnalysisProvider] 的 `analysisState` 决定**切页**：成功后由页面的
/// 状态分发切到结果页。**本组件不因时间线走完而导航** —— [onDone] 只是
/// 本地时钟模式的对外通知，页面可用它兜底，但切页的依据仍是 Provider 的
/// [AsyncState]。
///
/// ## 相对 on-parsing 光晕球的关系
///
/// 两屏共用同一组 CSS 类（`.ai-orb` / `.ai-halo` / `.ai-orb-complete`），
/// 呼吸 / 定形参数（缩放、亮度、时值、曲线）**逐值一致**，复用
/// [AppMotion.orbLoop] / [AppMotion.orbHaloDelay] / [AppMotion.orbComplete]。
/// 但两屏的**度量不同**（on-parsing 160/128/96，本屏 188/132），
/// 且该实现已在验收流程中的 on-parsing 内，本组件**不抽取共享组件**，
/// 而是平行实现 —— 是否合并成共享 `_AiOrb` 另立裁决，不私自重构已交付页面。
///
/// ## 退出语义
///
/// 「退出分析」→ 确认 Sheet「退出」→ [onExit]。**取消分析是否会回滚
/// 额度、如何终止底层分析**由 Provider 的 `exitAnalysis` 决定
/// （本组件只负责转述），见 `analysis_provider.dart`。
class CareerlyAnalysisProgress extends StatefulWidget {
  const CareerlyAnalysisProgress({
    super.key,
    required this.jobCount,
    this.onExit,
    this.onDone,
    this.progress,
  });

  /// 上下文胶囊的岗位数（「1 份简历 × N 个目标岗位」）。
  ///
  /// Phase 6 Mock 一次只允许添加 1 个 JD，页面固定传 `1`；
  /// 接真实多岗位后由页面按实际集合长度传入。
  final int jobCount;

  /// 用户在确认 Sheet 里点了「退出」。由页面转述给 Provider。
  final VoidCallback? onExit;

  /// UI 时钟定格为「分析完成」后触发（[AppMotion.analysisAdvance] 前）。
  ///
  /// ⚠️ **仅在本地时钟模式下会触发**。真实进度模式下本组件不会自己
  /// 定形 —— 定形的依据是任务真的完成了，由页面按 Provider 的
  /// [AsyncState] 替换本组件（见类注释「两种驱动模式」）。
  final VoidCallback? onDone;

  /// 引擎**真实节点**进度（P1-1b）。
  ///
  /// `null` = 本地时钟模式：整个时间线由组件自己的 [AppMotion.analysisBeats]
  /// 节拍表推进（原行为，Mock 路径）。
  ///
  /// 非 `null` = 真实进度模式：**步骤切换由后端节点决定**，组件只在
  /// 当前步内做百分比推进，推到该步的 `endPercent` 后**停住等**，
  /// 直到后端把 [AnalysisTaskProgress.stepIndex] 推进到下一步。
  /// 这正是「节点慢则动画等待」。
  final AnalysisTaskProgress? progress;

  @override
  State<CareerlyAnalysisProgress> createState() =>
      _CareerlyAnalysisProgressState();
}

class _CareerlyAnalysisProgressState extends State<CareerlyAnalysisProgress>
    with TickerProviderStateMixin {
  /// 5 步的标题与副行。Figma `STEPS`，文案逐字取自原型。
  static const List<(String, String)> _steps = <(String, String)>[
    ('岗位需求解析', 'AI 提取核心职责与技能要求'),
    ('简历信息解析', 'AI 提取经历、项目与能力证据'),
    ('能力匹配分析', '将简历能力与岗位要求深度匹配'),
    ('识别能力 Gap', '分析与岗位要求之间的成长空间'),
    ('生成分析报告', '整理匹配度、排名与改进建议'),
  ];

  /// 当前任务行文案。Figma `TASK_MSGS`。
  static const List<String> _taskMsgs = <String>[
    '正在读取岗位需求信息…',
    '正在解析简历与项目经历…',
    '正在深度匹配岗位与简历…',
    '正在识别能力 Gap…',
    '正在生成分析报告…',
  ];

  Duration _elapsed = Duration.zero;
  bool _done = false;

  // -- 真实进度模式（见 widget.progress）--

  /// 后端最近一次报出的步号，0 基。
  ///
  /// `null` 在真实进度模式下表示「后端给了未知节点」—— 此时**停住等**，
  /// 不是退回本地时钟。判据是 [_realMode]，不是这个字段。
  int? _serverStep;

  /// 是否处于真实进度模式。
  ///
  /// ⚠️ 判据是 `widget.progress != null`（「这次分析有没有真实进度源」），
  /// **不是** `_serverStep != null`（「这一步映射出来没有」）。
  /// 用后者会漏掉一种情况：后端报了映射表外的节点 → `stepIndex` 为 null
  /// → 组件以为「没有真实进度」→ 退回本地时钟 → 7.3 秒定形「分析完成」。
  /// 那正是本模式要修掉的缺陷。
  bool get _realMode => widget.progress != null;

  /// **进入当前步之后**经过的时间，用于步**内**的百分比推进。
  ///
  /// 与 [_elapsed] 的区别：[_elapsed] 是整条时间线的累计时长，
  /// [_serverStep] 变化时这里要归零 —— 否则第 2 步会带着第 1 步的
  /// 已用时长，一进来就直接跳到该步终点。
  Duration _inStep = Duration.zero;
  Timer? _ticker;
  Timer? _halo2Delay;
  Timer? _settleTimer;
  Timer? _advanceTimer;

  // -- 光晕球的三条动画（与 on-parsing 同一组 CSS 类，参数逐值一致）--

  /// 呼吸循环：缩放 + 亮度。
  late final AnimationController _orb = AnimationController(
    vsync: this,
    duration: AppMotion.orbLoop,
  )..repeat();

  /// 外层光晕扩散。
  late final AnimationController _halo1 = AnimationController(
    vsync: this,
    duration: AppMotion.orbLoop,
  )..repeat();

  /// 内层光晕扩散（延迟启动，对应 CSS `animation-delay`）。
  late final AnimationController _halo2 = AnimationController(
    vsync: this,
    duration: AppMotion.orbLoop,
  );

  /// 完成态定形。
  late final AnimationController _complete = AnimationController(
    vsync: this,
    duration: AppMotion.orbComplete,
  );

  /// 当前步徽标的脉冲环。
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.analysisStepPulse,
  )..repeat();

  @override
  void initState() {
    super.initState();
    _halo2Delay = Timer(AppMotion.orbHaloDelay, () {
      if (mounted && !_done) _halo2.repeat();
    });
    // 首帧就带着进度进来时（轮询比组件挂载快），这里必须补一次初始化 ——
    // didUpdateWidget 只在**变化**时触发，不会为初始值补课。
    _serverStep = widget.progress?.stepIndex;
    _ticker = Timer.periodic(AppMotion.analysisTick, _onTick);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _halo2Delay?.cancel();
    _settleTimer?.cancel();
    _advanceTimer?.cancel();
    _orb.dispose();
    _halo1.dispose();
    _halo2.dispose();
    _complete.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CareerlyAnalysisProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int? next = widget.progress?.stepIndex;
    // 后端给了未知节点（next == null）时**保持现状**：既不倒回第 0 步，
    // 也不换模式 —— 继续按当前步停住，等引擎走到下一个已知节点。
    if (next == null || next <= (_serverStep ?? -1)) return;
    final Duration? seed = _inStepForHandoff(next);
    setState(() {
      _serverStep = next;
      _inStep = seed ?? Duration.zero;
    });
  }

  /// 从本地时钟切到真实进度时的**无缝交接**。
  ///
  /// 组件先以本地时钟起步（拿到第一次轮询结果前没有进度可报），约 1 秒后
  /// 真实步号到达。若此时把 [_inStep] 归零，百分比会从本地时钟已经走到的
  /// 读数（第 0 步约 15%）**倒退**回 1% —— 肉眼可见地跳一下。
  ///
  /// 只有当后端报的正是第 0 步时才需要交接（否则是直接跳到后面的步，
  /// 从该步起点开始才是对的），此时用 [_elapsed] 接着走即可 —— 两种模式下
  /// 第 0 步的节拍时长相同，所以接得上。
  Duration? _inStepForHandoff(int next) {
    if (_serverStep != null || next != 0) return null;
    final Duration cap = AppMotion.analysisBeats[0].duration;
    return _elapsed < cap ? _elapsed : cap;
  }

  /// UI 时钟。Figma 的 `setInterval(tickMs=40)` + 每步 `setTimeout(duration)`。
  ///
  /// 真实进度模式下它**只推进步内百分比**，不推进步号、也永不定形 ——
  /// 步号的唯一来源是后端。
  void _onTick(Timer timer) {
    if (!mounted || _done) return;
    if (_realMode) {
      _onTickRealProgress();
      return;
    }
    if (_elapsed >= _total) return;
    Duration next = _elapsed + AppMotion.analysisTick;
    final bool crossed = next >= _total;
    if (crossed) next = _total;
    setState(() => _elapsed = next);
    if (crossed && _settleTimer == null) {
      // Figma：最后一步结束后 `setTimeout(() => setDone(true), 500)`
      // → done 定格 → `setTimeout(onDone, 900)`。
      _settleTimer = Timer(AppMotion.analysisSettle, () {
        if (!mounted) return;
        setState(() => _done = true);
        _ticker?.cancel();
        _orb.stop();
        _halo1.stop();
        _halo2.stop();
        _complete.forward(from: 0);
        _advanceTimer = Timer(AppMotion.analysisAdvance, () {
          if (mounted) widget.onDone?.call();
        });
      });
    }
  }

  /// 真实进度模式的节拍：只推进 [_inStep]，并在该步的节拍时长处**停住**。
  ///
  /// 停住 = 百分比停在该步的 `endPercent`，等后端把步号推到下一步。
  /// **不设** [_done]、**不调** [CareerlyAnalysisProgress.onDone] ——
  /// 定形的依据是任务终态，不是动画播完。
  void _onTickRealProgress() {
    final int? step = _serverStep;
    // 未知节点（step == null）或步号越界：**停住等**下一个已知节点，
    // 既不前推也不定形。
    if (step == null) return;
    final List<AppMotionBeat> beats = AppMotion.analysisBeats;
    if (step >= beats.length) return;
    final Duration cap = beats[step].duration;
    if (_inStep >= cap) return; // 本步已推到头 —— 等待后端推进
    Duration next = _inStep + AppMotion.analysisTick;
    if (next > cap) next = cap;
    setState(() => _inStep = next);
  }

  Duration get _total {
    Duration total = Duration.zero;
    for (final AppMotionBeat beat in AppMotion.analysisBeats) {
      total += beat.duration;
    }
    return total;
  }

  // -- 由 UI 时钟推导的展示值 --

  /// 某步的起读数。Figma `PCT_START = [0, 20, 40, 75, 90]`，
  /// 即 `i == 0 ? 0 : beats[i-1].pctEnd`。
  double _pctStart(int index) => index == 0
      ? 0
      : AppMotion.analysisBeats[index - 1].endPercent.toDouble();

  /// `(当前步序号, 大百分比, 当前步自身进度 0..1)`。
  ///
  /// 缓动：`1 - (1 - frac)^2.2`（[AppMotion.analysisEaseExponent]）；
  /// 百分比初值 [AppMotion.analysisStartPercent]（1，不是 0）。
  (int, int, double) _compute() {
    final List<AppMotionBeat> beats = AppMotion.analysisBeats;
    // 真实模式：步号未知时按第 0 步起点显示（「排队中」的样子），
    // 而不是回退到本地时钟那条会自行定形的路径。
    if (_realMode) return _computeFromServer(_serverStep ?? 0, beats);
    if (_done || _elapsed >= _total) {
      return (beats.length, 100, 1);
    }
    Duration acc = Duration.zero;
    for (int i = 0; i < beats.length; i++) {
      final AppMotionBeat beat = beats[i];
      final Duration end = acc + beat.duration;
      if (_elapsed < end) {
        final double frac =
            (_elapsed.inMicroseconds - acc.inMicroseconds) /
            beat.duration.inMicroseconds;
        final double eased =
            1 - math.pow(1 - frac, AppMotion.analysisEaseExponent).toDouble();
        final double from = _pctStart(i);
        final double to = beat.endPercent.toDouble();
        final int pct = math.max(AppMotion.analysisStartPercent,
            (from + (to - from) * eased).round());
        final double stepPct = to <= from ? 1 : ((pct - from) / (to - from));
        return (i, pct, stepPct.clamp(0.0, 1.0));
      }
      acc = end;
    }
    return (beats.length, 100, 1);
  }

  /// 真实进度模式的读数推导。
  ///
  /// 与本地时钟模式的唯一区别是**谁决定步号**：这里由后端节点决定
  /// （[step]），组件只负责在当前步内把百分比推到该步的 `endPercent`。
  /// 缓动、起点读数 [_pctStart]、初值 [AppMotion.analysisStartPercent]
  /// 与 Figma 逐值一致 —— 视觉不变，变的只是「什么时候进下一步」。
  ///
  /// ⚠️ 本模式下**没有** `(beats.length, 100, 1)` 这个收尾分支：后端从不
  /// 报出「第 5 步之后」，第 5 步推到 `endPercent` 后停住，直到任务终态
  /// 让页面替换本组件。自己凑一个 100% 就又回到「假完成」的老问题。
  (int, int, double) _computeFromServer(int step, List<AppMotionBeat> beats) {
    if (step >= beats.length) {
      // 后端步号越界（映射变更 / 版本错配）：显示已到末步读数，不崩。
      // 这不是「完成」—— 完成由任务终态表达。
      return (beats.length, beats.last.endPercent, 1);
    }
    final AppMotionBeat beat = beats[step];
    final double from = _pctStart(step);
    final double to = beat.endPercent.toDouble();
    final double frac =
        (_inStep.inMicroseconds / beat.duration.inMicroseconds).clamp(0.0, 1.0);
    final double eased =
        1 - math.pow(1 - frac, AppMotion.analysisEaseExponent).toDouble();
    final int pct = math.max(
      AppMotion.analysisStartPercent,
      (from + (to - from) * eased).round(),
    );
    final double stepPct = to <= from ? 1 : ((pct - from) / (to - from));
    return (step, pct, stepPct.clamp(0.0, 1.0));
  }

  Future<void> _showExitSheet() {
    return CareerlyBottomSheet.show<void>(
      context,
      tone: CareerlyBottomSheetTone.confirm,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('正在分析中', style: AppTypography.analysisSheetTitle),
            const SizedBox(height: 8),
            const Text(
              '现在离开不会影响你的简历和岗位信息，但本次分析需要重新开始。',
              style: AppTypography.analysisSheetBody,
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SheetButton(
                    label: '继续分析',
                    style: AppTypography.analysisSheetPrimary,
                    background: AppColors.primaryBlue,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SheetButton(
                    label: '退出',
                    style: AppTypography.analysisSheetGhost,
                    background: AppColors.analysisSheetGhostFill,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onExit?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (int stepIndex, int percent, double activeStepPct) = _compute();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TitleBar(done: _done, onBack: () => careerlyBack(context)),
        _ContextChip(jobCount: widget.jobCount),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _OrbZone(
                  orb: _orb,
                  halo1: _halo1,
                  halo2: _halo2,
                  complete: _complete,
                  done: _done,
                ),
                const SizedBox(height: 4),
                _PercentRow(percent: percent),
                _TaskLine(done: _done, stepIndex: stepIndex),
                const SizedBox(height: 20),
                _TimelineCard(
                  pulse: _pulse,
                  stepIndex: stepIndex,
                  activeStepPct: activeStepPct,
                  done: _done,
                ),
                if (!_done) ...<Widget>[
                  const SizedBox(height: 16),
                  _ExitButton(onPressed: _showExitSheet),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 标题栏
// ---------------------------------------------------------------------------

/// 标题栏：返回圆钮（36×36）+ 居中标题 + 右侧占位。Figma `px-4 pt-4 pb-1`。
class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.done, required this.onBack});

  final bool done;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: <Widget>[
          _BackButton(done: done, onBack: onBack),
          const Expanded(
            child: Center(child: Text('AI 正在分析', style: AppTypography.analysisTitle)),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

/// 返回圆钮。Figma：`w-9 h-9` 圆形 `rgba(255,255,255,0.55)`，
/// 18×18 左箭头 `2.2` 粗。完成态禁用（Figma `if (!done)`）。
class _BackButton extends StatelessWidget {
  const _BackButton({required this.done, required this.onBack});

  final bool done;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.analysisBarButtonFill,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: done ? null : onBack,
          child: const Icon(
            Icons.arrow_back_outlined,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// 上下文胶囊。Figma：`px-3 py-1.5` 圆胶囊，蓝底 `0.08` + 描边 `0.15`。
class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.jobCount});

  final int jobCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.analysisChipFill,
            border: Border.all(color: AppColors.analysisChipBorder, width: 0.5),
            borderRadius: AppRadius.borderPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('正在分析', style: AppTypography.analysisChipLabel),
              const SizedBox(width: 6),
              Text(
                '1 份简历 × $jobCount 个目标岗位',
                style: AppTypography.analysisChipValue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 光晕球
// ---------------------------------------------------------------------------

/// 光晕球区的度量。Figma：容器 188、主球 132；内层光晕 `inset 20` → 148。
abstract final class _OrbMetrics {
  static const double zone = 188;
  static const double orb = 132;
  static const double halo2Size = zone - 20 * 2;
  static const double specularW = 40;
  static const double specularH = 26;
  static const double specularTop = 18;
  static const double specularLeft = 22;
  static const double shimmerW = 20;
  static const double shimmerH = 14;
  static const double shimmerBottom = 22;
  static const double shimmerRight = 20;

  // 以下与 on-parsing `_OrbMetrics` 同值 —— 两屏共用同一组 CSS 类
  // （`.ai-orb` / `.ai-halo` / `.ai-orb-complete`），不是巧合重复。
  static const double haloScaleMin = 0.92;
  static const double haloScaleMax = 1.22;
  static const double haloOpacityMax = 0.7;
  static const double haloExpandStop = 60;
  static const double orbScaleMax = 1.07;
  static const double orbBrightnessMax = 1.06;
  static const double orbCompletePeakStop = 40;
  static const double orbCompleteScalePeak = 1.14;
  static const double orbCompleteScaleRest = 1.08;
  static const double orbCompleteBrightnessPeak = 1.15;
  static const double orbCompleteBrightnessRest = 1.08;
}

/// 光晕球 + 完成态。不渲染百分比 —— Figma 的大百分比在**球体下方**。
class _OrbZone extends StatelessWidget {
  const _OrbZone({
    required this.orb,
    required this.halo1,
    required this.halo2,
    required this.complete,
    required this.done,
  });

  final AnimationController orb;
  final AnimationController halo1;
  final AnimationController halo2;
  final AnimationController complete;
  final bool done;

  Animation<double> _haloScale(AnimationController controller) =>
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: _OrbMetrics.haloScaleMin, end: _OrbMetrics.haloScaleMax)
              .chain(CurveTween(curve: AppMotion.orbHaloCurve)),
          weight: _OrbMetrics.haloExpandStop,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: _OrbMetrics.haloScaleMax, end: _OrbMetrics.haloScaleMin)
              .chain(CurveTween(curve: AppMotion.orbHaloCurve)),
          weight: 100 - _OrbMetrics.haloExpandStop,
        ),
      ]).animate(controller);

  /// 光晕层的透明度：60% 之后恒 0（回程不可见）。
  Animation<double> _haloOpacity(AnimationController controller) =>
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: _OrbMetrics.haloOpacityMax, end: 0.0)
              .chain(CurveTween(curve: AppMotion.orbHaloCurve)),
          weight: _OrbMetrics.haloExpandStop,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(0.0),
          weight: 100 - _OrbMetrics.haloExpandStop,
        ),
      ]).animate(controller);

  /// 呼吸缩放：`0/100% → 1`，`50% → 1.07`。
  Animation<double> get _orbScale => TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: _OrbMetrics.orbScaleMax)
                .chain(CurveTween(curve: AppMotion.orbLoopCurve)),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: _OrbMetrics.orbScaleMax, end: 1.0)
                .chain(CurveTween(curve: AppMotion.orbLoopCurve)),
            weight: 50,
          ),
        ],
      ).animate(orb);

  /// 呼吸亮度：`0/100% → 1`，`50% → 1.06`。
  Animation<double> get _orbBrightness => TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: _OrbMetrics.orbBrightnessMax)
                .chain(CurveTween(curve: AppMotion.orbLoopCurve)),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: _OrbMetrics.orbBrightnessMax, end: 1.0)
                .chain(CurveTween(curve: AppMotion.orbLoopCurve)),
            weight: 50,
          ),
        ],
      ).animate(orb);

  /// 完成态定形缩放：`0% → 1`，`40% → 1.14`，`100% → 1.08`。
  Animation<double> get _completeScale => TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: _OrbMetrics.orbCompleteScalePeak)
                .chain(CurveTween(curve: AppMotion.orbCompleteCurve)),
            weight: _OrbMetrics.orbCompletePeakStop,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: _OrbMetrics.orbCompleteScalePeak, end: _OrbMetrics.orbCompleteScaleRest)
                .chain(CurveTween(curve: AppMotion.orbCompleteCurve)),
            weight: 100 - _OrbMetrics.orbCompletePeakStop,
          ),
        ],
      ).animate(complete);

  /// 完成态亮度：`0% → 1`，`40% → 1.15`，`100% → 1.08`。
  Animation<double> get _completeBrightness => TweenSequence<double>(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: _OrbMetrics.orbCompleteBrightnessPeak)
                .chain(CurveTween(curve: AppMotion.orbCompleteCurve)),
            weight: _OrbMetrics.orbCompletePeakStop,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: _OrbMetrics.orbCompleteBrightnessPeak, end: _OrbMetrics.orbCompleteBrightnessRest)
                .chain(CurveTween(curve: AppMotion.orbCompleteCurve)),
            weight: 100 - _OrbMetrics.orbCompletePeakStop,
          ),
        ],
      ).animate(complete);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _OrbMetrics.zone,
        height: _OrbMetrics.zone,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (!done) ...<Widget>[
              AnimatedBuilder(
                animation: halo1,
                builder: (BuildContext context, Widget? child) => _HaloLayer(
                  size: _OrbMetrics.zone,
                  gradient: AppColors.analysisHaloBlue,
                  opacity: _haloOpacity(halo1).value,
                  scale: _haloScale(halo1).value,
                ),
              ),
              AnimatedBuilder(
                animation: halo2,
                builder: (BuildContext context, Widget? child) => _HaloLayer(
                  size: _OrbMetrics.halo2Size,
                  gradient: AppColors.analysisHaloPurple,
                  opacity: _haloOpacity(halo2).value,
                  scale: _haloScale(halo2).value,
                ),
              ),
            ],
            AnimatedBuilder(
              animation: done ? complete : orb,
              builder: (BuildContext context, Widget? child) {
                final double scale = done ? _completeScale.value : _orbScale.value;
                final double brightness =
                    done ? _completeBrightness.value : _orbBrightness.value;
                Widget core = child!;
                // Figma 的 `filter: brightness(k)` —— 颜色矩阵等比放大 RGB
                //（同 on-parsing 的做法；`blur(0.5px)` 未复刻，同 D72）。
                if (brightness != 1) {
                  final double b = brightness;
                  core = ColorFiltered(
                    colorFilter: ColorFilter.matrix(<double>[
                      b, 0, 0, 0, 0, //
                      0, b, 0, 0, 0, //
                      0, 0, b, 0, 0, //
                      0, 0, 0, 1, 0, //
                    ]),
                    child: core,
                  );
                }
                return Transform.scale(scale: scale, child: core);
              },
              child: Container(
                width: _OrbMetrics.orb,
                height: _OrbMetrics.orb,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.analysisOrbGradient,
                  boxShadow: done
                      ? AppShadows.analysisOrbDone
                      : AppShadows.analysisOrb,
                ),
                child: ClipOval(
                  child: Stack(
                    children: <Widget>[
                      // Figma `inset 0 3px 10px rgba(255,255,255,0.38)` ——
                      // BoxShadow 不支持 inset（同 K5），用自上而下的线性
                      // 渐变近似（K5 既有处理方式）。
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: <Color>[
                                AppColors.analysisOrbInset,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 左上主高光。Figma 40×26 `rgba(255,255,255,0.42)` blur 5。
                      Positioned(
                        top: _OrbMetrics.specularTop,
                        left: _OrbMetrics.specularLeft,
                        child: _SoftBlob(
                          width: _OrbMetrics.specularW,
                          height: _OrbMetrics.specularH,
                          color: AppColors.analysisOrbSpecular,
                          radius: 5,
                        ),
                      ),
                      // 右下副微光。Figma 20×14 `rgba(255,255,255,0.18)` blur 4。
                      Positioned(
                        bottom: _OrbMetrics.shimmerBottom,
                        right: _OrbMetrics.shimmerRight,
                        child: _SoftBlob(
                          width: _OrbMetrics.shimmerW,
                          height: _OrbMetrics.shimmerH,
                          color: AppColors.analysisOrbShimmer,
                          radius: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 一层光晕：径向渐变圆 + 扩散缩放 + 淡出。
class _HaloLayer extends StatelessWidget {
  const _HaloLayer({
    required this.size,
    required this.gradient,
    required this.opacity,
    required this.scale,
  });

  final double size;
  final RadialGradient gradient;
  final double opacity;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
        ),
      ),
    );
  }
}

/// 球面上的柔光斑。Figma 的 `filter: blur(n)` 用 [ImageFiltered] 复刻。
class _SoftBlob extends StatelessWidget {
  const _SoftBlob({
    required this.width,
    required this.height,
    required this.color,
    required this.radius,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: radius, sigmaY: radius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(width / 2),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 百分比与任务行
// ---------------------------------------------------------------------------

/// 大百分比读数。Figma：在**球体下方**（不是球内），48px + 22px `%`，
/// `items-end gap-0.5`，`mt-1 mb-1.5`。
class _PercentRow extends StatelessWidget {
  const _PercentRow({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text('$percent', style: AppTypography.analysisPercent),
          const Padding(
            padding: EdgeInsets.only(bottom: 6, left: 2),
            child: Text('%', style: AppTypography.analysisPercentUnit),
          ),
        ],
      ),
    );
  }
}

/// 当前任务行。Figma：13px 居中，`minHeight: 18`；
/// 完成态换 `S.green` + `w600`，文案「分析完成！」，过渡 `color 350ms`。
class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.done, required this.stepIndex});

  final bool done;
  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    final String text = done
        ? '分析完成！'
        : _CareerlyAnalysisProgressState._taskMsgs[math.min(
            stepIndex, _CareerlyAnalysisProgressState._taskMsgs.length - 1)];
    final TextStyle style = AppTypography.analysisTaskLine.copyWith(
      color: done ? AppColors.success : AppColors.textSecondary,
      fontWeight: done ? FontWeight.w600 : FontWeight.w400,
    );
    return AnimatedDefaultTextStyle(
      duration: AppMotion.analysisTaskLine,
      style: style,
      child: Text(text),
    );
  }
}

// ---------------------------------------------------------------------------
// 时间线卡
// ---------------------------------------------------------------------------

/// 时间线卡。Figma：`rounded-2xl` Glass —— 白 `0.62` + `blur(10px)` +
/// 描边白 `0.65`；头部 `px-5 pt-4 pb-1`，步骤 `px-5 pt-1 pb-4`。
class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.pulse,
    required this.stepIndex,
    required this.activeStepPct,
    required this.done,
  });

  final AnimationController pulse;
  final int stepIndex;
  final double activeStepPct;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.borderMd,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.analysisTimelineFill,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.analysisTimelineBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text('分析进度', style: AppTypography.analysisSectionLabel),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  children: <Widget>[
                    for (int i = 0;
                        i < _CareerlyAnalysisProgressState._steps.length;
                        i++)
                      _StepRow(
                        pulse: pulse,
                        index: i,
                        isLast:
                            i ==
                            _CareerlyAnalysisProgressState._steps.length - 1,
                        label: _CareerlyAnalysisProgressState._steps[i].$1,
                        sub: _CareerlyAnalysisProgressState._steps[i].$2,
                        state: done || i < stepIndex
                            ? _StepState.complete
                            : i == stepIndex
                                ? _StepState.active
                                : _StepState.idle,
                        activeStepPct: activeStepPct,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _StepState { complete, active, idle }

/// 一行步骤：28×28 徽标 + 连接线（左列），标题 / 状态 / 副行 / 进度条（右列）。
/// 左列随行高拉伸（Figma 的 `flex` 连接线）。
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.pulse,
    required this.index,
    required this.isLast,
    required this.label,
    required this.sub,
    required this.state,
    required this.activeStepPct,
  });

  final AnimationController pulse;
  final int index;
  final bool isLast;
  final String label;
  final String sub;
  final _StepState state;
  final double activeStepPct;

  bool get _complete => state == _StepState.complete;
  bool get _active => state == _StepState.active;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = _complete
        ? AppColors.success
        : _active
            ? AppColors.textPrimary
            : AppColors.textSecondary;
    final Color statusColor = _complete
        ? AppColors.success
        : _active
            ? AppColors.primaryBlue
            : AppColors.analysisStepStatusIdle;
    final String statusText = switch (state) {
      _StepState.complete => '已完成 · 100%',
      _StepState.active => '进行中 · ${(activeStepPct * 100).round()}%',
      _StepState.idle => '等待中',
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 左列：徽标 + 连接线，固定宽 28。
          SizedBox(
            width: 28,
            child: Column(
              children: <Widget>[
                _StepBadge(pulse: pulse, index: index, state: state),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: _complete
                            ? AppColors.analysisStepRailDone
                            : AppColors.analysisStepRailIdle,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 右列：内容。非末行 `paddingBottom: 14`。
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: AppMotion.analysisStepState,
                          style: AppTypography.analysisStepLabel
                              .copyWith(color: labelColor),
                          child: Text(label),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedDefaultTextStyle(
                        duration: AppMotion.analysisStepState,
                        style: AppTypography.analysisStepStatus
                            .copyWith(color: statusColor),
                        child: Text(statusText),
                      ),
                    ],
                  ),
                  Text(sub, style: AppTypography.analysisStepSub),
                  if (_active) ...<Widget>[
                    const SizedBox(height: 8),
                    // 当前步进度条。Figma `h-1` 圆角轨道 + `S.primary` 填充。
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        height: 4,
                        child: Stack(
                          children: <Widget>[
                            Container(color: AppColors.analysisStepRailIdle),
                            FractionallySizedBox(
                              widthFactor: activeStepPct,
                              child: Container(color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 步骤徽标。已完成：浅绿底 + 绿勾；进行中：实心蓝 + 白序号 + 脉冲环；
/// 等待中：浅灰底 + 灰序号。底色过渡 400ms（[AppMotion.analysisStepState]）。
class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.pulse,
    required this.index,
    required this.state,
  });

  final AnimationController pulse;
  final int index;
  final _StepState state;

  bool get _complete => state == _StepState.complete;
  bool get _active => state == _StepState.active;

  @override
  Widget build(BuildContext context) {
    final Color background = _complete
        ? AppColors.analysisStepBadgeDone
        : _active
            ? AppColors.primaryBlue
            : AppColors.analysisStepBadgeIdle;
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (_active)
            AnimatedBuilder(
              animation: pulse,
              builder: (BuildContext context, Widget? child) {
                final double t = pulse.value;
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.analysisStepPulse
                            .withValues(alpha: AppColors.analysisStepPulse.a * (1 - t)),
                        spreadRadius: AppMotion.analysisStepPulseSpread * t,
                      ),
                    ],
                  ),
                );
              },
            ),
          AnimatedContainer(
            duration: AppMotion.analysisStepState,
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: background),
            child: _complete
                ? const Icon(Icons.check, size: 14, color: AppColors.success)
                : Text(
                    '${index + 1}',
                    style: AppTypography.analysisStepBadge.copyWith(
                      color: _active
                          ? AppColors.textInverse
                          : AppColors.analysisStepBadgeIdleInk,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 退出
// ---------------------------------------------------------------------------

/// 「退出分析」幽灵按钮。Figma：`h-10` 圆胶囊 `rgba(0,0,0,0.03)`，
/// 文字 13px `w500` `rgba(160,163,172,1)`。
class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Material(
        color: AppColors.analysisExitFill,
        borderRadius: AppRadius.borderPill,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text('退出分析', style: AppTypography.analysisExitAction),
          ),
        ),
      ),
    );
  }
}

/// 确认 Sheet 的按钮。Figma：`h-12` 圆胶囊 `flex-1`；
/// 主按钮实心 `S.primary` 白字 `w600`，次按钮 `rgba(0,0,0,0.04)` 灰字 `w500`。
///
/// ⚠️ 不用 [CareerlyButton]：它的 `primary` 是**蓝→紫渐变**（OnSplash 语境），
/// 与本 Sheet 的实心蓝不同形态；新建共享变体属组件层扩张，待另立裁决。
class _SheetButton extends StatelessWidget {
  const _SheetButton({
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
    return SizedBox(
      height: 48,
      child: Material(
        color: background,
        borderRadius: AppRadius.borderPill,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(child: Text(label, style: style)),
        ),
      ),
    );
  }
}
