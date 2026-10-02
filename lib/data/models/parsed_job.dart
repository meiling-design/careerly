import 'package:flutter/foundation.dart';

/// 一条**从岗位链接抓取回来的岗位**
/// （`POST /api/v1/analysis/jobs/parse-url`）。
///
/// 后端契约：`app/careerly/schemas.py` → `ParsedJob`。
///
/// ## 它存在的唯一理由是「回填」
///
/// ```text
/// 用户粘贴链接 → 抓取 → description 填进 JD 文本框 / title 填进岗位名
/// → 用户看得到、改得动 → 再走原有「开始分析」
/// ```
///
/// ⚠️ **抓取不是分析**：不扣额度、不建分析任务
/// （`CLAUDE.md` §5.2 —— 只有点击「开始分析」才扣）。
/// 它也**不是** [Job]：`Job` 是已经进入分析项目的岗位实体，
/// 有 id / 来源 / 创建时间；这一条只是还没被用户确认的输入素材。
///
/// ## 刻意不带爬虫的全部字段
///
/// 后端 `ParsedJob` 只回 `url / title / company / description` 四个字段
/// —— skills / location / department 这些爬虫其实抓得到，但前端多拿只会
/// 诱使 UI 去展示**尚未被产品确认**的字段。前端因此也不多存。
@immutable
class ParsedJob {
  const ParsedJob({
    required this.url,
    required this.title,
    this.company = '',
    required this.description,
  });

  /// 规范化后的链接（后端补过协议头，与用户输入的可能不同）。
  final String url;

  /// 岗位名称 —— 回填到「目标岗位」。
  final String title;

  /// 公司名。
  ///
  /// ⚠️ **当前 UI 不展示**（Figma 的「目标岗位」卡只有一个胶囊，
  /// 没有公司位）。保留字段是为了与后端契约逐字对齐，
  /// 不是因为要显示它 —— 展示与否属视觉决策，不自行决定。
  final String company;

  /// JD 正文 —— 回填到 JD 文本框。后端保证非空
  /// （只抓到标题没有正文的链接会被后端判为失败）。
  final String description;

  factory ParsedJob.fromJson(Map<String, dynamic> json) {
    return ParsedJob(
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'url': url,
    'title': title,
    'company': company,
    'description': description,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedJob &&
          other.url == url &&
          other.title == title &&
          other.company == company &&
          other.description == description;

  @override
  int get hashCode => Object.hash(url, title, company, description);

  @override
  String toString() =>
      'ParsedJob(url: $url, title: $title, company: $company, '
      'description: ${description.length} chars)';
}
