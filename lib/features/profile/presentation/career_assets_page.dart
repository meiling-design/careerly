import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/career_assets_provider.dart';
import 'profile_assets_loader.dart';

/// 职业资产页。
///
/// 真值来源：Figma `CareerAssetsPage`（`src/App.tsx` L3342-3634）。
///
/// ## 结构
///
/// ```text
/// 顶栏         玻璃圆返回钮 + 22px 居中标题「职业资产」      L3482-3491
/// 说明句       「AI 对你的简历和职业经历的持续记录与分析。」 L3494
/// 分组卡 ×4    工作经历 / 项目经历 / 专业技能 / 荣誉成果      L3498-3614
///              每张可展开 —— 展开后在卡内浮出一层磨砂面板
/// 能力画像卡   进度条 + 3 条 SkillBar + 底部「5 个维度」      L3588-3633
/// ```
///
/// ## 与详情页的关系
///
/// 四张分组卡的展开面板里，每一行都能直接进详情
/// （经历详情 / 项目详情）。**面板行与分组卡的「查看全部」是两条不同的路径**：
///
/// ```text
/// 点卡片主体   → 展开 / 收起（本页状态，不跳转）
/// 点面板里的一行 → 进该条的详情页
/// 点「查看全部」 → 进该分组的列表页
/// ```
///
/// ## ✅ 本轮的一处**收缩已解除**
///
/// | # | Figma | 本页（本轮起） |
/// |---|---|---|
/// | 1 | 专业技能 / 荣誉成果的「查看全部」跳各自的列表页 | **已接通** —— [AppRoutes.profileSkills] / [AppRoutes.profileAwards] 与能力页均已建立 |
///
/// 这三处入口此前为 `null`（按钮不渲染或不可点），理由是「落点页属批 2、
/// 尚未建立，指过去是死链」。批 2 落地后**收缩解除**，
/// 四个分组 + 能力画像卡现在都有真实的落点。
///
/// ## ⚠️ 仍在的一处偏离
///
/// | # | Figma | 本页 | 理由 |
/// |---|---|---|---|
/// | 2 | 能力画像条的宽度写死 `91% / 76% / 78%` | 由 `score` 派生 | Figma 的 `91%` 与它自己的 `score 85` 对不上（见下） |
///
/// 第 2 条与 Figma 在别处硬编码派生的计数是同一类问题
/// （**待裁决 · D89**，`docs/05_progress/TODO.md` §3.1）—— 本页同样选择「派生」，
/// 因为写死会让条宽与数据脱钩。
///
/// ## 四态（`CLAUDE.md` §5.5）
///
/// 由 [CareerlyAsyncStateView] 统一承载 Loading / Error / Retry；
/// **空数据不进入 Empty**（D99 规则，2026-09-29 产品侧确认）：
/// 四张分组卡 + 能力卡是固定骨架，始终渲染 —— 计数如实显示 0，
/// 组内与卡内空数据换成人话（见 [_AssetGroup.emptyLabel] /
/// [_AssetsCopy.capabilityCardEmpty]）。
class CareerAssetsPage extends StatefulWidget {
  const CareerAssetsPage({super.key});

  @override
  State<CareerAssetsPage> createState() => _CareerAssetsPageState();
}

class _CareerAssetsPageState extends State<CareerAssetsPage> {
  /// 当前展开的分组键。`null` = 全部收起。
  ///
  /// ⚠️ 这是**本页状态**，与 Figma 的 `useState<string | null>` 一一对应 ——
  /// 同一时刻只允许展开一张卡（点另一张会收起前一张）。
  String? _expanded;

  @override
  void initState() {
    super.initState();
    // 「我的」主页通常已经取过；深链直达本页时补一次。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ensureCareerAssetsLoaded(context);
    });
  }

  void _toggle(String key) {
    setState(() => _expanded = _expanded == key ? null : key);
  }

  @override
  Widget build(BuildContext context) {
    final CareerAssetsProvider provider = context
        .watch<CareerAssetsProvider>();

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(
            title: '职业资产',
            style: CareerlyTopBarStyle.glassCircle,
            onBack: () => careerlyBack(context),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              _AssetsMetrics.pageInset + _AssetsMetrics.listInset,
              _AssetsMetrics.subtitleTop,
              _AssetsMetrics.pageInset + _AssetsMetrics.listInset,
              _AssetsMetrics.subtitleBottom,
            ),
            child: Text(
              _AssetsCopy.subtitle,
              style: AppTypography.profilePageSubtitle,
            ),
          ),
          Expanded(
            child: CareerlyAsyncStateView<CareerAssets>(
              state: provider.state,
              onRetry: provider.load,
              loadingMessage: '正在读取职业资产',
              // D99 规则在职业资产域的落地（2026-09-29 产品侧确认）：
              // 四张分组卡 + 能力卡是**固定骨架**（职业资产域的「日历网格」），
              // 空数据时不消失 —— 计数如实显示 0，组内文案换成人话；
              // 因此这里**不设 isEmpty 门禁**，Success 一律渲染骨架。
              builder: (BuildContext context, CareerAssets assets) =>
                  _buildContent(assets, provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CareerAssets assets, CareerAssetsProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _AssetsMetrics.pageInset,
        0,
        _AssetsMetrics.pageInset,
        _AssetsMetrics.pageBottom,
      ),
      children: <Widget>[
        for (final _AssetGroup group in _AssetGroup.values) ...<Widget>[
          _AssetGroupCard(
            group: group,
            assets: assets,
            expanded: _expanded == group.key,
            onToggle: () => _toggle(group.key),
            panel: _buildPanel(group, assets),
          ),
          const SizedBox(height: _AssetsMetrics.cardGap),
        ],
        _CapabilityCard(
          preview: provider.capabilityPreview,
          all: provider.capabilities,
        ),
      ],
    );
  }

  /// 构造某个分组的展开面板内容。
  ///
  /// 「查看全部」的落点由 [_AssetGroup.listRoute] 给出；为 `null` 时
  /// **不渲染**该按钮。四个分组当前**都有落点**，因此这道判断目前恒为真 ——
  /// 保留它是为了让「某组暂时没有列表页」这种状态仍然可表达，
  /// 而不是每个分组都必须造一个页面出来。
  ///
  /// 组内为空时不再渲染空面板，而是给一句组内空文案（D99 规则：
  /// 骨架常驻、空数据换文字），与对应列表页的空态口径一致。
  Widget _buildPanel(_AssetGroup group, CareerAssets assets) {
    if (group.emptyOf(assets)) {
      return Padding(
        padding: const EdgeInsets.only(top: _AssetsMetrics.panelRowGap),
        child: Text(group.emptyLabel, style: AppTypography.profileSmallMeta),
      );
    }
    return switch (group) {
      _AssetGroup.work => _WorkPanel(items: assets.workExperiences),
      _AssetGroup.projects => _ProjectPanel(items: assets.projects),
      _AssetGroup.skills => _SkillPanel(names: assets.skillNames),
      _AssetGroup.awards => _AwardPanel(items: assets.awards),
    };
  }
}

// ---------------------------------------------------------------------------
// 分组定义
// ---------------------------------------------------------------------------

/// 职业资产页的四张分组卡。
///
/// 每张卡的视觉差异（底色 / 标题色 / 计数色 / 图标色）在 Figma 里是
/// **逐卡写死**的（`ASSETS` 数组，L3399-3455），没有一个统一规则可以推导。
/// 因此这里把它们收成枚举 —— 让「四张卡是四个特例」这件事显式可见，
/// 而不是在四个地方各写一遍。
enum _AssetGroup {
  /// 工作经历。深色卡 `#373b4d`。
  work(
    key: 'work',
    label: '工作经历',
    icon: Icons.work_outline,
    iconInk: AppColors.textPrimary,
    titleColor: AppColors.textInverse,
    titleMedium: false,
    listRoute: AppRoutes.profileWorkExperience,
  ),

  /// 项目经历。浅色卡 `#f1f2f6`。
  projects(
    key: 'projects',
    label: '项目经历',
    icon: Icons.grid_view_outlined,
    iconInk: AppColors.profileIconInk,
    titleColor: AppColors.profileTitleInk,
    titleMedium: false,
    listRoute: AppRoutes.profileProjects,
  ),

  /// 专业技能。品牌渐变卡。
  skills(
    key: 'skills',
    label: '专业技能',
    icon: Icons.star_border_rounded,
    iconInk: AppColors.profileSkillIconInk,
    titleColor: AppColors.textInverse,
    titleMedium: false,
    listRoute: AppRoutes.profileSkills,
  ),

  /// 荣誉成果。紫色卡 `#c3aff1`，标题字重被显式降到 `w500`。
  awards(
    key: 'awards',
    label: '荣誉成果',
    icon: Icons.emoji_events_outlined,
    iconInk: AppColors.profileAwardAccent,
    titleColor: AppColors.textInverse,
    titleMedium: true,
    listRoute: AppRoutes.profileAwards,
  );

  const _AssetGroup({
    required this.key,
    required this.label,
    required this.icon,
    required this.iconInk,
    required this.titleColor,
    required this.titleMedium,
    required this.listRoute,
  });

  /// 展开状态的键。
  final String key;

  /// 卡上的大标题。
  final String label;

  /// 白色圆钮里的图标。
  ///
  /// ⚠️ Figma 每张卡各画了一套描边 SVG（公文包 / 四宫格 / 五角星 / 奖杯）。
  /// 依 **D58** 先例（不新建图标资源，用 Material 字形近似）取上述字形。
  final IconData icon;

  /// 图标描边色。Figma 逐卡给出（`#111827` / `#201E22` / `#7B5CCC` / `#C44B8A`）。
  final Color iconInk;

  /// 大标题颜色。
  final Color titleColor;

  /// 是否用 `w500`（仅荣誉成果卡为真）。
  final bool titleMedium;

  /// 「查看全部」的落点。为 `null` 时该按钮不渲染。
  final String? listRoute;

  /// 该分组在数据为空时展示的组内空文案（D99 规则：骨架常驻、换文字）。
  ///
  /// 与对应列表页的 `emptyTitle` 同口径（「还没有 / 暂无 + 资产名」），
  /// 但面板空间小，用「暂无 ××」短句。
  String get emptyLabel => switch (this) {
        _AssetGroup.work => '暂无工作经历',
        _AssetGroup.projects => '暂无项目经历',
        _AssetGroup.skills => '暂无技能',
        _AssetGroup.awards => '暂无荣誉成果',
      };

  /// 该分组的数据是否为空。
  bool emptyOf(CareerAssets assets) => switch (this) {
        _AssetGroup.work => assets.workExperiences.isEmpty,
        _AssetGroup.projects => assets.projects.isEmpty,
        _AssetGroup.skills => assets.skillNames.isEmpty,
        _AssetGroup.awards => assets.awards.isEmpty,
      };
}

// ---------------------------------------------------------------------------
// 分组卡
// ---------------------------------------------------------------------------

/// 一张可展开的分组卡。Figma L3500-3612。
class _AssetGroupCard extends StatelessWidget {
  const _AssetGroupCard({
    required this.group,
    required this.assets,
    required this.expanded,
    required this.onToggle,
    required this.panel,
  });

  final _AssetGroup group;
  final CareerAssets assets;
  final bool expanded;
  final VoidCallback onToggle;

  /// 展开后的面板内容（不含底部的「查看全部」）。
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    final bool onDark = group.titleColor == AppColors.textInverse;
    final Color dateColor = onDark
        ? AppColors.profileOnDarkMuted
        : AppColors.profileInkMuted;
    final Color clockInk = onDark
        ? AppColors.textInverse
        : AppColors.profileInkDeep;

    return Container(
      // ⚠️ 四张卡的底色 / 投影各不相同，且工作与专业技能两张卡有投影、
      // 另两张没有 —— 逐卡给出，不归纳。
      decoration: _decorationOf(group),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(_AssetsMetrics.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Figma 给标题写死 `width: 200`，但它在 flex 里可收缩
                      // （右组才是 `flex-shrink-0`）。360dp 屏上可用宽度不足 200，
                      // 因此这里用 Expanded 等价表达「标题占满剩余、不够就换行」。
                      Expanded(
                        child: Text(
                          group.label,
                          style: group.titleMedium
                              ? AppTypography.profileAssetGroupTitleMedium
                              : AppTypography.profileAssetGroupTitle,
                        ),
                      ),
                      const SizedBox(width: _AssetsMetrics.titleCountGap),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _countLabel(group, assets),
                            style: AppTypography.onSurfaceVariant(
                              AppTypography.profileAssetGroupCount,
                              _countColor(group),
                            ),
                            maxLines: 1,
                          ),
                          const SizedBox(
                            width: _AssetsMetrics.countArrowGap,
                          ),
                          _ArrowCircle(icon: group.icon, iconInk: group.iconInk),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: _AssetsMetrics.cardRowGap),
                  Row(
                    children: <Widget>[
                      if (assets.spanLabel.isNotEmpty) ...<Widget>[
                        Icon(
                          Icons.schedule,
                          size: _AssetsMetrics.clockIcon,
                          color: clockInk,
                        ),
                        const SizedBox(width: _AssetsMetrics.clockGap),
                        Text(
                          assets.spanLabel,
                          style: AppTypography.onSurfaceVariant(
                            AppTypography.profileAssetGroupDate,
                            dateColor,
                          ),
                          maxLines: 1,
                        ),
                      ],
                      const Spacer(),
                      _ViewAllPill(dark: !onDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...<Widget>[
            _FrostPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  panel,
                  if (group.listRoute != null) ...<Widget>[
                    const SizedBox(height: _AssetsMetrics.panelFooterGap),
                    _PanelFooterAction(
                      label: '查看全部',
                      onTap: () => context.push(group.listRoute!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 卡片底色 / 投影。逐卡对应 Figma `ASSETS[].cardStyle`（L3402-3455）。
  static BoxDecoration _decorationOf(_AssetGroup group) {
    return switch (group) {
      _AssetGroup.work => const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.borderXl,
        boxShadow: AppShadows.profileNeutralCard,
      ),
      _AssetGroup.projects => const BoxDecoration(
        color: AppColors.profilePanelFill,
        borderRadius: AppRadius.borderXl,
      ),
      _AssetGroup.skills => const BoxDecoration(
        gradient: AppColors.profileSkillsCardGradient,
        borderRadius: AppRadius.borderXl,
        boxShadow: AppShadows.profileBrandCard,
      ),
      _AssetGroup.awards => const BoxDecoration(
        color: AppColors.profileAwardCardFill,
        borderRadius: AppRadius.borderXl,
      ),
    };
  }

  /// 计数色。Figma 逐卡给出（`#a2d84c` / `#171827` / `#1e1f22` / `#1e1f22`）。
  static Color _countColor(_AssetGroup group) => switch (group) {
    _AssetGroup.work => AppColors.profileAccentLime,
    _AssetGroup.projects => AppColors.profileTitleInk,
    _AssetGroup.skills => AppColors.profileInkDeep,
    _AssetGroup.awards => AppColors.profileInkDeep,
  };

  /// 右侧计数文案。
  ///
  /// ⚠️ 一律**从数据派生**，不照抄 Figma 的字符串：
  ///
  /// | 卡 | Figma | 派生结果 |
  /// |---|---|---|
  /// | 工作经历 | `${WORK_EXP.length} 段职业经历` | ✅ 同 |
  /// | 项目经历 | `${PROJECTS_DATA.length} 个项目经历` | ✅ 同 |
  /// | 专业技能 | 写死 `'12项目技能'` | ❌ 原型**写死且语句不通** |
  /// | 荣誉成果 | `${AWARDS.length} 项荣誉记录` | ✅ 同 |
  ///
  /// 技能卡的 `12项目技能` 与数组长度 13 也对不上（**待裁决 · D89**）。
  /// 本轮统一写成 `N 项技能` —— 既与数据一致，也修掉了原型的语句问题。
  /// ⚠️ 这属于**文案微调**，需产品侧在验收时确认。
  static String _countLabel(_AssetGroup group, CareerAssets assets) {
    return switch (group) {
      _AssetGroup.work => '${assets.workCount} 段职业经历',
      _AssetGroup.projects => '${assets.projectCount} 个项目经历',
      _AssetGroup.skills => '${assets.skillCount} 项技能',
      _AssetGroup.awards => '${assets.awardCount} 项荣誉记录',
    };
  }
}

/// 分组卡右上角的白色圆钮（内含分组图标）。Figma 的 `ArrowCircle`（L3370）。
class _ArrowCircle extends StatelessWidget {
  const _ArrowCircle({required this.icon, required this.iconInk});

  final IconData icon;
  final Color iconInk;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _AssetsMetrics.arrowCircleSize,
      height: _AssetsMetrics.arrowCircleSize,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: _AssetsMetrics.arrowCircleIcon,
        color: iconInk,
      ),
    );
  }
}

/// 分组卡上的磨砂「查看全部」胶囊。Figma 的 `ViewAllPill`（L3358-3364）。
///
/// ⚠️ 与「我的」主页资产卡上那个 `_ViewAllPill` **不是同一个组件** ——
/// 那个是圆角 22、无描边、带雪佛龙（Figma L3229）；
/// 这个是圆角 12、**1px 白描边**、无图标（Figma L3360）。
/// 两者分属两页，各自持名（同 `profileBackIconInk` 的处置原则）。
class _ViewAllPill extends StatelessWidget {
  const _ViewAllPill({required this.dark});

  /// 浅色卡上文字用 `#171827`，深色 / 彩色卡上用白色（Figma L3362）。
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _AssetsMetrics.viewAllPaddingH,
        vertical: _AssetsMetrics.viewAllPaddingV,
      ),
      decoration: const BoxDecoration(
        color: AppColors.profileViewAllPillFill,
        borderRadius: AppRadius.borderXs,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.surface),
        ),
      ),
      child: Text(
        '查看全部',
        style: AppTypography.onSurfaceVariant(
          AppTypography.profileViewAllPillLabel,
          dark ? AppColors.profileTitleInk : AppColors.textInverse,
        ),
      ),
    );
  }
}

/// 展开后的磨砂面板。Figma 的 `frostPanel`（L3459-3466）。
///
/// ```text
/// blur(20) · rgba(255,255,255,0.72) · 1px rgba(255,255,255,0.8) · padding 14/20/20
/// ```
///
/// ⚠️ 圆角 `0 0 24px 24px` 在这里**不需要** ——
/// 面板被父级 `Clip.antiAlias`（圆角 24）裁着，上沿本来就由父卡裁掉，
/// 等价于 CSS 的 `overflow: hidden` + 只给下沿圆角。
///
/// ⚠️ 这是一个**页面私有**的玻璃面，没有走 [GlassSurface] ——
/// 它的模糊半径（20）与填充 / 描边透明度都不属于
/// [GlassVariant] 的那两个标准变体，且 [GlassSurface] 是
/// **已交付未验收**的共享组件（`D30` / `D74` 先例：不为本轮改动它）。
class _FrostPanel extends StatelessWidget {
  const _FrostPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: GlassFilters.blur(_AssetsMetrics.frostBlur),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            _AssetsMetrics.frostPaddingH,
            _AssetsMetrics.frostPaddingTop,
            _AssetsMetrics.frostPaddingH,
            _AssetsMetrics.frostPaddingBottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.profileFrostPanelFill,
            border: Border.all(
              color: AppColors.profileFrostPanelBorder,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 面板底部的「查看全部 →」。Figma L3601-3606。
class _PanelFooterAction extends StatelessWidget {
  const _PanelFooterAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: AppTypography.profileFrostAction),
          const SizedBox(width: _AssetsMetrics.panelFooterIconGap),
          const Icon(
            // Figma 画的是带箭头的横线（`M5 12H19…`）。依 D58 用 Material
            // 字形近似；`east` 是线性箭头，比实心的 `arrow_forward` 更接近。
            Icons.east,
            size: _AssetsMetrics.panelFooterIcon,
            color: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 四个展开面板
// ---------------------------------------------------------------------------

/// 工作经历面板。Figma L3530-3550：时间轴 + 每行的「时间 / 职位 / 公司」。
class _WorkPanel extends StatelessWidget {
  const _WorkPanel({required this.items});

  final List<WorkExperience> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < items.length; i++) ...<Widget>[
          _WorkPanelRow(
            item: items[i],
            isLast: i == items.length - 1,
            onTap: () => context.push(
              AppRoutes.profileWorkDetail(items[i].id),
            ),
          ),
          if (i != items.length - 1)
            const SizedBox(height: _AssetsMetrics.panelRowGap),
        ],
      ],
    );
  }
}

/// 工作经历面板里的一行。
///
/// 用 [IntrinsicHeight] + `stretch` 让时间轴的竖线**跟着内容高度走** ——
/// Figma 的 `flex-1` + `minHeight: 36`（L3536）是同一意图的 CSS 写法。
/// 不写死行高，是为了让公司名换行时竖线也能延长（否则要裁字）。
class _WorkPanelRow extends StatelessWidget {
  const _WorkPanelRow({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  final WorkExperience item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: _AssetsMetrics.railDot,
              child: Column(
                children: <Widget>[
                  // 圆点距顶 `pt-1`（4）—— 与第一行文字的视觉基线对齐。
                  const SizedBox(height: _AssetsMetrics.railDotTop),
                  Container(
                    width: _AssetsMetrics.railDot,
                    height: _AssetsMetrics.railDot,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast) ...<Widget>[
                    const SizedBox(height: _AssetsMetrics.railDotGap),
                    const Expanded(
                      child: SizedBox(
                        width: _AssetsMetrics.railWidth,
                        child: ColoredBox(color: AppColors.profileTimelineRail),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: _AssetsMetrics.railTextGap),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: _AssetsMetrics.panelRowBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(item.period, style: AppTypography.profileTimelinePeriod),
                    const SizedBox(height: _AssetsMetrics.workTitleGap),
                    Text(item.title, style: AppTypography.profileSmallTitle),
                    Text(
                      item.company,
                      style: AppTypography.onSurfaceVariant(
                        AppTypography.profileAssetGroupDate,
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 项目经历面板。Figma L3552-3562：每行「项目名 … 年份」。
class _ProjectPanel extends StatelessWidget {
  const _ProjectPanel({required this.items});

  final List<ProjectExperience> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < items.length; i++) ...<Widget>[
          GestureDetector(
            onTap: () => context.push(
              AppRoutes.profileProjectDetail(items[i].id),
            ),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: _AssetsMetrics.projectRowPaddingV,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      items[i].name,
                      style: AppTypography.profileSmallTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: _AssetsMetrics.panelRowGap),
                  Text(items[i].year, style: AppTypography.profileMetaPlain),
                ],
              ),
            ),
          ),
          if (i != items.length - 1)
            const SizedBox(height: _AssetsMetrics.projectRowGap),
        ],
      ],
    );
  }
}

/// 专业技能面板。Figma L3564-3570：把全部分组**展平**成一排 Chip。
class _SkillPanel extends StatelessWidget {
  const _SkillPanel({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _AssetsMetrics.skillChipGap,
      runSpacing: _AssetsMetrics.skillChipGap,
      children: <Widget>[
        for (final String name in names)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _AssetsMetrics.skillChipPaddingH,
              vertical: _AssetsMetrics.skillChipPaddingV,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlueSurface,
              borderRadius: AppRadius.borderXs,
            ),
            child: Text(name, style: AppTypography.profileBrandChipLabel),
          ),
      ],
    );
  }
}

/// 荣誉成果面板。Figma L3572-3584：圆点 + 「荣誉名 / 年份 · 机构」。
class _AwardPanel extends StatelessWidget {
  const _AwardPanel({required this.items});

  final List<Award> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < items.length; i++) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: _AssetsMetrics.awardDotTop,
                ),
                child: Container(
                  width: _AssetsMetrics.awardDot,
                  height: _AssetsMetrics.awardDot,
                  decoration: const BoxDecoration(
                    color: AppColors.profileAwardAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: _AssetsMetrics.awardDotGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      items[i].name,
                      style: AppTypography.profileSmallTitle,
                    ),
                    Text(
                      items[i].metaLabel,
                      style: AppTypography.onSurfaceVariant(
                        AppTypography.profileMetaPlain,
                        AppColors.profileAwardAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (i != items.length - 1)
            const SizedBox(height: _AssetsMetrics.awardRowGap),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 职业能力画像卡
// ---------------------------------------------------------------------------

/// 职业能力画像卡。Figma L3588-3633。
///
/// ```text
/// 标题 + 「点击查看」+ 白圆钮
/// 总览进度条（轨道 24 高 / 圆角 12）
/// 3 条能力条
/// 底部：「N 个维度 · 综合上升中」 + 「查看全部」深色按钮
/// ```
class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({required this.preview, required this.all});

  /// 卡面上展示的能力条（前 3 条，规则由 [CareerAssetsProvider] 给出）。
  final List<Capability> preview;

  /// 全部分值。用于总览条比例与底部维度数 ——
  /// **两者都按全量算**，不是按展示的 3 条算（Figma 卡底写的是「5 个维度」）。
  final List<Capability> all;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.profilePanelFill,
        borderRadius: AppRadius.borderXl,
      ),
      padding: const EdgeInsets.fromLTRB(
        _AssetsMetrics.capabilityPaddingH,
        _AssetsMetrics.capabilityPaddingTop,
        _AssetsMetrics.capabilityPaddingH,
        _AssetsMetrics.capabilityPaddingBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Text(
                  '职业能力画像',
                  style: AppTypography.profileCapabilityTitle,
                ),
              ),
              const SizedBox(width: _AssetsMetrics.titleCountGap),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '点击查看',
                    style: AppTypography.profileCapabilityHint,
                  ),
                  const SizedBox(width: _AssetsMetrics.countArrowGap),
                  _ArrowCircle(
                    icon: Icons.folder_open,
                    iconInk: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: _AssetsMetrics.capabilityGap),
          // 空数据时只保留卡骨架（标题 + 空文案 + 「查看全部」），
          // 不画 0 值条 —— 0 值进度条是视觉误导（D99 规则落地，2026-09-29）。
          if (all.isEmpty) ...<Widget>[
            const Text(
              _AssetsCopy.capabilityCardEmpty,
              style: AppTypography.profileSmallMeta,
            ),
            const SizedBox(height: _AssetsMetrics.capabilityGap),
            Align(
              alignment: Alignment.centerRight,
              child: _DarkActionButton(
                label: '查看全部',
                onTap: () => context.push(AppRoutes.profileCapability),
              ),
            ),
          ] else ...<Widget>[
            _OverallBar(ratio: _overallRatio(all)),
            const SizedBox(height: _AssetsMetrics.capabilityGap),
            for (final Capability item in preview)
              _SkillBar(capability: item),
            const SizedBox(height: _AssetsMetrics.capabilityGap),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.schedule,
                  size: _AssetsMetrics.clockIcon,
                  color: AppColors.profileInkDeep,
                ),
                const SizedBox(width: _AssetsMetrics.clockGap),
                Expanded(
                  child: Text(
                    _dimensionLabel(all),
                    style: AppTypography.profileSmallMeta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: _AssetsMetrics.capabilityGap),
                _DarkActionButton(
                  label: '查看全部',
                  onTap: () => context.push(AppRoutes.profileCapability),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 总览进度条的填充比例 = 全部能力分值的**均值**。
  ///
  /// ⚠️ Figma 在这里写死 `62%`（L3606），而同一份数据是
  /// `85 / 76 / 78 / 60 / 74` —— 均值 `74.6`，`62` 不对应任何一种算法
  /// （也不是最低分、中位数、前一版均值）。
  ///
  /// 本页选择**派生**：条宽 = 均值，于是它会随数据变化而不是永远卡在 62%，
  /// 也不会在数据为空时仍画出一条 62% 的条。
  /// 该不一致与另两处硬编码派生值同类，一并登记 **待裁决 · D89**。
  static double _overallRatio(List<Capability> items) {
    if (items.isEmpty) return 0;
    int sum = 0;
    for (final Capability item in items) {
      sum += item.score;
    }
    return (sum / items.length) / 100;
  }

  /// 底部维度说明。
  ///
  /// Figma 写死 `'5 个维度 · 综合上升中'`（L3625）。这里维度数**从数据取**；
  /// 而「综合上升中」是一句**判断**，只有真的存在正向增量时才成立 ——
  /// 没有正增量时**整句略去**，而不是编一句「综合持平」之类的文案出来。
  static String _dimensionLabel(List<Capability> items) {
    final String count = '${items.length} 个维度';
    for (final Capability item in items) {
      if (item.isPositive) return '$count · 综合上升中';
    }
    return count;
  }
}

/// 能力画像卡上的总览进度条。Figma L3605-3612。
///
/// 轨道 `#e1e2e8` / 高 24 / 圆角 12，填充为**实心** `#cadb8f`（不是渐变 ——
/// 渐变只用在下面三条能力条上）。
///
/// ⚠️ 填充里的文字用 [OverflowBox] + [ClipRect] 而不是直接 `Text`：
/// 填充宽度随数据变化，窄于文字时**必须裁掉而不是溢出报错**（Figma 的
/// `overflow: hidden` 就是这个意思）。
class _OverallBar extends StatelessWidget {
  const _OverallBar({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _AssetsMetrics.overallBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.profileCapabilityTrack,
        borderRadius: AppRadius.borderXs,
      ),
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio.clamp(0.0, 1.0),
        child: ColoredBox(
          color: AppColors.profileCapabilityBar,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              child: const Padding(
                padding: EdgeInsets.only(
                  left: _AssetsMetrics.overallBarTextInset,
                ),
                child: Text(
                  _AssetsCopy.overallBarLabel,
                  style: AppTypography.profileCapabilityBarLabel,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 一条能力条。Figma 的 `SkillBar`（L3468-3483）。
///
/// ```text
/// [标签 72] [轨道 flex-1 高 5] [分值 22 右对齐] [增量 22]
/// ```
class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.capability});

  final Capability capability;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _AssetsMetrics.skillBarHeight,
      child: Padding(
        padding: const EdgeInsets.only(top: _AssetsMetrics.skillBarPaddingTop),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: _AssetsMetrics.skillBarLabelWidth,
              child: Text(
                capability.name,
                style: AppTypography.profileSmallMeta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: _AssetsMetrics.skillBarGap),
            Expanded(
              child: Container(
                height: _AssetsMetrics.skillBarTrackHeight,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlueSurface,
                  borderRadius: AppRadius.borderPill,
                ),
                clipBehavior: Clip.antiAlias,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  // ⚠️ Figma 给三条各写了 `91% / 76% / 78%`，而分值是
                  // `85 / 76 / 78` —— 只有第一条对不上（85 → 91）。
                  // 与总览条同一处置：条宽由 `score` 派生。
                  widthFactor: capability.ratio,
                  child: const ColoredBox(
                    color: Colors.transparent,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.profileCapabilityBarGradient,
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _AssetsMetrics.skillBarGap),
            SizedBox(
              width: _AssetsMetrics.skillBarNumberWidth,
              child: Text(
                '${capability.score}',
                style: AppTypography.profileSkillBarScore,
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(
              width: _AssetsMetrics.skillBarNumberWidth,
              child: Text(
                capability.deltaLabel,
                style: AppTypography.profileSkillDelta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 深底白字的小动作按钮（能力画像卡底部的「查看全部」）。
/// Figma L3626-3628：`#373b4d` + 1px 白描边 + `padding 6px 12px` + 圆角 12。
class _DarkActionButton extends StatelessWidget {
  const _DarkActionButton({required this.label, required this.onTap});

  final String label;

  /// 点击落点。
  ///
  /// ⚠️ 本轮之前这里是可空的 —— 落点页尚未建立时传 `null`，
  /// 按钮渲染成不可点的淡字。能力页落地后**不再有这种调用方**，
  /// 因此收成必填：让「不可点」这个状态**无法被表达出来**，
  /// 而不是留一个随时会被误用的空转分支。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _AssetsMetrics.viewAllPaddingH,
          vertical: _AssetsMetrics.viewAllPaddingV,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppRadius.borderXs,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.surface),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.onSurfaceVariant(
            AppTypography.profileViewAllPillLabel,
            AppColors.textInverse,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 文案
// ---------------------------------------------------------------------------

/// 职业资产页的静态文案。
///
/// ⚠️ [subtitle] 与 [overallBarLabel] **逐字来自 Figma**（L3494 / L3610）。
/// [capabilityCardEmpty] 是 **Flutter 侧自拟** —— 原型没有空态
/// （它永远有数据），而 `CLAUDE.md` §7 要求 Mock 默认返回空、
/// 让空态真实可见，所以必须有话可说。归属 **待裁决 · D90**。
///
/// D99 规则落地后（2026-09-29）：本页不再有整页 Empty 态 ——
/// 空数据由骨架内联文案承载；各分组的组内空文案见 [_AssetGroup.emptyLabel]。
abstract final class _AssetsCopy {
  static const String subtitle = 'AI 对你的简历和职业经历的持续记录与分析。';
  static const String overallBarLabel = '你的资产正在成就你的能力';
  static const String capabilityCardEmpty =
      '还没有能力数据 · 提交简历并完成职业基线后生成画像';
}

// ---------------------------------------------------------------------------
// 页面几何
// ---------------------------------------------------------------------------

/// 职业资产页的内部几何（Figma 逐条内联给出）。
///
/// ⚠️ 颜色 / 字号 / 字体族 / 圆角 / 动画时长一律走 Token（`CLAUDE.md` §8.2），
/// 本类只放宽高与内边距。
abstract final class _AssetsMetrics {
  /// 列表左右内边距 `px-5`。
  static const double pageInset = 20;

  /// 说明句的左右内边距是 `px-6`（24）—— 比列表宽 4。
  ///
  /// ⚠️ 与 `pageInset` **不同**，这正是 Figma 的写法（L3495 vs L3497），
  /// 不合并。
  static const double listInset = 4;

  static const double subtitleTop = 0;
  static const double subtitleBottom = 12;
  static const double pageBottom = 24;
  static const double cardGap = 12;

  // ── 分组卡（Figma L3502-3527）──────────────────────────────────────
  static const double cardPadding = 20;
  static const double cardRowGap = 20;
  static const double titleCountGap = 10;
  static const double countArrowGap = 10;
  static const double arrowCircleSize = 36;
  static const double arrowCircleIcon = 18;
  static const double clockIcon = 12;
  static const double clockGap = 6;

  /// 磨砂「查看全部」胶囊 `padding: 6px 12px`（Figma L3360）。
  static const double viewAllPaddingH = 12;
  static const double viewAllPaddingV = 6;

  // ── 磨砂面板（Figma L3460-3465）────────────────────────────────────
  static const double frostBlur = 20;
  static const double frostPaddingH = 20;
  static const double frostPaddingTop = 14;
  static const double frostPaddingBottom = 20;
  static const double panelFooterGap = 12;
  static const double panelFooterIcon = 12;
  static const double panelFooterIconGap = 4;

  // ── 工作经历面板（Figma L3532-3548）────────────────────────────────
  static const double panelRowGap = 12;
  static const double railDot = 8;
  static const double railDotTop = 4;
  static const double railDotGap = 4;
  static const double railWidth = 1;
  static const double railTextGap = 12;
  static const double panelRowBottom = 4;
  static const double workTitleGap = 2;

  // ── 项目经历面板（Figma L3554-3560）────────────────────────────────
  static const double projectRowPaddingV = 6;
  static const double projectRowGap = 8;

  // ── 专业技能面板（Figma L3565-3569）────────────────────────────────
  static const double skillChipPaddingH = 10;
  static const double skillChipPaddingV = 4;
  static const double skillChipGap = 8;

  // ── 荣誉成果面板（Figma L3574-3581）────────────────────────────────
  static const double awardDot = 6;
  static const double awardDotTop = 6;
  static const double awardDotGap = 10;
  static const double awardRowGap = 10;

  // ── 能力画像卡（Figma L3591-3630）──────────────────────────────────
  static const double capabilityPaddingTop = 28;
  static const double capabilityPaddingBottom = 20;
  static const double capabilityPaddingH = 20;
  static const double capabilityGap = 16;
  static const double overallBarHeight = 24;
  static const double overallBarTextInset = 12;
  static const double skillBarHeight = 25;
  static const double skillBarPaddingTop = 8;
  static const double skillBarGap = 8;
  static const double skillBarLabelWidth = 72;
  static const double skillBarTrackHeight = 5;
  static const double skillBarNumberWidth = 22;
}
