/// Careerly Mock Data Layer barrel。
///
/// Phase 1（§十八 Mock First）：Repository 全部指向这里的 Mock 实现。
/// 接入真实后端时，只需在 `lib/app/providers.dart` 里替换绑定，
/// Provider 与 UI 不需要改动。
library;

export 'demo_analysis_fixture.dart';
export 'demo_fixture.dart';
export 'mock_ai_repository.dart';
export 'mock_analysis_repository.dart';
export 'mock_auth_repository.dart';
export 'mock_career_assets_repository.dart';
export 'mock_config.dart';
export 'mock_growth_repository.dart';
export 'mock_home_repository.dart';
export 'mock_profile_repository.dart';
export 'mock_resume_repository.dart';
