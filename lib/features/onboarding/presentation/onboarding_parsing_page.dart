import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/state/async_state.dart';
import '../../../data/models/resume_profile.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../profile/state/growth_celebration_provider.dart';
import '../../profile/state/resume_provider.dart';

/// 「建立职业基线」进行页 —— Onboarding 第 5 屏。
///
/// 真值来源：Figma `OnParsing`（`src/App.tsx` L806-920）。
/// **视觉逐位保留**：光晕三层球 / 百分比 / 状态药丸 / 步骤清单卡 /
/// 时序与缓动；只有 **5 步文案**换成语义正确的版本。
///
/// ## ⚠️ 为什么文案要换 —— 产品侧裁决 D63
///
/// Figma 的五个步骤是「岗位需求解析 → 简历信息解析 → 能力匹配分析 →
/// 识别能力 Gap → 生成分析报告」，而 PRD §7.1 / IA §5.2 / Baseline §4.1
/// **三份文档逐条禁止** Onboarding 出现 JD / 岗位匹配 / 匹配度 / Gap。
///
/// 产品侧裁决：**保留 Figma 的进度视觉，只把 5 步文案换成
/// 「建立职业基线」语义**（依据 PRD §7.2 对 Career Baseline 的定义）。
///
/// ```text
/// ✅ 保留：三层光晕球、百分比、步骤清单、时序、缓动、完成态
/// ✅ 替换：5 步 label / sub（本文件的 _steps）
/// ❌ 不出现：岗位需求解析 / 岗位匹配 / 匹配度 / 排名 / Gap
/// ```
///
/// 具体文案由 AI 侧起草，**待产品侧确认** → `TODO.md` §3.1 · **D66**。
/// 未改动的 Figma 原文（`解析完成` / `解析完成！` / `正在认识`）同样挂在 D66。
///
/// ## ⚠️ 两条时钟：动画 vs 数据（Flutter 侧补齐 → D73）
///
/// Figma 这一屏**只有动画**，没有任何数据调用；到点即跳 `on-confirm`。
/// Flutter 侧这里同时做两件事：
///
/// ```text
/// ① Figma 的 8.9s 时间线（纯视觉）
/// ② ResumeProvider.buildBaseline()（真实调用，不扣额度 —— CLAUDE.md §5.2）
/// ```
///
/// 两者**都完成**才跳下一页；失败时停下时间线并给出 Error + Retry
/// （Figma 未定义该态）。见 **D73**。
///
/// ## ⚠️ 顶栏与 `OnboardingProgressHeader` 的两处不一致 → D69
///
/// 本页顶栏是 Figma 的**内联写法**（不是那个组件），两处取值与它不同：
/// 步骤阶梯（本页 `3 / 3` vs 注册页 `1 / 4`）与返回箭头色
/// （本页 `#4F7EF5` vs 组件 `#0088FF`）。此处**逐位照抄 Figma**，不自行统一。
class OnboardingParsingPage extends StatefulWidget {
  const OnboardingParsingPage({super.key});

  @override
  State<OnboardingParsingPage> createState() => _OnboardingParsingPageState();
}

class _OnboardingParsingPageState extends State<OnboardingParsingPage>
    with TickerProviderStateMixin {
  /// 5 步文案 —— ⚠️ **AI 侧起草，待产品侧确认（D66）**。
  ///
  /// 语义来源：PRD §7.2 对 Career Baseline 的定义
  /// （工作经历 / 项目经历 / 技能 / 奖项 / 初始能力画像 / 当前简历版本）。
  /// Figma 的时长与进度终点不在此表内 —— 它们在
  /// [AppMotion.baselineBeats]，两表**按序号一一对应**。
  static const List<_BaselineStep> _steps = <_BaselineStep>[
    _BaselineStep(label: '读取简历', sub: 'AI 通读你提交的简历内容'),
    _BaselineStep(label: '整理工作经历', sub: '归纳职位、职责与任职时间'),
    _BaselineStep(label: '提取项目经验', sub: '整理项目成果与其中的证据'),
    _BaselineStep(label: '汇总技能与获奖', sub: '汇总技能、证书与获奖经历'),
    _BaselineStep(label: '形成职业基线', sub: '生成你的初始能力画像'),
  ];

  /// 单步时间线控制器。每步换一次 `duration`（Figma 每步耗时不同）。
  late final AnimationController _step = AnimationController(
    vsync: this,
    duration: AppMotion.baselineBeats.first.duration,
  );

  /// 光晕球本体的呼吸循环。
  late final AnimationController _orb = AnimationController(
    vsync: this,
    duration: AppMotion.orbLoop,
  )..repeat();

  /// 光晕第 1 层（160×160）的扩散循环。
  late final AnimationController _halo1 = AnimationController(
    vsync: this,
    duration: AppMotion.orbLoop,
  )..repeat();

  /// 光晕第 2 层（128×128）的扩散循环，相位落后 [AppMotion.orbHaloDelay]。
  late final AnimationController _halo2 = AnimationController(
    vsync: this,
    duration: AppMotion.orbLoop,
    // 先给初相位再 repeat —— `repeat()` 会从当前 value 起跑。
    value:
        AppMotion.orbHaloDelay.inMilliseconds /
        AppMotion.orbLoop.inMilliseconds,
  )..repeat();

  /// 完成态的定形动画（一次性）。
  late final AnimationController _complete = AnimationController(
    vsync: this,
    duration: AppMotion.orbComplete,
  );

  int _stepIndex = 0;
  bool _timelineDone = false;
  bool _baselineDone = false;
  bool _delayElapsed = false;
  bool _advanced = false;

  // ---------------------------------------------------------------------------
  // 时间线（Figma 的 `useEffect` + RAF 的等价实现）
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // 文案表与节拍表必须等长，否则步骤卡会错位。
    assert(
      _steps.length == AppMotion.baselineBeats.length,
      '_steps 与 AppMotion.baselineBeats 数量必须一致',
    );
    // 首帧之后再起跑：`buildBaseline()` 会同步 notifyListeners，
    // 在 initState 里调用会撞上「build 期间 setState」。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _run();
    });
  }

  @override
  void dispose() {
    _step.dispose();
    _orb.dispose();
    _halo1.dispose();
    _halo2.dispose();
    _complete.dispose();
    super.dispose();
  }

  /// 从头跑一遍（首次进入 / 失败重试共用）。
  void _run() {
    setState(() {
      _stepIndex = 0;
      _timelineDone = false;
      _baselineDone = false;
      _delayElapsed = false;
      _advanced = false;
    });

    _complete.stop();
    _orb.repeat();
    _halo1.repeat();
    _halo2.repeat();
    _startStep(0);

    _buildBaseline();
  }

  /// 真正建立基线。⚠️ **不扣分析额度**（`CLAUDE.md` §5.2）。
  Future<void> _buildBaseline() async {
    final ResumeProvider provider = context.read<ResumeProvider>();
    await provider.buildBaseline();
    if (!mounted) return;

    if (provider.error != null) {
      // 数据侧失败 → 停下时间线，交给 Error 态接管（D73）。
      _stopAll();
      return;
    }
    if (provider.data?.hasBaseline == true) {
      context.read<GrowthCelebrationProvider>().record(
        GrowthMilestone.careerBaselineEstablished,
      );
    }
    _baselineDone = true;
    _maybeAdvance();
  }

  /// 跑第 [index] 步。
  ///
  /// Figma：`eased = 1 - pow(1 - frac, 2.2)`，
  /// 完成后 `setTimeout(300)` 进入下一步，最后一步则 `setDone(true)`。
  void _startStep(int index) {
    _step.duration = AppMotion.baselineBeats[index].duration;
    _step.forward(from: 0).whenComplete(() {
      if (!mounted) return;

      if (index < AppMotion.baselineBeats.length - 1) {
        Future<void>.delayed(AppMotion.baselineStepPause, () {
          if (!mounted) return;
          setState(() => _stepIndex = index + 1);
          _startStep(index + 1);
        });
        return;
      }

      // 最后一步：定形 + 停掉循环光晕（Figma 在此刻把 class 从
      // `ai-orb` / `ai-halo` 换成 `ai-orb-complete`）。
      _orb.stop();
      _halo1.stop();
      _halo2.stop();
      _complete.forward(from: 0);
      setState(() => _timelineDone = true);

      // Figma：`setTimeout(() => go('on-confirm'), 700)`
      Future<void>.delayed(AppMotion.baselineAdvance, () {
        if (!mounted) return;
        _delayElapsed = true;
        _maybeAdvance();
      });
    });
  }

  /// 两条时钟都到点才跳转（见类文档）。
  void _maybeAdvance() {
    if (!mounted || _advanced || !_delayElapsed || !_baselineDone) return;
    _advanced = true;
    context.go(AppRoutes.onboardingConfirm);
  }

  void _stopAll() {
    _step.stop();
    _orb.stop();
    _halo1.stop();
    _halo2.stop();
    _complete.stop();
  }

  // ---------------------------------------------------------------------------
  // 派生值（Figma 的 `pct` / `stepPct`）
  // ---------------------------------------------------------------------------

  /// 当前步骤的起点百分比。Figma `PCT_START = [0, 20, 50, 75, 90]`
  /// —— 恰是**上一步的终点**，故从节拍表推导，不另立一张平行表
  /// （平行表会在增删步骤时错位）。
  double _pctStart(int index) => index == 0
      ? 0
      : AppMotion.baselineBeats[index - 1].endPercent.toDouble();

  /// 整条时间线的百分比。Figma：`Math.round(pStart + (pEnd - pStart) * eased)`，
  /// 且 `pct` 的初值为 [AppMotion.baselineStartPercent]（1，不是 0）。
  int get _pct {
    final double eased =
        1 -
        math.pow(
          1 - _step.value,
          AppMotion.baselineEaseExponent,
        ).toDouble();
    final double from = _pctStart(_stepIndex);
    final double to = AppMotion.baselineBeats[_stepIndex].endPercent.toDouble();
    final int value = (from + (to - from) * eased).round();
    return value < AppMotion.baselineStartPercent
        ? AppMotion.baselineStartPercent
        : value;
  }

  /// 当前步骤**自身**的进度条比例。Figma：
  /// `round(((pct - PCT_START[i]) / (pEnd - PCT_START[i])) * 100)`。
  double _stepProgress(int index) {
    if (_timelineDone || index < _stepIndex) return 1;
    if (index != _stepIndex) return 0;

    final double from = _pctStart(index);
    final double to = AppMotion.baselineBeats[index].endPercent.toDouble();
    if (to <= from) return 1;
    return ((_pct - from) / (to - from)).clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------------------------
  // 光晕球的动画值
  // ---------------------------------------------------------------------------

  /// 呼吸循环的缩放。Figma `_ai-orb`：`0/100% → 1`，`50% → 1.07`。
  Animation<double> get _orbScale => TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: _OrbMetrics.orbScaleMax,
        ).chain(CurveTween(curve: AppMotion.orbLoopCurve)),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: _OrbMetrics.orbScaleMax,
          end: 1.0,
        ).chain(CurveTween(curve: AppMotion.orbLoopCurve)),
        weight: 50,
      ),
    ],
  ).animate(_orb);

  /// 呼吸循环的亮度。Figma `_ai-orb`：`0/100% → brightness(1)`，
  /// `50% → brightness(1.06)`。
  Animation<double> get _orbBrightness => TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: _OrbMetrics.orbBrightnessMax,
        ).chain(CurveTween(curve: AppMotion.orbLoopCurve)),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: _OrbMetrics.orbBrightnessMax,
          end: 1.0,
        ).chain(CurveTween(curve: AppMotion.orbLoopCurve)),
        weight: 50,
      ),
    ],
  ).animate(_orb);

  /// 光晕层的扩散。Figma `_ai-halo`：`0% → scale .92 / opacity .7`，
  /// `60% → scale 1.22 / opacity 0`，`100% → scale .92 / opacity 0`。
  Animation<double> _haloScale(AnimationController controller) =>
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: _OrbMetrics.haloScaleMin,
            end: _OrbMetrics.haloScaleMax,
          ).chain(CurveTween(curve: AppMotion.orbHaloCurve)),
          weight: _OrbMetrics.haloExpandStop,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: _OrbMetrics.haloScaleMax,
            end: _OrbMetrics.haloScaleMin,
          ).chain(CurveTween(curve: AppMotion.orbHaloCurve)),
          weight: 100 - _OrbMetrics.haloExpandStop,
        ),
      ]).animate(controller);

  /// 光晕层的透明度。60% 之后恒为 0（回程不可见）。
  Animation<double> _haloOpacity(AnimationController controller) =>
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: _OrbMetrics.haloOpacityMax,
            end: 0.0,
          ).chain(CurveTween(curve: AppMotion.orbHaloCurve)),
          weight: _OrbMetrics.haloExpandStop,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(0.0),
          weight: 100 - _OrbMetrics.haloExpandStop,
        ),
      ]).animate(controller);

  /// 完成态的定形缩放。Figma `_ai-orb-complete`：
  /// `0% → 1`，`40% → 1.14`，`100% → 1.08`。
  Animation<double> get _completeScale => TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: _OrbMetrics.orbCompleteScalePeak,
        ).chain(CurveTween(curve: AppMotion.orbCompleteCurve)),
        weight: _OrbMetrics.orbCompletePeakStop,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: _OrbMetrics.orbCompleteScalePeak,
          end: _OrbMetrics.orbCompleteScaleRest,
        ).chain(CurveTween(curve: AppMotion.orbCompleteCurve)),
        weight: 100 - _OrbMetrics.orbCompletePeakStop,
      ),
    ],
  ).animate(_complete);

  /// 完成态的定形亮度。Figma `_ai-orb-complete`：
  /// `0% → brightness(1)`，`40% → brightness(1.15)`，`100% → brightness(1.08)`。
  Animation<double> get _completeBrightness => TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: _OrbMetrics.orbCompleteBrightnessPeak,
        ).chain(CurveTween(curve: AppMotion.orbCompleteCurve)),
        weight: _OrbMetrics.orbCompletePeakStop,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: _OrbMetrics.orbCompleteBrightnessPeak,
          end: _OrbMetrics.orbCompleteBrightnessRest,
        ).chain(CurveTween(curve: AppMotion.orbCompleteCurve)),
        weight: 100 - _OrbMetrics.orbCompletePeakStop,
      ),
    ],
  ).animate(_complete);

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ResumeProvider provider = context.watch<ResumeProvider>();
    final AppError? failure = provider.error;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _ParsingTopBar(onBack: _leave),
              Expanded(
                child: failure == null
                    ? AnimatedBuilder(
                        animation: Listenable.merge(<Listenable>[
                          _step,
                          _orb,
                          _halo1,
                          _halo2,
                          _complete,
                        ]),
                        builder: (BuildContext context, Widget? _) =>
                            _buildTimeline(),
                      )
                    // Figma 未定义失败态（D73）：复用既有异步状态视图。
                    : CareerlyAsyncStateView<ResumeProfile>(
                        state: AsyncFailure<ResumeProfile>(failure),
                        builder: (_, _) => const SizedBox.shrink(),
                        onRetry: _run,
                      ),
              ),
              _ExitButton(onTap: _leave),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final bool done = _timelineDone;

    // 完成态：三层里第 1 层与核心换成定形动画，第 2 层停下（Figma 去掉
    // `ai-halo-2`，即静态停在 scale 1 / opacity 0.25）。
    final double layer1Scale = done
        ? _completeScale.value
        : _haloScale(_halo1).value;
    final double layer1Opacity = done
        ? _OrbMetrics.layer1Opacity
        : _haloOpacity(_halo1).value * _OrbMetrics.layer1Opacity;
    final double coreScale = done ? _completeScale.value : _orbScale.value;
    final double coreBrightness = done
        ? _completeBrightness.value
        : _orbBrightness.value;

    return SingleChildScrollView(
      // Figma 是 `overflow-hidden`（原型固定 390×844）。
      // 真机高度不一，这里改为可滚动，避免步骤卡在小屏上溢出。
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: <Widget>[
          _StatusPill(label: done ? '解析完成' : _steps[_stepIndex].label),
          const SizedBox(height: AppSpacing.mdLg),
          SizedBox(
            width: _OrbMetrics.orbSize,
            height: _OrbMetrics.orbSize,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _OrbLayer(
                  size: _OrbMetrics.orbSize,
                  opacity: layer1Opacity,
                  scale: layer1Scale,
                ),
                _OrbLayer(
                  size: _OrbMetrics.orbMiddleSize,
                  opacity: _OrbMetrics.layer2Opacity,
                  // 完成后停在 1（Figma 去掉 `ai-halo-2`）。
                  scale: done ? 1 : _haloScale(_halo2).value,
                ),
                Transform.scale(
                  scale: coreScale,
                  child: _OrbCore(
                    brightness: coreBrightness,
                    done: done,
                    percent: _pct,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.mdLg),
          if (!done) ...<Widget>[
            Text('$_pct%', style: AppTypography.numericLarge),
            const SizedBox(height: AppSpacing.xxs),
          ] else ...<Widget>[
            const Text('解析完成！', style: AppTypography.onboardingResultLabel),
            const SizedBox(height: AppSpacing.xxs),
          ],
          const SizedBox(height: AppSpacing.mdLg),
          const Text('正在认识', style: AppTypography.onboardingSubtitle),
          const SizedBox(height: AppSpacing.mdLg),
          _StepCard(
            steps: _steps,
            stepIndex: _stepIndex,
            done: done,
            progressOf: _stepProgress,
          ),
        ],
      ),
    );
  }

  /// 返回 / 退出：Figma 两处都是 `back()`，即回到上一屏（提交简历）。
  void _leave() => context.go(AppRoutes.onboardingResume);
}

/// 一步的文案。⚠️ **AI 侧起草，待产品侧确认（D66）**。
class _BaselineStep {
  const _BaselineStep({required this.label, required this.sub});

  final String label;
  final String sub;
}

/// 顶栏：返回圆钮 + 居中标题。
///
/// ⚠️ Figma 这里是**内联写法**，不是 `OnboardingProgressHeader`
/// 组件（本页没有进度条）。两处取值与该组件不同 → **D69**。
class _ParsingTopBar extends StatelessWidget {
  const _ParsingTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: SizedBox(
        height: _ParsingMetrics.backButtonSize,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Semantics(
                button: true,
                label: '返回',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBack,
                  child: Container(
                    width: _ParsingMetrics.backButtonSize,
                    height: _ParsingMetrics.backButtonSize,
                    decoration: const BoxDecoration(
                      color: AppColors.onboardingGlassFill,
                      borderRadius: AppRadius.borderPill,
                      boxShadow: AppShadows.onboardingBackPill,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_left,
                        size: _ParsingMetrics.backIconSize,
                        // Figma 本页箭头是 `#4F7EF5`，而
                        // `OnboardingProgressHeader` 用的是 `#0088FF`（D69）。
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 标题绝对居中（Figma `absolute left-1/2 -translate-x-1/2`），
            // 不受左侧返回钮宽度影响。
            const Center(
              child: Text('正在解析', style: AppTypography.onboardingBarTitle),
            ),
          ],
        ),
      ),
    );
  }
}

/// 顶部状态药丸。
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: _ParsingMetrics.pillVerticalPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.brandPillFill,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        label,
        style: AppTypography.onSurfaceVariant(
          AppTypography.onboardingSubtitle,
          AppColors.primaryBlue,
        ),
      ),
    );
  }
}

/// 光晕的一层（纯色块，无内容）。
class _OrbLayer extends StatelessWidget {
  const _OrbLayer({
    required this.size,
    required this.opacity,
    required this.scale,
  });

  final double size;
  final double opacity;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: AppColors.brandGradientDown,
            borderRadius: AppRadius.borderPill,
          ),
        ),
      ),
    );
  }
}

/// 光晕球核心：渐变圆 + 投影，内容为百分比或完成勾。
class _OrbCore extends StatelessWidget {
  const _OrbCore({
    required this.brightness,
    required this.done,
    required this.percent,
  });

  final double brightness;
  final bool done;
  final int percent;

  @override
  Widget build(BuildContext context) {
    Widget core = Container(
      width: _OrbMetrics.orbCoreSize,
      height: _OrbMetrics.orbCoreSize,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradientDown,
        borderRadius: AppRadius.borderPill,
        boxShadow: AppShadows.orb,
      ),
      child: Center(
        child: done
            ? const Icon(
                Icons.check,
                size: _OrbMetrics.orbCheckSize,
                color: AppColors.textInverse,
              )
            : Text('$percent%', style: AppTypography.orbValue),
      ),
    );

    // Figma 的 `filter: brightness(k)` —— 用颜色矩阵等比放大 RGB。
    // ⚠️ 同一条 filter 里的 `blur(0.5px)` **未复刻**（见 D72）。
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

    return core;
  }
}

/// 步骤清单卡。
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.steps,
    required this.stepIndex,
    required this.done,
    required this.progressOf,
  });

  final List<_BaselineStep> steps;
  final int stepIndex;
  final bool done;
  final double Function(int index) progressOf;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        // ⚠️ Figma 另配 `backdrop-filter: blur(16px)` —— 见 D72。
        color: AppColors.frostedFill,
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.frosted,
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < steps.length; i++)
            _StepRow(
              index: i,
              step: steps[i],
              isComplete: i < stepIndex || done,
              isActive: i == stepIndex && !done,
              progress: progressOf(i),
              showDivider: i < steps.length - 1,
            ),
        ],
      ),
    );
  }
}

/// 清单里的一行。
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.step,
    required this.isComplete,
    required this.isActive,
    required this.progress,
    required this.showDivider,
  });

  final int index;
  final _BaselineStep step;
  final bool isComplete;
  final bool isActive;
  final double progress;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isComplete
        ? AppColors.success
        : isActive
        ? AppColors.textPrimary
        : AppColors.textTertiary;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.rowDivider))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _ParsingMetrics.stepRowPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _StepBadge(
                  index: index,
                  isComplete: isComplete,
                  isActive: isActive,
                ),
                const SizedBox(width: _ParsingMetrics.stepRowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        step.label,
                        style: AppTypography.onSurfaceVariant(
                          AppTypography.onboardingSectionLabel,
                          labelColor,
                        ),
                      ),
                      if (isActive) ...<Widget>[
                        const SizedBox(height: _ParsingMetrics.stepSubGap),
                        Text(
                          step.sub,
                          style: AppTypography.onboardingStepSub,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (isActive) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              _StepProgress(value: progress),
            ],
          ],
        ),
      ),
    );
  }
}

/// 步骤徽标：完成 = 绿底勾，当前 = 渐变底序号，未到 = 灰底序号。
class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.index,
    required this.isComplete,
    required this.isActive,
  });

  final int index;
  final bool isComplete;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _ParsingMetrics.badgeSize,
      height: _ParsingMetrics.badgeSize,
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success
            : isActive
            ? null
            : AppColors.stepBadgeInactive,
        gradient: isActive ? AppColors.brandGradientDown : null,
        borderRadius: AppRadius.borderPill,
      ),
      child: Center(
        child: isComplete
            ? const Icon(
                Icons.check,
                size: _ParsingMetrics.badgeCheckSize,
                color: AppColors.textInverse,
              )
            : Text(
                '${index + 1}',
                style: AppTypography.onSurfaceVariant(
                  AppTypography.stepBadgeNumber,
                  isActive ? AppColors.textInverse : AppColors.textTertiary,
                ),
              ),
      ),
    );
  }
}

/// 当前步骤自身的进度条。
///
/// Figma 有 `transition: width 0.1s linear` —— 进度条**滞后**于百分比数字。
/// 这里用 [TweenAnimationBuilder] 复刻同一滞后（父级每帧给新目标值）。
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: AppMotion.baselineStepProgress,
      curve: AppMotion.linear,
      builder: (BuildContext context, double progress, Widget? _) =>
          ClipRRect(
            borderRadius: AppRadius.borderPill,
            child: SizedBox(
              height: _ParsingMetrics.stepBarHeight,
              child: Stack(
                children: <Widget>[
                  const ColoredBox(
                    color: AppColors.brandTint,
                    child: SizedBox.expand(),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradientDown,
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

/// 底部的「退出解析」。
///
/// ⚠️ Figma 原文是「退出分析」，本屏已不是「分析」→ 换成「解析」，
/// 属 **D66** 待确认的文案之一。
class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: CareerlyPressFeedback(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: _ParsingMetrics.exitHeight,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.ghostButtonFill,
              borderRadius: AppRadius.borderPill,
              boxShadow: AppShadows.ghostRing,
            ),
            child: Center(
              child: Text('退出解析', style: AppTypography.onboardingTextAction),
            ),
          ),
        ),
      ),
    );
  }
}

/// 光晕球的几何与关键帧位置（Figma 原值）。
///
/// 关键帧的**百分比停点**（50 / 60 / 40）不属 `CLAUDE.md` §8.2 列举的
/// 「颜色 / 字号 / 字体族 / 圆角 / 动画时长」，故不出现在 Token 里；
/// 时长与曲线则一律取自 `AppMotion`。
abstract final class _OrbMetrics {
  /// Figma：外层光晕 `160×160`。
  static const double orbSize = 160;

  /// Figma：中层光晕 `128×128`。
  static const double orbMiddleSize = 128;

  /// Figma：核心球 `96×96`。
  static const double orbCoreSize = 96;

  /// Figma：完成态勾的字形 `36×36`。
  static const double orbCheckSize = 36;

  /// Figma：外层光晕 `opacity: 0.18`。
  static const double layer1Opacity = 0.18;

  /// Figma：中层光晕 `opacity: 0.25`。
  static const double layer2Opacity = 0.25;

  /// `_ai-halo` 的起止缩放。
  static const double haloScaleMin = 0.92;
  static const double haloScaleMax = 1.22;

  /// `_ai-halo` 的起始透明度。
  static const double haloOpacityMax = 0.7;

  /// `_ai-halo` 的扩散在 **60%** 处结束，之后是不透明度恒 0 的回程。
  static const double haloExpandStop = 60;

  /// `_ai-orb` 的峰值缩放。
  static const double orbScaleMax = 1.07;

  /// `_ai-orb` 的峰值亮度。
  static const double orbBrightnessMax = 1.06;

  /// `_ai-orb-complete` 的 40% 峰值与终值。
  static const double orbCompletePeakStop = 40;
  static const double orbCompleteScalePeak = 1.14;
  static const double orbCompleteScaleRest = 1.08;
  static const double orbCompleteBrightnessPeak = 1.15;
  static const double orbCompleteBrightnessRest = 1.08;
}

/// 顶栏 / 清单的几何（Figma 原值）。
abstract final class _ParsingMetrics {
  /// Figma：返回键 `44×44`。
  static const double backButtonSize = 44;

  /// 同 `OnboardingProgressHeader` 的理由：Material 字形自带内边距。
  static const double backIconSize = 24;

  /// Figma：状态药丸 `padding: 5px 16px`（左右走 `AppSpacing.md`）。
  static const double pillVerticalPadding = 5;

  /// Figma：步骤行 `padding: 10px 0`。
  static const double stepRowPadding = 10;

  /// Figma：徽标与文字 `gap: 10`。
  static const double stepRowGap = 10;

  /// Figma：副行 `margin-top: 2px`。
  static const double stepSubGap = 2;

  /// Figma：徽标 `22×22`。
  static const double badgeSize = 22;

  /// Figma：徽标内勾的字形 `12×12`。
  static const double badgeCheckSize = 12;

  /// Figma：步骤进度条 `height: 4`。
  static const double stepBarHeight = 4;

  /// Figma：退出按钮（与主按钮不同值）`height: 44`。
  static const double exitHeight = 44;
}
