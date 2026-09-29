import 'package:flutter/foundation.dart';

/// 岗位（独立实体）。
///
/// 依据 Baseline §7.4：`Job` 是一个**可复用、可沉淀**的独立实体，
/// 而不是挂在某次分析下的一次性数据。
///
/// 原因（PRD §9.7）：
/// 「删除某岗位只代表本次分析不比较，**不删除其历史岗位记录**。」
/// 因此 Job 的归属是「我的 → 职业资产 → 历史岗位」，
/// 而 AnalysisProject 只是**引用**一组 Job。
@immutable
class Job {
  const Job({
    required this.id,
    required this.title,
    this.company = '',
    this.rawJd = '',
    this.source,
    this.createdAt,
  });

  /// 岗位唯一标识。
  final String id;

  /// 岗位名称。
  final String title;

  /// 公司名称。空串表示用户只粘贴了 JD 正文、未提供公司名。
  final String company;

  /// JD 原文。保留原文是为了「更新分析」时不必让用户重新粘贴。
  final String rawJd;

  /// 来源标识，例如 `paste` / `import` / `history`。
  final String? source;

  final DateTime? createdAt;

  /// 展示用名称。
  String get displayName =>
      company.isEmpty ? title : '$company · $title';

  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? rawJd,
    String? source,
    DateTime? createdAt,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      rawJd: rawJd ?? this.rawJd,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      rawJd: json['rawJd'] as String? ?? '',
      source: json['source'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'company': company,
    'rawJd': rawJd,
    'source': source,
    'createdAt': createdAt?.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Job && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Job($id, $displayName)';
}
