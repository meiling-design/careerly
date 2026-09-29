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

/// 项目经历列表页。
///
/// 真值来源：Figma `ProjectExperiencePage`（`src/App.tsx` L3723-3762）。
///
/// ```text
/// TopBar「项目经历」+ 右侧「N 个」            L3726
/// 列表 px-5 pb-6 space-y-3                   L3727
///   └ Card p-4（点击进详情）                   L3730-3759
///       上：类型 Chip + 年份 / 项目名 / 角色     L3732-3742
///       中：技能 Chip（紫）                     L3743-3745
///       下：影响的岗位（趋势图标 + 绿字）         L3746-3751
/// ```
///
/// ## ⚠️ 只显示**第一条**影响的岗位
///
/// Figma 取 `p.jobImpact[0]`（L3749），不是把全部列出来。
/// 卡片上只放一条摘要，完整列表在项目详情页的「影响的岗位匹配」卡里 ——
/// 因此这里也**只取第一条**，不是漏了。
///
/// ## ⚠️ 点击反馈的缩放系数
///
/// Figma 在这张卡上写 `scale(0.98)` / `120ms`（L3729-3732），
/// 而 Flutter 侧走共享的 [GlassSurface] 点击反馈
/// （[AppMotion.pressScale] = `0.96`）。
/// **[GlassSurface] 属已交付未验收的共享组件（`D30` / `D74`），本轮不改它** ——
/// 因此这里接受 `0.96`，差异在交付报告中声明。
class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
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
            trailing: provider.data == null
                ? null
                : Text(
                    '${provider.projects.length} 个',
                    style: AppTypography.profileTopBarTrailing,
                  ),
          ),
          Expanded(
            child: CareerlyAsyncStateView<CareerAssets>(
              state: provider.state,
              isEmpty: (CareerAssets assets) => assets.projects.isEmpty,
              onRetry: provider.load,
              loadingMessage: '正在读取项目经历',
              emptyTitle: '还没有项目经历',
              emptyMessage: '提交简历并完成职业基线后，这里会显示你参与过的项目',
              builder: (BuildContext context, CareerAssets assets) =>
                  _ProjectList(items: assets.projects),
            ),
          ),
        ],
      ),
    );
  }
}

/// 项目列表。
class _ProjectList extends StatelessWidget {
  const _ProjectList({required this.items});

  final List<ProjectExperience> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        _ProjectMetrics.inset,
        0,
        _ProjectMetrics.inset,
        _ProjectMetrics.bottom,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: _ProjectMetrics.gap),
      itemBuilder: (BuildContext context, int index) => _ProjectCard(
        item: items[index],
        onTap: () => context.push(
          AppRoutes.profileProjectDetail(items[index].id),
        ),
      ),
    );
  }
}

/// 一张项目卡。Figma L3730-3759。
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.item, required this.onTap});

  final ProjectExperience item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final JobImpact? impact = item.jobImpact.isEmpty
        ? null
        : item.jobImpact.first;

    return GlassSurface(
      onTap: onTap,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_ProjectMetrics.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _TypeChip(label: item.type),
                        const SizedBox(width: _ProjectMetrics.typeYearGap),
                        Text(item.year, style: AppTypography.profileMetaPlain),
                      ],
                    ),
                    const SizedBox(height: _ProjectMetrics.typeRowGap),
                    Text(item.name, style: AppTypography.profileProjectName),
                    Text(item.role, style: AppTypography.profileProjectRole),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: _ProjectMetrics.chevron,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          if (item.skills.isNotEmpty) ...<Widget>[
            const SizedBox(height: _ProjectMetrics.skillRowGap),
            Wrap(
              spacing: _ProjectMetrics.chipGap,
              runSpacing: _ProjectMetrics.chipGap,
              children: <Widget>[
                for (final String skill in item.skills)
                  _ProjectSkillChip(label: skill),
              ],
            ),
          ],
          if (impact != null) ...<Widget>[
            const SizedBox(height: _ProjectMetrics.impactRowGap),
            Row(
              children: <Widget>[
                const Icon(
                  // Figma 是一条上行的折线（`M23 6L13.5 15.5L8.5 10.5L1 18`），
                  // 依 D58 用 Material 的 `trending_up` 近似
                  // （Material 字形多一个箭头，观感差异可接受）。
                  Icons.trending_up,
                  size: _ProjectMetrics.impactIcon,
                  color: AppColors.success,
                ),
                const SizedBox(width: _ProjectMetrics.impactIconGap),
                Expanded(
                  child: Text(
                    // Figma L3749 写 `{job} +{delta}%` —— 与 [JobImpact.label]
                    // 同形，直接用模型给的文本，不在页面里重拼格式。
                    '${impact.job} ${impact.label}',
                    style: AppTypography.profileJobImpactInline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 项目类型 Chip。Figma L3736：蓝底 `rgba(79,126,245,0.10)`。
class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _ProjectMetrics.chipPaddingH,
        vertical: _ProjectMetrics.chipPaddingV,
      ),
      decoration: const BoxDecoration(
        // ⚠️ 与 [AppColors.primaryBlueSurface]（`0.08`）不是同一个值 ——
        // 原型在项目类型 Chip 上用 `0.10`，故用专门的令牌。
        color: AppColors.profileProjectTypeChipFill,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(label, style: AppTypography.profileBrandChipLabel),
    );
  }
}

/// 项目技能 Chip。Figma L3744：紫底 `rgba(167,123,230,0.10)`。
class _ProjectSkillChip extends StatelessWidget {
  const _ProjectSkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _ProjectMetrics.chipPaddingH,
        vertical: _ProjectMetrics.chipPaddingV,
      ),
      decoration: const BoxDecoration(
        // 与 Figma 逐位一致，且与共享令牌 [AppColors.primaryPurpleSurface] 同值 ——
        // 直接复用，不另立。
        color: AppColors.primaryPurpleSurface,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(label, style: AppTypography.profileProjectSkillChip),
    );
  }
}

/// 项目经历页的内部几何（Figma 逐条内联给出）。
abstract final class _ProjectMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 12;

  static const double cardPadding = 16;
  static const double typeYearGap = 8;
  static const double typeRowGap = 4;
  static const double chevron = 14;
  static const double skillRowGap = 8;
  static const double impactRowGap = 8;
  static const double chipGap = 6;
  static const double chipPaddingH = 8;
  static const double chipPaddingV = 2;
  static const double impactIcon = 12;
  static const double impactIconGap = 4;
}
