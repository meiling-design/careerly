import '../models/career_assets.dart';

/// 职业资产的数据访问接口。
///
/// 归属：「我的」→ 职业资产（IA §13）及其全部二级页
/// （工作经历 / 项目经历 / 专业技能 / 荣誉成果 / 职业能力画像）。
///
/// ## 为什么只有一个方法
///
/// 职业资产页要**同时**渲染四张分组卡 + 能力画像卡，主页还要从同一份数据
/// 派生四个计数。拆成五个方法会让这两处各发五个请求、各自维护五个四态 ——
/// 而它们在 Figma 里就是**一屏数据**。
///
/// 详情页（经历详情 / 项目详情）**不单独取数**：它们需要的条目
/// 已经在 [fetchAssets] 的返回里，由 State 层按 id 查找即可。
/// 因此本接口不提供 `fetchWorkExperienceById` —— 那是原子化拆分，
/// 与「一屏一取」的取舍相冲突（`CLAUDE.md` §6.5）。
///
/// ## 分层
///
/// `UI → CareerAssetsProvider → 本接口 → MockCareerAssetsRepository`
abstract interface class CareerAssetsRepository {
  /// 取回全部职业资产。
  ///
  /// 失败时**抛异常**（由 State 层归一化为 `AppError`），不返回错误码。
  /// 无数据时返回 `CareerAssets.empty`，**不是** `null` ——
  /// 「没有资产」是一个合法状态，不是错误。
  Future<CareerAssets> fetchAssets();
}
