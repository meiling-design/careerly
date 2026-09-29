import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/career_assets_provider.dart';
import 'profile_assets_loader.dart';

/// 专业技能页。
///
/// 真值来源：Figma `SkillsPage`（`src/App.tsx` L3817-3836）。
///
/// ```text
/// TopBar「技能」+ 右侧「N 项」            L3820
/// 列表 px-5 pb-6 space-y-4                L3821
///   └ Card p-5（每个技能分组一张）           L3823
///       h3 14/w700 + mb-3                  L3824
///       Wrap（gap 8）技能 Chip              L3825-3829
/// ```
///
/// ## 归属
///
/// IA §13「职业资产 → 技能」/ §21「技能 → 我的」。
/// 模型侧早有预告 —— `data/models/career_skill.dart` 类顶写着
/// 「专业**技能页**是按分类展示的（Figma `SKILL_CATS`）」，
/// 因此本页**保持分组渲染**，不做展平。
///
/// ## ⚠️ 顶栏计数是**派生**的，与原型屏幕上写的数字不同（**待裁决 · D89**）
///
/// Figma 的顶栏把计数写死成 `12 项`（L3820），而同一份原型的
/// `SKILL_CATS` 展平后是 **13** 项（`产品能力 5 + AI 能力 4 + 工具 4`）。
///
/// 本页与「我的」资产卡、职业资产页分组卡**同处一轮处置**：
/// 一律从数据派生（[CareerAssetsProvider.skillCount]），于是演示态显示 `13 项`。
/// **这个差异是原型自身的，不是 Flutter 侧的偏差** —— 写死会让计数与数据脱钩。
/// 该不一致已登记 **待裁决 · D89**（`docs/05_progress/TODO.md` §3.1）。
///
/// ## 四态（`CLAUDE.md` §5.5）
///
/// 由 [CareerlyAsyncStateView] 统一承载 Loading / Empty / Error / Retry；
/// 数据为空时整页走 Empty，**不**渲染空的卡片骨架。
class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
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
            title: '技能',
            onBack: () => careerlyBack(context),
            // ⚠️ 计数只在**数据到位后**显示。
            // `skillCount` 在未加载时返回 0，直接用它会让 Loading 期间显示
            // `0 项` —— 即把「还没到」说成「没有」。Empty 态照实写 `0 项`，
            // 与批 1 的工作经历页同一口径。
            trailing: provider.data == null
                ? null
                : Text(
                    '${provider.skillCount} 项',
                    style: AppTypography.profileTopBarTrailing,
                  ),
          ),
          Expanded(
            child: CareerlyAsyncStateView<CareerAssets>(
              state: provider.state,
              isEmpty: (CareerAssets assets) => assets.skillGroups.isEmpty,
              onRetry: provider.load,
              loadingMessage: '正在读取技能',
              emptyTitle: '还没有技能',
              emptyMessage: '提交简历并完成职业基线后，这里会显示你掌握的技能',
              builder: (BuildContext context, CareerAssets assets) =>
                  _SkillGroupList(groups: assets.skillGroups),
            ),
          ),
        ],
      ),
    );
  }
}

/// 技能分组列表。
class _SkillGroupList extends StatelessWidget {
  const _SkillGroupList({required this.groups});

  final List<SkillGroup> groups;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        _SkillsMetrics.inset,
        0,
        _SkillsMetrics.inset,
        _SkillsMetrics.bottom,
      ),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: _SkillsMetrics.gap),
      itemBuilder: (BuildContext context, int index) =>
          _SkillGroupCard(group: groups[index]),
    );
  }
}

/// 一个技能分组卡。Figma L3823-3830。
///
/// 卡面用 [GlassSurface]（Figma 的 `Card` = `rounded-3xl` + `S.glass`），
/// 与项目经历列表卡同一处置 —— `p-5`（20）内边距即本页的 [AppSpacing] 之外的
/// 页面级几何，见 [_SkillsMetrics]。
class _SkillGroupCard extends StatelessWidget {
  const _SkillGroupCard({required this.group});

  final SkillGroup group;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_SkillsMetrics.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(group.category, style: AppTypography.profileDetailCardTitle),
          const SizedBox(height: _SkillsMetrics.titleGap),
          Wrap(
            spacing: _SkillsMetrics.chipGap,
            runSpacing: _SkillsMetrics.chipGap,
            children: <Widget>[
              for (final String skill in group.skills)
                _SkillChip(label: skill),
            ],
          ),
        ],
      ),
    );
  }
}

/// 技能 Chip。Figma L3826：
/// `13px / w500` + `px-3 py-1.5` + `rounded-xl` +
/// `rgba(79,126,245,0.08)` 底 + `#4F7EF5` 字。
///
/// ⚠️ 底板与通用令牌 [AppColors.primaryBlueSurface] **逐位一致**，直接复用 ——
/// 依既有先例（`projects_page.dart` 的紫色技能 Chip 与 `primaryPurpleSurface` 同值复用的
/// 做法），**同值不另立令牌**。
class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _SkillsMetrics.chipPaddingH,
        vertical: _SkillsMetrics.chipPaddingV,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlueSurface,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(label, style: AppTypography.profileSkillsChipLabel),
    );
  }
}

/// 专业技能页的内部几何（Figma 逐条内联给出）。
///
/// 与 `_ProjectMetrics` / `_ProfileMetrics` 同一处置：
/// 这些是**本页特有**的绝对像素，不是全系统刻度，因此不进 `AppSpacing`。
///
/// ⚠️ **颜色 / 字号 / 字体族 / 圆角 / 动画时长一律走 Token**
/// （`CLAUDE.md` §8.2 的硬规则），本类只放宽高与内边距。
abstract final class _SkillsMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 16;

  static const double cardPadding = 20;
  static const double titleGap = 12;
  static const double chipGap = 8;
  static const double chipPaddingH = 12;
  static const double chipPaddingV = 6;
}
