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

  /// 上一次分析中该岗位的匹配分；首次分析时为 `null`。
  final int? previousScore;

  /// 当前 Gap 值（`100 - 匹配度`）。
  ///
  /// 与 Figma `JOBS.gap`（L38-43）逐位一致：86→14、82→18、74→26、68→32。
  int get gapPercent => 100 - match.score;

  /// 较上次变化；无上次结果时为 `null`。
  int? get delta => previousScore == null ? null : match.score - previousScore!;
}

/// 在项目列表中按 [jobId] 查找岗位视图；找不到返回 `null`。
///
/// 查找范围是**全部**项目（不是只看最新一个）——岗位可能在历史项目里，
/// 而「删除岗位只代表本次分析不比较，不删除其历史岗位记录」（PRD §9.7）。
AnalysisJobEntry? findAnalysisJobEntry(
  List<AnalysisProject> projects,
  String jobId,
) {
  for (final AnalysisProject project in projects) {
    for (final Job job in project.jobs) {
      if (job.id != jobId) continue;
      // 从最新结果往前找：岗位可能在历史版本里，而「原文」必须取
      // **提供这次匹配结果的那条记录**的快照（P1-02）。
      for (int i = project.results.length - 1; i >= 0; i--) {
        final AnalysisResult result = project.results[i];
        JobMatch? match;
        for (final JobMatch m in result.matches) {
          if (m.jobId == jobId) {
            match = m;
            break;
          }
        }
        if (match == null) continue;
        return AnalysisJobEntry(
          project: project,
          result: result,
          job: job,
          match: match,
          snapshot: result.snapshotFor(jobId),
          previousScore: _previousScore(project, jobId, beforeIndex: i),
        );
      }
      return null;
    }
  }
  return null;
}

/// [beforeIndex] 之前最近一次包含该岗位的匹配分。
int? _previousScore(
  AnalysisProject project,
  String jobId, {
  required int beforeIndex,
}) {
  for (int i = beforeIndex - 1; i >= 0; i--) {
    for (final JobMatch m in project.results[i].matches) {
      if (m.jobId == jobId) return m.score;
    }
  }
  return null;
}
