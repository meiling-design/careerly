import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../design_system/components/components.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../home_content.dart';

/// 首页 2×2 卡片区。
class HomeStilCards extends StatelessWidget {
  const HomeStilCards({
    super.key,
    required this.cards,
    this.onOpenAi,
    this.onOpenAnalysis,
    this.onOpenGrowth,
  });

  final List<HomeStilCardData> cards;
  final VoidCallback? onOpenAi;
  final VoidCallback? onOpenAnalysis;
  final VoidCallback? onOpenGrowth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < cards.length; i += 2)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : _StilMetrics.rowGap),
            child: SizedBox(
              height: _StilMetrics.cardHeight,
              child: Row(
                children: <Widget>[
                  Expanded(child: _card(cards[i])),
                  const SizedBox(width: _StilMetrics.columnGap),
                  Expanded(
                    child: i + 1 < cards.length
                        ? _card(cards[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _card(HomeStilCardData data) {
    final VoidCallback? onTap = switch (data.target) {
      null => null,
      HomeCardTarget.ai => onOpenAi,
      HomeCardTarget.analysis => onOpenAnalysis,
      HomeCardTarget.growth => onOpenGrowth,
    };

    final Widget surface = switch (data.kind) {
      HomeStilCardKind.status => _StatusCard(data: data),
      HomeStilCardKind.growth => _ContentCard(
        data: data,
        iconAsset: 'assets/images/home/home-growth.svg',
        iconGradient: AppColors.homeStilGradientGrowth,
      ),
      HomeStilCardKind.suggestion => _ContentCard(
        data: data,
        iconAsset: 'assets/images/home/home-suggestion.svg',
        iconGradient: AppColors.homeStilGradientAi,
      ),
      HomeStilCardKind.daily => _DailyCard(data: data),
    };

    if (onTap == null) return surface;
    return CareerlyPressFeedback(onTap: onTap, child: surface);
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.data});

  final HomeStilCardData data;

  @override
  Widget build(BuildContext context) {
    final int? score = data.statusScore;
    final String? badge = data.statusBadge;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.homeStatusCardGradient,
        borderRadius: BorderRadius.circular(_StilMetrics.radius),
        border: Border.all(
          color: AppColors.homeStatusCardBorder,
          width: _StilMetrics.statusBorderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_StilMetrics.radius),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: _StilMetrics.statusInset,
              right: _StilMetrics.statusInset,
              top: _StilMetrics.statusHeaderTop,
              height: _StilMetrics.statusHeaderHeight,
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/home/home-status-marker.svg',
                    width: _StilMetrics.statusMarkerWidth,
                    height: _StilMetrics.statusMarkerHeight,
                  ),
                  const SizedBox(width: _StilMetrics.statusMarkerGap),
                  Expanded(
                    child: Text(
                      data.title,
                      style: AppTypography.homeCardTitle.copyWith(
                        fontSize: _StilMetrics.statusTitleSize,
                        color: AppColors.textInverse,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badge != null && badge.isNotEmpty) ...<Widget>[
                    const SizedBox(width: _StilMetrics.statusChipGap),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _StilMetrics.statusChipHorizontal,
                        vertical: _StilMetrics.statusChipVertical,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.homeStatusChipFill,
                        borderRadius: BorderRadius.all(
                          Radius.circular(_StilMetrics.statusChipRadius),
                        ),
                      ),
                      child: Text(
                        badge,
                        style: AppTypography.homeCardDesc.copyWith(
                          fontSize: _StilMetrics.statusChipFontSize,
                          height: 14 / _StilMetrics.statusChipFontSize,
                          color: AppColors.homeStatusChipText,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 圆环始终保留（含无数据时）：有分数画进度弧，
            // 没分数只画底环，中间显示「暂无数据」而不是编造一个分数。
            Positioned(
              top: _StilMetrics.ringTop,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: _StilMetrics.ringSize,
                  height: _StilMetrics.ringSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned.fill(
                        child: SvgPicture.asset(
                          'assets/images/home/home-score-ring-track.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (score != null)
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/images/home/home-score-ring-fill.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            score == null ? '暂无数据' : '$score%',
                            style: score == null
                                ? AppTypography.homeCardDesc.copyWith(
                                    fontSize:
                                        _StilMetrics.scorePlaceholderFontSize,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.homeCardTitle,
                                  )
                                : AppTypography.homeHeroScore.copyWith(
                                    fontSize: _StilMetrics.scoreFontSize,
                                    height: 1.35,
                                    color: AppColors.homeCardTitle,
                                  ),
                          ),
                          Text(
                            '匹配度',
                            style: AppTypography.homeHeroScoreLabel.copyWith(
                              color: AppColors.homeStatusScoreLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: _StilMetrics.statusFooterInset,
              right: _StilMetrics.statusFooterInset,
              bottom: _StilMetrics.statusFooterBottom,
              child: _CardAction(
                label: data.actionLabel,
                iconAsset: 'assets/images/home/home-card-open.svg',
                color: AppColors.homeStatusActionText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.data,
    required this.iconAsset,
    required this.iconGradient,
  });

  final HomeStilCardData data;
  final String iconAsset;
  final LinearGradient iconGradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.homeCardFill,
        borderRadius: BorderRadius.circular(_StilMetrics.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_StilMetrics.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: _StilMetrics.iconTopPadding),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _StilMetrics.iconTileSize,
                  height: _StilMetrics.iconTileSize,
                  decoration: BoxDecoration(
                    gradient: iconGradient,
                    borderRadius: BorderRadius.circular(
                      _StilMetrics.iconTileRadius,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconAsset,
                      width: _StilMetrics.iconSize,
                      height: _StilMetrics.iconSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: _StilMetrics.iconContentGap),
            Text(
              data.title,
              style: AppTypography.homeCardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: _StilMetrics.titleGap),
            Expanded(child: _DescriptionLines(data: data)),
            _CardAction(
              label: data.actionLabel,
              iconAsset: 'assets/images/home/home-card-action.svg',
              color: AppColors.homeCardActionText,
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionLines extends StatelessWidget {
  const _DescriptionLines({required this.data});

  final HomeStilCardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < data.lines.length; i++)
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : _StilMetrics.descriptionLineGap,
            ),
            child: Text(
              data.lines[i],
              style: AppTypography.homeCardDesc.copyWith(
                color: i == data.lines.length - 1 && data.lineAccent != null
                    ? data.lineAccent
                    : AppColors.homeCardDesc,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.iconAsset,
    required this.color,
  });

  final String label;
  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SvgPicture.asset(
          iconAsset,
          width: _StilMetrics.actionIconSize,
          height: _StilMetrics.actionIconSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: _StilMetrics.actionGap),
        Flexible(
          child: Text(
            label,
            style: AppTypography.homeCardDesc.copyWith(
              fontSize: _StilMetrics.actionFontSize,
              height: 16 / _StilMetrics.actionFontSize,
              letterSpacing: _StilMetrics.actionLetterSpacing,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.data});

  final HomeStilCardData data;

  static const List<String> _weekdays = <String>[
    '周日',
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
  ];

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final String quote = <String>[
      data.title,
      ...data.lines,
    ].where((String line) => line.trim().isNotEmpty).join('\n');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.homeCardFill,
        borderRadius: BorderRadius.circular(_StilMetrics.radius),
        border: Border.all(
          color: AppColors.homeQuoteBorder,
          width: _StilMetrics.quoteBorderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_StilMetrics.quoteInnerRadius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _StilMetrics.quotePaddingLeft,
            _StilMetrics.quotePaddingTop,
            _StilMetrics.quotePaddingRight,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                today.day.toString().padLeft(2, '0'),
                style: AppTypography.homeCardTitle.copyWith(
                  fontFamily: 'serif',
                  fontSize: _StilMetrics.dateFontSize,
                  height:
                      _StilMetrics.dateLineHeight / _StilMetrics.dateFontSize,
                  fontWeight: FontWeight.w400,
                  letterSpacing: _StilMetrics.dateLetterSpacing,
                  color: AppColors.homeQuoteDate,
                ),
              ),
              const SizedBox(height: _StilMetrics.dateGap),
              Text(
                '${today.year} ｜ ${today.month.toString().padLeft(2, '0')} ｜ ${_weekdays[today.weekday % 7]}',
                style: AppTypography.homeCardDesc.copyWith(
                  fontSize: _StilMetrics.calendarFontSize,
                  height: 12 / _StilMetrics.calendarFontSize,
                  color: AppColors.homeQuoteDateMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: _StilMetrics.quoteGap),
              Text(
                '"',
                style: AppTypography.homeCardTitle.copyWith(
                  fontFamily: 'serif',
                  fontSize: _StilMetrics.quoteMarkSize,
                  height: 0.75,
                  fontWeight: FontWeight.w400,
                  color: AppColors.homeQuoteMark,
                ),
              ),
              const SizedBox(height: _StilMetrics.quoteTextGap),
              Text(
                quote,
                style: AppTypography.homeCardDesc.copyWith(
                  fontSize: _StilMetrics.quoteFontSize,
                  height: 16 / _StilMetrics.quoteFontSize,
                  fontWeight: FontWeight.w400,
                  color: AppColors.homeCardPurple,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class _StilMetrics {
  static const double cardHeight = 198;
  static const double rowGap = 10;
  static const double columnGap = 10;
  static const double radius = 28;

  static const double statusBorderWidth = 1;
  static const double statusInset = 17;
  static const double statusHeaderTop = 17;
  static const double statusHeaderHeight = 18;
  static const double statusMarkerWidth = 11;
  static const double statusMarkerHeight = 15;
  static const double statusMarkerGap = 6;
  static const double statusTitleSize = 12;
  static const double statusChipGap = 4;
  static const double statusChipHorizontal = 7;
  static const double statusChipVertical = 2;
  static const double statusChipRadius = 99;
  static const double statusChipFontSize = 8.5;
  static const double ringTop = 43;
  static const double ringSize = 118.56;
  static const double scoreFontSize = 32;

  /// 无数据时圆环内的「暂无数据」字号（比百分比小，避免撑满圆环）。
  static const double scorePlaceholderFontSize = 14;
  static const double statusFooterInset = 17;
  static const double statusFooterBottom = 9;

  static const double contentPadding = 18;
  static const double iconTopPadding = 10;
  static const double iconTileSize = 58;
  static const double iconTileRadius = 14;
  static const double iconSize = 27;
  static const double iconContentGap = 11;
  static const double titleGap = 4;
  static const double descriptionLineGap = 2;

  static const double actionIconSize = 16;
  static const double actionGap = 4;
  static const double actionFontSize = 10;
  static const double actionLetterSpacing = 0.5;

  static const double quoteBorderWidth = 5;
  static const double quoteInnerRadius = 23;
  static const double quotePaddingLeft = 12;
  static const double quotePaddingRight = 12;
  static const double quotePaddingTop = 8;
  static const double dateFontSize = 56;
  static const double dateLineHeight = 62;
  static const double dateLetterSpacing = -2;
  static const double dateGap = 2;
  static const double calendarFontSize = 8;
  static const double quoteGap = 4;
  static const double quoteMarkSize = 24;
  static const double quoteTextGap = 2;
  static const double quoteFontSize = 10;
}
