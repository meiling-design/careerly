import 'package:flutter/foundation.dart';

/// 成长事件的类型。
///
/// 对应 PRD §11.3 / IA §14 成长足迹展示内容：
/// 新增经历 / 技能变化 / 能力变化 / 匹配度变化 / 排名变化。
enum GrowthEventType {
  /// 新增工作或项目经历。
  experience('新增经历'),

  /// 技能变化。
  skill('技能变化'),

  /// 能力变化。
  capability('能力变化'),

  /// 岗位匹配度变化。
  matchScore('匹配度变化'),

  /// 岗位排名变化。
  rank('排名变化');

  const GrowthEventType(this.label);

  /// 中文展示名。
  final String label;

  static GrowthEventType? tryParse(String? raw) {
    if (raw == null) return null;
    for (final GrowthEventType type in GrowthEventType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }
}

/// 成长足迹条目。
///
/// 归属：**「我的」→ 成长足迹 → Detail**。
///
/// ⚠️ 开放项 O2（Baseline §9）已裁决：
/// 成长日历 / 成长时间线属于「成长足迹 Detail」内部，
/// **不增加第四张 Card、不增加一级导航、不创建独立页面**。
@immutable
class GrowthEvent {
  const GrowthEvent({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.delta,
    this.occurredAt,
  });

  final String id;

  final GrowthEventType type;

  /// 事件标题，例如「新增项目经历」。
  final String title;

  /// 补充说明。
  final String? description;

  /// 变化量（分值差 / 名次差）。无变化量时为 `null`。
  final int? delta;

  final DateTime? occurredAt;

  /// 是否为正向变化。
  bool get isPositive => (delta ?? 0) > 0;

  /// 变化量的展示文本，例如 `+8` / `-2`。
  String? get deltaLabel {
    final int? value = delta;
    if (value == null) return null;
    return value > 0 ? '+$value' : '$value';
  }

  GrowthEvent copyWith({
    String? id,
    GrowthEventType? type,
    String? title,
    String? description,
    int? delta,
    DateTime? occurredAt,
  }) {
    return GrowthEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      delta: delta ?? this.delta,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  factory GrowthEvent.fromJson(Map<String, dynamic> json) {
    return GrowthEvent(
      id: json['id'] as String,
      type:
          GrowthEventType.tryParse(json['type'] as String?) ??
          GrowthEventType.experience,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      delta: (json['delta'] as num?)?.toInt(),
      occurredAt: json['occurredAt'] == null
          ? null
          : DateTime.tryParse(json['occurredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'delta': delta,
    'occurredAt': occurredAt?.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GrowthEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GrowthEvent($id, ${type.label}, $title)';
}
