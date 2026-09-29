import 'package:flutter/foundation.dart';

import 'award.dart';
import 'capability.dart';
import 'career_skill.dart';
import 'project_experience.dart';
import 'work_experience.dart';

/// 职业资产聚合。
///
/// 归属：「我的」→ 职业资产（IA §13）及其全部二级页。
///
/// ## 为什么是一个聚合而不是五个平行接口
///
/// 职业资产页要**同时**渲染四张分组卡 + 能力画像卡，而「我的」主页还要
/// 从同一份数据派生四个计数与一句摘要。拆成五个接口会让这两处各发五个请求、
/// 各自维护五个 Loading / Error 态 —— 而它们在 Figma 里就是**一屏数据**。
///
/// 因此这里聚合成一个对象，由 `CareerAssetsRepository` 一次取回。
///
/// ## ⚠️ 与 `ResumeProfile` 的关系（**待裁决 · D88**）
///
/// 两者是**并存**的两层，不是替代关系：
///
/// ```text
/// ResumeProfile   长期资产层的「简历版本」容器 + Onboarding 时期的基线摘要
/// CareerAssets    长期资产层的富结构（经历时间区间 / 分值 / 增量）
/// ```
///
/// `ResumeProfile` 的字段类型**未被本次改动触碰** —— 详见
/// `work_experience.dart` 里 [WorkExperience] 的说明。
///
/// ## 计数一律**派生**，不存字段
///
/// ⚠️ Figma 原型里有一处**自身矛盾**：`ProfilePage` 的资产子卡硬编码
/// `4段 / 6个 / 12项`，而同一份原型的数据数组只有
/// `WORK_EXP.length == 3` / `PROJECTS_DATA.length == 4` /
/// `SKILL_CATS` 展平后 `13` 项。
///
/// Flutter 侧一律从**数据本身**派生（[workCount] / [projectCount] /
/// [skillCount]），不硬编码任何一个数。该矛盾已登记
/// **待裁决 · D89**（`docs/05_progress/TODO.md` §3.1）。
@immutable
class CareerAssets {
  const CareerAssets({
    this.workExperiences = const <WorkExperience>[],
    this.projects = const <ProjectExperience>[],
    this.skillGroups = const <SkillGroup>[],
    this.awards = const <Award>[],
    this.capabilities = const <Capability>[],
    this.spanLabel = '',
    this.monthlyAdded = 0,
  });

  /// 空资产 —— Mock 的默认返回（`CLAUDE.md` §7：默认返回空，让 Empty 态真实可见）。
  static const CareerAssets empty = CareerAssets();

  final List<WorkExperience> workExperiences;
  final List<ProjectExperience> projects;
  final List<SkillGroup> skillGroups;
  final List<Award> awards;
  final List<Capability> capabilities;

  /// 资产整体时间跨度的展示文本，例如 `2021/6/8 - 2026/9/9`。
  ///
  /// ⚠️ **保持字符串、不做日期解析** —— Figma 原型里四张分组卡用的是
  /// **同一个**字面量（`CareerAssetsPage` L3522），而不是各自的时间区间。
  /// 为空时分组卡不渲染这一行。
  final String spanLabel;

  /// 本月新增的资产项数。用于主页资产卡摘要句。
  final int monthlyAdded;

  /// 工作经历段数。
  int get workCount => workExperiences.length;

  /// 项目个数。
  int get projectCount => projects.length;

  /// 技能项数（各分组展平后的总数）。
  int get skillCount => skillNames.length;

  /// 荣誉个数。
  int get awardCount => awards.length;

  /// 各分组展平后的技能名。
  List<String> get skillNames => <String>[
    for (final SkillGroup group in skillGroups) ...group.skills,
  ];

  /// 全部资产是否为空。
  bool get isEmpty =>
      workExperiences.isEmpty &&
      projects.isEmpty &&
      skillGroups.isEmpty &&
      awards.isEmpty &&
      capabilities.isEmpty;

  /// 是否有任何资产。
  bool get isNotEmpty => !isEmpty;

  /// 增量最高的能力。为 `null` 时没有能力数据。
  ///
  /// 主页资产卡摘要句里的「AI 应用能力 +8」由此派生，而不是硬编码。
  Capability? get topDeltaCapability {
    if (capabilities.isEmpty) return null;
    Capability best = capabilities.first;
    for (final Capability item in capabilities) {
      if (item.delta > best.delta) best = item;
    }
    return best.delta > 0 ? best : null;
  }

  CareerAssets copyWith({
    List<WorkExperience>? workExperiences,
    List<ProjectExperience>? projects,
    List<SkillGroup>? skillGroups,
    List<Award>? awards,
    List<Capability>? capabilities,
    String? spanLabel,
    int? monthlyAdded,
  }) {
    return CareerAssets(
      workExperiences: workExperiences ?? this.workExperiences,
      projects: projects ?? this.projects,
      skillGroups: skillGroups ?? this.skillGroups,
      awards: awards ?? this.awards,
      capabilities: capabilities ?? this.capabilities,
      spanLabel: spanLabel ?? this.spanLabel,
      monthlyAdded: monthlyAdded ?? this.monthlyAdded,
    );
  }

  factory CareerAssets.fromJson(Map<String, dynamic> json) {
    return CareerAssets(
      workExperiences: (json['workExperiences'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => WorkExperience.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      projects: (json['projects'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic e) => ProjectExperience.fromJson(e as Map<String, dynamic>),
          )
          .toList(growable: false),
      skillGroups: (json['skillGroups'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => SkillGroup.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      awards: (json['awards'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => Award.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      capabilities: (json['capabilities'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => Capability.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      spanLabel: json['spanLabel'] as String? ?? '',
      monthlyAdded: (json['monthlyAdded'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'workExperiences': workExperiences
        .map((WorkExperience e) => e.toJson())
        .toList(),
    'projects': projects.map((ProjectExperience e) => e.toJson()).toList(),
    'skillGroups': skillGroups.map((SkillGroup e) => e.toJson()).toList(),
    'awards': awards.map((Award e) => e.toJson()).toList(),
    'capabilities': capabilities.map((Capability e) => e.toJson()).toList(),
    'spanLabel': spanLabel,
    'monthlyAdded': monthlyAdded,
  };

  @override
  String toString() =>
      'CareerAssets(经历 $workCount, 项目 $projectCount, '
      '技能 $skillCount, 荣誉 $awardCount, 能力 ${capabilities.length})';
}
