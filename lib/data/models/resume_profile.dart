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
    this.fullName,
    this.email,
    this.phone,
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

  /// 解析出的姓名。后端画像里的 `name`。
  ///
  /// ⚠️ 2026-10-04 新增 —— 简历详情页的「基本信息」段与 PDF 卡头部
  /// 需要这三项，而后端**一直在返回它们**（`ResumeProfile.model_dump()`
  /// 的 `name` / `email` / `phone`），只是此前的 Dart 映射把它们丢掉了。
  /// 因此这是**补齐既有字段**，不是新增产品数据（`CLAUDE.md` §7）。
  /// 解析不出时为空 —— 页面**不渲染**该行，而不是填占位符。
  final String? fullName;

  /// 解析出的邮箱。见 [fullName] 的说明。
  final String? email;

  /// 解析出的电话。见 [fullName] 的说明。
  final String? phone;

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
    String? fullName,
    String? email,
    String? phone,
    DateTime? updatedAt,
  }) {
    return ResumeProfile(
      versions: versions ?? this.versions,
      workExperiences: workExperiences ?? this.workExperiences,
      projectExperiences: projectExperiences ?? this.projectExperiences,
      skills: skills ?? this.skills,
      awards: awards ?? this.awards,
      capabilities: capabilities ?? this.capabilities,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
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
      fullName: _nonEmpty(json['fullName']),
      email: _nonEmpty(json['email']),
      phone: _nonEmpty(json['phone']),
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
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((dynamic e) => '$e').toList(growable: false);
}

/// 把可能为 `null` / 空串 / 空白的字符串收敛为 `null`。
///
/// 后端的画像字段可能给出空串（LLM 没抽取出该字段），保留空串会让
/// 页面渲染出「姓名：（空）」这样的行 —— 统一收敛成 `null`，由页面跳过该行。
String? _nonEmpty(Object? value) {
  final String text = '${value ?? ''}'.trim();
  return text.isEmpty ? null : text;
}
