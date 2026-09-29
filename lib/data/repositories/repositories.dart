/// Careerly Repository 接口 barrel。
///
/// 业务代码（Provider）依赖这些**抽象接口**，
/// 而不是 `../mock/` 下的具体实现——这样 Mock 换真实 API 时不需要改 Provider。
library;

export 'ai_repository.dart';
export 'analysis_repository.dart';
export 'auth_repository.dart';
export 'career_assets_repository.dart';
export 'growth_repository.dart';
export 'home_repository.dart';
export 'profile_repository.dart';
export 'resume_repository.dart';
