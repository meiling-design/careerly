import '../../../core/state/state.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/profile_repository.dart';

/// 「我的」身份资料状态（昵称 / 账号名 / 会员徽章）。
///
/// 归属：「我的」顶部信息卡。
///
/// ## 为什么与 [CareerAssetsProvider] 分开
///
/// 两者在「我的」主页上同屏出现，但**数据来源不同**：这一份是账号数据，
/// 那一份是职业数据。合成一个 State 会让任一失败连带另一块也无数据
/// （`CLAUDE.md` §6.3「按领域拆分」）。
///
/// ## ⚠️ 空资料是**合法状态**，不是错误
///
/// `CLAUDE.md` §7 要求 Mock 默认返回空，让 Empty 态真实可见。
/// 因此 [load] 成功但 [isEmpty] 为 `true` 是**预期路径**，
/// 页面必须为它渲染中性占位文案（见 `UserProfile` 顶部说明 · **D90**）。
class UserProfileProvider extends AsyncStateNotifier<UserProfile> {
  UserProfileProvider(this._repository);

  final ProfileRepository _repository;

  /// 取回当前用户的身份资料。
  Future<void> load() => execute(_repository.fetchUserProfile);

  /// 是否没有任何身份资料。
  bool get isEmpty => data?.isEmpty ?? true;
}
