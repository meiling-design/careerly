import '../../../core/state/state.dart';
import '../../../data/models/home_summary.dart';
import '../../../data/repositories/home_repository.dart';

/// 首页的**三态**（产品侧裁决 **D64** ①）。
///
/// ```text
/// State 01  首次使用：无简历 / 无岗位   →  引导上传简历
/// State 02  已有简历：无岗位分析        →  引导添加 JD
/// State 03  已有简历 + 岗位分析         →  Figma 现有的完整 Dashboard
/// ```
///
/// ## 为什么是「三态」而不是「四态」
///
/// 三态与 `CLAUDE.md` §5.5 的四态**不是同一层概念**，两者并存：
///
/// | 层 | 含义 | 本页的载体 |
/// |---|---|---|
/// | 四态 | 数据**加载**的生命周期 | [AsyncState]（Loading / Failure / Success） |
/// | 三态 | 数据**内容**所处的阶段 | 本枚举 |
///
/// 也就是说：`AsyncSuccess` 之后，页面还要按本枚举决定渲染哪一套文案。
///
/// ## 判定依据（D64 ⑥）
///
/// 三态由**真实数据是否存在**驱动，**不**由写死的演示状态驱动：
///
/// ```text
/// 是否有职业基线（ResumeProfile.hasBaseline）  →  State 01 / 02 的分界
/// 是否有分析数据（建议 / 匹配度标题 / 匹配变化） →  State 02 / 03 的分界
/// ```
///
/// ⚠️ 判定**只读 [HomeSummary]**，不跨域去读 `ResumeProvider`。
/// 依据 `CLAUDE.md` §6.1，首页的数据一律经由自己的 Repository 拿；
/// 「是否已建立基线」在真实后端是**摘要接口的一个字段**，不是前端拼出来的。
///
/// ⚠️ Figma 首页硬编码的 `Alex` / `86%` / `AI 产品经理` / `4/6/12/5`
/// **不得**进入 Mock（`CLAUDE.md` §7 / D64 ⑥）。
enum HomeStage {
  /// State 01 —— 首次使用，尚未建立职业基线。引导上传简历。
  firstUse,

  /// State 02 —— 已有职业基线，但还没有任何岗位分析。引导添加 JD。
  baselineOnly,

  /// State 03 —— 已有基线 + 已有岗位分析，展示完整 Dashboard。
  analyzed,
}

/// 首页状态。
///
/// 分层：`UI(HomePage) → State(本类) → Repository(HomeRepository) → Mock`
///
/// Baseline §7.3 要求「避免无限膨胀的 Global AppState」——
/// 因此每个领域一个 ChangeNotifier，首页只持有首页摘要。
class HomeProvider extends AsyncStateNotifier<HomeSummary> {
  HomeProvider(this._repository);

  final HomeRepository _repository;

  /// 读取首页摘要。
  ///
  /// 依据 Baseline §3.1，首页是「看见现在」，只拿摘要。
  Future<void> load() => execute(_repository.fetchSummary);

  /// 当前所处的阶段（见 [HomeStage]）。
  ///
  /// 加载中 / 失败时摘要不可用，此时返回 [HomeStage.firstUse] ——
  /// 这是**安全默认**：`CareerlyAsyncStateView` 在这两种状态下根本不会
  /// 走到内容分支，本值不会被渲染出来。
  HomeStage get stage {
    final HomeSummary? summary = data;
    if (summary == null || !summary.hasBaseline) return HomeStage.firstUse;
    final bool hasAnalysis =
        summary.latestTopScore != null ||
        summary.matchChanges.isNotEmpty ||
        summary.suggestions.isNotEmpty ||
        // 首次分析或分数未变化时，后端不会产生 matchChanges。
        summary.headline.trim().startsWith('当前与目标岗位的匹配度');
    return hasAnalysis ? HomeStage.analyzed : HomeStage.baselineOnly;
  }
}
