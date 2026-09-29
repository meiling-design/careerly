import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/career_assets_provider.dart';
import 'profile_assets_loader.dart';

/// 奖项页。
///
/// 真值来源：Figma `AwardsPage`（`src/App.tsx` L3838-3863）。
///
/// ```text
/// TopBar「奖项」+ 右侧「N 项」                 L3841
/// 列表 px-5 pb-6 space-y-3                    L3842
///   └ Card p-5（每条荣誉一张）                  L3844-3860
///       左：48×48 圆角 16 图标底板（🏆 22px）    L3847-3849
///       右：荣誉名 15/w700 + 年份胶囊            L3851-3853
///           颁发机构 12px                       L3854
///           一句话说明 12px leading-relaxed      L3855
/// ```
///
/// ## 归属
///
/// IA §13「职业资产 → 奖项」/ §21「技能 · 能力 → 我的」。
///
/// ## ⚠️ 本页是 `Award.description` 得以进入模型的原因
///
/// 原型里每条荣誉都带 `desc`，但它**只被本页渲染**（L3855）——
/// 职业资产页的荣誉成果分组只画 `name` / `year` / `org`（L3575-3576）。
/// 因此本文件落地之前，`description` 被有意略去（理由记在当时尚未有消费方的
/// `demo_fixture.dart` 里）。本页出现后该理由不再成立，
/// 三条说明已**逐字照抄原型**补回 —— 是原型已有的内容，不是本轮编造。
/// 详见 [Award.description] 的字段说明。
///
/// ## 四态（`CLAUDE.md` §5.5）
///
/// 由 [CareerlyAsyncStateView] 统一承载 Loading / Empty / Error / Retry；
/// 数据为空时整页走 Empty，**不**渲染空的卡片骨架。
class AwardsPage extends StatefulWidget {
  const AwardsPage({super.key});

  @override
  State<AwardsPage> createState() => _AwardsPageState();
}

class _AwardsPageState extends State<AwardsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ensureCareerAssetsLoaded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final CareerAssetsProvider provider = context.watch<CareerAssetsProvider>();

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(
            title: '奖项',
            onBack: () => careerlyBack(context),
            // ⚠️ 计数只在**数据到位后**显示。
            // 未加载时列表为空，直接取 `length` 会让 Loading 期间显示
            // `0 项` —— 即把「还没到」说成「没有」。Empty 态照实写 `0 项`，
            // 与批 1 的工作经历页同一口径。
            trailing: provider.data == null
                ? null
                : Text(
                    '${provider.awards.length} 项',
                    style: AppTypography.profileTopBarTrailing,
                  ),
          ),
          Expanded(
            child: CareerlyAsyncStateView<CareerAssets>(
              state: provider.state,
              isEmpty: (CareerAssets assets) => assets.awards.isEmpty,
              onRetry: provider.load,
              loadingMessage: '正在读取奖项',
              emptyTitle: '还没有荣誉成果',
              emptyMessage: '提交简历并完成职业基线后，这里会显示你获得的奖项与荣誉',
              builder: (BuildContext context, CareerAssets assets) =>
                  _AwardList(items: assets.awards),
            ),
          ),
        ],
      ),
    );
  }
}

/// 奖项列表。
class _AwardList extends StatelessWidget {
  const _AwardList({required this.items});

  final List<Award> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        _AwardsMetrics.inset,
        0,
        _AwardsMetrics.inset,
        _AwardsMetrics.bottom,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: _AwardsMetrics.gap),
      itemBuilder: (BuildContext context, int index) =>
          _AwardCard(item: items[index]),
    );
  }
}

/// 一条荣誉卡。Figma L3844-3860。
///
/// 卡上**没有点击行为** —— 原型里这张卡既没有 `onClick`、也没有对应详情页，
/// 因此这里用不带 `onTap` 的 [GlassSurface]（它不会渲染点击反馈与涟漪）。
class _AwardCard extends StatelessWidget {
  const _AwardCard({required this.item});

  final Award item;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_AwardsMetrics.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: _AwardsMetrics.tileSize,
            height: _AwardsMetrics.tileSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.profileAwardTileFill,
              borderRadius: AppRadius.borderMd,
            ),
            // Figma 这里就是一个 `🏆` 字符（L3849），不是 SVG ——
            // 因此照原样用字符渲染，与职业资产卡的 `⭐` 同一处置。
            child: const Text('🏆', style: AppTypography.profileAwardGlyph),
          ),
          const SizedBox(width: _AwardsMetrics.tileGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // 名与年份胶囊同排：名过长时**名先收缩**，胶囊不被挤走。
                    Flexible(
                      child: Text(
                        item.name,
                        style: AppTypography.profileAwardName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.year.isNotEmpty) ...<Widget>[
                      const SizedBox(width: _AwardsMetrics.nameYearGap),
                      _YearChip(year: item.year),
                    ],
                  ],
                ),
                if (item.org.isNotEmpty) ...<Widget>[
                  const SizedBox(height: _AwardsMetrics.yearOrgGap),
                  Text(
                    item.org,
                    style: AppTypography.profileAwardMeta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (item.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: _AwardsMetrics.orgDescGap),
                  Text(
                    item.description,
                    style: AppTypography.profileAwardDescription,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 年份胶囊。Figma L3853：
/// `11px / w600` + `px-2 py-0.5` + `rounded-full` +
/// `rgba(255,149,0,0.12)` 底 + `#FF9500` 字。
///
/// ⚠️ 底板 `0.12` 与图标底板的 `0.10` **不同**（[AppColors.profileAwardTileFill]）——
/// 两者在同一张卡上左右相邻，不可统一。
class _YearChip extends StatelessWidget {
  const _YearChip({required this.year});

  final String year;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _AwardsMetrics.chipPaddingH,
        vertical: _AwardsMetrics.chipPaddingV,
      ),
      decoration: const BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(year, style: AppTypography.profileAwardYearChip),
    );
  }
}

/// 奖项页的内部几何（Figma 逐条内联给出）。
///
/// ⚠️ **颜色 / 字号 / 字体族 / 圆角 / 动画时长一律走 Token**
/// （`CLAUDE.md` §8.2 的硬规则），本类只放宽高与内边距。
abstract final class _AwardsMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 12;

  static const double cardPadding = 20;

  /// 图标底板 `48×48` + `rounded-2xl`（16）（Figma L3848）。
  static const double tileSize = 48;
  static const double tileGap = 12;

  static const double nameYearGap = 8;

  /// 名/年份行与机构行 `mb-0.5`（2）（Figma L3851）。
  static const double yearOrgGap = 2;

  /// 机构行与说明行 `mb-1`（4）（Figma L3854）。
  static const double orgDescGap = 4;

  /// 年份胶囊 `px-2 py-0.5`（Figma L3853）。
  static const double chipPaddingH = 8;
  static const double chipPaddingV = 2;
}
