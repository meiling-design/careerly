import '../models/user_profile.dart';

/// 「我的」页身份资料的数据访问接口。
///
/// 归属：「我的」顶部身份区（昵称 / 账号名 / 会员徽章）。
///
/// ## 与 `CareerAssetsRepository` 的分工
///
/// ```text
/// CareerAssetsRepository   职业资产（经历 / 项目 / 技能 / 荣誉 / 能力）
/// ProfileRepository        账号身份（昵称 / 账号名 / 会员标签）
/// ```
///
/// 两者在「我的」主页上同屏出现，但**数据来源不同**：前者是职业数据，
/// 后者是账号数据。因此分成两个接口、两个 State，而不是合成一个聚合 ——
/// 否则任一失败会连带另一块也无数据（`CLAUDE.md` §6.3「按领域拆分」）。
///
/// ## ⚠️ 当前只有「读」，没有「写」
///
/// 没有 `updateProfile` —— 编辑资料这一功能在 PRD / IA / Figma 里
/// **都没有出现**，因此不预建（`CLAUDE.md` §6.5）。
abstract interface class ProfileRepository {
  /// 取回当前用户的身份资料。
  ///
  /// ⚠️ **当前数据来源不存在**：`AuthRepository.register` 不保存会话
  /// （D52：不引入本地存储依赖），注册时填的姓名读不回来。
  /// 因此 Mock 默认返回 [UserProfile.empty]，
  /// 相关未决项登记 **待裁决 · D90**（`docs/05_progress/TODO.md` §3.1）。
  ///
  /// 失败时**抛异常**（由 State 层归一化为 `AppError`）。
  Future<UserProfile> fetchUserProfile();
}
