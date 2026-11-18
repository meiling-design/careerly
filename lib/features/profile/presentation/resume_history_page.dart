import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/resume_file_picker.dart';
import '../../../data/models/models.dart';
import '../../../data/models/resume_file.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/career_assets_provider.dart';
import '../state/resume_provider.dart';
import 'profile_assets_loader.dart';
import 'widgets/resume_import_sheet.dart';
import 'widgets/resume_preview_sections.dart';
import 'widgets/resume_swipe_card.dart';

/// 我的简历 —— 简历历史。
///
/// 真值来源：Figma `ResumeHistoryPage`（`src/App.tsx` L4795-4896），
/// 左滑卡 `SwipeableResumeCard`（同文件 L4438-4545），
/// 导入弹层（同文件 L4910-4994）。
///
/// ```text
/// ✅ 当前简历横幅（徽章 / 版本名 / 更新日期 / 文档块 / 三格统计）
/// ✅ 「查看详情」→ resume-detail 页
/// ✅ 「历史版本 · 左滑操作」列表（设为当前 / 删除）
/// ✅ 右下角 56×56 渐变 FAB → 「导入新简历」弹层（文件 / 拍照 / 粘贴）
/// ```
///
/// ## ⚠️ 三处按真实数据收敛的地方（Figma 是写死的示例值）
///
/// | 项 | Figma | 这里 |
/// |---|---|---|
/// | 「最高匹配 86%」 | 横幅 + 每张卡都有一格匹配度 | **整块不渲染** —— 没有匹配度字段 |
/// | 版本名 | `Resume V3` | [ResumeVersion.label]（本项目 label 本身就是版本名） |
/// | 「本次变化」 | `新增 AI Agent 项目`（按版本存于 `allVersions`） | **不渲染** —— 缺字段 |
///
/// 三者都是**缺数据**而不是缺实现（`CLAUDE.md` §7 明令不得编造
/// 「匹配度 86%」这类产品数据）。补齐需要数据层加字段，
/// 缺口已登记 `docs/05_progress/TODO.md` §3.1。
///
/// ## 「当前简历」三格的数字从哪儿来
///
/// Figma 写死 `{ skills: 12, projects: 6, experience: 4 }`（按版本），
/// 与它自己的数组长度（13 / 4 / 3）又对不上 —— **D89 家族**。
/// 本轮**从 [CareerAssets] 的计数派生**（`` `${workCount}段` `` 等），
/// 即「当前职业资产的规模」，而不是伪造一份「V3 当时的快照」。
/// ⚠️ 口径差异：**这两者不等价**，实现「按版本快照」需要数据层加字段。
///
/// ## ⚠️ 「删除」没有二次确认
///
/// Figma 的交互就是「左滑 → 点删除 → 消失」，没有确认弹窗。
/// §3.1「Figma 已明确设计交互细节」→ 采纳 Figma，**不自行加确认**
/// （加确认属于改产品规则）。⚠️ 但删除是不可逆动作，
/// 数据层接通后应重新评估是否需要确认 —— 登记为待裁决。
///
/// 另：数据层当前**不支持删除版本**（后端只有一份基线简历），
/// [ResumeProvider.deleteVersion] 会如实失败并提示，**不假装删掉**。
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
    final CareerAssets? assets = context.watch<CareerAssetsProvider>().data;

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Stack(
        children: <Widget>[
          Column(
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

                    // 归档版本 = 除当前版本以外的全部。Figma 的
                    // `archivedList` 同理，**不含**当前版本。
                    final List<ResumeVersion> archived = profile.versions
                        .where((ResumeVersion v) => v.id != current.id)
                        .toList(growable: false);

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        _ResumeHistoryMetrics.inset,
                        0,
                        _ResumeHistoryMetrics.inset,
                        // Figma `pb-24`（96）—— 为右下角 FAB 留位（L4816）。
                        _ResumeHistoryMetrics.bottom,
                      ),
                      children: <Widget>[
                        _CurrentResumeBanner(
                          version: current,
                          stats: _stats(assets),
                          onViewDetail: () => _openDetail(current),
                        ),
                        if (archived.isNotEmpty) ...<Widget>[
                          const SizedBox(
                            height: _ResumeHistoryMetrics.sectionGap,
                          ),
                          const _HistoryListHeader(),
                          const SizedBox(height: _ResumeHistoryMetrics.listGap),
                          for (int i = 0; i < archived.length; i++) ...<Widget>[
                            if (i != 0)
                              const SizedBox(
                                height: _ResumeHistoryMetrics.cardGap,
                              ),
                            ResumeSwipeCard(
                              version: archived[i],
                              onTap: () => _openDetail(archived[i]),
                              // 归档版本一律不是当前版本，故「设为当前」恒可用。
                              onSetCurrent: () => _setCurrent(archived[i]),
                              onDelete: () => _delete(archived[i]),
                            ),
                          ],
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: _ResumeHistoryMetrics.fabRight,
            bottom: _ResumeHistoryMetrics.fabBottom,
            child: _ImportFab(onTap: _onImport),
          ),
          // 导入同样走 `POST /resume` 的同步解析（最长几分钟），
          // 期间铺忙等遮罩，覆盖顶栏与 FAB，避免重复导入。
          if (provider.isUploading)
            const Positioned.fill(child: CareerlyUploadingOverlay()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 动作
  // ---------------------------------------------------------------------------

  /// 「查看详情」→ 简历详情页（`resume-detail`）。
  void _openDetail(ResumeVersion version) {
    context.push(AppRoutes.profileResumeDetail(version.id));
  }

  /// 「设为当前」。
  Future<void> _setCurrent(ResumeVersion version) async {
    final ResumeProvider provider = context.read<ResumeProvider>();
    final bool ok = await provider.setCurrentVersion(version.id);
    if (!mounted) return;
    _toast(
      ok ? '已设为当前简历' : provider.actionError?.message ?? '设置失败，请重试',
      ok ? Icons.check_circle_outline : Icons.error_outline,
    );
  }

  /// 「删除」。
  ///
  /// ⚠️ 无二次确认 —— 理由见类文档「删除没有二次确认」一节。
  Future<void> _delete(ResumeVersion version) async {
    final ResumeProvider provider = context.read<ResumeProvider>();
    final bool ok = await provider.deleteVersion(version.id);
    if (!mounted) return;
    _toast(
      ok ? '已删除该版本' : provider.actionError?.message ?? '删除失败，请重试',
      ok ? Icons.check_circle_outline : Icons.error_outline,
    );
  }

  /// FAB → 「导入新简历」弹层 → 按选择分流。
  Future<void> _onImport() async {
    final ResumeImportChoice? choice = await showResumeImportSheet(context);
    if (!mounted || choice == null) return;

    switch (choice) {
      case ResumeImportChoice.file:
        await _importFromFile();
      case ResumeImportChoice.paste:
        await _importFromText();
      case ResumeImportChoice.camera:
        // ⚠️ 相机链路尚未接入（无拍照依赖，`CLAUDE.md` §6.5 不为此新增包）。
        // 如实提示，不假装导入成功。缺口已登记 `TODO.md` §3.1。
        _toast('拍照上传尚未接入', Icons.info_outline);
    }
  }

  /// 「从文件选择」—— 选 → 校验 → 提交 → 刷新画像 → 进详情页。
  ///
  /// 与 Onboarding 提交简历页同一条链路（`onboarding_resume_page.dart`），
  /// 差别只在成功后不去 `on-parsing`，而是直接进新版本的详情页。
  Future<void> _importFromFile() async {
    final ResumeFilePicker picker = context.read<ResumeFilePicker>();
    final ResumeProvider provider = context.read<ResumeProvider>();

    final ResumeFileData? file;
    try {
      file = await picker.pick();
    } catch (error, stackTrace) {
      if (!mounted) return;
      final AppError normalized = ErrorHandler.normalize(error, stackTrace);
      _toast(normalized.message, Icons.error_outline);
      return;
    }

    // 用户取消：不是失败，不做任何提示。
    if (!mounted || file == null) return;

    // 大小上限在提交前卡（选择器无法按大小过滤）。
    if (file.exceedsLimit) {
      _toast('文件超过 10MB 上限，请更换后重试', Icons.error_outline);
      return;
    }

    final bool ok = await provider.importFile(file);
    if (!mounted) return;
    _afterImport(ok, provider);
  }

  /// 「粘贴文本」—— 收文本 → 提交 → 刷新画像 → 进详情页。
  Future<void> _importFromText() async {
    final String? text = await showResumePasteSheet(context);
    if (!mounted || text == null) return;

    final ResumeProvider provider = context.read<ResumeProvider>();
    final bool ok = await provider.importText(text);
    if (!mounted) return;
    _afterImport(ok, provider);
  }

  /// 导入成功 / 失败之后的统一收尾。
  void _afterImport(bool ok, ResumeProvider provider) {
    if (!ok) {
      _toast(provider.submitError?.message ?? '导入失败，请重试', Icons.error_outline);
      return;
    }

    // 导入成功 → 立即进入新简历的详情页。
    // 与「点击『更换简历』后立即进入我的简历详情页」是同一条产品规则
    // （产品侧 2026-10-04 指令），这里只是换了个触发入口。
    final ResumeVersion? next = provider.data?.currentVersion;
    if (next == null) {
      _toast('简历已更新', Icons.check_circle_outline);
      return;
    }
    context.push(AppRoutes.profileResumeDetail(next.id));
  }

  void _toast(String message, IconData icon) {
    CareerlyToast.show(
      context,
      message: message,
      icon: icon,
      bottomOffset: _ResumeHistoryMetrics.toastOffset,
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

/// 当前简历横幅。Figma L4819-4868。
///
/// ## ⚠️ 没有抽成共享组件
///
/// 它与工作 / 项目 / 会员三页的 Hero 同为「品牌渐变 + 装饰圆」，
/// 但内部结构完全不同（两行说明 + 文档块 + 三格统计）。
/// 「4 处 Hero 不合并」的完整理由见 `work_detail_page.dart` 的 `_WorkHero`。
class _CurrentResumeBanner extends StatelessWidget {
  const _CurrentResumeBanner({
    required this.version,
    required this.stats,
    required this.onViewDetail,
  });

  final ResumeVersion version;
  final List<_ResumeStatSpec> stats;
  final VoidCallback onViewDetail;

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
                            // Figma 是 `Resume {V3}`（L4833）——
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
                              '更新于 ${formatResumeDate(version.uploadedAt!)}',
                              style: AppTypography.onSurfaceVariant(
                                AppTypography.profileProjectRole,
                                AppColors.onBrandMuted,
                              ),
                            ),
                          ],
                          // ⚠️ Figma 在这里还有一行「本次变化」（`新增 AI Agent 项目`，
                          // L4835），它按版本存于原型的 `allVersions` 表里。
                          // [ResumeVersion] **没有**这个字段 —— 不编，故略去。
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
                const SizedBox(height: _ResumeHistoryMetrics.matchGap),
                // Figma 这条是「最高匹配 86%」+「查看详情」（L4854-4866）。
                // ⚠️ 匹配度**整块不渲染** —— 数据层没有这个字段
                // （`CLAUDE.md` §7 明令不得编造「匹配度 86%」）。
                // 只剩「查看详情」，故按 Figma 的 `justify-between` 右对齐。
                Align(
                  alignment: Alignment.centerRight,
                  child: _ViewDetailButton(onTap: onViewDetail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 「查看详情」—— Figma `#373b4d` 深色胶囊，`100×30`，圆角 20。
class _ViewDetailButton extends StatelessWidget {
  const _ViewDetailButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _ResumeHistoryMetrics.viewDetailWidth,
        height: _ResumeHistoryMetrics.viewDetailHeight,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.borderPill,
        ),
        child: const Text(
          '查看详情',
          // 14 / w600 / 白 —— 与简历详情页底部操作栏同一组合，直接复用。
          style: AppTypography.resumeDetailActionLabel,
        ),
      ),
    );
  }
}

/// 「历史版本 · 左滑操作」列表标题。Figma L4873-4875。
///
/// Figma 带 `uppercase` —— 对中文标题不产生视觉差异（中文无大小写），
/// 故 Flutter 侧不设 `TextTransform`（Flutter 也没有该属性）。
class _HistoryListHeader extends StatelessWidget {
  const _HistoryListHeader();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '历史版本 · 左滑操作',
        style: AppTypography.resumeHistoryListTitle,
      ),
    );
  }
}

/// 右下角「导入新简历」FAB。Figma L4900-4908。
///
/// `right: 20 · bottom: 28 · 56×56 · 圆形 · 品牌渐变 · 0 8 24 rgba(79,126,245,.40)`
class _ImportFab extends StatelessWidget {
  const _ImportFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CareerlyPressFeedback(
      onTap: onTap,
      pressedScale: _ResumeHistoryMetrics.fabPressScale,
      child: Container(
        width: _ResumeHistoryMetrics.fabSize,
        height: _ResumeHistoryMetrics.fabSize,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
          shape: BoxShape.circle,
          boxShadow: AppShadows.resumeFab,
        ),
        child: const Icon(
          Icons.add,
          size: _ResumeHistoryMetrics.fabIcon,
          color: AppColors.textInverse,
        ),
      ),
    );
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

/// 「当前简历」徽章。Figma L4826-4829。
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

/// 横幅右侧的文档图标块。Figma L4838-4840。
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
        // Figma 是「文档 + 三条横线」的描边 SVG（L4839），
        // 依 D58 用 Material 字形近似。
        Icons.description_outlined,
        size: _ResumeHistoryMetrics.docIcon,
        color: AppColors.surface,
      ),
    );
  }
}

/// 一格统计。Figma L4845-4850。
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

  /// Figma `pb-24` —— 为右下角 FAB 留位（L4816）。
  static const double bottom = 96;

  /// Figma `space-y-5`（横幅与「历史版本」段之间）。
  static const double sectionGap = 20;

  /// Figma `mb-3`（列表标题与卡片之间）。
  static const double listGap = 12;

  /// Figma `space-y-2.5`（卡片之间）。
  static const double cardGap = 10;

  // ── 横幅（Figma L4819-4868）────────────────────────────────────────
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

  /// Figma `mb-4`（统计行与「匹配 / 查看详情」行之间）。
  static const double matchGap = 16;

  /// Figma：`width: 100` / `height: 30` / `borderRadius: 20`。
  static const double viewDetailWidth = 100;
  static const double viewDetailHeight = 30;

  // ── FAB（Figma L4900-4908）────────────────────────────────────────
  static const double fabSize = 56;
  static const double fabRight = 20;
  static const double fabBottom = 28;

  /// Figma：`+` 图标 `22×22`。
  static const double fabIcon = 22;

  /// Figma FAB 的按压是 `active:scale-90`（0.90），
  /// 比全局通用按压比例更浅 —— 故显式传入，不用默认值。
  static const double fabPressScale = 0.9;

  /// 提示的贴底距离（工程取值，非设计值）。
  static const double toastOffset = 96;
}
