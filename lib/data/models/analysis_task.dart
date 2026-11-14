import 'package:flutter/foundation.dart';

/// 一次分析任务的状态与**真实节点进度**（P1-1b）。
///
/// ## 为什么需要它
///
/// `POST /api/v1/analysis` 是**同步**的（契约决策 C2 / D-A ② 第一阶段）：
/// 跑完 8 个 LangGraph 节点才返回，客户端在运行期间**拿不到任何句柄**。
/// 于是「正在分析」页只能靠自己的一只本地时钟推进 —— 实测引擎单是
/// `routing` 一个节点就可能跑 100 秒以上，而那只时钟 7.3 秒就定形「完成」。
///
/// `POST /api/v1/analysis/tasks`（P1-1b）补上了这个缺口：立刻返回 202 +
/// `taskId`，客户端轮询 [AnalysisTask]，用引擎**真实的节点**推进动画。
///
/// ## 两个刻度，不要混用
///
/// ```text
/// completedCount / totalNodes   引擎节点刻度（8 个 LangGraph 节点）
/// stepIndex      / totalSteps   产品步骤刻度（界面上的 5 步，取自 Figma）
/// ```
///
/// 两者不是一一对应 —— 5 步是 8 节点的产品级抽象，映射由**后端**
/// （`app/careerly/router.py` 的 `_NODE_TO_STEP`）单点维护，
/// 客户端不需要认识引擎的节点名。**不要**拿 `completedCount / totalSteps` 算进度。
@immutable
class AnalysisTask {
  const AnalysisTask({
    required this.taskId,
    required this.status,
    this.projectId,
    this.errorCode,
    this.errorMessage,
    this.progress,
  });

  /// 任务状态取值。与后端 `analysis_tasks.status` 逐字一致。
  static const String statusQueued = 'queued';
  static const String statusProcessing = 'processing';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';

  /// 任务句柄。
  final String taskId;

  /// 见上方 `status*` 常量。
  final String status;

  /// 成功时为产出项目 id；否则 `null`。
  final String? projectId;

  /// 失败时的机器可读错误码（如 `QUOTA_EXCEEDED` / `NO_BASELINE`）。
  final String? errorCode;

  /// 失败时给用户看的中文说明（后端已归一化，直接上屏）。
  final String? errorMessage;

  /// 引擎实时节点进度。`null` = 还没有可报告的进度（排队中）。
  final AnalysisTaskProgress? progress;

  /// 是否已到终态（不再变化）。轮询循环据此退出。
  bool get isTerminal => isCompleted || isFailed;

  bool get isCompleted => status == statusCompleted;

  bool get isFailed => status == statusFailed;

  factory AnalysisTask.fromJson(Map<String, dynamic> json) {
    final Object? rawProgress = json['progress'];
    return AnalysisTask(
      taskId: json['taskId'] as String? ?? '',
      status: json['status'] as String? ?? statusQueued,
      projectId: json['projectId'] as String?,
      errorCode: json['errorCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
      progress: rawProgress is Map<String, dynamic>
          ? AnalysisTaskProgress.fromJson(rawProgress)
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'taskId': taskId,
    'status': status,
    'projectId': projectId,
    'errorCode': errorCode,
    'errorMessage': errorMessage,
    'progress': progress?.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisTask &&
          other.taskId == taskId &&
          other.status == status &&
          other.projectId == projectId &&
          other.errorCode == errorCode &&
          other.errorMessage == errorMessage &&
          other.progress == progress;

  @override
  int get hashCode => Object.hash(
    taskId,
    status,
    projectId,
    errorCode,
    errorMessage,
    progress,
  );

  @override
  String toString() =>
      'AnalysisTask($taskId, status: $status, project: $projectId, '
      'progress: $progress)';
}

/// 引擎的实时节点进度（后端 `_progress_payload` 的镜像）。
@immutable
class AnalysisTaskProgress {
  const AnalysisTaskProgress({
    this.currentNode,
    this.nodeStatus,
    this.completedCount,
    this.totalNodes,
    this.stepIndex,
    this.totalSteps,
    this.updatedAt,
  });

  /// 引擎当前节点名（`crawl` / `normalize` / …）。**仅供调试**，
  /// UI 不应直接展示引擎内部命名。
  final String? currentNode;

  /// 该节点的状态：`running` / `completed` / `failed` / `skipped`。
  final String? nodeStatus;

  /// 已完成的引擎节点数（刻度 A）。
  final int? completedCount;

  /// 引擎节点总数（刻度 A）。
  final int? totalNodes;

  /// 当前对应的**产品步骤**下标，0 基（刻度 B）。
  ///
  /// 后端在遇到未知节点时给 `null` —— 此时应**保持当前步不动**，
  /// 而不是回退到第 0 步。
  final int? stepIndex;

  /// 产品步骤总数（刻度 B，当前为 5）。
  final int? totalSteps;

  /// 后端写入该进度的时间（epoch 秒）。
  final double? updatedAt;

  factory AnalysisTaskProgress.fromJson(Map<String, dynamic> json) {
    return AnalysisTaskProgress(
      currentNode: json['currentNode'] as String?,
      nodeStatus: json['nodeStatus'] as String?,
      completedCount: json['completedCount'] as int?,
      totalNodes: json['totalNodes'] as int?,
      stepIndex: json['stepIndex'] as int?,
      totalSteps: json['totalSteps'] as int?,
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'currentNode': currentNode,
    'nodeStatus': nodeStatus,
    'completedCount': completedCount,
    'totalNodes': totalNodes,
    'stepIndex': stepIndex,
    'totalSteps': totalSteps,
    'updatedAt': updatedAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisTaskProgress &&
          other.currentNode == currentNode &&
          other.nodeStatus == nodeStatus &&
          other.completedCount == completedCount &&
          other.totalNodes == totalNodes &&
          other.stepIndex == stepIndex &&
          other.totalSteps == totalSteps &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    currentNode,
    nodeStatus,
    completedCount,
    totalNodes,
    stepIndex,
    totalSteps,
    updatedAt,
  );

  @override
  String toString() =>
      'AnalysisTaskProgress($currentNode/$nodeStatus, '
      'step: $stepIndex/$totalSteps, '
      'nodes: $completedCount/$totalNodes)';
}
