import 'package:flutter/material.dart';

import '../../../data/models/home_summary.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/home_provider.dart';

/// 首页内容装配。真实岗位、建议和成长数据来自 [HomeSummary]；
/// Figma 原型中的演示姓名、分数和日期不会作为业务数据使用。
@immutable
class HomeContent {
  const HomeContent({
    required this.hero,
    required this.stilCards,
    required this.section,
  });

  /// Hero 卡内容。
  final HomeHeroContent hero;

  /// 四张 2×2 卡片。
  final List<HomeStilCardData> stilCards;

  /// 「岗位匹配变化」区块（State 03 是岗位列表，01/02 是第一次分析引导）。
  final HomeSectionContent section;

  /// 按阶段装配内容。
  ///
  /// 内容阶段由真实摘要状态决定；今日内容可在任何阶段提供。
  factory HomeContent.forStage(HomeStage stage, HomeSummary summary) {
    switch (stage) {
      case HomeStage.firstUse:
        return _firstUse(summary.dailyContent);
      case HomeStage.baselineOnly:
        return _baselineOnly(summary.dailyContent);
      case HomeStage.analyzed:
        return _analyzed(summary);
    }
  }

  // ---------------------------------------------------------------------------
  // State 01 —— 首次使用（D64 ② 逐字）
  // ---------------------------------------------------------------------------

  static HomeContent _firstUse(String? dailyContent) {
    return HomeContent(
      hero: HomeHeroContent(
        label: '你的职业主页',
        title: '还没有职业分析',
        meta: '从一份简历开始，看见你的职业能力',
        actionLabel: '上传简历',
        action: HomeHeroAction.uploadResume,
      ),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          kind: HomeStilCardKind.status,
          title: '还没有职业分析',
          lines: <String>['上传简历并分析一个目标岗位', '看见你的能力匹配度'],
          actionLabel: '查看详情',
          target: HomeCardTarget.analysis,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.growth,
          title: '还没有成长记录',
          lines: <String>['每一次简历更新、技能增加', '都会成为你的职业资产'],
          actionLabel: '查看成长记录',
          lineAccent: AppColors.success,
          target: HomeCardTarget.growth,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.suggestion,
          title: '下一步建议',
          lines: <String>['不知道下一步该提升什么？', '和 AI 聊聊你的职业方向'],
          actionLabel: '与AI聊聊',
          lineAccent: AppColors.homeCardHighlight,
          target: HomeCardTarget.ai,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.daily,
          title: '今天也可以向前一步',
          lines: _dailyLines(dailyContent),
        ),
      ],
      section: HomeSectionContent.firstAnalysis(
        title: '开始你的第一次分析',
        body: '找到一个你感兴趣的岗位，把 JD 粘贴进 Careerly。',
        actionLabel: '分析第一个岗位 →',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State 02 —— 已有简历、无岗位分析（⚠️ AI 起草 → D76）
  // ---------------------------------------------------------------------------

  /// ⚠️ **产品侧只给了 State 01 与 State 03 的文案，State 02 未给**
  /// （D64 ② 只覆盖 State 01）。
  ///
  /// 因此这里按「**最小改写**」起草：与 State 01 **结构完全相同**，
  /// 只把「还没有简历」这一件事改写为「已经有简历、只差一个岗位」，
  /// 且**只用 D64 已经出现过的词**（职业基线 / 目标岗位 / 能力匹配度 /
  /// 第一次分析）。起草结果逐条列在 **待裁决 · D76** 供产品侧增删。
  static HomeContent _baselineOnly(String? dailyContent) {
    return HomeContent(
      hero: HomeHeroContent(
        label: '你的职业主页',
        title: '还没有岗位分析',
        meta: '用一份目标岗位 JD，看见你与它的距离',
        actionLabel: '添加目标岗位',
        action: HomeHeroAction.addJob,
      ),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          kind: HomeStilCardKind.status,
          // 「职业基线已建立」是 D63 已裁决的措辞。
          title: '职业基线已建立',
          lines: <String>['添加一个目标岗位并开始分析', '看见你的能力匹配度'],
          actionLabel: '查看职业能力',
          target: HomeCardTarget.capability,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.growth,
          title: '还没有成长记录',
          lines: <String>['每一次简历更新、技能增加', '都会成为你的职业资产'],
          actionLabel: '查看成长记录',
          lineAccent: AppColors.success,
          target: HomeCardTarget.growth,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.suggestion,
          title: '下一步建议',
          lines: <String>['不知道下一步该提升什么？', '和 AI 聊聊你的职业方向'],
          actionLabel: '与AI聊聊',
          lineAccent: AppColors.homeCardHighlight,
          target: HomeCardTarget.ai,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.daily,
          title: '今天也可以向前一步',
          lines: _dailyLines(dailyContent),
        ),
      ],
      section: HomeSectionContent.firstAnalysis(
        title: '开始你的第一次分析',
        body: '找到一个你感兴趣的岗位，把 JD 粘贴进 Careerly。',
        actionLabel: '分析第一个岗位 →',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State 03 —— 完整 Dashboard（Figma 结构 + 真实数据）
  // ---------------------------------------------------------------------------

  /// ⚠️ 本态是 Figma 首页**唯一有数据**的一态，因此 Hero 与四张卡都从
  /// [HomeSummary] 取数；取不到就留空（`CareerlyAsyncStateView` 之外
  /// 不再编造占位数据）。
  static HomeContent _analyzed(HomeSummary summary) {
    final List<MatchChange> matches = summary.matchChanges;
    final MatchChange? top = matches.isEmpty ? null : matches.first;
    final String headline = summary.headline.trim();

    return HomeContent(
      hero: HomeHeroContent(
        label: '当前职业状态',
        title: headline.isNotEmpty ? headline : top?.jobTitle ?? '',
        meta: summary.subheadline.trim(),
        actionLabel: '查看分析',
        action: HomeHeroAction.viewAnalysis,
      ),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          kind: HomeStilCardKind.status,
          title: '当前状态',
          lines: <String>[
            matches.isEmpty ? '已完成目标岗位分析' : '最近有 ${matches.length} 个岗位匹配变化',
          ],
          actionLabel: '查看详情',
          statusScore: top?.score,
          target: HomeCardTarget.analysis,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.growth,
          title: '最近成长',
          lines: _take(summary.recentGrowth, 2),
          actionLabel: '查看成长记录',
          lineAccent: AppColors.success,
          target: HomeCardTarget.growth,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.suggestion,
          title: '下一步建议',
          lines: _take(summary.suggestions, 2),
          actionLabel: '与AI聊聊',
          lineAccent: AppColors.homeCardHighlight,
          target: HomeCardTarget.ai,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.daily,
          title: '今天也可以向前一步',
          lines: _dailyLines(summary.dailyContent),
        ),
      ],
      section: HomeSectionContent.matches(title: '岗位匹配变化', matches: matches),
    );
  }

  /// 取前 [count] 条；不足时**不补空位**（不编造）。
  static List<String> _take(List<String> source, int count) {
    if (source.length <= count) return source;
    return source.sublist(0, count);
  }

  static List<String> _dailyLines(String? content) {
    if (content == null || content.trim().isEmpty) {
      return const <String>['先看见自己，再决定下一步。'];
    }
    return <String>[content.trim()];
  }
}

/// Hero 卡内小按钮的**目标**。
///
/// 与 [HomeHeroContent.actionLabel] 分开：文案归文案，目标归目标 ——
/// 这样改文案不会悄悄改掉跳转（Figma 的按钮文字与它的 `onClick`
/// 本就是两件事）。
enum HomeHeroAction {
  /// State 01：还没有简历 → 去建职业基线。
  uploadResume,

  /// State 02：有基线、无岗位 → 去添加目标岗位（JD 入口在「分析」）。
  addJob,

  /// State 03：去看这条岗位匹配的完整分析。
  viewAnalysis,
}

/// Hero 卡内容。
@immutable
class HomeHeroContent {
  const HomeHeroContent({
    required this.label,
    required this.title,
    required this.meta,
    required this.actionLabel,
    required this.action,
  });

  /// 小标签。
  final String label;

  /// 主标题（岗位名 / 空态标题）。
  final String title;

  /// 附加说明行（岗位时间 / 空态说明句）。为空时该行不渲染。
  final String meta;

  /// 按钮文字。
  final String actionLabel;

  /// 按钮的跳转目标。
  final HomeHeroAction action;
}

/// 2×2 卡片的数据。
@immutable
class HomeStilCardData {
  const HomeStilCardData({
    required this.kind,
    required this.title,
    required this.lines,
    this.actionLabel = '',
    this.statusScore,
    this.lineAccent,
    this.target,
  });

  final HomeStilCardKind kind;
  final String title;

  /// 描述行（0–2 行）。
  final List<String> lines;

  final String actionLabel;

  /// 最匹配岗位的真实匹配分；无分析时不显示读数。
  final int? statusScore;

  /// 最后一行的高亮色。为 `null` 时该卡所有描述行都用中性灰。
  final Color? lineAccent;

  /// 点击目标。为 `null` 时不可点（Figma 的「今日一句」卡）。
  final HomeCardTarget? target;
}

enum HomeStilCardKind { status, growth, suggestion, daily }

/// 2×2 卡片的点击目标。
enum HomeCardTarget {
  /// 「下一步建议」/「与AI聊聊」→ AI Tab。
  ai,

  /// 「当前状态」→ 分析 Tab（Figma `onAnalysisClick` → `go('analysis')`）。
  analysis,

  /// 「职业基线已建立」→ 我的职业能力详情（IA §6 Empty State）。
  capability,

  /// 「最近成长」→ Figma 是 `go('cap-change')`（能力变化页）。
  ///
  /// ⚠️ 按 IA §2.2，成长页属于「**我的 → 成长足迹**」内部 ——
  /// 而那一层尚未实现（Phase 6）。当前落到「我的」Tab，
  /// **不**新建页面、也**不**改判到「分析」。
  /// 归属登记 **待裁决 · D81**。
  growth,
}

/// 「岗位匹配变化」区块的内容 —— **两种互斥形态**。
@immutable
class HomeSectionContent {
  const HomeSectionContent.matches({required this.title, required this.matches})
    : body = null,
      actionLabel = null;

  const HomeSectionContent.firstAnalysis({
    required this.title,
    required this.body,
    required this.actionLabel,
  }) : matches = const <MatchChange>[];

  final String title;

  /// State 03：岗位列表（可空列表，空即不渲染行）。
  final List<MatchChange>? matches;

  /// State 01 / 02：引导语。
  final String? body;

  /// State 01 / 02：行动行文字。
  final String? actionLabel;

  /// 是否为「第一次分析」引导形态。
  bool get isFirstAnalysis => body != null;
}
