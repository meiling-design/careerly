import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/career_assets_provider.dart';
import 'profile_assets_loader.dart';

/// 一个项目的详情页。
///
/// 真值来源：Figma `ProjectDetailPage`（`src/App.tsx` L3764-3811）。
///
/// ```text
/// TopBar「项目经历」                          L3768  ← 与工作详情同理，标题是列表名
/// Hero  品牌渐变 + 类型 Chip + 年份 + 名称 + 角色 L3770-3784
/// Card  项目背景                              L3785-3788
/// Card  项目成果                              L3789-3792
/// Card  相关能力（行 + 分隔线）                 L3793-3802
/// Card  影响的岗位匹配（绿底；仅有数据时）        L3803-3810
/// ```
///
/// ## ⚠️「影响的岗位匹配」卡不是普通 Glass 卡
///
/// Figma 在这张卡上把 `Card` 的 `background` 与 `border` **覆盖**成绿色系
/// （`rgba(52,199,89,0.08)` / `rgba(52,199,89,0.20)`），但 `Card` 自带
/// 的 `backdrop-filter` 与 `boxShadow` **仍然生效** ——
/// 也就是说它是一张**绿色玻璃卡**，不是一块不透明绿块。
///
/// Flutter 侧 [GlassSurface] 的填充色由 `variant` 决定、不可覆盖，
/// 而它是**已交付未验收**的共享组件（`D30` / `D74`，本轮不改）。
/// 因此这里用「模糊层 + 绿填充 + 绿描边」自行拼出同一种材质，
/// 与职业资产页的磨砂面板同一手法。
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  /// 路由参数里的项目 id（`/profile/projects/:id`）。
  final String projectId;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ensureCareerAssetsLoaded(context);
    });
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
            title: '项目经历',
            onBack: () => careerlyBack(context),
          ),
          Expanded(
            child: CareerlyAsyncStateView<CareerAssets>(
              state: provider.state,
              isEmpty: (CareerAssets assets) => assets.projects.every(
                (ProjectExperience p) => p.id != widget.projectId,
              ),
              onRetry: provider.load,
              loadingMessage: '正在读取这个项目',
              emptyTitle: '找不到这个项目',
              emptyMessage: '这个项目可能已被删除，或链接已失效',
              builder: (BuildContext context, CareerAssets assets) =>
                  _ProjectDetailBody(
                    item: provider.projectById(widget.projectId),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 详情正文。
class _ProjectDetailBody extends StatelessWidget {
  const _ProjectDetailBody({required this.item});

  /// 查不到时为 `null`（外层已判过 empty），渲染空盒子而不是抛异常。
  final ProjectExperience? item;

  @override
  Widget build(BuildContext context) {
    final ProjectExperience? project = item;
    if (project == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _ProjectDetailMetrics.inset,
        0,
        _ProjectDetailMetrics.inset,
        _ProjectDetailMetrics.bottom,
      ),
      children: <Widget>[
        _ProjectHero(item: project),
        const SizedBox(height: _ProjectDetailMetrics.gap),
        // ⚠️ 三张信息卡都加了判空。Figma 是**无条件渲染**的（L3785 / L3789 /
        // L3793），内容为空时会画出一张只有标题的空卡 —— 那是原型的疏漏，
        // 不是设计意图。**属有意偏离**，与工作详情页的「带来的能力提升」
        // 同一处置，一并记入交付报告。
        if (project.description.isNotEmpty) ...<Widget>[
          _DetailCard(
            title: '项目背景',
            child: Text(
              project.description,
              style: AppTypography.profileBodyRelaxed,
            ),
          ),
          const SizedBox(height: _ProjectDetailMetrics.gap),
        ],
        if (project.outcome.isNotEmpty) ...<Widget>[
          _DetailCard(
            title: '项目成果',
            child: Text(
              project.outcome,
              style: AppTypography.profileBodyRelaxed,
            ),
          ),
          const SizedBox(height: _ProjectDetailMetrics.gap),
        ],
        if (project.skills.isNotEmpty)
          _DetailCard(
            title: '相关能力',
            titleGap: _ProjectDetailMetrics.listTitleGap,
            child: _DividedRows(
              rows: <Widget>[
                for (final String skill in project.skills)
                  _AbilityRow(name: skill),
              ],
            ),
          ),
        if (project.jobImpact.isNotEmpty) ...<Widget>[
          if (project.skills.isNotEmpty)
            const SizedBox(height: _ProjectDetailMetrics.gap),
          _JobImpactCard(items: project.jobImpact),
        ],
      ],
    );
  }
}

/// 详情页 Hero。Figma L3770-3784。
///
/// 装饰圆的合并说明见 [AppColors.profileHeroDecoration]，
/// 「为什么不抽共享组件」的完整理由见 `work_detail_page.dart` 的 `_WorkHero`。
class _ProjectHero extends StatelessWidget {
  const _ProjectHero({required this.item});

  final ProjectExperience item;

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
            top: _ProjectDetailMetrics.heroCircleOffset,
            right: _ProjectDetailMetrics.heroCircleOffset,
            child: Container(
              width: _ProjectDetailMetrics.heroCircle,
              height: _ProjectDetailMetrics.heroCircle,
              decoration: const BoxDecoration(
                color: AppColors.profileHeroDecoration,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_ProjectDetailMetrics.heroPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _ProjectDetailMetrics.heroChipPaddingH,
                        vertical: _ProjectDetailMetrics.heroChipPaddingV,
                      ),
                      decoration: const BoxDecoration(
                        // ⚠️ 与 [AppColors.onBrandSurface]（`0.20`）不是同一个值。
                        color: AppColors.profileHeroChipFill,
                        borderRadius: AppRadius.borderPill,
                      ),
                      child: Text(
                        item.type,
                        style: AppTypography.profileHeroChip,
                      ),
                    ),
                    const SizedBox(
                      width: _ProjectDetailMetrics.heroChipYearGap,
                    ),
                    Text(
                      item.year,
                      style: AppTypography.onSurfaceVariant(
                        // 11px / w400 / white 60%，**无字距** ——
                        // 因此不能用 [AppTypography.profileHeroPeriod]
                        // （那个带 `tracking-widest`，是 Hero 时间区间的专用角色）。
                        AppTypography.profileMetaPlain,
                        AppColors.onBrandMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _ProjectDetailMetrics.heroChipGap),
                Text(item.name, style: AppTypography.profileHeroTitle),
                const SizedBox(height: _ProjectDetailMetrics.heroRoleGap),
                Text(item.role, style: AppTypography.profileHeroRole),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 详情页的信息卡（`Card p-5` + 小标题 + 内容）。
///
/// Figma 的 `Card` = `rounded-3xl` + `S.glass` = [GlassSurface] 的默认形态
/// （圆角 24 / [GlassVariant.standard]），故直接复用，
/// **不新建** `CareerlyDetailCard`（它没有自己的行为，`CLAUDE.md` §8.4）。
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.child,
    this.titleGap = _ProjectDetailMetrics.bodyTitleGap,
  });

  final String title;

  /// 标题与内容之间的距离。Figma 在「项目背景 / 项目成果」上是 `mb-2`（8），
  /// 在「相关能力」上是 `mb-3`（12）。
  final double titleGap;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_ProjectDetailMetrics.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: AppTypography.profileDetailCardTitle),
          SizedBox(height: titleGap),
          child,
        ],
      ),
    );
  }
}

/// 「影响的岗位匹配」卡。Figma L3803-3810。
///
/// 绿色玻璃卡 —— 材质说明见类顶注释。
class _JobImpactCard extends StatelessWidget {
  const _JobImpactCard({required this.items});

  final List<JobImpact> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: AppRadius.borderXl,
        boxShadow: AppShadows.glass,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderXl,
        child: BackdropFilter(
          filter: GlassFilters.standard,
          child: Container(
            padding: const EdgeInsets.all(
              _ProjectDetailMetrics.impactCardPadding,
            ),
            decoration: BoxDecoration(
              color: AppColors.profileImpactCardFill,
              border: Border.all(color: AppColors.profileImpactCardBorder),
              borderRadius: AppRadius.borderXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  '影响的岗位匹配',
                  style: AppTypography.profileImpactTitle,
                ),
                const SizedBox(height: _ProjectDetailMetrics.impactTitleGap),
                for (final JobImpact impact in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: _ProjectDetailMetrics.impactRowPaddingV,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            impact.job,
                            style: AppTypography.profileImpactJob,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          width: _ProjectDetailMetrics.impactRowGap,
                        ),
                        Text(
                          // Figma L3808：`↑ +{delta}%`。`↑` 是文本而不是图标。
                          '↑ ${impact.label}',
                          style: AppTypography.profileImpactDelta,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 竖排的行 + 行间 1px 分隔线。
///
/// Figma 的 `<Divider/>` = `S.divider` = `rgba(229,231,235,0.7)`
/// = [AppColors.divider]，最后一行的分隔线由 `i < length - 1` 跳过。
class _DividedRows extends StatelessWidget {
  const _DividedRows({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < rows.length; i++) ...<Widget>[
          rows[i],
          if (i != rows.length - 1)
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider,
            ),
        ],
      ],
    );
  }
}

/// 「相关能力」里的一行。Figma L3797-3800：紫点 + 能力名。
class _AbilityRow extends StatelessWidget {
  const _AbilityRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _ProjectDetailMetrics.abilityRowPaddingV,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: _ProjectDetailMetrics.abilityDot,
            height: _ProjectDetailMetrics.abilityDot,
            decoration: const BoxDecoration(
              // 项目详情的点是**紫色**，与工作详情的蓝点不同（Figma L3798）。
              color: AppColors.primaryPurple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _ProjectDetailMetrics.abilityDotGap),
          Expanded(
            child: Text(name, style: AppTypography.profileBodyInk),
          ),
        ],
      ),
    );
  }
}

/// 项目详情页的内部几何（Figma 逐条内联给出）。
abstract final class _ProjectDetailMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 16;

  // ── Hero（Figma L3771-3783）────────────────────────────────────────
  static const double heroPadding = 20;
  static const double heroCircle = 128;
  static const double heroCircleOffset = -32;
  static const double heroChipPaddingH = 10;
  static const double heroChipPaddingV = 2;
  static const double heroChipYearGap = 8;
  static const double heroChipGap = 8;
  static const double heroRoleGap = 2;

  // ── 信息卡（Figma L3786-3800）──────────────────────────────────────
  static const double cardPadding = 20;
  static const double bodyTitleGap = 8;
  static const double listTitleGap = 12;
  static const double abilityRowPaddingV = 10;
  static const double abilityDot = 8;
  static const double abilityDotGap = 8;

  // ── 影响的岗位匹配卡（Figma L3803-3809）─────────────────────────────
  static const double impactCardPadding = 16;
  static const double impactTitleGap = 8;
  static const double impactRowPaddingV = 6;
  static const double impactRowGap = 8;
}
