import 'package:flutter/foundation.dart';

/// 一次分析中的一个**目标岗位**入参（多岗位分析）。
///
/// 与 [Job] 的区别：`Job` 是已经分析过、落库后的岗位实体；
/// 本类是「新建分析」表单里还没提交的岗位草稿 —— 没有 id，也不属于
/// 任何项目。点击「开始分析」时整组草稿一次性交给后端：
///
/// ```text
/// 1 份简历 × N 个目标岗位 → 一次分析 → 跨岗位排名
/// ```
///
/// 额度按**一次分析**扣减，不按岗位数扣（`CLAUDE.md` §5.2）。
@immutable
class AnalysisJobInput {
  const AnalysisJobInput({
    required this.title,
    required this.rawJd,
    this.jobId,
    this.company = '',
    this.source = 'paste',
    this.sourceUrl,
  });

  /// 岗位名称。粘贴 JD 时由首行推导；链接 / 历史岗位导入时取抓取结果。
  final String title;

  /// JD 原文。会随请求交给后端写入 P1-02 的 JD 快照。
  final String rawJd;

  /// 更新已有项目时保留的稳定岗位 ID；新建分析时为 null。
  final String? jobId;

  /// 公司名。粘贴 JD 时为空。
  final String company;

  /// 导入方式：`paste` / `url` / `history`。
  final String source;

  /// 岗位链接导入时的原始 URL。
  final String? sourceUrl;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'rawJd': rawJd,
    if (jobId != null) 'jobId': jobId,
    'company': company,
    'source': source,
    if (sourceUrl != null) 'sourceUrl': sourceUrl,
  };

  /// 展示用名称（公司名存在时带上公司）。
  String get displayName => company.isEmpty ? title : '$company · $title';

  @override
  bool operator ==(Object other) =>
      other is AnalysisJobInput &&
      other.title == title &&
      other.rawJd == rawJd &&
      other.jobId == jobId &&
      other.company == company &&
      other.source == source &&
      other.sourceUrl == sourceUrl;

  @override
  int get hashCode =>
      Object.hash(title, rawJd, jobId, company, source, sourceUrl);

  @override
  String toString() => 'AnalysisJobInput($title)';
}
