import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/career_assets_provider.dart';
import '../state/resume_provider.dart';
import 'profile_assets_loader.dart';

/// 我的简历 —— 简历历史。
///
/// 真值来源：Figma `ResumeHistoryPage`（`src/App.tsx` L4479-4600）。
///
/// ## ⚠️ 批 1 只交付**当前简历横幅**，其余属批 3
///
/// ```text
/// ✅ 已交付  当前简历横幅（徽章 / 版本名 / 更新日期 / 文档块 / 三格统计）
/// ⬜ 批 3    「最高匹配」行与「查看详情」按钮
///            「历史版本 · 左滑操作」列表 + 滑动操作
///            右下角新建 FAB + 导入 Bottom Sheet
///            （`resume-detail` 页面本身也属批 3）
/// ```
///
/// 为什么切在这里：Figma 的「最高匹配」是**按版本**存的
/// （`allVersions[V3].match = '86%'`，L4493-4497），而
/// [ResumeVersion] **没有**匹配度字段；`resume-detail` 也还没有页面。
/// 硬造一个「当前简历的最高匹配」等于编产品数据（`CLAUDE.md` §7）。
///
/// ## 「当前简历」三格的数字从哪儿来
///
/// Figma 写死 `{ skills: 12, projects: 6, experience: 4 }`（按版本），
/// 与它自己的数组长度（13 / 4 / 3）又对不上 —— **D89 家族**。
/// 本轮**从 [CareerAssets] 的计数派生**（`` `${workCount}段` `` 等），
/// 即「当前职业资产的规模」，而不是伪造一份「V3 当时的快照」。
/// ⚠️ 口径差异已在交付报告中声明：**这两者不等价**，
/// 实现「按版本快照」需要数据层加字段（批 3 一并处理）。
class ResumeHistoryPage extends StatefulWidget {
  const ResumeHistoryPage({super.key});

  @override
  State<ResumeHistoryPage> createState() => _ResumeHistoryPageState();
}

class _ResumeHistoryPageState extends State<ResumeHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ensureCareerAssetsLoaded(context);
      final ResumeProvider provider = context.read<ResumeProvider>();
      if (provider.data == null && !provider.isLoading) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ResumeProvider provider = context.watch<ResumeProvider>();
    final CareerAssets? assets = context
        .watch<CareerAssetsProvider>()
        .data;

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(
            title: '我的简历',
            onBack: () => careerlyBack(context),
          ),
          Expanded(
            child: CareerlyAsyncStateView<ResumeProfile>(
              state: provider.state,
              isEmpty: (ResumeProfile profile) => profile.isEmpty,
              onRetry: provider.load,
              loadingMessage: '正在读取简历',
              emptyTitle: '还没有简历',
              emptyMessage: '提交第一份简历后，每次更新都会留下一个版本',
              builder: (BuildContext context, ResumeProfile profile) {
                final ResumeVersion? current = profile.currentVersion;
                if (current == null) return const SizedBox.shrink();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    _ResumeHistoryMetrics.inset,
                    0,
                    _ResumeHistoryMetrics.inset,
                    // ⚠️ Figma 是 `pb-24`（96），为右下角的新建 FAB 留位（L4499）。
                    // 批 1 没有 FAB，故用常规的 24；
                    // 批 3 补 FAB 时**必须**同时把这个值改回 96，
                    // 否则最后一屏会被 FAB 压住。
                    _ResumeHistoryMetrics.bottom,
                  ),
                  children: <Widget>[
                    _CurrentResumeBanner(
                      version: current,
                      stats: _stats(assets),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 三格统计。
  ///
  /// 数据源见类顶说明 —— 取**当前职业资产**的计数，不是某个版本的历史快照。
  static List<_ResumeStatSpec> _stats(CareerAssets? assets) {
    return <_ResumeStatSpec>[
      _ResumeStatSpec(
        value: '${assets?.workCount ?? 0}',
        label: '段经历',
      ),
      _ResumeStatSpec(
        value: '${assets?.projectCount ?? 0}',
        label: '个项目',
      ),
      _ResumeStatSpec(
        value: '${assets?.skillCount ?? 0}',
        label: '项技能',
      ),
    ];
  }
}

/// 当前简历横幅。Figma L4500-4551。
///
/// ## ⚠️ 没有抽成共享组件
///
/// 它与工作 / 项目 / 会员三页的 Hero 同为「品牌渐变 + 装饰圆」，
/// 但内部结构完全不同（两行说明 + 文档块 + 三格统计）。
/// 「4 处 Hero 不合并」的完整理由见 `work_detail_page.dart` 的 `_WorkHero`。
class _CurrentResumeBanner extends StatelessWidget {
  const _CurrentResumeBanner({required this.version, required this.stats});

  final ResumeVersion version;
  final List<_ResumeStatSpec> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.borderXl,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _ResumeHistoryMetrics.circleTopOffset,
            right: _ResumeHistoryMetrics.circleTopOffset,
            child: const _HeroCircle(size: _ResumeHistoryMetrics.circleLarge),
          ),
          Positioned(
            bottom: _ResumeHistoryMetrics.circleBottomOffset,
            left: _ResumeHistoryMetrics.circleBottomOffset,
            child: const _HeroCircle(size: _ResumeHistoryMetrics.circleSmall),
          ),
          Padding(
            padding: const EdgeInsets.all(_ResumeHistoryMetrics.heroPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _CurrentBadge(),
                const SizedBox(height: _ResumeHistoryMetrics.badgeGap),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            // Figma 是 `Resume {V3}`（L4517）——
                            // 「Resume」只是它给版本名加的前缀，
                            // 而本项目的 [ResumeVersion.label] **本身就是版本名**
                            // （见 `analysis_page.dart` 的用法）。
                            // 再加一次前缀会得到「Resume 2026 春招版」，故不加。
                            version.label,
                            style: AppTypography.profileHeroTitle,
                          ),
                          if (version.uploadedAt != null) ...<Widget>[
                            const SizedBox(
                              height: _ResumeHistoryMetrics.dateGap,
                            ),
                            Text(
                              '更新于 ${_formatDate(version.uploadedAt!)}',
                              style: AppTypography.onSurfaceVariant(
                                AppTypography.profileProjectRole,
                                AppColors.onBrandMuted,
                              ),
                            ),
                          ],
                          // ⚠️ Figma 在这里还有一行「本次变化」（`新增 AI Agent 项目`，
                          // L4519），它按版本存于原型的 `allVersions` 表里。
                          // [ResumeVersion] **没有**这个字段 —— 不编，故略去。
                          // 缺字段问题随「历史版本」列表一并留到批 3。
                        ],
                      ),
                    ),
                    const SizedBox(width: _ResumeHistoryMetrics.titleDocGap),
                    const _ResumeDocTile(),
                  ],
                ),
                const SizedBox(height: _ResumeHistoryMetrics.statsGap),
                Row(
                  children: <Widget>[
                    for (int i = 0; i < stats.length; i++) ...<Widget>[
                      Expanded(child: _ResumeStatTile(stat: stats[i])),
                      if (i != stats.length - 1)
                        const SizedBox(width: _ResumeHistoryMetrics.statGap),
                    ],
                  ],
                ),
                // ⬜ 「最高匹配 / 查看详情」一行属批 3 —— 见类顶说明。
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// `2026.08.27`。手写格式化，与 `analysis_page.dart` / `growth_record_page.dart`
  /// 同一格式（项目没有 `intl` 依赖，`CLAUDE.md` §6.5）。
  static String _formatDate(DateTime at) {
    final String month = at.month.toString().padLeft(2, '0');
    final String day = at.day.toString().padLeft(2, '0');
    return '${at.year}.$month.$day';
  }
}

/// 横幅上的装饰圆。透明度合并说明见 [AppColors.profileHeroDecoration]。
class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.profileHeroDecoration,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 「当前简历」徽章。Figma L4510-4513。
class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _ResumeHistoryMetrics.badgePaddingH,
          vertical: _ResumeHistoryMetrics.badgePaddingV,
        ),
        decoration: const BoxDecoration(
          // Figma `rgba(255,255,255,0.20)` —— 与 [AppColors.onBrandSurface] 同值，
          // 直接复用。
          color: AppColors.onBrandSurface,
          borderRadius: AppRadius.borderPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: _ResumeHistoryMetrics.badgeDot,
              height: _ResumeHistoryMetrics.badgeDot,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: _ResumeHistoryMetrics.badgeDotGap),
            Text(
              '当前简历',
              // 11 / w600 —— 与页面段里的品牌 Chip 标签同一组合，
              // 只把颜色换成白色（`CLAUDE.md` §8.2：字号字重走 Token，
              // 颜色换肤走 `onSurfaceVariant`）。
              style: AppTypography.onSurfaceVariant(
                AppTypography.profileBrandChipLabel,
                AppColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 横幅右侧的文档图标块。Figma L4525-4530。
class _ResumeDocTile extends StatelessWidget {
  const _ResumeDocTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _ResumeHistoryMetrics.docTile,
      height: _ResumeHistoryMetrics.docTile,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        // Figma `rgba(255,255,255,0.18)`。
        color: AppColors.profileOnBrandTileStrong,
        borderRadius: AppRadius.borderSm,
      ),
      child: const Icon(
        // Figma 是「文档 + 三条横线」的描边 SVG（L4529），
        // 依 D58 用 Material 字形近似。
        Icons.description_outlined,
        size: _ResumeHistoryMetrics.docIcon,
        color: AppColors.surface,
      ),
    );
  }
}

/// 一格统计。Figma L4534-4540。
class _ResumeStatTile extends StatelessWidget {
  const _ResumeStatTile({required this.stat});

  final _ResumeStatSpec stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: _ResumeHistoryMetrics.statPaddingV,
      ),
      decoration: const BoxDecoration(
        color: AppColors.profileOnBrandTileFill,
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        children: <Widget>[
          Text(stat.value, style: AppTypography.profileResumeStatValue),
          const SizedBox(height: _ResumeHistoryMetrics.statLabelGap),
          Text(stat.label, style: AppTypography.profileResumeStatLabel),
        ],
      ),
    );
  }
}

/// 一格统计的数据。
class _ResumeStatSpec {
  const _ResumeStatSpec({required this.value, required this.label});

  final String value;
  final String label;
}

// ---------------------------------------------------------------------------
// 页面几何
// ---------------------------------------------------------------------------

/// 简历历史页的内部几何（Figma 逐条内联给出）。
abstract final class _ResumeHistoryMetrics {
  static const double inset = 20;
  static const double bottom = 24;

  // ── 横幅（Figma L4501-4546）────────────────────────────────────────
  static const double heroPadding = 20;
  static const double circleLarge = 144;
  static const double circleSmall = 112;
  static const double circleTopOffset = -40;
  static const double circleBottomOffset = -32;

  static const double badgePaddingH = 12;
  static const double badgePaddingV = 4;
  static const double badgeDot = 6;
  static const double badgeDotGap = 6;
  static const double badgeGap = 16;

  static const double titleDocGap = 12;
  static const double dateGap = 4;
  static const double docTile = 48;
  static const double docIcon = 22;

  static const double statsGap = 16;
  static const double statGap = 12;
  static const double statPaddingV = 10;
  static const double statLabelGap = 2;
}
