import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../design_system/tokens/tokens.dart';

/// Login-screen companion, using the original Figma vector asset.
class OnboardingLoginIp extends StatefulWidget {
  const OnboardingLoginIp({super.key, required this.width});

  final double width;

  @override
  State<OnboardingLoginIp> createState() => _OnboardingLoginIpState();
}

class _OnboardingLoginIpState extends State<OnboardingLoginIp>
    with TickerProviderStateMixin {
  static const String _assetPath = 'assets/images/nebula/careerly-login-ip.svg';
  static const Duration _floatDelay = Duration(milliseconds: 980);
  static const Duration _messageDuration = Duration(milliseconds: 2200);

  late final AnimationController _entryController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 880),
  );
  late final Animation<Offset> _entryOffset =
      TweenSequence<Offset>(<TweenSequenceItem<Offset>>[
        _offsetTween(const Offset(0, 230), const Offset(0, 230), 14),
        _offsetTween(const Offset(0, 230), const Offset(0, 108), 36),
        _offsetTween(const Offset(0, 108), const Offset(0, 45), 14),
        _offsetTween(const Offset(0, 45), const Offset(0, 45), 1),
        _offsetTween(const Offset(0, 45), const Offset(0, -10), 13),
        _offsetTween(const Offset(0, -10), const Offset(0, 4), 12),
        _offsetTween(const Offset(0, 4), Offset.zero, 10),
      ]).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: const Cubic(0.22, 0.78, 0.24, 1),
        ),
      );
  late final Animation<double> _entryOpacity =
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 1),
          weight: 14,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1, end: 1),
          weight: 86,
        ),
      ]).animate(_entryController);
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _floatOffset = Tween<double>(
    begin: 0,
    end: -3,
  ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
  late final AnimationController _interactionController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..addStatusListener(_onInteractionStatus);
  late final Animation<double> _bounceScale =
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1, end: 1.04),
          weight: 38,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.04, end: 1),
          weight: 62,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _interactionController,
          curve: const Cubic(0.22, 0.9, 0.32, 1),
        ),
      );
  late final Animation<double> _starHop =
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: -8),
          weight: 42,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -8, end: 0),
          weight: 58,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _interactionController,
          curve: const Cubic(0.22, 0.9, 0.32, 1),
        ),
      );

  Timer? _floatTimer;
  Timer? _messageTimer;
  bool _showMessage = false;
  bool _reduceMotion = false;

  static TweenSequenceItem<Offset> _offsetTween(
    Offset begin,
    Offset end,
    double weight,
  ) {
    return TweenSequenceItem<Offset>(
      tween: Tween<Offset>(begin: begin, end: end),
      weight: weight,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (_reduceMotion) return;
      _entryController.forward();
      _floatTimer = Timer(_floatDelay, () {
        if (mounted) _floatController.repeat(reverse: true);
      });
    });
  }

  @override
  void dispose() {
    _floatTimer?.cancel();
    _messageTimer?.cancel();
    _entryController.dispose();
    _floatController.dispose();
    _interactionController.dispose();
    super.dispose();
  }

  void _onInteractionStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _interactionController.reset();
    }
  }

  void _respond() {
    _messageTimer?.cancel();
    setState(() => _showMessage = true);
    if (!_reduceMotion) _interactionController.forward(from: 0);
    _messageTimer = Timer(_messageDuration, () {
      if (mounted) setState(() => _showMessage = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = widget.width * 219.123 / 209.472;

    return Semantics(
      button: true,
      label: 'Careerly 职业成长伙伴，点击互动',
      child: GestureDetector(
        key: const ValueKey<String>('onboarding-login-ip'),
        behavior: HitTestBehavior.opaque,
        onTap: _respond,
        child: SizedBox(
          width: widget.width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge(<Listenable>[
                    _entryController,
                    _floatController,
                    _interactionController,
                  ]),
                  child: SvgPicture.asset(
                    _assetPath,
                    width: widget.width,
                    height: height,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                  builder: (BuildContext context, Widget? child) {
                    final Offset entryOffset = _reduceMotion
                        ? Offset.zero
                        : _entryOffset.value;
                    final double floatOffset = _reduceMotion
                        ? 0
                        : _floatOffset.value;
                    final double scale = _reduceMotion ? 1 : _bounceScale.value;
                    return Opacity(
                      opacity: _reduceMotion ? 1 : _entryOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, entryOffset.dy + floatOffset),
                        child: Transform.scale(
                          alignment: Alignment.bottomCenter,
                          scale: scale,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!_reduceMotion)
                Positioned(
                  left: widget.width * 0.13,
                  top: height * 0.27,
                  child: _InteractionStar(
                    color: const Color(0xFFFFF1A8),
                    hop: _starHop,
                    scale: _bounceScale,
                  ),
                ),
              if (!_reduceMotion)
                Positioned(
                  right: widget.width * 0.14,
                  top: height * 0.14,
                  child: _InteractionStar(
                    color: const Color(0xFFE3D9FF),
                    hop: _starHop,
                    scale: _bounceScale,
                    size: 5,
                  ),
                ),
              if (_showMessage)
                Positioned(
                  left: -widget.width * 0.58,
                  top: height * 0.54,
                  child: _LoginIpMessage(maxWidth: math.min(175, widget.width)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractionStar extends AnimatedWidget {
  const _InteractionStar({
    required this.color,
    required this.hop,
    required this.scale,
    this.size = 7,
  }) : super(listenable: hop);

  final Color color;
  final Animation<double> hop;
  final Animation<double> scale;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scale,
      builder: (BuildContext context, Widget? child) => Transform.translate(
        offset: Offset(0, hop.value),
        child: Transform.scale(scale: scale.value, child: child),
      ),
      child: Icon(Icons.auto_awesome, size: size, color: color),
    );
  }
}

class _LoginIpMessage extends StatelessWidget {
  const _LoginIpMessage({required this.maxWidth});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Text(
            '欢迎回来，我陪你继续成长。',
            style: AppTypography.authFooter.copyWith(
              fontSize: 11,
              height: 17 / 11,
              color: const Color(0xFF373B4D),
            ),
          ),
        ),
      ),
    );
  }
}
