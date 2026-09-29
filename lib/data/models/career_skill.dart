import 'package:flutter/foundation.dart';

/// 一组技能。
///
/// 归属：「我的」→ 职业资产 → 专业技能。
///
/// ## 为什么要分组，而不是一个扁平 `List<String>`
///
/// 职业资产页的**展开面板**只用扁平列表（Figma L3564 把分组 `flatMap` 掉了），
/// 但**专业技能页**是按分类展示的（Figma `SKILL_CATS`）。
/// 两者是同一份数据的两种投影，因此模型保留分组，
/// 由消费方决定 `flatMap` 还是分组渲染。
@immutable
class SkillGroup {
  const SkillGroup({required this.category, this.skills = const <String>[]});

  /// 分类名，例如「产品能力」。
  final String category;

  /// 该分类下的技能名。
  final List<String> skills;

  /// 该分类的技能数量。
  int get count => skills.length;

  factory SkillGroup.fromJson(Map<String, dynamic> json) {
    return SkillGroup(
      category: json['category'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e as String)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'category': category,
    'skills': skills,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SkillGroup && other.category == category;

  @override
  int get hashCode => category.hashCode;

  @override
  String toString() => 'SkillGroup($category, ${skills.length} 项)';
}
