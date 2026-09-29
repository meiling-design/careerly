import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import 'demo_fixture.dart';
import 'mock_config.dart';

/// [ProfileRepository] 的 Mock 实现。
///
/// ## 两条轨道（`MockConfig.demoData`）
///
/// ```text
/// false（默认） → UserProfile.empty        —— 中性空态（CLAUDE.md §7）
/// true          → DemoFixture.userProfile  —— Figma 的 Alex / @elmasekeri
/// ```
///
/// ⚠️ **默认路径不返回「Alex」这类样例身份** —— `CLAUDE.md` §7 点名禁止的
/// 正是这种假数据。演示身份只在 `--dart-define=CAREERLY_DEMO_DATA=true` 时出现。
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({MockConfig? config})
    : _config = config ?? MockSettings.config;

  final MockConfig _config;

  @override
  Future<UserProfile> fetchUserProfile() async {
    await _config.simulate();
    return _config.demoData ? DemoFixture.userProfile : UserProfile.empty;
  }
}
