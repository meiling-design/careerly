/// Careerly 真实 API 数据层 barrel。
///
/// 与 `../mock/` 平行：接真实后端时在 `lib/app/providers.dart` 里换绑即可。
///
/// ```bash
/// adb reverse tcp:8000 tcp:8000   # 每次重插 USB 后跑一次
/// flutter run                      # main() 默认即接真实后端
/// flutter run --dart-define=CAREERLY_USE_API=false   # 回到 Mock
/// flutter run --dart-define=CAREERLY_API_BASE_URL=http://192.168.x.x:8000
/// ```
///
/// 默认值由**入口**决定：`main()` 取真实后端，测试与 `CareerlyApp`
/// 的自身默认仍是 Mock（见 `providers.dart` 的 `useApi` 参数）。
///
/// 当前只实现后端已建端点对应的接口（auth / analysis / resume / quota /
/// growth / career assets / home summary / profile / ai）。
library;

export 'analysis_task_store.dart';
export 'api_ai_repository.dart';
export 'api_analysis_repository.dart';
export 'api_auth_repository.dart';
export 'api_career_assets_repository.dart';
export 'api_client.dart';
export 'api_growth_repository.dart';
export 'api_home_summary_repository.dart';
export 'api_profile_repository.dart';
export 'api_resume_repository.dart';
