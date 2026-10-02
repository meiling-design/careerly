/// Careerly 真实 API 数据层 barrel。
///
/// 与 `../mock/` 平行：Mock First（Phase 1 §十八）默认走 Mock，
/// 接真实后端时在 `lib/app/providers.dart` 里换绑即可。
///
/// ```bash
/// flutter run --dart-define=CAREERLY_USE_API=true \
///             --dart-define=CAREERLY_API_BASE_URL=http://10.0.2.2:8000
/// ```
///
/// 当前只实现后端已建端点对应的接口（auth / analysis / resume / quota /
/// growth / career assets / home summary / profile）；ai 在后端端点落地前
/// **继续走 Mock**，不在此预建。
library;

export 'api_analysis_repository.dart';
export 'api_auth_repository.dart';
export 'api_career_assets_repository.dart';
export 'api_client.dart';
export 'api_growth_repository.dart';
export 'api_home_summary_repository.dart';
export 'api_profile_repository.dart';
export 'api_resume_repository.dart';
