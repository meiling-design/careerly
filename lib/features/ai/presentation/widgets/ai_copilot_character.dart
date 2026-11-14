import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AICopilotMotionState { idle, thinking, responding }

/// Nebula companion above the AI composer, animated from real chat state.
///
/// ## 两种形象按页面状态区分（2026-11-14 产品侧指定）
///
/// ```text
/// 快捷引导态（welcome: true）  → 「办公」IP（careerly-assets/svg/办公.svg）
/// 对话态（welcome: false）     → 原有四态星云形象
///                                idle / thinking / responding / completed
/// ```
///
/// 动效（悬浮、呼吸、粒子、完成弹跳）在两种状态下一致，
/// 只有**图形素材**按状态切换。
class AICopilotCharacter extends StatefulWidget {
  const AICopilotCharacter({
    super.key,
    required this.state,
    this.completionId,
    this.welcome = false,
  });

  final AICopilotMotionState state;
  final String? completionId;

  /// 是否为 AI 快捷引导（欢迎）态。
  ///
  /// `true` 时使用「办公」IP；`false` 时使用对话态的四张星云素材。
  final bool welcome;

  @override
  State<AICopilotCharacter> createState() => _AICopilotCharacterState();
}

class _AICopilotCharacterState extends State<AICopilotCharacter>
    with TickerProviderStateMixin {
  static const double _width = 100;
  static const double _height = 93;
  static const Duration _messageDuration = Duration(milliseconds: 2200);

  /// 快捷引导页的 IP 形象（2026-11-14 产品侧指定）。
  ///
  /// 素材来源：`careerly-assets/svg/办公.svg` —— 与「感叹」「休息」
  /// 属于同一套 IP。
  static const String _officeAsset =
      'assets/images/nebula/careerly-ai-office.svg';

  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final AnimationController _activity = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  late final AnimationController _interaction = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final AnimationController _completion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  )..addStatusListener(_onCompletionStatus);

  Timer? _messageTimer;
  bool _showMessage = false;
  bool _showCompletion = false;
  bool _reduceMotion = false;
  String? _lastCompletionId;

  static const List<_ParticleSpec> _particleSpecs = <_ParticleSpec>[
    _ParticleSpec(left: 12, top: 39, color: Color(0xE6FFE193)),
    _ParticleSpec(
      left: 37,
      top: 12,
      color: Color(0xE0B5DDFF),
      size: 3,
      drift: -3,
      delay: 0.22,
    ),
    _ParticleSpec(
      right: 12,
      top: 33,
      color: Color(0xDCCDBCFF),
      drift: 3,
      delay: 0.48,
    ),
    _ParticleSpec(
      left: 23,
      top: 63,
      color: Color(0xD1B5DDFF),
      size: 3,
      drift: -2,
      delay: 0.63,
    ),
    _ParticleSpec(
      right: 29,
      top: 54,
      color: Color(0xDCFFE193),
      size: 3,
      drift: 1,
      delay: 0.22,
    ),
    _ParticleSpec(
      right: 2,
      top: 17,
      color: Color(0xD1CDBCFF),
      size: 3,
      drift: 4,
      delay: 0.48,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _lastCompletionId = widget.completionId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (_reduceMotion) return;
      _ambient.repeat(reverse: true);
      _syncActivity();
    });
  }

  @override
  void didUpdateWidget(covariant AICopilotCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) _syncActivity();
    if (widget.completionId != null &&
        widget.completionId != _lastCompletionId) {
      _lastCompletionId = widget.completionId;
      if (!_reduceMotion) {
        _showCompletion = true;
        _completion.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _ambient.dispose();
    _activity.dispose();
    _interaction.dispose();
    _completion.dispose();
    super.dispose();
  }

  void _syncActivity() {
    if (_reduceMotion) return;
    if (widget.state == AICopilotMotionState.idle) {
      _activity.stop();
      _activity.value = 0;
    } else {
      _activity.repeat();
    }
  }

  void _onCompletionStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() => _showCompletion = false);
    _completion.reset();
  }

  void _onTap() {
    _messageTimer?.cancel();
    setState(() => _showMessage = true);
    if (!_reduceMotion) _interaction.forward(from: 0);
    _messageTimer = Timer(_messageDuration, () {
      if (mounted) setState(() => _showMessage = false);
    });
  }

  /// 按页面状态选择 IP 素材。
  ///
  /// 快捷引导态固定用「办公」；对话态保留原来的四态星云稿。
  String get _assetPath {
    if (widget.welcome) return _officeAsset;
    if (_showCompletion) {
      return 'assets/images/nebula/careerly-ai-completed.svg';
    }
    return switch (widget.state) {
      AICopilotMotionState.idle => 'assets/images/nebula/careerly-ai-idle.svg',
      AICopilotMotionState.thinking =>
        'assets/images/nebula/careerly-ai-thinking.svg',
      AICopilotMotionState.responding =>
        'assets/images/nebula/careerly-ai-responding.svg',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Careerly AI 职业顾问，点击互动',
      child: GestureDetector(
        key: const ValueKey<String>('ai-copilot-character'),
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: SizedBox(
          width: _width,
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              AnimatedBuilder(
                animation: Listenable.merge(<Listenable>[
                  _ambient,
                  _activity,
                  _interaction,
                  _completion,
                ]),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: SvgPicture.asset(
                    _assetPath,
                    key: ValueKey<String>(_assetPath),
                    width: _width,
                    height: _height,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    excludeFromSemantics: true,
                  ),
                ),
                builder: (BuildContext context, Widget? child) {
                  final double ambientProgress = _reduceMotion
                      ? 0
                      : _ambient.value;
                  final double interactionProgress = _reduceMotion
                      ? 0
                      : _interaction.value;
                  final double completionProgress = _reduceMotion
                      ? 0
                      : _completion.value;
                  final double floatOffset =
                      -4 * Curves.easeInOut.transform(ambientProgress);
                  final double breathScale =
                      1 + 0.012 * math.sin(ambientProgress * math.pi);
                  final double bounceScale =
                      1 + 0.04 * _bounceCurve.transform(interactionProgress);
                  return Transform.translate(
                    offset: Offset(
                      0,
                      floatOffset + _completionOffset(completionProgress),
                    ),
                    child: Transform.scale(
                      alignment: Alignment.bottomCenter,
                      scale: breathScale * bounceScale,
                      child: child,
                    ),
                  );
                },
              ),
              Positioned(
                left: 24,
                bottom: 1,
                child: _CharacterShadow(progress: _ambient),
              ),
              if (!_reduceMotion && widget.state != AICopilotMotionState.idle)
                for (int index = 0; index < _particleSpecs.length; index++)
                  if (widget.state == AICopilotMotionState.responding ||
                      index < 3)
                    _AnimatedParticle(
                      spec: _particleSpecs[index],
                      progress: _activity,
                    ),
              if (!_reduceMotion)
                Positioned(
                  left: 12,
                  top: 25,
                  child: _InteractionSparkle(
                    progress: _interaction,
                    color: const Color(0xFFFFF1A8),
                    size: 7,
                  ),
                ),
              if (!_reduceMotion)
                Positioned(
                  right: 14,
                  top: 13,
                  child: _InteractionSparkle(
                    progress: _interaction,
                    color: const Color(0xFFE3D9FF),
                    size: 5,
                  ),
                ),
              if (_showMessage)
                const Positioned(
                  left: 76,
                  top: -12,
                  child: _CompanionMessage(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static final Curve _bounceCurve = const Cubic(0.22, 0.9, 0.32, 1);

  static double _completionOffset(double progress) {
    final double t = Curves.easeOut.transform(progress);
    if (t <= 0.42) return -7 * (t / 0.42);
    if (t <= 0.70) return -7 + 9 * ((t - 0.42) / 0.28);
    return 2 * (1 - (t - 0.70) / 0.30);
  }
}

class _ParticleSpec {
  const _ParticleSpec({
    this.left,
    this.right,
    required this.top,
    required this.color,
    this.size = 4,
    this.drift = 2,
    this.delay = 0,
  });

  final double? left;
  final double? right;
  final double top;
  final Color color;
  final double size;
  final double drift;
  final double delay;
}

class _AnimatedParticle extends AnimatedWidget {
  const _AnimatedParticle({
    required this.spec,
    required Animation<double> progress,
  }) : super(listenable: progress);

  final _ParticleSpec spec;

  @override
  Widget build(BuildContext context) {
    final double progress = (listenable as Animation<double>).value;
    final double local = ((progress - spec.delay) / (1 - spec.delay)).clamp(
      0.0,
      1.0,
    );
    final double opacity = local < 0.22
        ? local / 0.22 * 0.7
        : local < 0.76
        ? 0.7 - (local - 0.22) / 0.54 * 0.35
        : (1 - local) / 0.24 * 0.35;
    final double rise = 5 + 29 * local;
    return Positioned(
      left: spec.left,
      right: spec.right,
      top: spec.top - rise,
      child: Opacity(
        opacity: opacity.clamp(0.0, 0.7),
        child: Transform.translate(
          offset: Offset(spec.drift * local, 0),
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: spec.size,
              height: spec.size,
              decoration: BoxDecoration(
                color: spec.color,
                borderRadius: BorderRadius.circular(1),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: spec.color.withValues(alpha: 0.28),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterShadow extends AnimatedWidget {
  const _CharacterShadow({required Animation<double> progress})
    : super(listenable: progress);

  @override
  Widget build(BuildContext context) {
    final double progress = (listenable as Animation<double>).value;
    final double wave = math.sin(progress * math.pi);
    return Opacity(
      opacity: 0.2 - wave * 0.07,
      child: Transform.scale(
        alignment: Alignment.center,
        scaleX: 0.9 - wave * 0.12,
        child: Container(
          width: 53,
          height: 9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: const RadialGradient(
              colors: <Color>[
                Color(0x3D354181),
                Color(0x1A5B7CFA),
                Color(0x005B7CFA),
              ],
              stops: <double>[0, 0.46, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractionSparkle extends AnimatedWidget {
  const _InteractionSparkle({
    required Animation<double> progress,
    required this.color,
    required this.size,
  }) : super(listenable: progress);

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double progress = (listenable as Animation<double>).value;
    final double opacity = (1 - progress).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity * 0.85,
      child: Transform.translate(
        offset: Offset(0, -8 * progress),
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Icon(Icons.auto_awesome, size: size, color: color),
        ),
      ),
    );
  }
}

class _CompanionMessage extends StatelessWidget {
  const _CompanionMessage();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 168),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF3F487E).withValues(alpha: 0.14),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Text(
            '我一直在这里，随时陪你聊聊。',
            style: TextStyle(
              fontSize: 11,
              height: 17 / 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF373B4D),
            ),
          ),
        ),
      ),
    );
  }
}
