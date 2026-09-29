import 'package:flutter/material.dart';

import '../../../data/models/home_summary.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/home_provider.dart';

/// 首页**三态的内容装配**。
///
/// ## 为什么单独一个文件
///
/// 产品侧裁决 **D64** ①bis 的原话是「只替换文字内容，不要修改 figma 视觉设计」。
/// 把三态的**全部差异**收敛到本文件，是为了让这条约束**在结构上成立**：
///
/// ```text
/// presentation/widgets/*  →  只认 HomeContent，不认识 HomeStage
/// 本文件                  →  唯一知道「三态文案分别是什么」的地方
/// ```
///
/// 因此「只换文案」不是一句要靠自觉遵守的话 ——
/// 视觉层根本没有可以分叉的地方。
///
/// ## 文案来源逐条标注
///
/// | 状态 | 来源 |
/// |---|---|
/// | State 01 | **D64 ② 逐字**（产品侧给出的完整规格） |
/// | State 02 | ⚠️ **AI 起草**（产品侧未给）→ **待裁决 · D76** |
/// | State 03 | **Figma 原文**；其中数据位由 `HomeSummary` 填充 |
///
/// ## ⚠️ 为什么 State 03 的卡片文案要从数据来
///
/// Figma 首页的 `排名 #1` / `AI 能力 68→76 ↑8` / `补充 AI Agent 项目案例`
/// 都是**硬编码的假数据**。依 `CLAUDE.md` §7「不编造产品数据」与
/// D64 ⑥，它们**不得**搬进 Mock —— 所以这几行由 `HomeSummary`
/// （`suggestions` / `recentGrowth`）填充，**没有数据时留空**，
/// 而不是回落到 Figma 的假字符串。
@immutable
class HomeContent {
  const HomeContent({
    required this.headerTitle,
    required this.hero,
    required this.stilCards,
    required this.section,
  });

  /// 顶部主标题（`主页` 小标签下方的整句）。
  final String headerTitle;

  /// Hero 卡内容。
  final HomeHeroContent hero;

  /// 四张 2×2 卡片。
  final List<HomeStilCardData> stilCards;

  /// 「岗位匹配变化」区块（State 03 是岗位列表，01/02 是第一次分析引导）。
  final HomeSectionContent section;

  /// 按阶段装配内容。
  ///
  /// [summary] 只在 [HomeStage.analyzed] 下被真正使用 ——
  /// State 01 / 02 的文案是**固定**的（产品侧规格），不随摘要变化。
  factory HomeContent.forStage(HomeStage stage, HomeSummary summary) {
    switch (stage) {
      case HomeStage.firstUse:
        return _firstUse();
      case HomeStage.baselineOnly:
        return _baselineOnly();
      case HomeStage.analyzed:
        return _analyzed(summary);
    }
  }

  // ---------------------------------------------------------------------------
  // State 01 —— 首次使用（D64 ② 逐字）
  // ---------------------------------------------------------------------------

  static HomeContent _firstUse() {
    return const HomeContent(
      // ⚠️ D64 ② **没有**给 Header 区块的文案（它只列了 Hero / 四卡 /
      // 岗位匹配变化）。此处取 D64 自己写的「你的职业主页」填该槽位
      // —— 不另造新词。登记 **待裁决 · D76**。
      headerTitle: '你的职业主页',
      hero: HomeHeroContent(
        label: '你的职业主页',
        title: '还没有职业分析',
        meta: '从一份简历开始，看见你的职业能力',
        actionLabel: '上传简历',
        action: HomeHeroAction.uploadResume,
      ),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          title: '问问 AI',
          lines: <String>['不知道下一步该提升什么？', '和 AI 聊聊你的职业方向'],
          iconBackground: AppColors.homeStilGradientAi,
          icon: Icons.image_outlined,
          lineAccent: AppColors.homeCardHighlight,
          target: HomeCardTarget.ai,
        ),
        HomeStilCardData(
          title: '还没有职业分析',
          lines: <String>['上传简历并分析一个目标岗位', '看见你的能力匹配度'],
          iconBackground: AppColors.homeStilGradientStatus,
          icon: Icons.grid_on_outlined,
          // 「当前状态」卡在 State 01 引导去分析。
          target: HomeCardTarget.analysis,
        ),
        HomeStilCardData(
          title: '还没有成长记录',
          lines: <String>['每一次简历更新、技能增加', '都会成为你的职业资产'],
          iconBackground: AppColors.homeStilGradientGrowth,
          icon: Icons.videocam_outlined,
          lineAccent: AppColors.success,
          target: HomeCardTarget.growth,
        ),
        HomeStilCardData(
          // 「今日一句」不看岗位数据，三态通用（D64 ② 的原话）。
          // ⚠️ 与「State 03 = Figma 现有 Dashboard」的措辞存在歧义
          // → 登记 **待裁决 · D78**。
          title: '今天也可以向前一步',
          lines: <String>['先看见自己，再决定下一步。'],
          iconBackground: AppColors.homeStilGradientDaily,
          icon: Icons.folder_outlined,
          lineAccent: AppColors.homeCardPurple,
          isQuote: true,
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
  static HomeContent _baselineOnly() {
    return const HomeContent(
      headerTitle: '你的职业主页',
      hero: HomeHeroContent(
        label: '你的职业主页',
        title: '还没有岗位分析',
        meta: '用一份目标岗位 JD，看见你与它的距离',
        actionLabel: '添加目标岗位',
        action: HomeHeroAction.addJob,
      ),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          title: '问问 AI',
          lines: <String>['不知道下一步该提升什么？', '和 AI 聊聊你的职业方向'],
          iconBackground: AppColors.homeStilGradientAi,
          icon: Icons.image_outlined,
          lineAccent: AppColors.homeCardHighlight,
          target: HomeCardTarget.ai,
        ),
        HomeStilCardData(
          // 「职业基线已建立」是 D63 已裁决的措辞。
          title: '职业基线已建立',
          lines: <String>['添加一个目标岗位并开始分析', '看见你的能力匹配度'],
          iconBackground: AppColors.homeStilGradientStatus,
          icon: Icons.grid_on_outlined,
          target: HomeCardTarget.analysis,
        ),
        HomeStilCardData(
          title: '还没有成长记录',
          lines: <String>['每一次简历更新、技能增加', '都会成为你的职业资产'],
          iconBackground: AppColors.homeStilGradientGrowth,
          icon: Icons.videocam_outlined,
          lineAccent: AppColors.success,
          target: HomeCardTarget.growth,
        ),
        HomeStilCardData(
          title: '今天也可以向前一步',
          lines: <String>['先看见自己，再决定下一步。'],
          iconBackground: AppColors.homeStilGradientDaily,
          icon: Icons.folder_outlined,
          lineAccent: AppColors.homeCardPurple,
          isQuote: true,
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

    return HomeContent(
      // ⚠️ Figma 写的是 `Alex 的职业主页`，而 `Alex` 是硬编码假名。
      // `HomeSummary` 目前**没有**用户姓名字段，取不到真名时
      // 用「你的职业主页」兜底，不回落到 `Alex`。登记 **待裁决 · D76**。
      headerTitle: '你的职业主页',
      hero: HomeHeroContent(
        label: '最匹配岗位',
        title: top?.jobTitle ?? '',
        // Figma 的位置是「更新时间」。摘要里没有该字段 → 留空，
        // 不搬 Figma 的 `2026/9/12`。登记 **待裁决 · D77**。
        meta: '',
        actionLabel: '查看分析',
        action: HomeHeroAction.viewAnalysis,
        score: top?.score,
        scoreDelta: top?.delta,
      ),
      stilCards: <HomeStilCardData>[
        HomeStilCardData(
          // 标题是 Figma 原文（不是数据）；两行描述在 Figma 里是假数据，
          // 改由「行动建议」填充。
          title: '问问AI',
          lines: _take(summary.suggestions, 2),
          iconBackground: AppColors.homeStilGradientAi,
          icon: Icons.chat_bubble_outline,
          lineAccent: AppColors.homeCardHighlight,
          target: HomeCardTarget.ai,
        ),
        HomeStilCardData(
          title: '当前状态',
          // 第一行在 Figma 里是 `排名 #1`（假数据）→ 改为真实的分析数量；
          // 第二行 `点击查看详细分析` 是**文案**而非数据，保留原文。
          lines: <String>[
            '已分析 ${matches.length} 个目标岗位',
            '点击查看详细分析',
          ],
          iconBackground: AppColors.homeStilGradientStatus,
          icon: Icons.grid_on_outlined,
          target: HomeCardTarget.analysis,
        ),
        HomeStilCardData(
          title: '最近成长',
          // Figma 的 `新增 AI Agent 项目` / `AI 能力 68→76 ↑8` 同为假数据。
          lines: _take(summary.recentGrowth, 2),
          iconBackground: AppColors.homeStilGradientGrowth,
          icon: Icons.videocam_outlined,
          lineAccent: AppColors.success,
          target: HomeCardTarget.growth,
        ),
        HomeStilCardData(
          title: '今天也可以向前一步',
          lines: <String>['先看见自己，再决定下一步。'],
          iconBackground: AppColors.homeStilGradientDaily,
          icon: Icons.folder_outlined,
          lineAccent: AppColors.homeCardPurple,
          isQuote: true,
        ),
      ],
      section: HomeSectionContent.matches(
        title: '岗位匹配变化',
        matches: matches,
      ),
    );
  }

  /// 取前 [count] 条；不足时**不补空位**（不编造）。
  static List<String> _take(List<String> source, int count) {
    if (source.length <= count) return source;
    return source.sublist(0, count);
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
    this.score,
    this.scoreDelta,
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

  /// 匹配度读数。
  ///
  /// ⚠️ **为 `null` 时右侧读数区整体不渲染** ——
  /// State 01 / 02 没有匹配度可言，不得用 `0` 或 `--` 占位。
  /// 装饰弧线**照常保留**（它是纯装饰，与分数不成比例）。
  /// 登记 **待裁决 · D77**。
  final int? score;

  /// 相比上次的变化量。
  final int? scoreDelta;
}

/// 2×2 卡片的数据。
@immutable
class HomeStilCardData {
  const HomeStilCardData({
    required this.title,
    required this.lines,
    required this.iconBackground,
    required this.icon,
    this.lineAccent,
    this.isQuote = false,
    this.target,
  });

  final String title;

  /// 描述行（0–2 行）。
  final List<String> lines;

  /// 图标底板的渐变（Figma 四张卡各不相同）。
  final LinearGradient iconBackground;

  /// 图标字形。
  ///
  /// ⚠️ Figma 是自绘 SVG 路径。这里用 Material 字形近似，
  /// 与注册页头像（**D58**）、提交简历页（**D72**）同一处置，
  /// **不新建图标资源**。
  final IconData icon;

  /// 最后一行的高亮色。为 `null` 时该卡所有描述行都用中性灰。
  ///
  /// ⚠️ **这是卡片的槽位属性，不是状态的文案属性** ——
  /// 同一张卡在三个状态下取**同一个颜色**（D64 ①bis：只换文字、
  /// 不换视觉）。Figma 逐卡给出的取值见 [_analyzed]。
  final Color? lineAccent;

  /// 是否为「今日一句」卡 —— 该卡在 Figma 里 `onClick` 为 `undefined`，
  /// 文字样式也与其余三张不同（单行、w400、紫色）。
  final bool isQuote;

  /// 点击目标。为 `null` 时不可点（Figma 的「今日一句」卡）。
  ///
  /// ⚠️ 这是**槽位属性**，与 [lineAccent] 同理：同一张卡在三个状态下
  /// 去同一个地方（D64 ①bis 只换文字）。Figma 逐卡的 `onClick` 见
  /// [HomeContent] 的类文档。
  final HomeCardTarget? target;
}

/// 2×2 卡片的点击目标。
enum HomeCardTarget {
  /// 「问问AI」→ AI Tab（Figma `onAIClick` → `setTabNav('ai')`）。
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
  const HomeSectionContent.matches({
    required this.title,
    required this.matches,
  }) : body = null,
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
