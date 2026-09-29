import 'package:flutter/foundation.dart';

import 'analysis_result.dart';
import 'job.dart';

/// 分析项目。
///
/// 依据 Baseline §7.4 / PRD §9.6–9.7，分析项目是「一对多的容器」：
///
/// ```text
/// AnalysisProject
/// ├── Jobs       岗位集合（引用 Job 实体，可复用）
/// └── Results    多次分析结果（versioned，旧结果不覆盖）
/// ```
///
/// 归属：**只属于「分析」**。
/// Baseline §3.4 / IA §17：「分析负责用，我的负责存」——
/// 历史分析项目的浏览与更新入口统一在「分析 → 历史分析」，
/// 「我的」不再提供历史分析入口。
@immutable
class AnalysisProject {
  const AnalysisProject({
    required this.id,
    required this.name,
    this.jobs = const <Job>[],
    this.results = const <AnalysisResult>[],
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// 项目名称（用户可编辑，或由首个岗位推导）。
  final String name;

  /// 本项目包含的岗位集合。
  ///
  /// PRD §9.7：从本项目移除岗位**不删除**该岗位的历史记录——
  /// 因此这里只是引用，删掉引用不影响 [Job] 实体本身。
  final List<Job> jobs;

  /// 历次分析结果，按 version 递增。
  final List<AnalysisResult> results;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// 最新一次分析结果。
  AnalysisResult? get latestResult =>
      results.isEmpty ? null : results.last;

  /// 下一次分析的版本号。
  int get nextVersion => results.length + 1;

  /// 最近一次分析的匹配度摘要。
  int? get latestTopScore => latestResult?.top?.score;

  AnalysisProject copyWith({
    String? id,
    String? name,
    List<Job>? jobs,
    List<AnalysisResult>? results,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnalysisProject(
      id: id ?? this.id,
      name: name ?? this.name,
      jobs: jobs ?? this.jobs,
      results: results ?? this.results,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AnalysisProject.fromJson(Map<String, dynamic> json) {
    return AnalysisProject(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      jobs: (json['jobs'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      results: (json['results'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => AnalysisResult.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'jobs': jobs.map((Job j) => j.toJson()).toList(growable: false),
    'results': results
        .map((AnalysisResult r) => r.toJson())
        .toList(growable: false),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  @override
  String toString() =>
      'AnalysisProject($id, ${jobs.length} jobs, v${results.length})';
}
