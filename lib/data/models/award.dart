import 'package:flutter/foundation.dart';

/// 一项荣誉成果。
///
/// 归属：「我的」→ 职业资产 → 荣誉成果。
@immutable
class Award {
  const Award({
    required this.name,
    this.year = '',
    this.org = '',
    this.description = '',
  });

  /// 荣誉名。
  final String name;

  /// 年份，例如 `2026`。**保持字符串** —— Figma 只展示到年。
  final String year;

  /// 颁发机构。
  final String org;

  /// 一句话说明，例如「AI 招聘助手项目年度最佳产品奖」。
  ///
  /// ## 为什么以前没有、现在有了
  ///
  /// 本字段在原型里叫 `desc`（`src/App.tsx` L72-76）。它**只被奖项页使用**
  /// （`AwardsPage` L3855 渲染 `{a.desc}`），而职业资产页的荣誉成果分组
  /// 只画 `name` / `year` / `org`（L3575-3576）。
  ///
  /// 因此本字段在**只实现到职业资产页**时被有意略去（当时的理由记在
  /// `demo_fixture.dart`：「原型未使用该字段，依 §7 不引入」）。
  /// 奖项页落地后该理由不再成立 —— 说明是**原型已有的、逐字可回溯的**内容，
  /// 不是本轮编造的。为空时奖项卡不渲染这一行。
  final String description;

  /// 年份与机构的合并展示文本，例如 `2026 · 某机构`。
  ///
  /// Figma 的写法是 `{aw.year} · {aw.org}`（`src/App.tsx` L3576）。
  /// 任一为空时不留悬空分隔符。
  String get metaLabel {
    if (year.isEmpty) return org;
    if (org.isEmpty) return year;
    return '$year · $org';
  }

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      name: json['name'] as String? ?? '',
      year: json['year'] as String? ?? '',
      org: json['org'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'year': year,
    'org': org,
    'description': description,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Award && other.name == name && other.year == year;

  @override
  int get hashCode => Object.hash(name, year);

  @override
  String toString() => 'Award($name, $metaLabel)';
}
