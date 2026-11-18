import 'package:flutter/foundation.dart';

/// 首页单项：岗位匹配变化摘要。
///
/// 依据 Baseline §3.1 / PRD §8：
/// 首页只提供**摘要和入口**，不完整复制分析结果。
///
/// 因此这里只保留「够不够让用户判断要不要点进去」的信息：
/// 岗位、当前匹配度、变化量。完整的 Gap / 匹配原因 / 排序留在「分析」。
@immutable
class MatchChange {
  const MatchChange({
    required this.jobId,
    required this.jobTitle,
    required this.score,
    this.company,
    this.delta,
  });

  final String jobId;
  final String jobTitle;
  final String? company;

  /// 当前匹配度 0–100。
  final int score;

  /// 相比上一次分析的变化量。
  final int? delta;

  String get displayName =>
      (company == null || company!.isEmpty) ? jobTitle : '$company · $jobTitle';

  /// 变化量展示文本。
  String? get deltaLabel {
    final int? value = delta;
    if (value == null) return null;
    return value > 0 ? '+$value' : '$value';
  }

  factory MatchChange.fromJson(Map<String, dynamic> json) {
    return MatchChange(
      jobId: json['jobId'] as String,
      jobTitle: json['jobTitle'] as String? ?? '',
      company: json['company'] as String?,
      score: (json['score'] as num?)?.round() ?? 0,
      delta: (json['delta'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'jobId': jobId,
    'jobTitle': jobTitle,
    'company': company,
    'score': score,
    'delta': delta,
  };
}

/// 首页摘要。
///
/// 严格对应 Baseline §3.1「首页｜看见现在」的六项内容：
/// 当前职业状态 / 最近变化 / 岗位匹配变化 / 行动建议 / 最近成长 / 今日内容。
///
/// **首页不是完整数据仓库**——这里只放摘要，
/// 完整分析结果只在「分析」，「我的」只负责长期资产。
///
/// Phase 1 只定义结构，不产生真实数据；Mock 默认返回空摘要，
/// 让首页渲染 Empty State（PRD §8 新用户 Empty State）。
@immutable
class HomeSummary {
  const HomeSummary({
    this.headline = '',
    this.subheadline = '',
    this.latestTopScore,
    this.suggestions = const <String>[],
    this.matchChanges = const <MatchChange>[],
    this.recentGrowth = const <String>[],
    this.dailyContent,
    this.hasBaseline = false,
  });

  /// 空摘要：尚未建立职业基线或尚未分析的新用户。
  static const HomeSummary empty = HomeSummary();

  /// 顶部核心状态文案。
  final String headline;

  /// 状态补充说明。
  final String subheadline;

  /// 最新一次分析中的最高匹配分；无分析结果时为 `null`。
  final int? latestTopScore;

  /// 行动建议摘要。
  final List<String> suggestions;

  /// 最近岗位匹配变化。
  final List<MatchChange> matchChanges;

  /// 最近成长摘要。
  final List<String> recentGrowth;

  /// 轻量陪伴内容 / 今日内容。
  final String? dailyContent;

  /// 是否已建立职业基线（Onboarding 是否完成）。
  final bool hasBaseline;

  /// 是否为完全空白的新用户。
  ///
  /// 对应 PRD §8 新用户 Empty State：
  /// 「职业基线已建立 → 查看职业能力 → 开始第一次岗位分析」。
  bool get isEmpty =>
      headline.isEmpty &&
      latestTopScore == null &&
      suggestions.isEmpty &&
      matchChanges.isEmpty &&
      recentGrowth.isEmpty;

  HomeSummary copyWith({
    String? headline,
    String? subheadline,
    int? latestTopScore,
    List<String>? suggestions,
    List<MatchChange>? matchChanges,
    List<String>? recentGrowth,
    String? dailyContent,
    bool? hasBaseline,
  }) {
    return HomeSummary(
      headline: headline ?? this.headline,
      subheadline: subheadline ?? this.subheadline,
      latestTopScore: latestTopScore ?? this.latestTopScore,
      suggestions: suggestions ?? this.suggestions,
      matchChanges: matchChanges ?? this.matchChanges,
      recentGrowth: recentGrowth ?? this.recentGrowth,
      dailyContent: dailyContent ?? this.dailyContent,
      hasBaseline: hasBaseline ?? this.hasBaseline,
    );
  }

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    return HomeSummary(
      headline: json['headline'] as String? ?? '',
      subheadline: json['subheadline'] as String? ?? '',
      latestTopScore: (json['latestTopScore'] as num?)?.round(),
      suggestions: _stringList(json['suggestions']),
      matchChanges: (json['matchChanges'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => MatchChange.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      recentGrowth: _stringList(json['recentGrowth']),
      dailyContent: json['dailyContent'] as String?,
      hasBaseline: json['hasBaseline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'headline': headline,
    'subheadline': subheadline,
    'latestTopScore': latestTopScore,
    'suggestions': suggestions,
    'matchChanges': matchChanges
        .map((MatchChange m) => m.toJson())
        .toList(growable: false),
    'recentGrowth': recentGrowth,
    'dailyContent': dailyContent,
    'hasBaseline': hasBaseline,
  };
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((dynamic e) => '$e').toList(growable: false);
}
