import '../models/home_summary.dart';

/// 首页数据访问接口。
///
/// 分层依据（Phase 1 §十六 / §十八）：
/// `UI → State → Repository → Data Source (API | Local | Mock)`
///
/// **页面不得直接调用本接口，必须经由 Provider。**
///
/// 依据 Baseline §3.1：首页是「看见现在」，
/// 只返回**摘要**，不返回完整分析结果。
abstract interface class HomeRepository {
  /// 读取首页摘要。
  Future<HomeSummary> fetchSummary();
}
