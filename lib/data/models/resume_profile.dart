import 'package:flutter/foundation.dart';

/// 简历版本。
///
/// PRD §14：简历属于职业资产，由「我的」管理。
/// 支持当前简历 / 历史简历 / 上传新简历 / 删除 / 设置当前简历。
@immutable
class ResumeVersion {
  const ResumeVersion({
    required this.id,
    required this.label,
    this.fileName,
    this.uploadedAt,
    this.isCurrent = false,
  });

  final String id;

  /// 展示名，例如「2026 春招版」。
  final String label;

  final String? fileName;
  final DateTime? uploadedAt;

  /// 是否为当前简历。
  final bool isCurrent;

  ResumeVersion copyWith({
    String? id,
    String? label,
    String? fileName,
    DateTime? uploadedAt,
    bool? isCurrent,
  }) {
    return ResumeVersion(
      id: id ?? this.id,
      label: label ?? this.label,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  factory ResumeVersion.fromJson(Map<String, dynamic> json) {
    return ResumeVersion(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      fileName: json['fileName'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.tryParse(json['uploadedAt'] as String),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'label': label,
    'fileName': fileName,
    'uploadedAt': uploadedAt?.toIso8601String(),
    'isCurrent': isCurrent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ResumeVersion && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// 简历解析后的结构化职业信息。
///
/// 对应 PRD §7.2 Career Baseline 的构成：
/// 工作经历 / 项目经历 / 技能 / 奖项 / 初始能力画像 / 当前简历版本。
///
/// **重要（PRD §7 / Baseline §4.1）：**
/// 首次 Onboarding 只建立职业基线，**不包含 JD、目标岗位、首次匹配**。
@immutable
class ResumeProfile {
  const ResumeProfile({
    this.versions = const <ResumeVersion>[],
    this.workExperiences = const <String>[],
    this.projectExperiences = const <String>[],
    this.skills = const <String>[],
    this.awards = const <String>[],
    this.capabilities = const <String, int>{},
    this.updatedAt,
  });

  /// 空画像：尚未上传简历的新用户。
  static const ResumeProfile empty = ResumeProfile();

  /// 简历版本列表。
  final List<ResumeVersion> versions;

  final List<String> workExperiences;
  final List<String> projectExperiences;
  final List<String> skills;
  final List<String> awards;

  /// 能力画像（能力名 → 分值）。
  final Map<String, int> capabilities;

  final DateTime? updatedAt;

  /// 当前简历版本。
  ResumeVersion? get currentVersion {
    for (final ResumeVersion v in versions) {
      if (v.isCurrent) return v;
    }
    return versions.isEmpty ? null : versions.last;
  }

  /// 是否已经建立职业基线。
  bool get hasBaseline => versions.isNotEmpty;

  /// 是否为尚未上传简历的新用户（首页 Empty State 依据，PRD §8）。
  bool get isEmpty =>
      versions.isEmpty &&
      workExperiences.isEmpty &&
      projectExperiences.isEmpty &&
      skills.isEmpty;

  ResumeProfile copyWith({
    List<ResumeVersion>? versions,
    List<String>? workExperiences,
    List<String>? projectExperiences,
    List<String>? skills,
    List<String>? awards,
    Map<String, int>? capabilities,
    DateTime? updatedAt,
  }) {
    return ResumeProfile(
      versions: versions ?? this.versions,
      workExperiences: workExperiences ?? this.workExperiences,
      projectExperiences: projectExperiences ?? this.projectExperiences,
      skills: skills ?? this.skills,
      awards: awards ?? this.awards,
      capabilities: capabilities ?? this.capabilities,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ResumeProfile.fromJson(Map<String, dynamic> json) {
    return ResumeProfile(
      versions: (json['versions'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => ResumeVersion.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      workExperiences: _stringList(json['workExperiences']),
      projectExperiences: _stringList(json['projectExperiences']),
      skills: _stringList(json['skills']),
      awards: _stringList(json['awards']),
      capabilities:
          (json['capabilities'] as Map<String, dynamic>? ?? <String, dynamic>{})
              .map(
                (String k, dynamic v) =>
                    MapEntry<String, int>(k, (v as num).round()),
              ),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'versions': versions.map((ResumeVersion v) => v.toJson()).toList(),
    'workExperiences': workExperiences,
    'projectExperiences': projectExperiences,
    'skills': skills,
    'awards': awards,
    'capabilities': capabilities,
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((dynamic e) => '$e').toList(growable: false);
}
