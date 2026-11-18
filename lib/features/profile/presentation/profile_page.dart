import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../analysis/state/analysis_provider.dart';
import '../state/career_assets_provider.dart';
import '../state/growth_provider.dart';
import '../state/resume_provider.dart';
import '../state/user_profile_provider.dart';

/// 「我的」主页。
///
/// 真值来源：Figma `ProfilePage`（`src/App.tsx` L3102-3339）。
///
/// ## 结构（自上而下）
///
/// ```text
/// 头部        品牌字标 + 玻璃齿轮钮（设置）              L3137-3160
/// 头像        96×96 品牌渐变圆 + 首字母                  L3162-3167
/// 信息卡      姓名/账号 + 会员徽章 + 三格统计 + Pro 横幅  L3169-3204
/// Tab 行      可横向滚动的胶囊（**只 3 个**，见下）        L3206-3214
/// 资产卡      156 高渐变卡 + 4 张子卡                    L3217-3247
/// 成长区块    「我的职业成长」标题 + 入口卡               L3250-3273
/// 简历卡      玻璃卡 + 「最新版」Chip                    L3276-3297
/// ```
///
/// ## ⚠️ 与 Figma 的三处**有意偏离**（均已裁决，验收时须逐条对照）
///
/// | # | Figma | 本页 | 依据 |
/// |---|---|---|---|
/// | 1 | Tab 有 **5 个**（多「历史分析」「设置」） | **只 3 个** | `CLAUDE.md` §5.4 / §2.2 / IA §16 |
/// | 2 | 底部另有**历史分析卡**与**设置卡** | **不渲染** | §2.2（历史分析只属「分析」）；IA §16（设置唯一入口 = 右上齿轮） |
/// | 3 | 「我的职业成长」内嵌**成长日历本体** | 只保留标题 + 入口卡，**日历移入详情页** | §2.2 / Baseline O2 |
///
/// 三处的原委均登记在 `docs/05_progress/TODO.md` §3.1（**D95**）。
/// ⚠️ 此处原引作 `D86`，而 `D86` 已被注册页的登录形态缺口占用（撞号）——
/// 编号已按 `TODO.md` §3.1 的集中补登改正。
///
/// 另有**两处不是偏离、而是缺口**，一并记在 K 表：头部 Logo 是位图资源
/// 而仓库没有（**K16**），空态文案 Figma 里不存在（**D90**）。
///
/// ## Tab 行为（`CLAUDE.md` §4 决策 1 / §5.4）
///
/// ```text
/// 点击 Tab  → 对应 Card 动画移动到第一位（250–350ms，平滑，不突跳/回弹）
/// 点击 Card → 打开对应 Detail
/// ```
///
/// 因此**卡片顺序是页面状态**，不是固定布局 —— 用 [AnimatedList] 承载重排，
/// 时长取 [AppMotion.cardReorder]（300ms，落在 250–350ms 区间内）。
///
/// ## 数据来源：五个领域，互不合成
///
/// ```text
/// UserProfileProvider    身份（昵称 / 账号 / 会员徽章）
/// CareerAssetsProvider   职业资产（资产卡四个计数 + 摘要句）
/// ResumeProvider         简历版本（简历卡 + 「简历版本」统计）
/// GrowthProvider         成长记录条数（成长入口卡）
/// AnalysisProvider       分析岗位 / 分析次数 / 剩余额度（统计 + Pro 横幅）
/// ```
///
/// 依 `CLAUDE.md` §6.3「按领域拆分」，这里读五个 Provider 而**不**新建一个
/// `ProfileProvider` 把它们包起来 —— 合成一个会让任一失败连带整页无数据。
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// 卡片的当前顺序。第一张即被选中 Tab 对应的卡片。
  final List<_ProfileSection> _sections = <_ProfileSection>[
    _ProfileSection.assets,
    _ProfileSection.growth,
    _ProfileSection.resume,
  ];

  _ProfileSection _selected = _ProfileSection.assets;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProfileProvider>().load();
      context.read<CareerAssetsProvider>().load();
      context.read<ResumeProvider>().load();
      context.read<GrowthProvider>().load();
      context.read<AnalysisProvider>().loadQuota();
    });
  }

  /// 把 [section] 移到第一位（`CLAUDE.md` §5.4）。
  ///
  /// 先 `removeItem` 再 `insertItem`，两次动画时长相同 ——
  /// 原位置收缩成空槽、首位展开，其余卡片相对顺序不变，
  /// 视觉上是一次平滑移动（不突跳、不回弹）。
  void _selectSection(_ProfileSection section) {
    final int oldIndex = _sections.indexOf(section);
    if (oldIndex > 0) {
      final _ProfileSection moved = _sections.removeAt(oldIndex);
      _listKey.currentState?.removeItem(
        oldIndex,
        (BuildContext context, Animation<double> animation) => SizeTransition(
          sizeFactor: animation,
          child: _SectionSlot(section: moved, blank: true),
        ),
        duration: AppMotion.cardReorder,
      );
      _sections.insert(0, moved);
      _listKey.currentState?.insertItem(0, duration: AppMotion.cardReorder);
    }
    setState(() => _selected = section);
  }

  @override
  Widget build(BuildContext context) {
    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: _ProfileMetrics.pageBottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ProfileHeader(onSettings: () => context.push(AppRoutes.settings)),
            const _ProfileAvatar(),
            const _ProfileInfoCard(),
            _ProfileTabs(selected: _selected, onSelect: _selectSection),
            SizedBox(
              height: _ProfileMetrics.cardListHeight,
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _sections.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder:
                    (
                      BuildContext context,
                      int index,
                      Animation<double> animation,
                    ) => SizeTransition(
                      sizeFactor: animation,
                      child: _SectionSlot(section: _sections[index]),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 「我的」主页上的三张卡片。
///
/// ⚠️ 只有 3 个 —— Figma 的「历史分析」「设置」两个 Tab **不实现**
/// （`CLAUDE.md` §2.2 / IA §16），因此也没有对应卡片。
enum _ProfileSection {
  /// 职业资产渐变卡。
  assets('职业资产'),

  /// 「我的职业成长」区块。
  growth('成长足迹'),

  /// 我的简历卡。
  resume('我的简历');

  const _ProfileSection(this.label);

  /// Tab 文案。
  final String label;
}

/// 一张卡片在列表里的固定槽位。
///
/// ## 为什么是**固定高度**
///
/// [AnimatedList] 没有 `shrinkWrap`，嵌在 [SingleChildScrollView] 里需要
/// 确定高度。三张卡片的高度因此是**常量**（见 [_ProfileMetrics]），
/// 而不是由内容撑开 —— 这与 Figma 本来就给卡片写死高度（`156` / `72`）一致。
///
/// ⚠️ 代价：内容超过槽位高度会被裁掉。给卡片加内容时必须同步改高度。
class _SectionSlot extends StatelessWidget {
  const _SectionSlot({required this.section, this.blank = false});

  final _ProfileSection section;

  /// 渲染为**等高的空槽**。仅用于 [AnimatedList] 的**移除**动画 ——
  /// 那一帧要表达的是「原位置空出来、收起」，而那卡片此刻已经在
  /// 首位重新出现（见 [_ProfilePageState._selectSection]）。
  ///
  /// ⚠️ 必须是**等高**的空槽而不是 `SizedBox.shrink()`：
  /// `SizeTransition` 靠 child 的固有高度做收缩动画，
  /// 高度为 0 的 child 会让整段动画什么都不发生（槽位瞬间消失）。
  final bool blank;

  @override
  Widget build(BuildContext context) {
    final Widget content = switch (section) {
      _ProfileSection.assets => const _AssetsCard(),
      _ProfileSection.growth => const _GrowthCard(),
      _ProfileSection.resume => const _ResumeCard(),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: _ProfileMetrics.cardGap),
      child: SizedBox(
        height: _ProfileMetrics.heightOf(section),
        child: blank ? const SizedBox.expand() : content,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 头部 / 头像 / 信息卡
// ---------------------------------------------------------------------------

/// 头部：品牌字标 + 玻璃齿轮钮。Figma L3137-3160。
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _ProfileMetrics.headerHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _ProfileMetrics.headerInset,
          _ProfileMetrics.headerPaddingTop,
          _ProfileMetrics.headerInset,
          _ProfileMetrics.headerPaddingBottom,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const _ProfileWordmark(),
            // 设置入口：Figma 的玻璃圆钮 = `S.glassLight`
            // （`rgba(255,255,255,0.45)` + `blur(16)` + 品牌蓝投影），
            // 与 `GlassSurface` 的 `light` 变体逐位一致。
            GlassSurface(
              variant: GlassVariant.light,
              radius: AppRadius.pill,
              width: _ProfileMetrics.gearSize,
              height: _ProfileMetrics.gearSize,
              onTap: onSettings,
              child: const Center(
                child: Icon(
                  // Figma 画的是设置齿轮 SVG。依 **D58** 先例（不新建图标资源，
                  // 用 Material 字形近似）取 `settings_outlined`。
                  Icons.settings_outlined,
                  size: _ProfileMetrics.gearIcon,
                  color: AppColors.profileGearInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 头部品牌字标。
///
/// ## ⚠️ 这是一个**近似实现**（缺口已登记 **K16**）
///
/// Figma 在这里放的是一张**位图 Logo** —— 109×27 的裁剪框里塞了一张
/// `205×137` 的图（L3139-3143），而仓库内**没有**该资源，
/// 也没有任何品牌字标组件。
///
/// 依 `CLAUDE.md` §3.1「Figma 有视觉，但 Flutter 没有对应实现方式
/// → **重新实现**，而不是放弃视觉」，这里用**文字字标**顶替，
/// 填充沿用品牌渐变（[AppColors.splashTitleGradient] —— 项目里已有的、
/// 开屏页正在用的同一个 Careerly 字标渐变）。
///
/// ```text
/// ❌ 不下载位图资源（与 K1 字体缺口同一处置原则）
/// ❌ 不照着图猜形状再画一遍
/// ✅ 用已有的品牌字标视觉顶上，并把缺口登记为 K16
/// ```
///
/// 待设计侧提供 Logo 资源后，**只替换本组件**，页面其余部分不受影响。
class _ProfileWordmark extends StatelessWidget {
  const _ProfileWordmark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ProfileMetrics.wordmarkWidth,
      height: _ProfileMetrics.wordmarkHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) =>
              AppColors.splashTitleGradient.createShader(bounds),
          child: const Text(
            'Careerly',
            maxLines: 1,
            style: AppTypography.profileHeaderWordmark,
          ),
        ),
      ),
    );
  }
}

/// 头像。Figma L3162-3167：96×96 圆 + `135deg` 品牌渐变 + 品牌蓝投影。
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final UserProfile profile =
        context.watch<UserProfileProvider>().data ?? UserProfile.empty;
    final String? glyph = profile.avatarGlyph;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _ProfileMetrics.avatarVertical,
      ),
      child: Center(
        child: Container(
          width: _ProfileMetrics.avatarSize,
          height: _ProfileMetrics.avatarSize,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.brandGradient,
            boxShadow: AppShadows.profileAvatar,
          ),
          child: glyph == null
              // 没有身份资料时**不编一个字母**（`CLAUDE.md` §7），
              // 用中性人形图标表示「还没有头像」。
              ? const Icon(
                  Icons.person_outline,
                  size: _ProfileMetrics.avatarPlaceholderIcon,
                  color: AppColors.textInverse,
                )
              : Text(glyph, style: AppTypography.profileAvatarGlyph),
        ),
      ),
    );
  }
}

/// 信息卡：姓名/账号 + 会员徽章 + 三格统计 + Pro 横幅。Figma L3169-3204。
class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard();

  @override
  Widget build(BuildContext context) {
    final UserProfile profile =
        context.watch<UserProfileProvider>().data ?? UserProfile.empty;
    final ResumeProfile resume =
        context.watch<ResumeProvider>().data ?? ResumeProfile.empty;
    final AnalysisProvider analysis = context.watch<AnalysisProvider>();

    // 「分析岗位」= 全部分析项目里已添加的岗位总数（派生，不硬编码）。
    final int analyzedJobs =
        analysis.data?.fold<int>(
          0,
          (int sum, AnalysisProject project) => sum + project.jobs.length,
        ) ??
        0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _ProfileMetrics.infoCardInset,
        vertical: _ProfileMetrics.infoCardVertical,
      ),
      child: Container(
        padding: const EdgeInsets.all(_ProfileMetrics.infoCardPadding),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          // Figma 的描边是 `1.5px rgba(255,255,255,0.23)` ——
          // 全项目**唯一**一条 0.23 的 Glass 描边，比 `glassBorder` 弱得多。
          border: Border.all(
            color: AppColors.profileInfoCardBorder,
            width: _ProfileMetrics.infoCardBorderWidth,
          ),
          borderRadius: AppRadius.borderXl,
          boxShadow: AppShadows.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        profile.isEmpty
                            ? _ProfileCopy.emptyName
                            : profile.displayName,
                        style: AppTypography.profileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: _ProfileMetrics.nameHandleGap),
                      Text(
                        profile.isEmpty
                            ? _ProfileCopy.emptyHandle
                            : profile.handle,
                        style: AppTypography.profileHandle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (profile.membershipLabel.isNotEmpty) ...<Widget>[
                  const SizedBox(width: _ProfileMetrics.infoCardGap),
                  _MembershipBadge(label: profile.membershipLabel),
                ],
              ],
            ),
            const SizedBox(height: _ProfileMetrics.infoCardGap),
            CareerlyStatRow(
              stats: <CareerlyStat>[
                CareerlyStat(value: '${resume.versions.length}', label: '简历版本'),
                CareerlyStat(value: '$analyzedJobs', label: '分析岗位'),
                CareerlyStat(
                  value: '${analysis.quota?.used ?? 0}',
                  label: '分析次数',
                ),
              ],
            ),
            const SizedBox(height: _ProfileMetrics.infoCardGap),
            _ProBanner(remaining: analysis.quota?.remaining),
          ],
        ),
      ),
    );
  }
}

/// 「V1会员」徽章。Figma L3173-3178：`#373b4d` 胶囊 + 金色皇冠 + 白字。
///
/// ⚠️ 徽章文案（`V1会员`）的等级语义**产品侧未定义** → **待裁决 · D87**。
/// 这里只渲染 Mock 给的字符串，**不解析、不推导等级**。
class _MembershipBadge extends StatelessWidget {
  const _MembershipBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _ProfileMetrics.badgePaddingH,
        vertical: _ProfileMetrics.badgePaddingV,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.borderPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            // Figma 的皇冠是金色描边 SVG（`#F2C94C`）。依 D58 用 Material 字形近似。
            Icons.workspace_premium_outlined,
            size: _ProfileMetrics.badgeIcon,
            color: AppColors.pro,
          ),
          const SizedBox(width: _ProfileMetrics.badgeIconGap),
          Text(label, style: AppTypography.profileMemberBadge),
        ],
      ),
    );
  }
}

/// Careerly Pro 横幅。Figma L3190-3203。
///
/// 副标题按**剩余额度**分支（Figma 的 `remaining > 0 ? … : …`），
/// 数据取自 [AnalysisProvider.quota] —— 也就是 §5.2 那个**唯一**的额度真值。
/// 这里**不新建第二份额度状态**：额度只在「开始分析」时扣减，
/// 复制一份就会出现两个真值、两边不同步。
class _ProBanner extends StatelessWidget {
  const _ProBanner({required this.remaining});

  /// 剩余分析次数。`null` 表示额度尚未取回（文案退回中性说明）。
  final int? remaining;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.profileMembership),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _ProfileMetrics.proBannerHeight,
        padding: const EdgeInsets.only(
          left: _ProfileMetrics.proBannerPaddingH,
          right: _ProfileMetrics.proBannerPaddingH,
        ),
        decoration: const BoxDecoration(
          gradient: AppColors.profileProBannerGradient,
          borderRadius: AppRadius.borderMd,
        ),
        child: Row(
          children: <Widget>[
            const Text('✦', style: AppTypography.profileProGlyph),
            const SizedBox(width: _ProfileMetrics.proGlyphGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Careerly Pro',
                    style: AppTypography.profileProBannerTitle,
                  ),
                  const SizedBox(height: _ProfileMetrics.proTextGap),
                  Text(
                    _subtitle,
                    style: AppTypography.profileProBannerSub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _subtitle {
    final int? value = remaining;
    if (value == null) return _ProfileCopy.proBannerUnknown;
    if (value == QuotaState.unlimited) return _ProfileCopy.proBannerMember;
    if (value > 0) {
      return '免费体验剩余 $value/${QuotaState.free.total} 次 · 无限分析 AI 顾问';
    }
    return '免费次数已用完，升级解锁无限功能';
  }
}

// ---------------------------------------------------------------------------
// Tab 行
// ---------------------------------------------------------------------------

/// 可横向滚动的胶囊 Tab。Figma L3206-3214。
///
/// ⚠️ Figma 给了 5 个 Tab，这里**只有 3 个** ——
/// 「历史分析」属「分析」（`CLAUDE.md` §2.2），
/// 「设置」的唯一入口是右上角齿轮（IA §16）。
///
/// 三个胶囊在 360dp 屏上放得下，但 Figma 的容器本来就是横向可滚动的，
/// 这里保留滚动能力 —— 字号随系统放大时才不会溢出。
class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.selected, required this.onSelect});

  final _ProfileSection selected;
  final ValueChanged<_ProfileSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
        left: _ProfileMetrics.tabsPaddingLeft,
        right: _ProfileMetrics.tabsPaddingRight,
        top: _ProfileMetrics.tabsPaddingVertical,
        bottom: _ProfileMetrics.tabsPaddingVertical,
      ),
      child: Row(
        children: <Widget>[
          for (final _ProfileSection section in _ProfileSection.values)
            Padding(
              padding: EdgeInsets.only(
                right: section == _ProfileSection.values.last
                    ? 0
                    : _ProfileMetrics.tabsGap,
              ),
              child: _TabPill(
                label: section.label,
                selected: section == selected,
                onTap: () => onSelect(section),
              ),
            ),
        ],
      ),
    );
  }
}

/// 单个胶囊 Tab。Figma L3209-3214。
class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _ProfileMetrics.tabPaddingH,
          vertical: _ProfileMetrics.tabPaddingV,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.borderLg,
          // Figma：选中态**无描边**，未选中态 `1px #eaeafa`。
          border: selected
              ? null
              : Border.all(color: AppColors.profileTabBorder),
        ),
        child: Text(
          label,
          style: selected
              ? AppTypography.profileTabLabelActive
              : AppTypography.profileTabLabelIdle,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 三张卡片
// ---------------------------------------------------------------------------

/// 职业资产渐变卡。Figma L3217-3247。
class _AssetsCard extends StatelessWidget {
  const _AssetsCard();

  @override
  Widget build(BuildContext context) {
    final CareerAssets assets =
        context.watch<CareerAssetsProvider>().data ?? CareerAssets.empty;
    final bool isEmpty = assets.isEmpty;
    final List<_AssetTileSpec> tiles = _assetTiles(assets);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _ProfileMetrics.cardInset,
      ),
      child: Container(
        height: _ProfileMetrics.assetsCardHeight,
        decoration: const BoxDecoration(
          gradient: AppColors.profileAssetsCardGradient,
          borderRadius: AppRadius.borderXl,
          boxShadow: AppShadows.profileBrandCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: _ProfileMetrics.assetsHeaderHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  _ProfileMetrics.assetsHeaderPaddingH,
                  _ProfileMetrics.assetsHeaderPaddingTop,
                  _ProfileMetrics.assetsHeaderPaddingH,
                  _ProfileMetrics.assetsHeaderPaddingBottom,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: _ProfileMetrics.assetGlyphTile,
                      height: _ProfileMetrics.assetGlyphTile,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.profileAssetTileIconFill,
                        borderRadius: AppRadius.borderXs,
                      ),
                      // Figma 这里就是一个 `⭐` 字符（`fontSize: 18`），
                      // 不是 SVG —— 因此照原样用字符渲染。
                      child: const Text(
                        '⭐',
                        style: AppTypography.profileAssetGlyph,
                      ),
                    ),
                    const SizedBox(width: _ProfileMetrics.assetsHeaderTextGap),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            '职业资产',
                            style: AppTypography.profileAssetsCardTitle,
                          ),
                          Text(
                            _summary(assets, isEmpty),
                            style: AppTypography.profileAssetsCardSub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: _ProfileMetrics.assetsHeaderTextGap),
                    _ViewAllPill(
                      onTap: () => context.push(AppRoutes.profileCareerAssets),
                    ),
                  ],
                ),
              ),
            ),
            // Figma 把四张子卡绝对定位在 `top: 68`（卡高 156），
            // 于是子卡高 73、卡底余 15。这里用 Expanded 等价表达。
            Expanded(
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < tiles.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? _ProfileMetrics.assetTileEdgeInset : 0,
                          right: i == tiles.length - 1
                              ? _ProfileMetrics.assetTileEdgeInset
                              : 0,
                        ),
                        child: _AssetTile(spec: tiles[i], isFirst: i == 0),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: _ProfileMetrics.assetsBottomGap),
          ],
        ),
      ),
    );
  }

  /// 摘要句。
  ///
  /// Figma 是 `本月新增 1 项 · AI 能力 +8` —— 两个数**都从数据派生**：
  /// 新增项数取 [CareerAssets.monthlyAdded]，能力名与增量取
  /// [CareerAssets.topDeltaCapability]（增量最高的那一项）。
  /// 没有任何正增量时**不硬凑一句**，退回「只报新增」。
  static String _summary(CareerAssets assets, bool isEmpty) {
    if (isEmpty) return _ProfileCopy.assetsEmptySummary;
    final String added = '本月新增 ${assets.monthlyAdded} 项';
    final Capability? top = assets.topDeltaCapability;
    if (top == null) return added;
    return '$added · ${top.name} ${top.deltaLabel}';
  }

  static List<_AssetTileSpec> _assetTiles(CareerAssets assets) =>
      <_AssetTileSpec>[
        _AssetTileSpec(
          value: '${assets.workCount}',
          unit: '段',
          label: '工作经历',
          icon: Icons.work_outline,
          route: AppRoutes.profileWorkExperience,
        ),
        _AssetTileSpec(
          value: '${assets.projectCount}',
          unit: '个',
          label: '项目',
          icon: Icons.grid_view_outlined,
          route: AppRoutes.profileProjects,
        ),
        _AssetTileSpec(
          value: '${assets.skillCount}',
          unit: '项',
          label: '技能',
          icon: Icons.star_border_rounded,
          route: AppRoutes.profileSkills,
        ),
        _AssetTileSpec(
          value: '${assets.awardCount}',
          unit: '个',
          label: '奖项',
          icon: Icons.emoji_events_outlined,
          route: AppRoutes.profileAwards,
        ),
      ];
}

/// 资产子卡的展示规格。
class _AssetTileSpec {
  const _AssetTileSpec({
    required this.value,
    required this.unit,
    required this.label,
    required this.icon,
    required this.route,
  });

  final String value;
  final String unit;
  final String label;

  /// Figma 每个子卡各有一套描边 SVG。依 D58 先例（不新建图标资源，
  /// 用 Material 字形近似）：公文包 → `work_outline`、
  /// 四宫格 → `grid_view_outlined`、五角星 → `star_border_rounded`、
  /// 奖杯 → `emoji_events_outlined`。
  final IconData icon;

  /// 点击落点。
  final String route;
}

/// 资产子卡。Figma L3233-3246：`75.5×73` + 圆角 14 + `rgba(255,255,255,0.15)`。
///
/// ⚠️ Figma 给的是**固定宽 75.5**（在 390+ 宽的画布上四张正好铺满）。
/// 360dp 的 Android 屏上 `4 × 75.5 + 3 × 8 = 326 > 340 - 2 × 16 = 308`
/// 会溢出，因此这里改用**等分**（`Expanded`）——
/// 与 `CareerlyStatRow` 对 Figma `flex: 1` 的处置同一个道理：
/// 视觉等价（四张等宽、间距 8），且不会溢出。
///
/// ## ⚠️ 上下内边距**不照搬**（Figma 自身溢出 4px）
///
/// Figma 的子卡是 `height: 73` + `padding: 11px 10px 10px`
/// + `justify-content: center`，内容却是
/// `17(图标) + 2(间距) + 22(数字行高) + 15(标签行高) = 56`，
/// 而内框只有 `73 - 11 - 10 = 52` —— **原型自己就溢出 4px**。
///
/// 浏览器不裁剪（子卡没有 `overflow: hidden`），靠**不安全的居中溢出**兜住：
/// 内容中心 = 内框中心 = `11 + 52 / 2 = 37`，内容占 `9 → 65`。
///
/// Flutter 的 `RenderFlex` 在 debug 下会对这 4px **直接抛异常**
/// （`flutter test` 实测：`A RenderFlex overflowed by 4.0 pixels`），
/// 因此这里**去掉上下内边距**、让 56px 的内容在 73px 里自然居中：
/// 内容中心 = 36.5，占 `8.5 → 64.5` ——
/// 与图上的 `9 → 65` 只差 **0.5px**，比「保留内边距再溢出」更接近原图。
///
/// 左右内边距 10 **保留**（它决定文字左对齐位置，与垂直居中无关）。
class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.spec, required this.isFirst});

  final _AssetTileSpec spec;

  /// 是否为第一张（只有它左侧留页面内边距，见 [_ProfileMetrics]）。
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _ProfileMetrics.assetTileHeight,
      child: GestureDetector(
        onTap: () => context.push(spec.route),
        behavior: HitTestBehavior.opaque,
        child: Container(
          // ⚠️ 只有左右内边距 —— 上下不设，理由见类顶说明。
          padding: const EdgeInsets.symmetric(
            horizontal: _ProfileMetrics.assetTilePaddingH,
          ),
          decoration: const BoxDecoration(
            color: AppColors.profileAssetTileFill,
            borderRadius: AppRadius.borderSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                spec.icon,
                // 四张子卡的图标色在 Figma 里**都是白色**（`stroke="white"`），
                // 与卡片底色无关 —— 因此这里恒为白色。
                size: _ProfileMetrics.assetTileIcon,
                color: AppColors.textInverse,
              ),
              const SizedBox(height: _ProfileMetrics.assetTileIconGap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(spec.value, style: AppTypography.profileAssetTileValue),
                  Text(spec.unit, style: AppTypography.profileAssetTileUnit),
                ],
              ),
              Text(spec.label, style: AppTypography.profileAssetTileLabel),
            ],
          ),
        ),
      ),
    );
  }
}

/// 资产卡上的磨砂「查看全部」胶囊。Figma L3229-3232。
class _ViewAllPill extends StatelessWidget {
  const _ViewAllPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _ProfileMetrics.viewAllPaddingH,
          vertical: _ProfileMetrics.viewAllPaddingV,
        ),
        decoration: const BoxDecoration(
          color: AppColors.profileViewAllPillFill,
          // Figma 的圆角是 22 —— 这是一个 28 高的小胶囊，22 与 999 在该尺寸下
          // **视觉完全等价**（半径已超过半高），因此取 `pill`。
          borderRadius: AppRadius.borderPill,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('查看全部', style: AppTypography.profileAssetsPillLabel),
            SizedBox(width: _ProfileMetrics.viewAllIconGap),
            Icon(
              Icons.chevron_right,
              size: _ProfileMetrics.viewAllIcon,
              color: AppColors.textInverse,
            ),
          ],
        ),
      ),
    );
  }
}

/// 「我的职业成长」区块。Figma L3250-3273。
///
/// ## ⚠️ 有意偏离：**日历本体不在主页**（类顶表格的第 3 处偏离）
///
/// Figma 把整个 `GrowthCalendar`（月历网格 + 选中日事件列表）直接铺在主页的
/// 这张卡里。但 `CLAUDE.md` §2.2 与 Baseline O2 把成长日历 / 时间线定为
/// **「我的 → 成长足迹 → Detail」内部**的局部展示 —— 它既不是主页内容，
/// 也不是独立页面。
///
/// 因此本区块只保留 Figma 的**标题行**（「我的职业成长」+「查看全部 →」，
/// 即 [CareerlySectionHeader]）与一张**入口卡**；日历本体落在
/// [AppRoutes.profileGrowthRecord] 里。
///
/// > 这是本轮**唯一**按规则偏离 Figma 视觉的一处，已在交付报告中显式声明。
class _GrowthCard extends StatelessWidget {
  const _GrowthCard();

  @override
  Widget build(BuildContext context) {
    final int count = context.watch<GrowthProvider>().data?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _ProfileMetrics.cardInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlySectionHeader(
            title: '我的职业成长',
            actionLabel: '查看全部 →',
            onAction: () => context.push(AppRoutes.profileGrowthRecord),
          ),
          Expanded(
            child: _GateCard(
              // Figma 没有这张入口卡（它的位置上是日历本体），
              // 图标因此是本轮选的：日历 = 详情页里的东西，指向最直接。
              icon: Icons.calendar_month_outlined,
              iconSurface: AppColors.primaryBlueSurface,
              iconInk: AppColors.primaryBlue,
              title: '成长足迹',
              subtitle: count == 0
                  ? _ProfileCopy.growthEmpty
                  : '已记录 $count 条成长变化',
              trailing: const Icon(
                Icons.chevron_right,
                size: _ProfileMetrics.chevron,
                color: AppColors.textSecondary,
              ),
              onTap: () => context.push(AppRoutes.profileGrowthRecord),
            ),
          ),
        ],
      ),
    );
  }
}

/// 我的简历卡。Figma L3276-3297。
class _ResumeCard extends StatelessWidget {
  const _ResumeCard();

  @override
  Widget build(BuildContext context) {
    final ResumeProfile profile =
        context.watch<ResumeProvider>().data ?? ResumeProfile.empty;
    final ResumeVersion? current = profile.currentVersion;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _ProfileMetrics.cardInset,
      ),
      child: _GateCard(
        icon: Icons.description_outlined,
        iconSurface: AppColors.profileResumeIconSurface,
        iconInk: AppColors.success,
        title: '我的简历',
        subtitle: current == null
            ? _ProfileCopy.resumeEmpty
            : _resumeSubtitle(current),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (current != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: _ProfileMetrics.chipPaddingH,
                  vertical: _ProfileMetrics.chipPaddingV,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: AppRadius.borderPill,
                ),
                child: const Text(
                  '最新版',
                  style: AppTypography.profileListCardChip,
                ),
              ),
            const SizedBox(height: _ProfileMetrics.chipChevronGap),
            const Icon(
              Icons.chevron_right,
              size: _ProfileMetrics.chevron,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        onTap: () => context.push(AppRoutes.profileResumeHistory),
      ),
    );
  }

  /// Figma 是 `Resume V3 · 2026.08.27` —— 版本名与上传日**都从数据取**。
  /// 没有版本时不走这里（上面已换成中性文案）。
  static String _resumeSubtitle(ResumeVersion version) {
    final DateTime? at = version.uploadedAt;
    if (at == null) return version.label;
    // ⚠️ `toLocal()` 不能省 —— 后端时间戳是 UTC（见 `formatResumeDate` 的说明）。
    final DateTime local = at.toLocal();
    final String date = '${local.year}.${_two(local.month)}.${_two(local.day)}';
    return version.label.isEmpty ? date : '${version.label} · $date';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

/// 小卡片的共同外壳（成长入口卡 / 简历卡）。
///
/// 真值来源：Figma 的「我的简历」/「历史分析」/「设置」三张卡是**同一套**
/// 玻璃卡样式（L3278-3281 / L3300-3303 / L3322-3325）：
/// `blur(24)` + `rgba(255,255,255,0.68)` + `1.188px rgba(255,255,255,0.55)`
/// + 圆角 24 + `0 8px 32px rgba(79,126,245,0.08)` + 内边距 16 + 间距 12。
/// 这与 [GlassVariant.standard] 逐位一致，因此直接用 [GlassSurface]。
///
/// ⚠️ 唯一差异：Figma 的描边是 `1.188px`，`GlassSurface` 用 `1px`
/// （它的 `_defaultBorderWidth`）。0.188px 在任何设备上都不可能渲染出
/// 区别，**不为它单独开参数**。
class _GateCard extends StatelessWidget {
  const _GateCard({
    required this.icon,
    required this.iconSurface,
    required this.iconInk,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color iconSurface;
  final Color iconInk;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.all(_ProfileMetrics.gateCardPadding),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: _ProfileMetrics.gateIconTile,
            height: _ProfileMetrics.gateIconTile,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: AppRadius.borderXs,
            ),
            child: Icon(icon, size: _ProfileMetrics.gateIcon, color: iconInk),
          ),
          const SizedBox(width: _ProfileMetrics.gateGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTypography.profileListCardTitle),
                Text(
                  subtitle,
                  style: AppTypography.profileSmallMeta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: _ProfileMetrics.gateGap),
          trailing,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 文案
// ---------------------------------------------------------------------------

/// 空态中性文案。
///
/// ## ⚠️ 这些句子是 **Flutter 侧造的**（**D90**）
///
/// Figma 原型永远有数据（`Alex` / `Resume V3` / `4段`…），因此
/// **没有任何空态文案可抄**。而 `CLAUDE.md` §7 要求 Mock 默认返回空、
/// 让 Empty 态真实可见 —— 于是必须有话可说。
///
/// 本轮的选择是「**中性描述状态**：不描述用户、不承诺功能、
/// 不出现原型里的样例身份」：
///
/// ```text
/// ✅ 「职业画像未建立」          —— 陈述事实
/// ❌ 「快来完善你的职业档案吧」  —— 编产品话术
/// ❌ 「Alex」                    —— 那是 §7 明文禁止的编造样例数据
/// ```
///
/// 这些句子需要产品侧定稿，已登记 **D90**。
abstract final class _ProfileCopy {
  static const String emptyName = '职业画像未建立';
  static const String emptyHandle = '完成职业简历后自动建立';
  static const String assetsEmptySummary = '还没有职业资产，先去完成职业简历';
  static const String growthEmpty = '还没有成长记录';
  static const String resumeEmpty = '还没有上传简历';
  static const String proBannerUnknown = '查看 Careerly Pro 权益';
  static const String proBannerMember = 'Pro 会员 · 无限分析 AI 顾问';
}

// ---------------------------------------------------------------------------
// 页面几何
// ---------------------------------------------------------------------------

/// 「我的」主页的内部几何。
///
/// ## 为什么留在这里而不进 `AppSpacing` / `AppRadius`
///
/// 这些都是**本页特有**的绝对像素（Figma 逐条内联给出），
/// 不是全系统刻度 —— 与 `_SplashMetrics` / `_TopBarMetrics` 同一处置。
///
/// ⚠️ **颜色 / 字号 / 字体族 / 圆角 / 动画时长一律走 Token**
/// （`CLAUDE.md` §8.2 的硬规则），本类只放宽高与内边距。
abstract final class _ProfileMetrics {
  // ── 头部（Figma L3137）──────────────────────────────────────────────
  static const double headerHeight = 60;
  static const double headerInset = 24;
  static const double headerPaddingTop = 16;
  static const double headerPaddingBottom = 12;

  /// Logo 裁剪框 `109×27`（Figma L3139）。
  static const double wordmarkWidth = 109;
  static const double wordmarkHeight = 27;

  /// 齿轮钮 `40×40`，图标 `17×17`（Figma L3145 / L3150）。
  static const double gearSize = 40;
  static const double gearIcon = 17;

  // ── 头像（Figma L3163）───────────────────────────────────────────────
  static const double avatarSize = 96;
  static const double avatarVertical = 12;
  static const double avatarPlaceholderIcon = 40;

  // ── 信息卡（Figma L3169-3204）────────────────────────────────────────
  /// ⚠️ 信息卡的左右内边距是 **24**（Figma L3169），
  /// 而其余卡片是 **20**（Figma L3217 的 `px-5`）—— 两者**不同**。
  static const double infoCardInset = 24;
  static const double cardInset = 20;
  static const double infoCardVertical = 8;
  static const double infoCardPadding = 20;
  static const double infoCardBorderWidth = 1.5;
  static const double infoCardGap = 16;
  static const double nameHandleGap = 2;

  /// 会员徽章 `padding: 6px 12px`，图标 12，间隙 4（Figma L3173）。
  static const double badgePaddingH = 12;
  static const double badgePaddingV = 6;
  static const double badgeIcon = 12;
  static const double badgeIconGap = 4;

  /// Pro 横幅 `height: 53` + 圆角 16 + 左内边距 14（Figma L3190-3191）。
  static const double proBannerHeight = 53;
  static const double proBannerPaddingH = 14;
  static const double proGlyphGap = 8;
  static const double proTextGap = 2;

  // ── Tab 行（Figma L3206-3207）───────────────────────────────────────
  // ⚠️ 左右**不对称**：Figma 是 `paddingLeft: 30 / paddingRight: 20` ——
  // 左边多出的 10 是给横向滚动的首个胶囊留的视觉呼吸位。
  static const double tabsPaddingLeft = 30;
  static const double tabsPaddingRight = 20;
  static const double tabsPaddingVertical = 16;
  static const double tabsGap = 12;

  /// 胶囊 `padding: 10px 16px`（Figma L3211）。
  static const double tabPaddingH = 16;
  static const double tabPaddingV = 10;

  // ── 卡片列表（Figma L3217-3297）─────────────────────────────────────
  /// 资产卡 `height: 156`（Figma L3219）。
  static const double assetsCardHeight = 156;

  /// 成长区块 = 标题行（标题行高 24 + 下间距 12）+ 入口卡 72。
  static const double growthBlockHeight = 108;

  /// 简历卡 = `padding 16` × 2 + 内容 40（Figma L3282）。
  static const double resumeCardHeight = 72;

  /// 卡片之间 `space-y-3`（Figma L3276）。
  static const double cardGap = 12;

  // ── 资产卡内部（Figma L3222-3246）───────────────────────────────────
  static const double assetsHeaderHeight = 68;
  static const double assetsHeaderPaddingH = 16;
  static const double assetsHeaderPaddingTop = 16;
  static const double assetsHeaderPaddingBottom = 12;
  static const double assetsHeaderTextGap = 12;
  static const double assetGlyphTile = 40;
  static const double assetTileHeight = 73;

  /// ⚠️ Figma 的上下内边距是 `11 / 10`，**此处不设**（会溢出 4px）——
  /// 数值留档于此，理由见 [_AssetTile] 的类顶说明。
  /// static const double assetTilePaddingTop = 11;    // Figma L3235
  /// static const double assetTilePaddingBottom = 10; // Figma L3235
  static const double assetTilePaddingH = 10;
  static const double assetTileIcon = 17;
  static const double assetTileIconGap = 2;
  static const double assetsBottomGap = 15;

  /// 四张子卡整体距卡片左右边缘的留白。
  ///
  /// Figma 是 `left: 50%` + `translateX(-50%)` 居中，即总宽 326 时
  /// 左右各余 `(390 - 326) / 2 = 32`。这里取 **16** ——
  /// 因为子卡改成了等分（见 `_AssetTile` 的说明），
  /// 留白只需与卡片内边距（16）对齐即可。
  static const double assetTileEdgeInset = 16;

  /// 「查看全部」胶囊 `padding: 5px 10px`（Figma L3229）。
  static const double viewAllPaddingH = 10;
  static const double viewAllPaddingV = 5;
  static const double viewAllIcon = 12;
  static const double viewAllIconGap = 4;

  // ── 小卡片（Figma L3278-3290）──────────────────────────────────────
  static const double gateCardPadding = 16;
  static const double gateIconTile = 40;
  static const double gateIcon = 20;
  static const double gateGap = 12;
  static const double chevron = 14;
  static const double chipPaddingH = 8;
  static const double chipPaddingV = 2;

  /// 简历卡右列：「最新版」Chip 与雪佛龙之间 `gap: 6`（Figma L3289）。
  static const double chipChevronGap = 6;

  /// 滚动内容底部留白。
  ///
  /// 一级页面内容全高滚动（内容可从悬浮导航下方穿过），
  /// 因此导航避让必须由页面自己的滚动内容承担：
  /// Figma 根布局 `pb-24`（96）+ ProfilePage 自身 `pb-6`（24）= 120。
  static const double pageBottom = AppConstants.navigationBarContentInset + 24;

  /// 卡片列表的总高度。
  ///
  /// [AnimatedList] 没有 `shrinkWrap`，必须是确定高度 ——
  /// 三张卡片高度固定（见 [_SectionSlot] 的说明），总和即列表高度。
  static const double cardListHeight =
      assetsCardHeight +
      cardGap +
      growthBlockHeight +
      cardGap +
      resumeCardHeight +
      cardGap;

  /// 按区块取固定高度。
  static double heightOf(_ProfileSection section) => switch (section) {
    _ProfileSection.assets => assetsCardHeight,
    _ProfileSection.growth => growthBlockHeight,
    _ProfileSection.resume => resumeCardHeight,
  };
}
