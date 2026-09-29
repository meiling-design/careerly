import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../data/models/home_summary.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/home_provider.dart';
import 'home_content.dart';
import 'widgets/home_analysis_section.dart';
import 'widgets/home_header.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/home_stil_cards.dart';

/// 首页 —— 「我现在在哪？」
///
/// 真值来源：Figma `HomePage`（`App.tsx` L987-1182），
/// 版面为 `px-5 pt-3 pb-6 space-y-4`（左右 20 / 上 12 / 下 24 / 块间 16）。
///
/// ## 三态（内容）与四态（加载）不是一回事
///
/// ```text
/// 四态    AsyncState 的加载生命周期：Loading / Success / Error / Retry
///         → 由 [CareerlyAsyncStateView] 承载（CLAUDE.md §5.5）
/// 三态    成功态**内部**的内容阶段（D64）：
///           State 01 首次使用（没有职业基线）
///           State 02 已有简历（有基线、无岗位分析）
///           State 03 已有简历 + 岗位分析（= Figma 现有的那版首页）
///         → 由 [HomeProvider.stage] 判定，[HomeContent] 装配
/// ```
///
/// ⚠️ **不传 `isEmpty`** —— 首页的「空」本身就是**要展示的内容**
/// （State 01），若交给 [CareerlyAsyncStateView] 的通用 Empty 分支，
/// 用户会看到一句「暂无内容」，而不是 D64 规定的引导页。
///
/// ## 视觉复用
///
/// 三态**共用同一套 Figma 视觉**，只有文字不同（D64 ①bis）。
/// 因此这五个区块的组件只认识 `HomeContent` 的字段，
/// 不认识 [HomeStage] —— 视觉层没有可以分叉的地方。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 首帧后再触发加载：避免在 build 期间 notifyListeners。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final HomeProvider provider = context.watch<HomeProvider>();

    return CareerlyScaffold(
      // Figma 首页没有标题栏 —— 顶部是它自己的身份区（[HomeHeader]）。
      showAppBar: false,
      // 页面内边距：Figma `px-5 pt-3 pb-6`。
      //
      // ⚠️ 底部这 24 **不是**导航避让 —— 导航避让（Figma 容器的 `pb-24`）
      // 已由 [CareerlyShell] 统一提供（`navigationBarContentInset`）。
      // 两者是**相加**关系（Figma 里就是容器 `pb-24` + 页面 `pb-6`），
      // 故这里照抄页面的 24，不减。
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.mdLg,
        AppSpacing.sm,
        AppSpacing.mdLg,
        AppSpacing.lg,
      ),
      child: CareerlyAsyncStateView<HomeSummary>(
        state: provider.state,
        onRetry: provider.load,
        loadingMessage: '正在载入你的职业主页',
        builder: (BuildContext context, HomeSummary summary) =>
            _HomeContent(
              content: HomeContent.forStage(provider.stage, summary),
            ),
      ),
    );
  }
}

/// 三态共用的版面骨架。
///
/// ```text
/// Header           身份区
/// Hero             职业主页主卡
/// StilCards        2×2 卡片
/// AnalysisSection  筛选行 + 岗位匹配变化
/// ```
///
/// 块间一律 16（Figma `space-y-4`）—— 这是**页面级**节奏，
/// 与各区块内部自己的 gap 不是一回事。
class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.content});

  final HomeContent content;

  /// Figma `space-y-4`。
  static const double _blockGap = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HomeHeader(title: content.headerTitle),
          const SizedBox(height: _blockGap),
          HomeHeroCard(
            content: content.hero,
            onAction: _onHeroAction(context, content.hero.action),
          ),
          const SizedBox(height: _blockGap),
          HomeStilCards(
            cards: content.stilCards,
            onOpenAi: () => context.go(AppRoutes.ai),
            onOpenAnalysis: () => context.go(AppRoutes.analysis),
            // 成长归属「我的 → 成长足迹」（IA §2.2），那一层尚未实现
            // → 先落「我的」Tab。见 [HomeCardTarget.growth] / D81。
            onOpenGrowth: () => context.go(AppRoutes.profile),
          ),
          const SizedBox(height: _blockGap),
          HomeAnalysisSection(
            content: content.section,
            onNewAnalysis: () => context.go(AppRoutes.analysis),
            onViewAll: () => context.go(AppRoutes.analysis),
          ),
        ],
      ),
    );
  }

  /// Hero 卡内小按钮的点击目标。
  ///
  /// 目标由 [HomeHeroContent.action] 给出，**不**从按钮文案反推 ——
  /// 改文案不会悄悄改掉跳转。
  ///
  /// ⚠️ 「上传简历」目前复用 Onboarding 的**提交简历**页
  /// —— 应用内**没有**第二处简历上传入口（`我的 → 我的简历` 属 Phase 6）。
  /// 复用而非新建页面，是因为新建一级页面须先经产品侧裁决。
  /// 该归属问题登记 **待裁决 · D80**。
  VoidCallback _onHeroAction(BuildContext context, HomeHeroAction action) {
    return switch (action) {
      HomeHeroAction.uploadResume => () =>
        context.go(AppRoutes.onboardingResume),
      // 目标岗位来自 JD，而 JD 入口只在「分析」。
      HomeHeroAction.addJob => () => context.go(AppRoutes.analysis),
      HomeHeroAction.viewAnalysis => () => context.go(AppRoutes.analysis),
    };
  }
}
