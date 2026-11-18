import 'package:flutter/foundation.dart';

/// 优势能力（**带分数**）。
///
/// ## ⚠️ 这是 Figma 视觉演示扩展，不是 PRD 定义
///
/// PRD §9.4 只把「优势能力」定义为一个列表（见 [JobMatch.strengths]），
/// **没有定义每个优势能力的分数**。Figma 岗位详情页
/// （`AnalysisJobDetailPage`，`src/App.tsx` L2358）给每项加了
/// `score`（85 / 76 / 78 / 74）。
///
/// 本模型仅用于**还原 Figma 视觉**，字段值来自 Mock 演示夹具、
/// 明确标注为**演示值、非产品真值**。真实能力模型接入后，
/// 是否保留「分数」须产品侧裁决。
@immutable
class StrengthScore {
  const StrengthScore({required this.name, required this.score});

  /// 优势能力名称。
  final String name;

  /// 该能力分值（0–100，Figma 演示值）。
  final int score;

  factory StrengthScore.fromJson(Map<String, dynamic> json) => StrengthScore(
    name: json['name'] as String? ?? '',
    score: (json['score'] as num?)?.round() ?? 0,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'score': score,
  };
}

/// 能力 Gap 详情（**带数值与行动建议**）。
///
/// ## ⚠️ 这是 Figma 视觉演示扩展，不是 PRD 定义
///
/// PRD §9.4 只把「能力 Gap」定义为一个列表（见 [JobMatch.gaps]），
/// **没有定义**「你的能力 / 岗位要求 / Gap 数值、Gap 等级、
/// 差距原因、行动建议」。Figma Gap 页
/// （`AnalysisGapPage`，`src/App.tsx` L2446-2449）给出了这些字段。
///
/// 本模型仅用于**还原 Figma 视觉**，字段值来自 Mock 演示夹具、
/// 明确标注为**演示值、非产品真值**。真实能力模型接入后，
/// 是否保留这些字段须产品侧裁决。
@immutable
class GapDetail {
  const GapDetail({
    required this.name,
    this.yours,
    this.target,
    this.level,
    this.why,
    this.actions = const <String>[],
  });

  /// 能力 Gap 名称。
  final String name;

  /// 「你的能力」分值（0–100，Figma 演示值）。
  final int? yours;

  /// 「岗位要求」分值（0–100，Figma 演示值）。
  final int? target;

  /// Gap 等级，如「关键 Gap」「一般 Gap」（Figma 演示值）。
  final String? level;

  /// 差距原因（Figma 演示值）。
  final String? why;

  /// 如何缩小差距的行动建议（Figma 演示值）。
  final List<String> actions;

  /// 该 Gap 的数值缺口（`target - yours`，两者齐全时才有意义）。
  int? get gap {
    if (yours == null || target == null) return null;
    return target! - yours!;
  }

  factory GapDetail.fromJson(Map<String, dynamic> json) => GapDetail(
    name: json['name'] as String? ?? '',
    yours: (json['yours'] as num?)?.round(),
    target: (json['target'] as num?)?.round(),
    level: json['level'] as String?,
    why: json['why'] as String?,
    actions: _stringList(json['actions']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'yours': yours,
    'target': target,
    'level': level,
    'why': why,
    'actions': actions,
  };
}

/// 单个岗位的匹配结果。
///
/// 对应 PRD §9.4 分析结果结构：
/// 匹配度 / 排序 / 匹配原因 / 优势能力 / 能力 Gap / 行动建议。
///
/// **硬规则（PRD §9.4 / Baseline §6.1、CLAUDE.md）：**
/// `score` 为 0–100，且**只由能力匹配计算**。
/// 薪资 / 通勤 / 城市**不得**进入该分值。
@immutable
class JobMatch {
  const JobMatch({
    required this.jobId,
    required this.score,
    required this.rank,
    this.strengths = const <String>[],
    this.gaps = const <String>[],
    this.reasons = const <String>[],
    this.suggestion,
    this.strengthScores = const <StrengthScore>[],
    this.gapDetails = const <GapDetail>[],
  });

  /// 关联的 [Job.id]。
  final String jobId;

  /// 能力匹配度，0–100。
  final int score;

  /// 本次分析中的排名（从 1 开始）。
  final int rank;

  /// 优势能力。
  final List<String> strengths;

  /// 能力 Gap。
  final List<String> gaps;

  /// 匹配依据 / 匹配原因。
  final List<String> reasons;

  /// AI 提升点 / 行动建议。
  final String? suggestion;

  /// 优势能力（**带分数**，Figma 岗位详情页视觉演示扩展）。
  ///
  /// 为 [strengths] 的**并行富化**：真实能力模型尚未接入时为空，
  /// Mock 演示夹具用它还原 Figma 的「能力优势 + 分数」视觉。
  final List<StrengthScore> strengthScores;

  /// 能力 Gap 详情（Figma Gap 页视觉演示扩展）。
  ///
  /// 为 [gaps] 的**并行富化**：真实能力模型尚未接入时为空，
  /// Mock 演示夹具用它还原 Figma 的 Gap 页完整视觉。
  final List<GapDetail> gapDetails;

  JobMatch copyWith({
    String? jobId,
    int? score,
    int? rank,
    List<String>? strengths,
    List<String>? gaps,
    List<String>? reasons,
    String? suggestion,
    List<StrengthScore>? strengthScores,
    List<GapDetail>? gapDetails,
  }) {
    return JobMatch(
      jobId: jobId ?? this.jobId,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      strengths: strengths ?? this.strengths,
      gaps: gaps ?? this.gaps,
      reasons: reasons ?? this.reasons,
      suggestion: suggestion ?? this.suggestion,
      strengthScores: strengthScores ?? this.strengthScores,
      gapDetails: gapDetails ?? this.gapDetails,
    );
  }

  factory JobMatch.fromJson(Map<String, dynamic> json) {
    return JobMatch(
      jobId: json['jobId'] as String,
      score: (json['score'] as num?)?.round() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      strengths: _stringList(json['strengths']),
      gaps: _stringList(json['gaps']),
      reasons: _stringList(json['reasons']),
      suggestion: json['suggestion'] as String?,
      strengthScores: (json['strengthScores'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic e) => StrengthScore.fromJson(e as Map<String, dynamic>),
          )
          .toList(growable: false),
      gapDetails: (json['gapDetails'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => GapDetail.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'jobId': jobId,
    'score': score,
    'rank': rank,
    'strengths': strengths,
    'gaps': gaps,
    'reasons': reasons,
    'suggestion': suggestion,
    'strengthScores':
        strengthScores.map((StrengthScore s) => s.toJson()).toList(
          growable: false,
        ),
    'gapDetails':
        gapDetails.map((GapDetail g) => g.toJson()).toList(growable: false),
  };

  @override
  String toString() => 'JobMatch($jobId, score: $score, rank: $rank)';
}

/// 一次分析实际使用的岗位原文快照（P1-02）。
///
/// ⚠️ **不可变证据**：它记录的是「这次分析当时真正发给引擎的 JD」，
/// 不是当前 `Job.rawJd`。岗位信息之后被修改、链接被重新解析，都不会
/// 改写这里。
///
/// [available] 为 `false` 表示这是功能上线前的历史记录 ——
/// 后端明确告知「没有保存原文」，UI 必须显示缺失态，
/// **不得**回退到当前岗位的 JD 冒充历史原文。
@immutable
class JobSnapshot {
  const JobSnapshot({
    required this.jobId,
    this.title = '',
    this.company = '',
    this.rawJd = '',
    this.source,
    this.sourceUrl,
    this.importMethod,
    this.capturedAt,
    this.available = true,
  });

  final String jobId;
  final String title;
  final String company;

  /// 本次分析使用的 JD 原文。
  final String rawJd;

  /// 导入方式：`paste` / `url` / `history`。
  final String? source;

  /// 岗位链接导入时的原始 URL。
  final String? sourceUrl;

  /// 与 [source] 同义的导入方式字段（后端兼容字段）。
  final String? importMethod;

  /// 快照创建时间。
  final DateTime? capturedAt;

  /// 是否真的保存了原文。`false` = 历史数据缺失。
  final bool available;

  /// 展示用岗位名。
  String get displayName =>
      company.isEmpty ? title : '$company · $title';

  factory JobSnapshot.fromJson(Map<String, dynamic> json) => JobSnapshot(
    jobId: json['jobId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    company: json['company'] as String? ?? '',
    rawJd: json['rawJd'] as String? ?? '',
    source: json['source'] as String?,
    sourceUrl: json['sourceUrl'] as String?,
    importMethod: json['importMethod'] as String?,
    capturedAt: json['capturedAt'] == null
        ? null
        : DateTime.tryParse(json['capturedAt'] as String),
    available: json['available'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'jobId': jobId,
    'title': title,
    'company': company,
    'rawJd': rawJd,
    'source': source,
    'sourceUrl': sourceUrl,
    'importMethod': importMethod,
    'capturedAt': capturedAt?.toIso8601String(),
    'available': available,
  };
}

/// 一次分析的结果记录（**有版本**）。
///
/// 依据 Baseline §7.4 / PRD §9.7：
/// > 「更新分析不是覆盖，旧结果保留，新结果建立新的结果记录。」
///
/// 因此每次分析都产生一条新的 [AnalysisResult]，
/// [version] 递增，并记录当次使用的简历版本 [resumeVersionId]——
/// 这是「能力变化 / 匹配度变化 / 排名变化」可追踪的前提。
@immutable
class AnalysisResult {
  const AnalysisResult({
    required this.id,
    required this.projectId,
    required this.version,
    required this.matches,
    this.resumeVersionId,
    this.resumeVersionLabel,
    this.capabilitySnapshot = const <String, int>{},
    this.jobSnapshots = const <JobSnapshot>[],
    this.createdAt,
  });

  final String id;

  /// 所属分析项目。
  final String projectId;

  /// 版本号，从 1 开始递增。
  final int version;

  /// 本次分析**实际使用**的简历版本 id。
  /// 为 `null` 表示使用了一次性内联文本（没有对应的简历版本）。
  final String? resumeVersionId;

  /// 本次分析实际使用的简历版本标签（如 `V3`）的快照。
  ///
  /// 版本之后被删除时，历史记录仍能显示「基于哪一版」。
  final String? resumeVersionLabel;

  /// 各岗位的匹配结果（未排序，排序由 UI/Repository 决定）。
  final List<JobMatch> matches;

  /// 本次分析时的能力快照（能力名 → 分值）。
  /// 用于后续计算能力变化。
  final Map<String, int> capabilitySnapshot;

  /// 本次分析实际使用的岗位原文快照（P1-02）。
  ///
  /// 每条分析记录独立持有；历史记录没有快照时包含
  /// `available = false` 的条目，**不要**回退到 [Job.rawJd]。
  final List<JobSnapshot> jobSnapshots;

  final DateTime? createdAt;

  /// 按 jobId 查本次分析保存的岗位快照；没有记录时返回 `null`。
  JobSnapshot? snapshotFor(String jobId) {
    for (final JobSnapshot snapshot in jobSnapshots) {
      if (snapshot.jobId == jobId) return snapshot;
    }
    return null;
  }

  /// 按匹配度降序排列的结果。PRD §9.4：多岗位排序。
  List<JobMatch> get ranked {
    final List<JobMatch> sorted = List<JobMatch>.of(matches)
      ..sort((JobMatch a, JobMatch b) => b.score.compareTo(a.score));
    return sorted;
  }

  /// 最高匹配度，无结果时为 `null`。
  JobMatch? get top => ranked.isEmpty ? null : ranked.first;

  AnalysisResult copyWith({
    String? id,
    String? projectId,
    int? version,
    List<JobMatch>? matches,
    String? resumeVersionId,
    String? resumeVersionLabel,
    Map<String, int>? capabilitySnapshot,
    List<JobSnapshot>? jobSnapshots,
    DateTime? createdAt,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      version: version ?? this.version,
      matches: matches ?? this.matches,
      resumeVersionId: resumeVersionId ?? this.resumeVersionId,
      resumeVersionLabel: resumeVersionLabel ?? this.resumeVersionLabel,
      capabilitySnapshot: capabilitySnapshot ?? this.capabilitySnapshot,
      jobSnapshots: jobSnapshots ?? this.jobSnapshots,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      projectId: json['projectId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      resumeVersionId: json['resumeVersionId'] as String?,
      resumeVersionLabel: json['resumeVersionLabel'] as String?,
      matches: (json['matches'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => JobMatch.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      capabilitySnapshot:
          (json['capabilitySnapshot'] as Map<String, dynamic>? ??
                  <String, dynamic>{})
              .map(
                (String k, dynamic v) =>
                    MapEntry<String, int>(k, (v as num).round()),
              ),
      jobSnapshots: (json['jobSnapshots'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => JobSnapshot.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'projectId': projectId,
    'version': version,
    'resumeVersionId': resumeVersionId,
    'resumeVersionLabel': resumeVersionLabel,
    'matches': matches.map((JobMatch m) => m.toJson()).toList(growable: false),
    'capabilitySnapshot': capabilitySnapshot,
    'jobSnapshots': jobSnapshots
        .map((JobSnapshot s) => s.toJson())
        .toList(growable: false),
    'createdAt': createdAt?.toIso8601String(),
  };

  @override
  String toString() =>
      'AnalysisResult($id, v$version, ${matches.length} jobs)';
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((dynamic e) => '$e').toList(growable: false);
}
