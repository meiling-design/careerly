import 'package:flutter/material.dart';

import '../../../data/models/home_summary.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/home_provider.dart';

/// 按当前时段给出问候语（Figma Hero 的「中午好！」那一行）。
///
/// 只负责「几点说什么」，不自己读时钟 —— 由调用方传入 [now]，便于测试。
String homeGreetingFor(DateTime now) {
  final int hour = now.hour;
  if (hour >= 5 && hour < 9) return '早上好！';
  if (hour >= 9 && hour < 12) return '上午好！';
  if (hour >= 12 && hour < 14) return '中午好！';
  if (hour >= 14 && hour < 18) return '下午好！';
  if (hour >= 18 && hour < 23) return '晚上好！';
  return '夜深了';
}

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
  ///
  /// [greeting] / [userName] 只用于空态 Hero 的问好：
  /// 问候语按当前时段（[homeGreetingFor]），姓名来自真实用户资料
  /// （`UserProfile.displayName`）—— **不**回落到 Figma 的 `Alex`。
  factory HomeContent.forStage(
    HomeStage stage,
    HomeSummary summary, {
    String greeting = '',
    String userName = '',
  }) {
    switch (stage) {
      case HomeStage.firstUse:
        return _firstUse(
          summary.dailyContent,
          greeting: greeting,
          userName: userName,
        );
      case HomeStage.baselineOnly:
        return _baselineOnly(
          summary.dailyContent,
          greeting: greeting,
          userName: userName,
        );
      case HomeStage.analyzed:
        return _analyzed(summary);
    }
  }

  // ---------------------------------------------------------------------------
  // State 01 —— 首次使用（D64 ② 逐字）
  // ---------------------------------------------------------------------------

  static HomeContent _firstUse(
    String? dailyContent, {
    required String greeting,
    required String userName,
  }) {
    return HomeContent(
      hero: HomeHeroContent(
        // Figma 的问候式 Hero：小字问候 + 真实姓名 + 品牌短句，
        // 主按钮直接进入「新建分析」。
        label: greeting.isEmpty ? '你好！' : greeting,
        title: userName.trim(),
        meta: '看见能力，也看见前进的自己~',
        actionLabel: '新建分析',
        action: HomeHeroAction.newAnalysis,
      ),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          kind: HomeStilCardKind.status,
          title: '当前状态',
          lines: const <String>['还没有岗位分析'],
          actionLabel: '去新建分析',
          target: HomeCardTarget.analysis,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.growth,
          title: '成长记录',
          lines: const <String>['简历更新、技能增加', '都会成为职业资产'],
          actionLabel: '查看成长记录',
          lineAccent: AppColors.success,
          target: HomeCardTarget.growth,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.suggestion,
          title: '下一步建议',
          lines: const <String>['不确定提升方向？', '和 AI 聊聊职业方向'],
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
  static HomeContent _baselineOnly(
    String? dailyContent, {
    required String greeting,
    required String userName,
  }) {
    return HomeContent(
      hero: HomeHeroContent(
        label: greeting.isEmpty ? '你好！' : greeting,
        title: userName.trim(),
        meta: '看见能力，也看见前进的自己~',
        actionLabel: '新建分析',
        action: HomeHeroAction.newAnalysis,
      ),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          kind: HomeStilCardKind.status,
          title: '当前状态',
          lines: const <String>['还没有岗位分析'],
          actionLabel: '去新建分析',
          target: HomeCardTarget.analysis,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.growth,
          title: '成长记录',
          lines: const <String>['简历更新、技能增加', '都会成为职业资产'],
          actionLabel: '查看成长记录',
          lineAccent: AppColors.success,
          target: HomeCardTarget.growth,
        ),
        HomeStilCardData(
          kind: HomeStilCardKind.suggestion,
          title: '下一步建议',
          lines: const <String>['不确定提升方向？', '和 AI 聊聊职业方向'],
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
          // 卡片标题固定，不随有无数据变化。
          title: '成长记录',
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

  /// 空态主按钮：去「分析」开始一次新的岗位分析。
  newAnalysis,

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
