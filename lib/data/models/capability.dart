import 'package:flutter/foundation.dart';

/// 一项职业能力。
///
/// 归属：「我的」→ 职业资产 → 职业能力画像 / 能力变化。
///
/// ## ⚠️ 与「技能」的区别
///
/// 在本项目的数据模型里这是**两类**东西，不是同一份数据换名字：
///
/// | | [Capability] | `SkillGroup.skills` |
/// |---|---|---|
/// | 形态 | 名称 + 分值 + 增量 | 纯名称 |
/// | Figma 来源 | `SKILLS_DATA`（L44-50） | `SKILL_CATS` |
/// | 展示位置 | 能力画像卡的进度条 | 专业技能页的 Chip |
///
/// 二者**不互为派生** —— 因此不合并、不互相推导。
@immutable
class Capability {
  const Capability({
    required this.name,
    required this.score,
    this.delta = 0,
    this.previousScore,
  });

  /// 能力名，例如「产品规划」。
  final String name;

  /// 当前分值（0–100）。
  final int score;

  /// 相对上一次的变化量。
  final int delta;

  /// 上一次的分值。为 `null` 时未知。
  final int? previousScore;

  /// 是否为正向变化。
  bool get isPositive => delta > 0;

  /// 进度条填充比例，范围 `0.0`–`1.0`。
  double get ratio => (score.clamp(0, 100)) / 100;

  /// 展示文本，例如 `+5`。
  String get deltaLabel => delta > 0 ? '+$delta' : '$delta';

  factory Capability.fromJson(Map<String, dynamic> json) {
    return Capability(
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      delta: (json['delta'] as num?)?.toInt() ?? 0,
      previousScore: (json['previousScore'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'score': score,
    'delta': delta,
    'previousScore': previousScore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Capability && other.name == name && other.score == score;

  @override
  int get hashCode => Object.hash(name, score);

  @override
  String toString() => 'Capability($name $score $deltaLabel)';
}
