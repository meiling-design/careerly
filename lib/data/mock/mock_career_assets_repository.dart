import '../models/career_assets.dart';
import '../repositories/career_assets_repository.dart';
import 'demo_fixture.dart';
import 'mock_config.dart';

/// [CareerAssetsRepository] 的 Mock 实现。
///
/// ## 两条轨道（`MockConfig.demoData`）
///
/// ```text
/// false（默认） → CareerAssets.empty   —— 让 Empty 态真实可见（CLAUDE.md §7）
/// true          → DemoFixture.careerAssets —— Figma 原型样例数据，供视觉比对
/// ```
///
/// ⚠️ **默认路径返回空，不返回任何编造的数据**。演示数据的位置与理由
/// 见 `demo_fixture.dart` 顶部说明。
class MockCareerAssetsRepository implements CareerAssetsRepository {
  MockCareerAssetsRepository({MockConfig? config})
    : _config = config ?? MockSettings.config;

  final MockConfig _config;

  @override
  Future<CareerAssets> fetchAssets() async {
    await _config.simulate();
    return _config.demoData ? DemoFixture.careerAssets : CareerAssets.empty;
  }
}
