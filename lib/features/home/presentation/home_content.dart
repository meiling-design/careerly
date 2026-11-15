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
  /// 三态**共用同一套 Hero 与四象限结构**（D64 ①bis），
  /// 只有卡片里的数据不同：State 01 / 02 给引导文案，State 03 给真实摘要。
  ///
  /// [greeting] / [userName] 用于问候式 Hero：
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
      case HomeStage.baselineOnly:
        return _notAnalyzed(
          summary.dailyContent,
          greeting: greeting,
          userName: userName,
        );
      case HomeStage.analyzed:
        return _analyzed(summary, greeting: greeting, userName: userName);
    }
  }

  /// 问候式 Hero —— 三态共用。
  ///
  /// 左侧：时段问候 + 真实昵称 + 品牌短句；下方深色「＋新建分析」胶囊。
  /// 右侧插画与裁切由 [HomeHeroCard] 负责，与内容无关。
  static HomeHeroContent _hero({
    required String greeting,
    required String userName,
  }) {
    return HomeHeroContent(
      label: greeting.isEmpty ? '你好！' : greeting,
      title: userName.trim(),
      meta: '看见能力，也看见前进的自己~',
      actionLabel: '新建分析',
    );
  }

  /// 2×2 卡片的引导态（State 01 / 02 共用）。
  ///
  /// State 01 与 State 02 的**可见文案完全一致**：两者都还没有岗位分析，
  /// 差异只在首页之外的职业基线，因此不再维护两份重复结构。
  static HomeContent _notAnalyzed(
    String? dailyContent, {
    required String greeting,
    required String userName,
  }) {
    return HomeContent(
      hero: _hero(greeting: greeting, userName: userName),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          kind: HomeStilCardKind.status,
          title: '当前状态',
          lines: const <String>[],
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
  // State 03 —— 完整 Dashboard（四象限 + 真实数据）
  // ---------------------------------------------------------------------------

  /// Hero **不**承载分析结论（旧版的「岗位名 / 查看分析」数据卡已废弃）；
  /// 真实数据只进入固定的四象限卡片与下方列表，避免有数据时换一套骨架。
  static HomeContent _analyzed(
    HomeSummary summary, {
    required String greeting,
    required String userName,
  }) {
    final List<MatchChange> matches = summary.matchChanges;
    final MatchChange? top = matches.isEmpty ? null : matches.first;

    return HomeContent(
      hero: _hero(greeting: greeting, userName: userName),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          kind: HomeStilCardKind.status,
          title: '当前状态',
          // 右上角只放短标签；岗位变化条数留在下方列表，
          // 不把长句塞进卡片头部挤掉标题。
          lines: const <String>[],
          statusBadge: top == null ? null : 'TOP 1',
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

/// Hero 卡内容。
///
/// Hero 是三态共用的问候区：问候语 + 昵称 + 品牌短句 + 「新建分析」。
/// 分析结论不进入 Hero —— 那会让有数据时换成另一套骨架。
@immutable
class HomeHeroContent {
  const HomeHeroContent({
    required this.label,
    required this.title,
    required this.meta,
    required this.actionLabel,
  });

  /// 小标签（时段问候）。
  final String label;

  /// 主标题（真实昵称）。为空时该行不渲染。
  final String title;

  /// 附加说明行（品牌短句）。为空时该行不渲染。
  final String meta;

  /// 深色胶囊按钮文字。
  final String actionLabel;
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
    this.statusBadge,
    this.lineAccent,
    this.target,
  });

  final HomeStilCardKind kind;
  final String title;

  /// 描述行（0–2 行）。「当前状态」卡不展示描述行。
  final List<String> lines;

  final String actionLabel;

  /// 最匹配岗位的真实匹配分；无分析时不显示读数。
  final int? statusScore;

  /// 「当前状态」卡右上角的短标签（如 `TOP 1`）；无数据时不渲染。
  final String? statusBadge;

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
