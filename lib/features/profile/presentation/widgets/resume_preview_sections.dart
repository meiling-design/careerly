import '../../../../data/models/models.dart';

/// 简历预览里的一个分段（基本信息 / 工作经历 / …）。
///
/// 真值来源：Figma `RESUME_SECTIONS`（`src/App.tsx` L4549-4597）。
///
/// ## ⚠️ 段名取自 Figma，**内容不取自 Figma**
///
/// Figma 的 `RESUME_SECTIONS` 是一份写死的示例简历（张明远 / 高级产品经理 /
/// 4 段工作经历 …）。按 `CLAUDE.md` §7「不编造产品数据」，这里**只借用
/// 段名与排布方式**，条目一律由真实 [ResumeProfile] 派生；
/// 画像里没有的字段就不生成行，页面因此如实呈现 Empty 而不是示例值。
class ResumeSection {
  const ResumeSection({required this.title, required this.items});

  /// 段名。见 [resumeBasicInfoTitle] 等常量。
  final String title;

  final List<ResumeItem> items;
}

/// 分段里的一条。`value` / `detail` 为空时不渲染该部分。
class ResumeItem {
  const ResumeItem({required this.label, this.value, this.detail});

  /// 名称（左列）。
  final String label;

  /// 值（右列）。为空时只画名称。
  final String? value;

  /// 补充说明（独占整行）。
  final String? detail;
}

/// 「基本信息」段名。
///
/// 单独提出为常量，是因为 PDF 预览卡要**跳过**这一段
/// （它已经画在卡片头部的渐变区里，Figma `slice(1)`）。
const String resumeBasicInfoTitle = '基本信息';

/// 把画像收敛成可渲染的分段列表。
///
/// 顺序与 Figma 一致：基本信息 → 工作经历 → 项目经历 → 技能。
/// **空段不产生** —— 没有技能的用户不该看到一行空的「技能」标题。
List<ResumeSection> resumeSectionsOf(ResumeProfile profile) {
  final List<ResumeSection> sections = <ResumeSection>[];

  final List<ResumeItem> basic = <ResumeItem>[
    if (profile.fullName != null)
      ResumeItem(label: '姓名', value: profile.fullName),
    if (profile.workExperiences.isNotEmpty)
      ResumeItem(label: '职位', value: profile.workExperiences.first),
    if (profile.email != null) ResumeItem(label: '邮箱', value: profile.email),
    if (profile.phone != null) ResumeItem(label: '电话', value: profile.phone),
  ];
  if (basic.isNotEmpty) {
    sections.add(ResumeSection(title: resumeBasicInfoTitle, items: basic));
  }

  if (profile.workExperiences.isNotEmpty) {
    sections.add(
      ResumeSection(
        title: '工作经历',
        items: <ResumeItem>[
          for (final String role in profile.workExperiences)
            ResumeItem(label: role),
        ],
      ),
    );
  }

  if (profile.projectExperiences.isNotEmpty) {
    sections.add(
      ResumeSection(
        title: '项目经历',
        items: <ResumeItem>[
          for (final String project in profile.projectExperiences)
            ResumeItem(label: project),
        ],
      ),
    );
  }

  if (profile.skills.isNotEmpty) {
    sections.add(
      ResumeSection(
        title: '技能',
        items: <ResumeItem>[
          for (final String skill in profile.skills) ResumeItem(label: skill),
        ],
      ),
    );
  }

  return sections;
}

/// `2026.08.27`。
///
/// 手写格式化 —— 项目没有 `intl` 依赖（`CLAUDE.md` §6.5），
/// 与 `analysis_page.dart` / `growth_record_page.dart` 同一格式。
///
/// ⚠️ **必须先 `toLocal()`**。后端的时间戳统一走 `schemas.py` 的 `iso()`，
/// 产出的是 **UTC** ISO 串（`2026-10-04T18:24:31+00:00`），
/// `DateTime.tryParse` 解出来带 `isUtc: true`。直接读 `.day` 拿到的是
/// **UTC 的日历日**，于是 UTC+8 的用户在每天 08:00 之前看到的日期
/// **比实际早一天**。
///
/// 这个坑真实发生过：2026-10-05 02:24 上传的简历，横幅显示「更新于
/// 2026.10.04」，看起来像「上传没生效」——排查了半天数据刷新，
/// 其实是时区。日期是**给本地用户看的**，格式化时就该落到本地时间。
String formatResumeDate(DateTime at) {
  final DateTime local = at.toLocal();
  final String month = local.month.toString().padLeft(2, '0');
  final String day = local.day.toString().padLeft(2, '0');
  return '${local.year}.$month.$day';
}
