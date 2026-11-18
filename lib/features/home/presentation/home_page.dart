import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/home_summary.dart';
import '../../../design_system/components/components.dart';
import '../../profile/state/growth_celebration_provider.dart';
import '../../profile/state/user_profile_provider.dart';
import '../state/home_provider.dart';
import 'home_content.dart';
import 'widgets/home_analysis_section.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/home_stil_cards.dart';

/// 首页 —— 「我现在在哪？」
///
/// 真值来源：Figma `HomePage`（`App.tsx` L1341-1480）。
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
  GoRouter? _router;
  final GlobalKey _matchChangesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 首帧后再触发加载：避免在 build 期间 notifyListeners。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().load();
      // Hero 的问好要显示真实昵称；资料未加载时先拉一次
      // （没有 Provider 的隔离测试环境里为 null，问好只显示问候语）。
      final UserProfileProvider? profile = Provider.of<UserProfileProvider?>(
        context,
        listen: false,
      );
      if (profile != null && profile.data == null) profile.load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GoRouter? router = GoRouter.maybeOf(context);
    if (identical(router, _router)) return;
    _router?.routeInformationProvider.removeListener(_onRouteChanged);
    _router = router;
    _router?.routeInformationProvider.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    _router?.routeInformationProvider.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final HomeProvider provider = context.watch<HomeProvider>();
    final GrowthCelebrationProvider? celebrations =
        Provider.of<GrowthCelebrationProvider?>(context);
    final UserProfileProvider? profile = Provider.of<UserProfileProvider?>(
      context,
    );
    final String greeting = homeGreetingFor(DateTime.now());
    final String userName = profile?.data?.displayName ?? '';
    final bool isHomeVisible =
        _router == null ||
        _router!.routeInformationProvider.value.uri.path == AppRoutes.home;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: CareerlyScaffold(
        // Figma 首页没有独立标题栏；欢迎 Hero 延伸至页面左右边缘。
        showAppBar: false,
        applySafeArea: false,
        padding: EdgeInsets.zero,
        child: CareerlyAsyncStateView<HomeSummary>(
          state: provider.state,
          onRetry: provider.load,
          loadingMessage: '正在载入你的职业主页',
          builder: (BuildContext context, HomeSummary summary) => _HomeContent(
            content: HomeContent.forStage(
              provider.stage,
              summary,
              greeting: greeting,
              userName: userName,
            ),
            celebration: isHomeVisible ? celebrations?.nextPending : null,
            onCelebrationFinished: celebrations?.consume ?? _ignoreCelebration,
            matchChangesKey: _matchChangesKey,
            onJumpToChanges: _scrollToChanges,
          ),
        ),
      ),
    );
  }

  Future<void> _scrollToChanges() async {
    final BuildContext? targetContext = _matchChangesKey.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      alignment: 0.08,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  static void _ignoreCelebration(int _) {}
}

/// 三态共用的版面骨架。
///
/// ```text
/// Hero             全宽欢迎区
/// StilCards        2×2 卡片
/// AnalysisSection  最新变化操作 + 岗位匹配变化
/// ```
///
/// Hero 与卡片之间、卡片与操作区之间均为 Figma 的 14px 间距。
class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.content,
    required this.celebration,
    required this.onCelebrationFinished,
    required this.matchChangesKey,
    required this.onJumpToChanges,
  });

  final HomeContent content;
  final GrowthCelebration? celebration;
  final ValueChanged<int> onCelebrationFinished;
  final GlobalKey matchChangesKey;
  final VoidCallback onJumpToChanges;

  static const double _blockGap = 14;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 底部留白由页面自己承担（Figma 内容区 `pb-24`），
      // 这样内容可以滚到悬浮导航下方，而末项仍能在导航上方停住。
      padding: const EdgeInsets.only(
        bottom: AppConstants.navigationBarContentInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HomeHeroCard(
            content: content.hero,
            // 三态共用同一个「＋新建分析」入口：分析 Tab 的新建分析页。
            onAction: () => context.go(AppRoutes.analysis),
            celebration: celebration,
            onCelebrationFinished: onCelebrationFinished,
          ),
          const SizedBox(height: _blockGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: HomeStilCards(
                  cards: content.stilCards,
                  onOpenAi: () => context.go(AppRoutes.ai),
                  onOpenAnalysis: () => context.go(AppRoutes.analysis),
                  onOpenGrowth: () => context.go(AppRoutes.profileGrowthRecord),
                ),
              ),
            ),
          ),
          const SizedBox(height: _blockGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HomeAnalysisSection(
              content: content.section,
              changesKey: matchChangesKey,
              onNewAnalysis: () => context.go(AppRoutes.analysis),
              onJumpToChanges: onJumpToChanges,
              onViewAll: () => context.go(AppRoutes.analysis),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
