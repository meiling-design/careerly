import '../models/home_summary.dart';
import '../repositories/home_repository.dart';
import 'mock_config.dart';

/// [HomeRepository] 的 Mock 实现。
///
/// ⚠️ **默认返回空摘要**，让首页渲染 Empty State（PRD §8 新用户状态）。
///
/// 这里**刻意不编造**职业状态、匹配度、成长记录等看起来像真实产品的数据——
/// Phase 1 不产生业务数据，也不预设产品文案。
/// 真实的 Mock 数据在 Phase 5（首页）随 UI 一起补齐。
class MockHomeRepository implements HomeRepository {
  MockHomeRepository({MockConfig? config})
    : _config = config ?? MockSettings.config;

  final MockConfig _config;

  @override
  Future<HomeSummary> fetchSummary() async {
    await _config.simulate();
    return HomeSummary.empty;
  }
}
