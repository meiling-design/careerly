import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../profile/state/growth_celebration_provider.dart';
import '../home_content.dart';

/// 首页全宽欢迎区。姓名和状态内容均来自当前首页阶段，不使用原型假名。
class HomeHeroCard extends StatefulWidget {
  const HomeHeroCard({
    super.key,
    required this.content,
    this.onAction,
    this.celebration,
    this.onCelebrationFinished,
  });

  final HomeHeroContent content;
  final VoidCallback? onAction;
  final GrowthCelebration? celebration;
  final ValueChanged<int>? onCelebrationFinished;

  @override
  State<HomeHeroCard> createState() => _HomeHeroCardState();
}

class _HomeHeroCardState extends State<HomeHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebrationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..addStatusListener(_onAnimationStatus);

  GrowthCelebration? _activeCelebration;

  @override
  void initState() {
    super.initState();
    if (widget.celebration != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startCelebration(widget.celebration);
      });
    }
  }

  @override
  void didUpdateWidget(covariant HomeHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.celebration?.id != widget.celebration?.id) {
      _startCelebration(widget.celebration);
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _startCelebration(GrowthCelebration? celebration) {
    if (celebration == null) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onCelebrationFinished?.call(celebration.id);
      });
      return;
    }
    setState(() => _activeCelebration = celebration);
    _celebrationController.forward(from: 0);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    final int? completedId = _activeCelebration?.id;
    setState(() => _activeCelebration = null);
    if (completedId != null) {
      widget.onCelebrationFinished?.call(completedId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double scale = (constraints.maxWidth / _HeroMetrics.designWidth)
            .clamp(0.0, 1.0)
            .toDouble();

        return SizedBox(
          height: _HeroMetrics.height * scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.homeWelcomeGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(_HeroMetrics.bottomRadius * scale),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(_HeroMetrics.bottomRadius * scale),
              ),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minWidth: _HeroMetrics.designWidth,
                maxWidth: _HeroMetrics.designWidth,
                minHeight: _HeroMetrics.height,
                maxHeight: _HeroMetrics.height,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _HeroMetrics.designWidth,
                    height: _HeroMetrics.height,
                    child: Stack(
                      children: <Widget>[
                        const Positioned(
                          left: _HeroMetrics.circleLeft,
                          top: _HeroMetrics.circleTop,
                          child: _HeroCircle(),
                        ),
                        Positioned(
                          right: _HeroMetrics.imageRight,
                          top: _HeroMetrics.imageTop,
                          width: _HeroMetrics.imageWidth,
                          height: _HeroMetrics.imageHeight,
                          child: AnimatedBuilder(
                            animation: _celebrationController,
                            builder: (BuildContext context, Widget? child) {
                              final double progress =
                                  _celebrationController.value;
                              final double hop =
                                  math.sin(progress * math.pi * 3) *
                                  (1 - progress) *
                                  9;
                              final double imageScale =
                                  1 + math.sin(progress * math.pi * 3) * 0.055;
                              return Transform.translate(
                                offset: Offset(0, -hop),
                                child: Transform.rotate(
                                  angle:
                                      math.sin(progress * math.pi * 2) * 0.035,
                                  child: Transform.scale(
                                    scale: imageScale,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOutBack,
                              switchOutCurve: Curves.easeIn,
                              child: SvgPicture.asset(
                                _activeCelebration == null
                                    ? 'assets/images/nebula/home-welcome.svg'
                                    : 'assets/images/nebula/home-celebration.svg',
                                key: ValueKey<bool>(_activeCelebration != null),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        if (_activeCelebration != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _celebrationController,
                                builder:
                                    (BuildContext context, Widget? child) =>
                                        CustomPaint(
                                          painter: _HomeCelebrationPainter(
                                            progress:
                                                _celebrationController.value,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: _HeroMetrics.contentLeft,
                          top: _HeroMetrics.contentTop,
                          width: _HeroMetrics.contentWidth,
                          child: _HeroCopy(content: widget.content),
                        ),
                        Positioned(
                          left: _HeroMetrics.actionLeft,
                          top: _HeroMetrics.actionTop,
                          child: _HeroActionButton(
                            label: widget.content.actionLabel,
                            onPressed: widget.onAction,
                          ),
                        ),
                        if (_activeCelebration != null)
                          Positioned(
                            right: 12,
                            bottom: 10,
                            child: _CelebrationMessage(
                              progress: _celebrationController,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CelebrationMessage extends AnimatedWidget {
  const _CelebrationMessage({required Animation<double> progress})
    : super(listenable: progress);

  @override
  Widget build(BuildContext context) {
    final double progress = (listenable as Animation<double>).value;
    final double opacity =
        ((progress - 0.12) / 0.18).clamp(0.0, 1.0) *
        ((1 - progress) / 0.18).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.9),
          borderRadius: AppRadius.borderPill,
        ),
        child: Text(
          '太棒了！又向前一步 ✨',
          style: AppTypography.homeHeroMeta.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _HomeCelebrationPainter extends CustomPainter {
  const _HomeCelebrationPainter({required this.progress});

  final double progress;

  static const List<Color> _ribbonColors = <Color>[
    Color(0xFFFF7DB8),
    Color(0xFFFFD36B),
    Color(0xFF75E1D2),
    Color(0xFFB5A2FF),
  ];

  static const List<_ConfettiPiece> _pieces = <_ConfettiPiece>[
    _ConfettiPiece(0.55, 0.02, 0.02, 0.34, 0),
    _ConfettiPiece(0.63, 0.12, -0.08, 0.42, 1),
    _ConfettiPiece(0.70, 0.08, 0.05, 0.48, 2),
    _ConfettiPiece(0.77, 0.10, 0.15, 0.36, 3),
    _ConfettiPiece(0.85, 0.12, 0.20, 0.44, 0),
    _ConfettiPiece(0.58, 0.18, -0.19, 0.32, 2),
    _ConfettiPiece(0.67, 0.17, 0.11, 0.32, 1),
    _ConfettiPiece(0.74, 0.14, -0.12, 0.40, 3),
    _ConfettiPiece(0.82, 0.16, 0.08, 0.32, 2),
    _ConfettiPiece(0.91, 0.12, -0.18, 0.38, 1),
    _ConfettiPiece(0.61, 0.20, 0.22, 0.32, 3),
    _ConfettiPiece(0.79, 0.18, -0.04, 0.45, 0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double ribbonProgress = ((progress - 0.04) / 0.34).clamp(0.0, 1.0);
    final double ribbonOpacity =
        (1 - ((progress - 0.70) / 0.30).clamp(0.0, 1.0)) * 0.82;
    if (ribbonProgress > 0 && ribbonOpacity > 0) {
      _paintRibbons(canvas, size, ribbonProgress, ribbonOpacity);
    }
    _paintConfetti(canvas, size);
    _paintStars(canvas, size);
  }

  void _paintRibbons(
    Canvas canvas,
    Size size,
    double drawProgress,
    double opacity,
  ) {
    final double centerX = size.width * 0.73;
    final double centerY = size.height * 0.62;
    final List<Path> paths = <Path>[
      Path()
        ..moveTo(centerX - 18, centerY)
        ..cubicTo(
          size.width * 0.52,
          size.height * 0.34,
          size.width * 0.26,
          size.height * 0.24,
          size.width * 0.05,
          size.height * 0.42,
        ),
      Path()
        ..moveTo(centerX + 5, centerY - 5)
        ..cubicTo(
          size.width * 0.88,
          size.height * 0.35,
          size.width * 0.90,
          size.height * 0.22,
          size.width * 0.98,
          size.height * 0.34,
        ),
      Path()
        ..moveTo(centerX - 10, centerY + 2)
        ..cubicTo(
          size.width * 0.57,
          size.height * 0.82,
          size.width * 0.30,
          size.height * 0.94,
          size.width * 0.08,
          size.height * 0.84,
        ),
      Path()
        ..moveTo(centerX + 12, centerY + 1)
        ..cubicTo(
          size.width * 0.91,
          size.height * 0.78,
          size.width * 0.84,
          size.height * 0.96,
          size.width * 0.98,
          size.height * 0.88,
        ),
    ];

    for (int index = 0; index < paths.length; index++) {
      final PathMetric metric = paths[index].computeMetrics().first;
      final Path segment = metric.extractPath(
        0,
        metric.length * Curves.easeOutCubic.transform(drawProgress),
      );
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = index.isEven ? 4 : 3
        ..strokeCap = StrokeCap.round
        ..color = _ribbonColors[index].withValues(alpha: opacity);
      canvas.drawPath(segment, paint);
    }
  }

  void _paintConfetti(Canvas canvas, Size size) {
    for (int index = 0; index < _pieces.length; index++) {
      final _ConfettiPiece piece = _pieces[index];
      final double local = ((progress - piece.delay) / (1 - piece.delay)).clamp(
        0.0,
        1.0,
      );
      if (local <= 0 || local >= 1) continue;
      final double eased = Curves.easeIn.transform(local);
      final double x = (piece.startX + piece.endX * eased) * size.width;
      final double y = (0.32 + piece.endY * eased) * size.height;
      final double opacity = math.sin(math.pi * local);
      final double angle = local * math.pi * 2 * (index.isEven ? 1 : -1);
      final Color color = _ribbonColors[piece.colorIndex];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: index.isEven ? 6 : 4,
            height: index.isEven ? 9 : 5,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    const List<Offset> locations = <Offset>[
      Offset(0.58, 0.48),
      Offset(0.90, 0.49),
      Offset(0.68, 0.80),
      Offset(0.92, 0.74),
    ];
    for (int index = 0; index < locations.length; index++) {
      final double phase = progress * math.pi * 5 + index * 1.6;
      final double radius = 2 + (math.sin(phase) + 1) * 2.2;
      final double opacity =
          ((math.sin(phase) + 1) / 2) * (1 - progress * 0.55);
      final Offset center = Offset(
        locations[index].dx * size.width,
        locations[index].dy * size.height,
      );
      final Path star = Path()
        ..moveTo(center.dx, center.dy - radius * 2)
        ..quadraticBezierTo(
          center.dx + radius * 0.25,
          center.dy - radius * 0.25,
          center.dx + radius * 2,
          center.dy,
        )
        ..quadraticBezierTo(
          center.dx + radius * 0.25,
          center.dy + radius * 0.25,
          center.dx,
          center.dy + radius * 2,
        )
        ..quadraticBezierTo(
          center.dx - radius * 0.25,
          center.dy + radius * 0.25,
          center.dx - radius * 2,
          center.dy,
        )
        ..quadraticBezierTo(
          center.dx - radius * 0.25,
          center.dy - radius * 0.25,
          center.dx,
          center.dy - radius * 2,
        )
        ..close();
      canvas.drawPath(
        star,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HomeCelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ConfettiPiece {
  const _ConfettiPiece(
    this.startX,
    this.delay,
    this.endX,
    this.endY,
    this.colorIndex,
  );

  final double startX;
  final double delay;
  final double endX;
  final double endY;
  final int colorIndex;
}

class _HeroCircle extends StatelessWidget {
  const _HeroCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _HeroMetrics.circleSize,
      height: _HeroMetrics.circleSize,
      decoration: const BoxDecoration(
        color: AppColors.homeWelcomeCircle,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.content});

  final HomeHeroContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          content.label,
          style: AppTypography.homeHeroLabel.copyWith(
            fontSize: _HeroMetrics.labelFontSize,
            height: _HeroMetrics.labelLineHeight / _HeroMetrics.labelFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: _HeroMetrics.labelLetterSpacing,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // 昵称是真实数据，可能为空（未登录 / 资料未加载）——
        // 此时 Hero 只显示问候语与品牌短句，不占位、不编造名字。
        if (content.title.isNotEmpty) ...<Widget>[
          const SizedBox(height: _HeroMetrics.titleGap),
          SizedBox(
            height: _HeroMetrics.titleLineHeight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                content.title,
                style: AppTypography.homeHeroTitle.copyWith(
                  fontSize: _HeroMetrics.titleFontSize,
                  height:
                      _HeroMetrics.titleLineHeight / _HeroMetrics.titleFontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: _HeroMetrics.titleLetterSpacing,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
        if (content.meta.isNotEmpty) ...<Widget>[
          const SizedBox(height: _HeroMetrics.metaGap),
          Text(
            content.meta,
            style: AppTypography.homeHeroMeta.copyWith(
              fontSize: _HeroMetrics.metaFontSize,
              height: _HeroMetrics.metaLineHeight / _HeroMetrics.metaFontSize,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CareerlyPressFeedback(
      onTap: onPressed,
      child: Container(
        height: _HeroMetrics.actionHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: _HeroMetrics.actionPadding,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.borderPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/home/home-new-analysis.svg',
              width: _HeroMetrics.actionIconSize,
              height: _HeroMetrics.actionIconSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: _HeroMetrics.actionIconGap),
            Text(
              label,
              style: AppTypography.homeHeroButton.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class _HeroMetrics {
  static const double designWidth = 390;
  static const double height = 227;
  static const double bottomRadius = 36;

  static const double circleLeft = -27;
  static const double circleTop = -6;
  static const double circleSize = 155;

  static const double imageWidth = 190;
  static const double imageHeight = 166;
  static const double imageRight = 4;
  static const double imageTop = 67;

  static const double contentLeft = 40;
  static const double contentTop = 79;
  static const double contentWidth = 180;
  static const double labelFontSize = 13;
  static const double labelLineHeight = 16.5;
  static const double labelLetterSpacing = 1.1;
  static const double titleGap = 6;
  static const double titleFontSize = 26;
  static const double titleLineHeight = 27;
  static const double titleLetterSpacing = 1;
  static const double metaGap = 6;
  static const double metaFontSize = 13;
  static const double metaLineHeight = 17;

  static const double actionLeft = 32;
  static const double actionTop = 171;
  static const double actionHeight = 38;
  static const double actionPadding = 12;
  static const double actionIconSize = 25;
  static const double actionIconGap = 4;
}
