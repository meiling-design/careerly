import 'package:flutter/foundation.dart';

/// 一个项目对某个岗位匹配度的影响。
///
/// 归属：「我的」→ 职业资产 → 项目经历 / 项目详情（「影响的岗位匹配」卡）。
@immutable
class JobImpact {
  const JobImpact({required this.job, required this.delta});

  /// 岗位名，例如「AI 产品经理」。
  final String job;

  /// 匹配度提升的百分点。Figma 一律是正数。
  final int delta;

  /// 展示文本，例如 `+8%`。
  String get label => '+$delta%';

  factory JobImpact.fromJson(Map<String, dynamic> json) {
    return JobImpact(
      job: json['job'] as String? ?? '',
      delta: (json['delta'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'job': job,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobImpact && other.job == job && other.delta == delta;

  @override
  int get hashCode => Object.hash(job, delta);

  @override
  String toString() => 'JobImpact($job $label)';
}

/// 一个项目经历。
///
/// 归属：「我的」→ 职业资产 → 项目经历（列表）/ 项目详情。
///
/// ⚠️ 与 `WorkExperience.projects`（`List<String>`）的关系：
/// 那里只是**经历详情里带过的项目名**，这里是**独立的项目条目**。
/// 两者在 Figma 里确实是两份数据（`WORK_EXP[].projects` 与 `PROJECTS_DATA`），
/// 不互为派生。
@immutable
class ProjectExperience {
  const ProjectExperience({
    required this.id,
    required this.name,
    required this.year,
    this.type = '',
    this.role = '',
    this.description = '',
    this.outcome = '',
    this.skills = const <String>[],
    this.jobImpact = const <JobImpact>[],
  });

  final String id;

  /// 项目名。
  final String name;

  /// 年份，例如 `2026`。**保持字符串** —— Figma 只展示到年。
  final String year;

  /// 项目类型标签，例如「AI 应用」。
  final String type;

  /// 担任角色。
  final String role;

  /// 项目背景（详情页「项目背景」段落）。
  final String description;

  /// 项目成果（详情页「项目成果」段落）。
  final String outcome;

  /// 相关能力（详情页「相关能力」列表）。
  final List<String> skills;

  /// 影响的岗位匹配（详情页底部绿卡）。
  final List<JobImpact> jobImpact;

  factory ProjectExperience.fromJson(Map<String, dynamic> json) {
    return ProjectExperience(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      year: json['year'] as String? ?? '',
      type: json['type'] as String? ?? '',
      role: json['role'] as String? ?? '',
      description: json['description'] as String? ?? '',
      outcome: json['outcome'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e as String)
          .toList(growable: false),
      jobImpact: (json['jobImpact'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => JobImpact.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'year': year,
    'type': type,
    'role': role,
    'description': description,
    'outcome': outcome,
    'skills': skills,
    'jobImpact': jobImpact.map((JobImpact e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProjectExperience && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProjectExperience($id, $name)';
}
