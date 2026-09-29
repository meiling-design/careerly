import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/career_assets_provider.dart';
import 'profile_assets_loader.dart';

/// 一段工作经历的详情页。
///
/// 真值来源：Figma `WorkDetailPage`（`src/App.tsx` L3672-3721）。
///
/// ```text
/// TopBar「工作经历」                           L3676  ← 标题仍是列表名，不是经历名
/// Hero  品牌渐变 + 装饰圆 + 时间 / 职位 / 公司   L3678-3687
/// Card  工作内容                               L3688-3691
/// Card  带来的能力提升（行 + 分隔线）            L3692-3702
/// Card  相关项目（仅当非空；行 + 分隔线）         L3703-3717
/// ```
///
/// ## ⚠️ 顶栏标题是「工作经历」而不是这段经历的名字
///
/// 看似重复（从「工作经历」列表点进来、顶栏又写「工作经历」），
/// 但 Figma 就是这样：**经历名在 Hero 里**，顶栏只表达「我在哪个列表下」。
/// 不是笔误，不改写。
///
/// ## 找不到 id 时
///
/// [CareerAssetsProvider.workById] 返回 `null` → 走 Empty 态。
/// 文案说的是「找不到这段经历」而不是「还没有工作经历」——
/// **深链里的 id 失效**与**用户没有经历**是两件事，不能共用一句话。
class WorkDetailPage extends StatefulWidget {
  const WorkDetailPage({super.key, required this.workId});

  /// 路由参数里的经历 id（`/profile/work-experience/:id`）。
  final String workId;

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
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
          ),
          Expanded(
            child: CareerlyAsyncStateView<CareerAssets>(
              state: provider.state,
              isEmpty: (CareerAssets assets) => assets.workExperiences
                  .every((WorkExperience w) => w.id != widget.workId),
              onRetry: provider.load,
              loadingMessage: '正在读取这段经历',
              emptyTitle: '找不到这段经历',
              emptyMessage: '这条经历可能已被删除，或链接已失效',
              builder: (BuildContext context, CareerAssets assets) =>
                  _WorkDetailBody(item: provider.workById(widget.workId)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 详情正文。
class _WorkDetailBody extends StatelessWidget {
  const _WorkDetailBody({required this.item});

  /// 查不到时为 `null` —— 理论上不会走到（外层已判过 empty），
  /// 这里渲染空盒子而不是抛异常。
  final WorkExperience? item;

  @override
  Widget build(BuildContext context) {
    final WorkExperience? work = item;
    if (work == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _WorkDetailMetrics.inset,
        0,
        _WorkDetailMetrics.inset,
        _WorkDetailMetrics.bottom,
      ),
      children: <Widget>[
        _WorkHero(item: work),
        const SizedBox(height: _WorkDetailMetrics.gap),
        _DetailCard(
          title: '工作内容',
          titleGap: _WorkDetailMetrics.bodyTitleGap,
          child: Text(
            work.description,
            style: AppTypography.profileBodyRelaxed,
          ),
        ),
        if (work.skills.isNotEmpty) ...<Widget>[
          // ⚠️ Figma 在「带来的能力提升」上**没有**这层判断（L3693 直接 map），
          // 技能为空时会渲染出一张只有标题的空卡。这是原型的疏漏而不是设计意图，
          // 故这里加判空。**属有意偏离**，已在交付报告中声明。
          const SizedBox(height: _WorkDetailMetrics.gap),
          _DetailCard(
            title: '带来的能力提升',
            titleGap: _WorkDetailMetrics.listTitleGap,
            child: _DividedRows(
              rows: <Widget>[
                for (final SkillDelta skill in work.skills)
                  _AbilityRow(skill: skill),
              ],
            ),
          ),
        ],
        if (work.projects.isNotEmpty) ...<Widget>[
          const SizedBox(height: _WorkDetailMetrics.gap),
          _DetailCard(
            title: '相关项目',
            titleGap: _WorkDetailMetrics.listTitleGap,
            child: _DividedRows(
              rows: <Widget>[
                for (final String name in work.projects)
                  _RelatedProjectRow(name: name),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 详情页的信息卡。
///
/// Figma 的 `Card` 是共享组件（`rounded-3xl` + `S.glass`），
/// 在 Flutter 侧正好等于 [GlassSurface] 的默认形态 ——
/// 圆角 [AppRadius.xl]（24）、[GlassVariant.standard]（`S.glass`）。
///
/// ⚠️ 这里**不新建** `CareerlyDetailCard` 组件：它只是
/// 「[GlassSurface] + 一个小标题 + 一段间距」，没有自己的行为。
/// 依 `CLAUDE.md` §8.4「变体用参数，不用新组件」，
/// 也避免在批 1 里新增计划外的共享组件（本轮只规划了 3 个）。
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.titleGap,
    required this.child,
  });

  final String title;

  /// 标题与内容之间的距离。Figma 在「工作内容」上是 `mb-2`（8），
  /// 在两个列表卡上是 `mb-3`（12）—— 两种都真实存在，故由调用方给。
  final double titleGap;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(_WorkDetailMetrics.cardPadding),
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

/// 竖排的行 + 行间 1px 分隔线（最后一行后无分隔线）。
///
/// Figma 里的写法是每行后面跟一个 `<Divider/>`（`S.divider` =
/// `rgba(229,231,235,0.7)` = [AppColors.divider]），
/// 最后一行的分隔线由 `i < length - 1` 跳过。这里等价表达。
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

/// 详情页 Hero。Figma L3678-3687。
///
/// ## ⚠️ 为什么没有抽成共享组件
///
/// 同形态的 Hero 在 Figma 里出现 **4 次**（工作详情 / 项目详情 / 会员页 /
/// 简历历史），但四者的**内部结构各不相同**：
///
/// | 页 | 装饰圆 | 内部 |
/// |---|---|---|
/// | 工作详情 | 1 个 | 左对齐：时间 / 标题 / 公司 |
/// | 项目详情 | 1 个 | 左对齐：时间 / 标题 / 角色 **+ 类型 Chip** |
/// | 会员页 | 2 个 | **居中**：眉标 / 大标题 / 副标题 |
/// | 简历历史 | 2 个 | 左对齐：徽章 / 标题 / 两行说明 / 文档块 / 三格统计 |
///
/// 要覆盖它们至少需要 5 个开关，而它们**没有一处可复用的行为** ——
/// 只是同一段装饰被复制了 4 次。因此本轮按页各写一份，
/// 把「4 处重复」记入交付报告作为后续批次的合并候选，
/// 而不是现在造一个参数化的壳。
///
/// 装饰圆在四页里的四档白（`0.08 / 0.07 / 0.06 / 0.05`）已合并为
/// [AppColors.profileHeroDecoration] —— 理由见该令牌的说明。
class _WorkHero extends StatelessWidget {
  const _WorkHero({required this.item});

  final WorkExperience item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // `S.primary` = `linear-gradient(135deg, …)` = [AppColors.brandGradient]。
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.borderXl,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _WorkDetailMetrics.heroCircleOffset,
            right: _WorkDetailMetrics.heroCircleOffset,
            child: Container(
              width: _WorkDetailMetrics.heroCircle,
              height: _WorkDetailMetrics.heroCircle,
              decoration: const BoxDecoration(
                color: AppColors.profileHeroDecoration,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_WorkDetailMetrics.heroPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.period, style: AppTypography.profileHeroPeriod),
                const SizedBox(height: _WorkDetailMetrics.heroPeriodGap),
                Text(item.title, style: AppTypography.profileHeroTitle),
                const SizedBox(height: _WorkDetailMetrics.heroCompanyGap),
                Text(item.company, style: AppTypography.profileHeroCompany),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 「带来的能力提升」里的一行。Figma L3695-3699。
class _AbilityRow extends StatelessWidget {
  const _AbilityRow({required this.skill});

  final SkillDelta skill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _WorkDetailMetrics.abilityRowPaddingV,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(skill.name, style: AppTypography.profileBodyInk),
          ),
          const SizedBox(width: _WorkDetailMetrics.abilityRowGap),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _WorkDetailMetrics.badgePaddingH,
              vertical: _WorkDetailMetrics.badgePaddingV,
            ),
            decoration: const BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: AppRadius.borderPill,
            ),
            child: Text(skill.label, style: AppTypography.profileAbilityDelta),
          ),
        ],
      ),
    );
  }
}

/// 「相关项目」里的一行。Figma L3707-3710。
class _RelatedProjectRow extends StatelessWidget {
  const _RelatedProjectRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _WorkDetailMetrics.projectRowPaddingV,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: _WorkDetailMetrics.projectDot,
            height: _WorkDetailMetrics.projectDot,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _WorkDetailMetrics.projectDotGap),
          Expanded(
            child: Text(name, style: AppTypography.profileBodyInk),
          ),
        ],
      ),
    );
  }
}

/// 工作详情页的内部几何（Figma 逐条内联给出）。
abstract final class _WorkDetailMetrics {
  static const double inset = 20;
  static const double bottom = 24;
  static const double gap = 16;

  // ── Hero（Figma L3679-3686）────────────────────────────────────────
  static const double heroPadding = 20;
  static const double heroCircle = 128;
  static const double heroCircleOffset = -32;
  static const double heroPeriodGap = 4;
  static const double heroCompanyGap = 2;

  // ── 信息卡（Figma L3688-3710）──────────────────────────────────────
  static const double cardPadding = 20;
  static const double bodyTitleGap = 8;
  static const double listTitleGap = 12;
  static const double abilityRowPaddingV = 12;
  static const double abilityRowGap = 8;
  static const double badgePaddingH = 10;
  static const double badgePaddingV = 2;
  static const double projectRowPaddingV = 10;
  static const double projectDot = 8;
  static const double projectDotGap = 8;
}
