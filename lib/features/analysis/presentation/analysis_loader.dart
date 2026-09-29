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
    required this.job,
    required this.match,
    this.previousScore,
  });

  /// 包含该岗位的分析项目。
  final AnalysisProject project;

  /// 岗位实体。
  final Job job;

  /// 最新一次分析中该岗位的匹配结果。
  final JobMatch match;

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
      final AnalysisResult? latest = project.latestResult;
      if (latest == null) return null;
      JobMatch? match;
      for (final JobMatch m in latest.matches) {
        if (m.jobId == jobId) {
          match = m;
          break;
        }
      }
      if (match == null) return null;
      return AnalysisJobEntry(
        project: project,
        job: job,
        match: match,
        previousScore: _previousScore(project, jobId),
      );
    }
  }
  return null;
}

/// 上一次分析（`results` 倒数第二条）中该岗位的匹配分。
int? _previousScore(AnalysisProject project, String jobId) {
  if (project.results.length < 2) return null;
  final AnalysisResult previous = project.results[project.results.length - 2];
  for (final JobMatch m in previous.matches) {
    if (m.jobId == jobId) return m.score;
  }
  return null;
}
