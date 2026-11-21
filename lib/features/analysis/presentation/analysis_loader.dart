import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../data/models/analysis_project.dart';
import '../../../data/models/analysis_result.dart';
import '../../../data/models/job.dart';
import '../state/analysis_provider.dart';

/// 分析二级页（岗位详情 / Gap / 目标岗位）的**取数兜底**。
///
/// 与 `profile_assets_loader.dart` 同一套约定：
///
/// ```text
/// 常规路径：分析 Tab 已 load，二级页不重复取
/// 绕过路径：深链直达 /analysis/job/:jobId（AppDebugEntry 可指定）
///          → provider 为空时必须补取，否则永远停在 Loading
/// ```
///
/// ## 为什么是「下一帧」调用
///
/// `initState` 期间不能 `read` provider，也不该触发 `notifyListeners`；
/// 调用方统一在 `addPostFrameCallback` 里调本函数。
void ensureAnalysisProjectsLoaded(BuildContext context) {
  final AnalysisProvider provider = context.read<AnalysisProvider>();
  // `data == null` 且有在途请求 → 什么都不做，避免重复取。
  // `data != null` → 已有数据，重进页面不刷新（Figma 无下拉刷新）。
  if (provider.data == null && !provider.isLoading) {
    provider.load();
  }
}

/// 一个岗位在某个分析项目里的**完整视图**：
/// 岗位实体 + 最新一次匹配 + 上一次匹配分（用于「较上次」）。
///
/// 岗位详情页 / Gap 页共用这份查找结果，
/// 避免两页各自写一遍「遍历项目 → 找岗位 → 找匹配 → 找上次分值」。
class AnalysisJobEntry {
  const AnalysisJobEntry({
    required this.project,
    required this.result,
    required this.job,
    required this.match,
    this.snapshot,
    this.previousScore,
  });

  /// 包含该岗位的分析项目。
  final AnalysisProject project;

  /// 提供 [match] 的那条分析结果（通常是项目的最新结果）。
  final AnalysisResult result;

  /// 岗位实体。
  final Job job;

  /// 该分析结果中此岗位的匹配结果。
  final JobMatch match;

  /// 该分析结果保存的岗位原文快照（P1-02）。
  ///
  /// `null` 或 `available == false` 表示历史数据没有原文 ——
  /// 页面必须显示缺失态，**不得**读 [job].rawJd 冒充。
  final JobSnapshot? snapshot;

  /// 上一次**可比**分析的匹配分；由后端下发（[JobMatch.previousScore]）。
  ///
  /// 为 `null` 表示不可比较（首次分析 / 换岗位 / 换 JD / 换评分口径 /
  /// 简历没换）。**不是**「暂未计算」—— 前端不推断，见 [delta]。
  final int? previousScore;

  /// 当前 Gap 值（`100 - 匹配度`）。
  ///
  /// 与 Figma `JOBS.gap`（L38-43）逐位一致：86→14、82→18、74→26、68→32。
  int get gapPercent => 100 - match.score;

  /// 较上次变化；不可比较时为 `null`（不展示增长数值）。
  int? get delta => match.scoreDelta;
}

/// 在项目列表中按 [jobId] 查找岗位视图；找不到返回 `null`。
///
/// ## 来源上下文（`projectId` / `resultId`）
///
/// `jobId` 只保证「在一个项目内」唯一。同一个岗位实体可以出现在多个
/// 分析项目、多次分析结果里；只按 `jobId` 遍历全部项目会命中列表里
/// 最先遇到的那一条（通常是**最新分析**），从而把用户从「某条历史
/// 分析」带进另一次分析的详情。
///
/// 因此详情页从结果页进入时会携带来源：
///
/// ```text
/// projectId 给定 → 只在该项目内查找；项目不存在则返回 null
///                  （**不**回退到其它项目 —— 那会显示错的数据）
/// resultId 给定  → 只在该条结果内查找；结果不存在则返回 null
/// 两者都缺省     → 维持旧的「全部项目、最新结果」兜底（深链 / 旧链接）
/// ```
AnalysisJobEntry? findAnalysisJobEntry(
  List<AnalysisProject> projects,
  String jobId, {
  String? projectId,
  String? resultId,
}) {
  final Iterable<AnalysisProject> candidates = projectId == null
      ? projects
      : projects.where((AnalysisProject p) => p.id == projectId);

  // 显式给了 projectId 却找不到 → 直接 Empty，不拿别的项目冒充。
  if (projectId != null && candidates.isEmpty) return null;

  for (final AnalysisProject project in candidates) {
    final Job? job = _jobById(project, jobId);
    if (job == null) continue;

    final AnalysisResult? result = _resultFor(
      project,
      jobId,
      resultId: resultId,
    );
    if (result == null) {
      // 给了 resultId 却找不到对应匹配 → Empty；没给 resultId 时
      // 说明项目里有岗位、但没有任何结果能提供匹配（同样是 Empty）。
      return null;
    }

    final JobMatch match = result.matches.firstWhere(
      (JobMatch m) => m.jobId == jobId,
    );
    return AnalysisJobEntry(
      project: project,
      result: result,
      job: job,
      match: match,
      snapshot: result.snapshotFor(jobId),
      // P1-01：只认后端确认可比的值。**不要**在这里遍历相邻结果
      // 取同 jobId 的分数 —— 岗位改名 / JD 改版 / 评分口径升级后，
      // 那些数字不能相减。
      previousScore: match.previousScore,
    );
  }
  return null;
}

Job? _jobById(AnalysisProject project, String jobId) {
  for (final Job job in project.jobs) {
    if (job.id == jobId) return job;
  }
  return null;
}

/// 选出「提供这次匹配结果」的那条分析记录。
///
/// 优先级：
/// 1. 显式 [resultId] —— 必须是该结果且包含 [jobId]；
/// 2. 否则从最新结果往前找第一条包含 [jobId] 的结果。
AnalysisResult? _resultFor(
  AnalysisProject project,
  String jobId, {
  String? resultId,
}) {
  if (resultId != null) {
    for (final AnalysisResult result in project.results) {
      if (result.id != resultId) continue;
      return result.matches.any((JobMatch m) => m.jobId == jobId)
          ? result
          : null;
    }
    return null;
  }

  // 从最新结果往前找：岗位可能在历史版本里，而「原文」必须取
  // **提供这次匹配结果的那条记录**的快照（P1-02）。
  for (int i = project.results.length - 1; i >= 0; i--) {
    final AnalysisResult result = project.results[i];
    if (result.matches.any((JobMatch m) => m.jobId == jobId)) {
      return result;
    }
  }
  return null;
}
