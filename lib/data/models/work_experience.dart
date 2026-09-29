import 'package:flutter/foundation.dart';

/// 一段经历带来的技能增量。
///
/// 归属：「我的」→ 职业资产 → 工作经历 / 经历详情。
///
/// ⚠️ 这是 [WorkExperience] **内部**的部件，不是独立的职业资产条目 ——
/// 因此没有 id，也不单独存取。
@immutable
class SkillDelta {
  const SkillDelta({required this.name, required this.delta});

  /// 技能名，例如「产品规划」。
  final String name;

  /// 这段经历带来的分值增量。Figma 一律是正数。
  final int delta;

  /// 展示文本，例如 `+5`。
  String get label => '+$delta';

  factory SkillDelta.fromJson(Map<String, dynamic> json) {
    return SkillDelta(
      name: json['name'] as String? ?? '',
      delta: (json['delta'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'delta': delta,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillDelta && other.name == name && other.delta == delta;

  @override
  int get hashCode => Object.hash(name, delta);

  @override
  String toString() => 'SkillDelta($name $label)';
}

/// 一段工作经历。
///
/// 归属：「我的」→ 职业资产 → 工作经历（列表）/ 经历详情。
///
/// ## ⚠️ 与 `ResumeProfile.workExperiences` 的关系（**待裁决 · D88**）
///
/// `ResumeProfile`（Phase 4 交付）把工作经历建模为 `List<String>`，
/// 只够表达「基线摘要」；本模型是同一条数据在**长期资产层**的富结构。
///
/// ```text
/// ResumeProfile.workExperiences : List<String>   ← Onboarding 时期的摘要
/// CareerAssets.workExperiences  : List<WorkExperience>  ← 长期资产层
/// ```
///
/// **为什么不直接把 `ResumeProfile` 的字段改成富结构**：
/// 它是 Phase 4 已交付、`OnboardingConfirmPage` 正在依赖的实现，
/// 改类型会波及 Onboarding。两者并存的关系已登记 **待裁决 · D88**
/// （`docs/05_progress/TODO.md` §3.1）。
@immutable
class WorkExperience {
  const WorkExperience({
    required this.id,
    required this.period,
    required this.title,
    required this.company,
    this.description = '',
    this.skills = const <SkillDelta>[],
    this.projects = const <String>[],
  });

  final String id;

  /// 时间区间，例如 `2024.06 — 至今`。**保持字符串**，不做日期解析 ——
  /// Figma 展示的就是这个字面量，「至今」无法被结构化。
  final String period;

  /// 职位，例如「产品经理」。
  final String title;

  /// 公司。
  final String company;

  /// 工作内容（详情页「工作内容」段落）。
  final String description;

  /// 这段经历带来的能力提升。
  final List<SkillDelta> skills;

  /// 相关项目名（详情页「相关项目」）。
  final List<String> projects;

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'] as String,
      period: json['period'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      description: json['description'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => SkillDelta.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      projects: (json['projects'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e as String)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'period': period,
    'title': title,
    'company': company,
    'description': description,
    'skills': skills.map((SkillDelta e) => e.toJson()).toList(),
    'projects': projects,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkExperience && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WorkExperience($id, $title @ $company)';
}
