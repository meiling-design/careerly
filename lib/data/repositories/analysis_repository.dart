import '../models/analysis_project.dart';
import '../models/analysis_task.dart';
import '../models/job.dart';
import '../models/parsed_job.dart';
import '../models/quota_state.dart';

/// 分析数据访问接口。
///
/// 归属（Baseline §3.2 / IA §17）：**分析项目只属于「分析」**。
/// 历史分析不会出现在「我的」。
///
/// Phase 1 只定义**接口形状**，不实现分析引擎、
/// 不实现 JD 解析、不实现匹配计算（Phase 1 §八明确禁止）。
abstract interface class AnalysisRepository {
  /// 读取全部分析项目（历史分析列表）。
  Future<List<AnalysisProject>> fetchProjects();

  /// 读取单个分析项目。
  Future<AnalysisProject?> fetchProject(String projectId);

  /// 读取用户的历史岗位库。
  ///
  /// PRD §9.3：岗位来源为「用户粘贴 JD」或「从历史岗位添加」。
  Future<List<Job>> fetchJobLibrary();

  /// 抓取一条岗位链接，返回可回填 JD 文本框的岗位信息。
  ///
  /// ⚠️ **这不是分析**：不扣额度、不建分析任务
  /// （`CLAUDE.md` §5.2 —— 上传简历 / 粘贴 JD / 进分析页都不扣）。
  /// 抓到的 [ParsedJob.description] 回填到 JD 输入框，由用户确认或修改后，
  /// 再由 Provider 调 [analyze]。
  ///
  /// 抓不到（链接无效 / 抓不到正文 / 爬虫失败）**必须抛错**，
  /// 不得静默返回空 —— 用户正盯着一个空表单等结果。
  Future<ParsedJob> parseJobUrl(String url);

  /// 使用一条 JD 创建并执行一次单岗位分析。
  ///
  /// 额度扣减由 Provider 在调用前负责；Repository 只负责数据访问与分析结果。
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
  });

  /// 读取分析额度状态。
  ///
  /// 依据 Baseline §5：免费用户 3 次完整分析；
  /// **上传简历、粘贴 JD、进入分析页面均不扣减**，
  /// 只有真正点击「开始分析」才扣减。
  Future<QuotaState> fetchQuota();
}

/// 「能报告**真实**分析进度」的数据源（P1-1b）。
///
/// ## 为什么要单独一个接口，而不是往 [AnalysisRepository] 上加方法
///
/// 只有**真实后端**有节点可报告。Mock 背后没有 agent 流程 —— 它的
/// 「分析」是一次 `Future.delayed`，没有 `crawl` / `routing` 可言。
/// 让它实现这个接口，就等于让 Mock 编一套假节点名，正是
/// `CLAUDE.md` §7 禁止的「编造产品数据」。
///
/// 所以能力**按实现者区分**，而不是按接口假装统一：
///
/// ```text
/// ApiAnalysisRepository   implements AnalysisProgressSource  →  真实节点驱动动效
/// MockAnalysisRepository  不实现                              →  沿用组件内时钟
/// ```
///
/// `AnalysisProvider` 用 `_repository is AnalysisProgressSource` 探测，
/// 拿不到就走原路径。这也让「正在分析」页的两套驱动方式在代码上是**显式**
/// 的，而不是藏在一个布尔开关里。
abstract interface class AnalysisProgressSource {
  /// 发起一次分析，**立刻**返回任务句柄（不等引擎跑完）。
  ///
  /// 对应 `POST /api/v1/analysis/tasks`（202）。
  /// 额度扣减由 Provider 在调用前负责；前置拒绝（额度耗尽 / 无基线）
  /// 由后端抛成 `AppError`，与同步端点同码。
  Future<AnalysisTask> startAnalysisTask({
    required String title,
    required String rawJd,
  });

  /// 读取任务最新状态（含真实节点进度）。
  ///
  /// 对应 `GET /api/v1/analysis/tasks/{task_id}`。调用方轮询直到
  /// [AnalysisTask.isTerminal]；成功后用 [AnalysisTask.projectId] 取结果。
  Future<AnalysisTask> fetchAnalysisTask(String taskId);
}
