import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/services/resume_file_picker.dart';
import '../data/api/api.dart';
import '../data/mock/mock.dart';
import '../data/repositories/repositories.dart';
import '../features/analysis/state/analysis_provider.dart';
import '../features/ai/state/ai_provider.dart';
import '../features/home/state/home_provider.dart';
import '../features/onboarding/state/onboarding_provider.dart';
import '../features/profile/state/career_assets_provider.dart';
import '../features/profile/state/growth_provider.dart';
import '../features/profile/state/resume_provider.dart';
import '../features/profile/state/user_profile_provider.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'state/app_provider.dart';

/// Careerly 依赖装配。
///
/// 这是**唯一**决定「用哪个实现」的地方。
///
/// ## Mock First（Phase 1 §十八）
///
/// 当前全部 Repository 绑定到 `lib/data/mock/` 下的 Mock 实现。
/// 接入真实后端时，**只改这一个文件**：
///
/// ```dart
/// // 现在
/// Provider<HomeRepository>(create: (_) => MockHomeRepository()),
/// // 接入 API 后
/// Provider<HomeRepository>(create: (ctx) => ApiHomeRepository(ctx.read<ApiClient>())),
/// ```
///
/// Provider 与 UI 一行都不用动——因为它们依赖的是抽象接口。
///
/// ## 为什么 GoRouter 也在这里
///
/// `GoRouter` 是 `ChangeNotifier`，必须**只创建一次**。
/// 若在 `build` 里 new，每次重建都会重置导航栈。
/// [initialLocation] 只透传给路由，默认首页（见 `createAppRouter` 的说明）。
List<SingleChildWidget> careerlyProviders({
  String initialLocation = AppRoutes.home,

  /// 测试 / 调试用的**尾部覆盖**。
  ///
  /// `MultiProvider` 同类型查找时**后注册者胜出**，
  /// 因此把 Fake / Stub 追加在列表末尾即可替换上面的生产实现，
  /// 不必改动任何默认装配。生产代码**不要传**这个参数。
  List<SingleChildWidget> overrides = const <SingleChildWidget>[],

  /// 外部预建的 [ApiClient]（**P1-6 / D-B**）。
  ///
  /// 冷启动需要在 `runApp` **之前**完成 `restoreSession()`（异步读 Keystore），
  /// 而这里是同步的 `List` 构建 —— 所以由 `main()` 建好并恢复完再传进来。
  /// 不传则本函数自建一个（内存 TokenStore），行为与 P1-6 之前一致。
  ApiClient? apiClient,
}) {
  // 真实后端开关：--dart-define=CAREERLY_USE_API=true 时，
  // 后端已建端点对应的接口（auth / analysis / resume / quota / growth /
  // career assets / home summary / profile）改绑 API 实现，
  // 其余接口（ai）在后端端点落地前继续走 Mock。
  const bool useApi = ApiClient.useApi;

  final ApiClient client = apiClient ?? ApiClient();

  return <SingleChildWidget>[
    // -------------------------------------------------------------------------
    // Data Source 层（默认 Mock；CAREERLY_USE_API=true 时部分换绑 API）
    // -------------------------------------------------------------------------
    Provider<ApiClient>(
      create: (_) => client,
      dispose: (_, ApiClient c) => c.dispose(),
    ),
    Provider<HomeRepository>(
      create: (_) =>
          useApi ? ApiHomeSummaryRepository(client) : MockHomeRepository(),
    ),
    Provider<AIRepository>(create: (_) => MockAIRepository()),
    Provider<AnalysisRepository>(
      create: (_) =>
          useApi ? ApiAnalysisRepository(client) : MockAnalysisRepository(),
    ),
    Provider<ResumeRepository>(
      create: (_) =>
          useApi ? ApiResumeRepository(client) : MockResumeRepository(),
    ),
    // 成长足迹（P2-5）：后端 /api/v1/growth/* 已落地，随开关切真实 API。
    Provider<GrowthRepository>(
      create: (_) =>
          useApi ? ApiGrowthRepository(client) : MockGrowthRepository(),
    ),
    // Onboarding（Phase 4 批 1）。⚠️ 纯 Mock，不保存会话 —— 见 AuthRepository 的说明。
    Provider<AuthRepository>(
      create: (_) =>
          useApi ? ApiAuthRepository(client) : MockAuthRepository(),
    ),
    // 「我的」职业资产（P3-5a）：后端 /api/v1/career/assets 已落地，随开关切真实 API。
    Provider<CareerAssetsRepository>(
      create: (_) => useApi
          ? ApiCareerAssetsRepository(client)
          : MockCareerAssetsRepository(),
    ),
    // 「我的」身份资料（P3-5a）：后端 /api/v1/profile 已落地，随开关切真实 API。
    Provider<ProfileRepository>(
      create: (_) =>
          useApi ? ApiProfileRepository(client) : MockProfileRepository(),
    ),
    // 「选择文件」的平台网关（D67 关闭）。走平台通道，
    // Widget 测试里用 overrides 换成 Fake（不触发真通道）。
    Provider<ResumeFilePicker>(create: (_) => const DefaultResumeFilePicker()),

    // -------------------------------------------------------------------------
    // Router
    // -------------------------------------------------------------------------
    Provider<GoRouter>(
      create: (_) => createAppRouter(initialLocation: initialLocation),
      dispose: (_, GoRouter router) => router.dispose(),
    ),

    // -------------------------------------------------------------------------
    // App 级状态
    // -------------------------------------------------------------------------
    ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),

    // -------------------------------------------------------------------------
    // 领域状态
    //
    // Baseline §7.3：每个领域一个 ChangeNotifier，
    // 避免无限膨胀的 Global AppState。
    //
    // 注意：CareerProvider / AIProvider 此刻没有数据源，建了只会是死代码。
    // CareerProvider 随 Phase 8（我的）建立，AIProvider 随 Phase 7（AI）建立。
    //
    // ⚠️ Phase 4 批 1 **建立的是 OnboardingProvider，不是 AuthProvider** ——
    // 它只承载注册提交的生命周期状态，**不持有登录态**（本轮无会话持久化）。
    // 等到真的需要「当前用户是谁」时再建 AuthProvider，届时它才是死代码的反面。
    // -------------------------------------------------------------------------
    ChangeNotifierProvider<OnboardingProvider>(
      create: (BuildContext context) =>
          OnboardingProvider(context.read<AuthRepository>()),
    ),
    ChangeNotifierProvider<HomeProvider>(
      create: (BuildContext context) =>
          HomeProvider(context.read<HomeRepository>()),
    ),
    ChangeNotifierProvider<AnalysisProvider>(
      create: (BuildContext context) =>
          AnalysisProvider(context.read<AnalysisRepository>()),
    ),
    ChangeNotifierProvider<AIProvider>(
      create: (BuildContext context) =>
          AIProvider(context.read<AIRepository>()),
    ),
    ChangeNotifierProvider<ResumeProvider>(
      create: (BuildContext context) =>
          ResumeProvider(context.read<ResumeRepository>()),
    ),
    ChangeNotifierProvider<GrowthProvider>(
      create: (BuildContext context) =>
          GrowthProvider(context.read<GrowthRepository>()),
    ),
    // 成长时间线与月网格是两个粒度不同的数据流（Figma 两份源数据），
    // 因此两个 Provider —— 合成一个会让任一为空连带另一块也无数据。
    ChangeNotifierProvider<GrowthTimelineProvider>(
      create: (BuildContext context) =>
          GrowthTimelineProvider(context.read<GrowthRepository>()),
    ),
    // Phase 8 批 1：职业资产与身份资料是**两个领域**，因此两个 Provider ——
    // 合成一个会让任一失败连带另一块也无数据（CLAUDE.md §6.3）。
    ChangeNotifierProvider<CareerAssetsProvider>(
      create: (BuildContext context) =>
          CareerAssetsProvider(context.read<CareerAssetsRepository>()),
    ),
    ChangeNotifierProvider<UserProfileProvider>(
      create: (BuildContext context) =>
          UserProfileProvider(context.read<ProfileRepository>()),
    ),

    // -------------------------------------------------------------------------
    // 尾部覆盖（仅测试 / 调试）：同类型后注册者胜出。
    // -------------------------------------------------------------------------
    ...overrides,
  ];
}
