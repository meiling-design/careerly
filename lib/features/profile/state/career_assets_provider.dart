import '../../../core/state/state.dart';
import '../../../data/models/award.dart';
import '../../../data/models/capability.dart';
import '../../../data/models/career_assets.dart';
import '../../../data/models/career_skill.dart';
import '../../../data/models/project_experience.dart';
import '../../../data/models/work_experience.dart';
import '../../../data/repositories/career_assets_repository.dart';

/// 职业资产状态。
///
/// 归属：「我的」→ 职业资产（IA §13）及其全部二级页。
///
/// ## 一次取回，多处消费
///
/// [load] 一次取回整个 [CareerAssets]，主页、职业资产页、四张分组卡页
/// 与两个详情页**都从这一份数据读**。详情页不单独取数 ——
/// 用 [workById] / [projectById] 在当前数据里查。
///
/// 这样做的理由：它们在 Figma 里就是**一屏数据**，拆开会让
/// 「从列表进详情」变成一次多余的网络往返，并且详情页要独立处理四态。
///
/// ## ⚠️ 详情页的深链
///
/// [workById] / [projectById] 在**数据尚未加载**（或不存在该 id）时返回 `null`。
/// 调用方要先判断 [isLoading]，再判断 `null` ——
/// 前者是「还没到」，后者是「没有这条」，两者不能合并成同一个空态。
class CareerAssetsProvider extends AsyncStateNotifier<CareerAssets> {
  CareerAssetsProvider(this._repository);

  final CareerAssetsRepository _repository;

  /// 取回全部职业资产。
  ///
  /// 无数据时 `state` 走向 success 且值为 `CareerAssets.empty` ——
  /// 「没有资产」是合法状态而不是错误，页面据此渲染 Empty。
  Future<void> load() => execute(_repository.fetchAssets);

  /// 全部资产是否为空。
  bool get isEmpty => data?.isEmpty ?? true;

  /// 按 id 取一段工作经历。找不到时返回 `null`。
  WorkExperience? workById(String id) {
    final CareerAssets? assets = data;
    if (assets == null) return null;
    for (final WorkExperience item in assets.workExperiences) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// 按 id 取一个项目经历。找不到时返回 `null`。
  ProjectExperience? projectById(String id) {
    final CareerAssets? assets = data;
    if (assets == null) return null;
    for (final ProjectExperience item in assets.projects) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// 全部工作经历，按数据顺序（新的在前）。
  ///
  /// 供工作经历列表页与职业资产页的展开面板读取 —— 页面**不直接摸 [data]**，
  /// 这样「数据未加载」与「数据为空」在页面侧都是同一个空列表，
  /// 无需各自写 `?? const []`。
  List<WorkExperience> get workExperiences =>
      data?.workExperiences ?? const <WorkExperience>[];

  /// 全部项目经历。
  List<ProjectExperience> get projects =>
      data?.projects ?? const <ProjectExperience>[];

  /// 全部奖项。
  List<Award> get awards => data?.awards ?? const <Award>[];

  /// 全部技能分组（**保持分组**，专业技能页按分类渲染）。
  ///
  /// 与 [skillCount] 的关系：后者是**展平后**的总数，用于「N 项」计数。
  List<SkillGroup> get skillGroups =>
      data?.skillGroups ?? const <SkillGroup>[];

  /// 各分组展平后的技能总数。技能页顶栏的「N 项」由此派生。
  int get skillCount => data?.skillCount ?? 0;

  /// 全部能力。
  List<Capability> get capabilities => data?.capabilities ?? const <Capability>[];

  /// 能力画像卡上展示的能力条。
  ///
  /// Figma 的能力画像卡只画**前 3 条**（`src/App.tsx` L3615-3617），
  /// 而卡底写的是「5 个维度」（L3623）—— 卡片只放得下 3 条。
  /// 因此这里把「展示 3 条」定为读取规则，而不是让页面各自 `take(3)`。
  List<Capability> get capabilityPreview =>
      capabilities.take(_capabilityPreviewCount).toList(growable: false);

  static const int _capabilityPreviewCount = 3;
}
