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

/// 工作经历列表页。
///
/// 真值来源：Figma `WorkExperiencePage`（`src/App.tsx` L3636-3666）。
///
/// ```text
/// TopBar「工作经历」+ 右侧「N 段」          L3640
/// 列表 px-5 pb-6 space-y-4                  L3641
///   └ Card p-4 · 点击进详情                  L3643-3664
///       左：时间轴（空心圆点 + 60px 竖轨）    L3645-3648
///       中：时间 / 职位 / 公司 / 技能增量 Chip L3650-3660
///       右：14px 雪佛龙                       L3662
/// ```
///
/// ## ⚠️ 竖轨是**固定 60px**，不是撑满
///
/// 与职业资产页展开面板里的时间轴（`flex-1`）不同，这一页 Figma 写死了
/// `height: 60`（L3647）。因此本页的行高由竖轨决定而不是由内容决定 ——
/// 换行更长的公司名不会把竖轨拉长。这是原型的写法，不改。
class WorkExperiencePage extends StatefulWidget {
  const WorkExperiencePage({super.key});

  @override
  State<WorkExperiencePage> createState() => _WorkExperiencePageState();
}

class _WorkExperiencePageState extends State<WorkExperiencePage> {
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
            title: '工作经历',
            onBack: () => careerlyBack(context),
            // ⚠️ 计数只在**数据到位后**显示。
            // provider 的列表 getter 在未加载时返回空列表，
            // 直接用它会让 Loading 期间显示「0 段」，即把「还没到」说成「没有」。
            trailing: provider.data == null
                ? null
                : Text(
                    '${provider.workExperiences.length} 段',
                    style: AppTypography.profileTopBarTrailing,
                  ),
          ),
          Expanded(
            child: CareerlyAsyncStateView<CareerAssets>(
              state: provider.state,
              isEmpty: (CareerAssets assets) =>
                  assets.workExperiences.isEmpty,
              onRetry: provider.load,
              loadingMessage: '正在读取工作经历',
              emptyTitle: '还没有工作经历',
              emptyMessage: '提交简历并完成职业基线后，这里会显示你的每一段经历',
              builder: (BuildContext context, CareerAssets assets) =>
                  _WorkList(items: assets.workExperiences),
            ),
          ),
        ],
      ),
    );
  }
}

/// 经历列表。
class _WorkList extends StatelessWidget {
  const _WorkList({required this.items});

  final List<WorkExperience> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        _WorkMetrics.inset,
        0,
        _WorkMetrics.inset,
        _WorkMetrics.bottom,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: _WorkMetrics.gap),
      itemBuilder: (BuildContext context, int index) => _WorkCard(
        item: items[index],
        isLast: index == items.length - 1,
        onTap: () => context.push(
          AppRoutes.profileWorkDetail(items[index].id),
        ),
      ),
    );
  }
}

/// 一张经历卡。Figma L3643-3664。
class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  final WorkExperience item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      onTap: onTap,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_WorkMetrics.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: _WorkMetrics.dotSize,
            child: Column(
              children: <Widget>[
                const SizedBox(height: _WorkMetrics.dotTop),
                Container(
                  width: _WorkMetrics.dotSize,
                  height: _WorkMetrics.dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: AppColors.primaryBlue,
                      width: _WorkMetrics.dotBorder,
                    ),
                  ),
                ),
                if (!isLast) ...<Widget>[
                  const SizedBox(height: _WorkMetrics.railGap),
                  // ⚠️ 固定 60 —— 见类顶说明，不是 `Expanded`。
                  const SizedBox(
                    height: _WorkMetrics.railHeight,
                    width: _WorkMetrics.railWidth,
                    child: ColoredBox(color: AppColors.profileTimelineRail),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: _WorkMetrics.railGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.period, style: AppTypography.profileTimelinePeriod),
                const SizedBox(height: _WorkMetrics.periodGap),
                // 15 / w700 / #111827 —— 与二级页顶栏标题同一个组合，
                // 共用 [AppTypography.profileTopBarTitle]（见该角色的说明）。
                Text(item.title, style: AppTypography.profileTopBarTitle),
                Text(item.company, style: AppTypography.profileBodyMuted),
                if (item.skills.isNotEmpty) ...<Widget>[
                  const SizedBox(height: _WorkMetrics.chipRowGap),
                  Wrap(
                    spacing: _WorkMetrics.chipGap,
                    runSpacing: _WorkMetrics.chipGap,
                    children: <Widget>[
                      for (final SkillDelta skill in item.skills)
                        _SkillDeltaChip(skill: skill),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: _WorkMetrics.railGap),
          const Icon(
            // Figma 是 `M9 18L15 12L9 6` 的线性雪佛龙（L3662），
            // 依 D58 用 Material 字形近似。
            Icons.chevron_right,
            size: _WorkMetrics.chevron,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// 技能增量 Chip。Figma L3657：「产品规划 +5」。
///
/// 绿色底（`rgba(52,199,89,0.12)`）取共享令牌 [AppColors.successSurface] ——
/// 与该角色既有的 8 处用法是同一个值、同一语义（正向增量），因此复用而不是另立。
class _SkillDeltaChip extends StatelessWidget {
  const _SkillDeltaChip({required this.skill});

  final SkillDelta skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _WorkMetrics.chipPaddingH,
        vertical: _WorkMetrics.chipPaddingV,
      ),
      decoration: const BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        '${skill.name} ${skill.label}',
        style: AppTypography.profileSkillChipInk,
      ),
    );
  }
}

/// 工作经历页的内部几何（Figma 逐条内联给出）。
abstract final class _WorkMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 16;

  static const double cardPadding = 16;
  static const double dotSize = 12;
  static const double dotBorder = 2;
  static const double dotTop = 4;
  static const double railGap = 12;
  static const double railWidth = 2;
  static const double railHeight = 60;
  static const double periodGap = 4;
  static const double chipRowGap = 8;
  static const double chipGap = 6;
  static const double chipPaddingH = 8;
  static const double chipPaddingV = 2;
  static const double chevron = 14;
}
