import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/back_navigation.dart';
import '../../../core/state/async_state.dart';
import '../../../data/models/models.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../state/growth_provider.dart';

/// 成长记录 —— 「我的」→ 成长足迹 → Detail。
///
/// ## 归属（Baseline 开放项 O2，已裁决）
///
/// 成长日历 / 成长时间线属于**本页内部**：
///
/// ```text
/// ✅ 它们是「成长足迹 Detail」的局部展示
/// ❌ 不是独立页面、不是第 5 个一级导航、不是第 4 张 Card
/// ```
///
/// ## 🔴 Phase 8A 产品规则（2026-09-28，产品侧）—— 日历与事件解耦
///
/// ```text
/// ✅ 日历是**默认存在的核心页面结构** —— 永远渲染
/// ✅ 即使没有任何事件，也必须显示完整日历 + 对应的当天空状态
/// ❌ 不得根据 Event 是否存在来决定是否渲染 Calendar
/// ```
///
/// 页面结构（本页 = 「我的」→ 成长足迹 → Detail）：
///
/// ```text
/// 周日历条
/// 月网格 ← 月份切换 / 今天定位 / 日期选择 / 有事件日期标记
/// 当天事件区 ← 按 selectedDate 查询；为空时给空状态（不是隐藏）
/// 全部记录 ← 时间线（独立数据流，Figma 两份源数据）
/// ```
///
/// **事件不是本页产生的**：它由各业务操作逐步写入
/// （更新简历 / 完成岗位分析 / 新增项目经历 → `GrowthEvent`）。
/// 当前 Mock 只读、默认为空 —— 因此本页**在空数据下也必须是一个完整、正确的页面**。
///
/// ## 页面规格（Figma `GrowthRecordPage`，`src/App.tsx` L3973-4114）
///
/// ```text
/// 顶栏      返回 + 「成长记录」+ 副标题「每一次变化，都是成长的痕迹。」
/// 分割线    #e8e4f0
/// 周日历条  动态真实日期（原型即 `new Date()`），今天 = 蓝紫渐变圆
/// 月网格    Figma `GrowthCalendar`（L2989-3086）搬入本页（O2 归属）
/// 时间线    日期标签 + 彩色圆点 + 渐变连接线 + 类型色卡
/// ```
///
/// ## D91 已裁决（2026-09-22）
///
/// 项目模型 5 类事件映射到 Figma 时间线 4 套配色，**排名变化新增第 5 套**：
///
/// ```text
/// experience(新增经历)   → Figma project    短名「项目」
/// skill(技能变化)        → Figma resume     短名「简历」
/// capability(能力变化)   → Figma capability 短名「能力」
/// matchScore(匹配度变化) → Figma analysis   短名「分析」
/// rank(排名变化)         → 第 5 套粉色系     短名「排名」（暂定值 D96）
/// ```
///
/// 短名依据：Figma 徽章是 42px 圆、10px 字，只能放 2 个字，
/// 完整类型名（「新增经历」等 4 字）放不下 —— 用 Figma `typeLabel`（L3995-3997）
/// 的原值，第 5 类补「排名」（同 D96 暂定值）。
///
/// ## ⚠️ 两处 Flutter 侧补充（不属于 Figma 原值）
///
/// 1. **月份切换箭头（待确认 · D97）** —— Figma 是静态原型，天然没有
///    月份导航；而真实事件会跨月累积，没有切换时旧事件永远不可见。
///    属 `CLAUDE.md` §3.2「Figma 天生无法表达，在 Flutter 里实现」一类。
/// 2. **图例换行** —— Figma 图例 4 项挂在月份标题右侧；5 类后横向放不下，
///    图例下移为独立一行（纯布局处理）。
class GrowthRecordPage extends StatefulWidget {
  const GrowthRecordPage({super.key});

  @override
  State<GrowthRecordPage> createState() => _GrowthRecordPageState();
}

class _GrowthRecordPageState extends State<GrowthRecordPage> {
  late DateTime _displayMonth;
  late DateTime _today;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // 日历不依赖任何数据即可渲染（Phase 8A：Calendar 永远显示）。
    _today = _dateOnly(DateTime.now());
    _displayMonth = DateTime(_today.year, _today.month);
    _selectedDate = _today; // 今天定位：默认选中今天
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  /// 只取「日」，抹掉时间部分 —— 日期比较一律按天。
  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// 把 [day] 夹到 [month] 的合法天数内（如 31 → 2 月取 28/29）。
  static DateTime _dayInMonth(DateTime month, int day) {
    final int lastDay = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(month.year, month.month, day.clamp(1, lastDay));
  }

  bool _isCurrentMonth(DateTime month) =>
      month.year == _today.year && month.month == _today.month;

  /// 视图是否停在「今天」（决定要不要出「今天」快捷定位）。
  bool get _isViewingToday =>
      _isCurrentMonth(_displayMonth) &&
      _selectedDate.year == _today.year &&
      _selectedDate.month == _today.month &&
      _selectedDate.day == _today.day;

  /// 取数。**不改选中日期** —— 选中日期是页面状态（默认今天），
  /// 不随数据到达而漂移（旧实现会预选「最近有事件的日期」，已按
  /// Phase 8A 规则移除）。
  Future<void> _load() async {
    if (!mounted) return;
    final GrowthProvider events = context.read<GrowthProvider>();
    final GrowthTimelineProvider timeline =
        context.read<GrowthTimelineProvider>();
    final List<Future<void>> loads = <Future<void>>[];
    if (events.data == null && !events.isLoading) loads.add(events.load());
    if (timeline.data == null && !timeline.isLoading) {
      loads.add(timeline.load());
    }
    await Future.wait(loads);
  }

  /// 月份切换（Flutter 侧补充交互，D97）。
  ///
  /// 选中日期**跟随展示月份** —— 否则切月后「当天事件区」会指向网格里
  /// 看不见的日期。切到当前月时选中今天。
  void _shiftMonth(int delta) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + delta);
      _selectedDate = _isCurrentMonth(_displayMonth)
          ? _today
          : _dayInMonth(_displayMonth, _selectedDate.day);
    });
  }

  /// 今天定位（Flutter 侧补充交互）。
  void _goToday() {
    setState(() {
      _displayMonth = DateTime(_today.year, _today.month);
      _selectedDate = _today;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GrowthProvider events = context.watch<GrowthProvider>();
    final GrowthTimelineProvider timeline =
        context.watch<GrowthTimelineProvider>();

    // 🔴 Phase 8A：日历**不**由事件数据决定是否渲染 ——
    // 事件加载中 / 失败 / 为空，日历都必须完整显示。
    final List<GrowthEvent> loadedEvents =
        events.data ?? const <GrowthEvent>[];

    return CareerlyScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _GrowthHeader(onBack: () => careerlyBack(context)),
          Container(
            height: _GrowthMetrics.dividerHeight,
            margin: const EdgeInsets.symmetric(
              horizontal: _GrowthMetrics.inset,
            ),
            color: AppColors.growthPageDivider,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                bottom: _GrowthMetrics.pageBottom,
              ),
              children: <Widget>[
                const _GrowthWeekStrip(),
                _GrowthMonthGridCard(
                  events: loadedEvents,
                  eventsState: events.state,
                  displayMonth: _displayMonth,
                  selectedDate: _selectedDate,
                  today: _today,
                  showTodayAction: !_isViewingToday,
                  onShiftMonth: _shiftMonth,
                  onSelectDay: (DateTime day) =>
                      setState(() => _selectedDate = day),
                  onGoToday: _goToday,
                  onRetryEvents: events.load,
                ),
                // 时间线是独立数据流（Figma 两份源数据，见
                // GrowthTimelineProvider），四态单独处理，
                // 不受当天事件区数据状态牵连。
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _GrowthMetrics.inset,
                  ),
                  child: CareerlySectionHeader(
                    title: '全部记录',
                    bottomSpacing: _GrowthMetrics.timelineHeaderBottom,
                  ),
                ),
                CareerlyAsyncStateView<List<GrowthEvent>>(
                  state: timeline.state,
                  isEmpty: (List<GrowthEvent> t) => t.isEmpty,
                  onRetry: timeline.load,
                  compact: true,
                  loadingMessage: '正在读取成长时间线',
                  emptyTitle: '暂无成长时间线',
                  builder:
                      (
                        BuildContext context,
                        List<GrowthEvent> timelineEvents,
                      ) => _GrowthTimeline(events: timelineEvents),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// D91 类型映射 —— 模型 5 类 → Figma 视觉（已裁决，2026-09-22）
// ═══════════════════════════════════════════════════════════════════════════

/// 一类成长事件在两套视觉体系下的全部取色。
@immutable
class _TypePalette {
  const _TypePalette({
    required this.shortLabel,
    required this.timelineDot,
    required this.timelineCardBg,
    required this.timelineLine,
    required this.gridDot,
  });

  /// 徽章 / Chip 短名（Figma `typeLabel` 原值 + 「排名」补名）。
  final String shortLabel;

  /// 时间线：圆点 / 徽章底。
  final Color timelineDot;

  /// 时间线：事件卡底色。
  final Color timelineCardBg;

  /// 时间线：连接线渐变起点。
  final Color timelineLine;

  /// 月网格：活动圆点（⚠️ 与时间线不同套，Figma 两处各自定义）。
  final Color gridDot;
}

const Map<GrowthEventType, _TypePalette> _palettes =
    <GrowthEventType, _TypePalette>{
      GrowthEventType.experience: _TypePalette(
        shortLabel: '项目',
        timelineDot: AppColors.growthExperienceDot,
        timelineCardBg: AppColors.growthExperienceCardBg,
        timelineLine: AppColors.growthExperienceLine,
        gridDot: AppColors.growthGridExperienceDot,
      ),
      GrowthEventType.skill: _TypePalette(
        shortLabel: '简历',
        timelineDot: AppColors.growthSkillDot,
        timelineCardBg: AppColors.growthSkillCardBg,
        timelineLine: AppColors.growthSkillLine,
        gridDot: AppColors.growthGridSkillDot,
      ),
      GrowthEventType.capability: _TypePalette(
        shortLabel: '能力',
        timelineDot: AppColors.growthCapabilityDot,
        timelineCardBg: AppColors.growthCapabilityCardBg,
        timelineLine: AppColors.growthCapabilityLine,
        gridDot: AppColors.growthGridCapabilityDot,
      ),
      GrowthEventType.matchScore: _TypePalette(
        shortLabel: '分析',
        timelineDot: AppColors.growthMatchScoreDot,
        timelineCardBg: AppColors.growthMatchScoreCardBg,
        timelineLine: AppColors.growthMatchScoreLine,
        gridDot: AppColors.growthGridMatchScoreDot,
      ),
      // 第 5 套为 D96 暂定值 —— 调整只改 Token，本表不动。
      GrowthEventType.rank: _TypePalette(
        shortLabel: '排名',
        timelineDot: AppColors.growthRankDot,
        timelineCardBg: AppColors.growthRankCardBg,
        timelineLine: AppColors.growthRankLine,
        gridDot: AppColors.growthGridRankDot,
      ),
    };

_TypePalette _paletteOf(GrowthEventType type) => _palettes[type]!;

// ═══════════════════════════════════════════════════════════════════════════
// 顶栏（Figma L4001-4018）
// ═══════════════════════════════════════════════════════════════════════════

class _GrowthHeader extends StatelessWidget {
  const _GrowthHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _GrowthMetrics.headerInset,
        _GrowthMetrics.headerTop,
        _GrowthMetrics.headerInset,
        _GrowthMetrics.headerBottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: _GrowthMetrics.backButtonSize,
              height: _GrowthMetrics.backButtonSize,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderSm,
                boxShadow: AppShadows.growthBackButton,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: _GrowthMetrics.backIconSize,
                color: AppColors.growthWeekDayInk,
              ),
            ),
          ),
          const SizedBox(width: _GrowthMetrics.headerGap),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('成长记录', style: AppTypography.growthPageTitle),
              Text(
                '每一次变化，都是成长的痕迹。',
                style: AppTypography.growthPageSubtitle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 周日历条（Figma L4024-4056 · 动态真实日期，周日为一周之首）
// ═══════════════════════════════════════════════════════════════════════════

class _GrowthWeekStrip extends StatelessWidget {
  const _GrowthWeekStrip();

  static const List<String> _dowLabels = <String>[
    '日',
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
  ];

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    // Dart weekday: Mon=1 … Sun=7 → 距离本周日的天数 = weekday % 7。
    final DateTime sunday = now.subtract(Duration(days: now.weekday % 7));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _GrowthMetrics.inset,
        _GrowthMetrics.weekStripTop,
        _GrowthMetrics.inset,
        _GrowthMetrics.weekStripBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: _GrowthMetrics.weekMonthLabelInset,
              bottom: _GrowthMetrics.weekMonthLabelBottom,
            ),
            child: Text(
              '${now.year}年${now.month}月',
              style: AppTypography.growthWeekMonthLabel,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(7, (int i) {
              final DateTime day = sunday.add(Duration(days: i));
              final bool isToday =
                  day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              return _WeekDayCell(
                dowLabel: _dowLabels[i],
                dayNumber: day.day,
                isToday: isToday,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.dowLabel,
    required this.dayNumber,
    required this.isToday,
  });

  final String dowLabel;
  final int dayNumber;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _GrowthMetrics.weekCellWidth,
      child: Column(
        children: <Widget>[
          Text(
            dowLabel,
            style: isToday
                ? AppTypography.growthWeekDowLabelToday
                : AppTypography.growthWeekDowLabel,
          ),
          const SizedBox(height: _GrowthMetrics.weekDowGap),
          Container(
            width: _GrowthMetrics.weekCircleSize,
            height: _GrowthMetrics.weekCircleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isToday ? AppColors.growthTodayCircleGradient : null,
              color: isToday ? null : AppColors.surface,
              border: isToday
                  ? null
                  : Border.all(
                      color: AppColors.growthWeekDayStroke,
                      width: _GrowthMetrics.weekCircleStrokeWidth,
                    ),
              boxShadow: isToday ? AppShadows.growthTodayCircle : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$dayNumber',
              style: isToday
                  ? AppTypography.growthWeekDayNumberToday
                  : AppTypography.growthWeekDayNumber,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 月网格日历（Figma `GrowthCalendar` L2989-3086 · 周一为一周之首）
// ═══════════════════════════════════════════════════════════════════════════

class _GrowthMonthGridCard extends StatelessWidget {
  const _GrowthMonthGridCard({
    required this.events,
    required this.eventsState,
    required this.displayMonth,
    required this.selectedDate,
    required this.today,
    required this.showTodayAction,
    required this.onShiftMonth,
    required this.onSelectDay,
    required this.onGoToday,
    required this.onRetryEvents,
  });

  /// 已加载的事件。加载中 / 失败时为空表 —— **网格照常渲染**。
  final List<GrowthEvent> events;

  /// 当天事件区的数据状态（只有这一区受 Loading / Error 影响）。
  final AsyncState<List<GrowthEvent>> eventsState;

  final DateTime displayMonth;

  /// 选中日期。**恒有值**（默认今天），因此当天事件区恒渲染。
  final DateTime selectedDate;

  final DateTime today;

  /// 视图不在「今天」时，显示「今天」快捷定位。
  final bool showTodayAction;

  final ValueChanged<int> onShiftMonth;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onGoToday;
  final VoidCallback onRetryEvents;

  static const List<String> _dowLabels = <String>[
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '日',
  ];

  @override
  Widget build(BuildContext context) {
    final int year = displayMonth.year;
    final int month = displayMonth.month;

    // 当月事件按「日」分组（模型带完整日期，无需近似）。
    final Map<int, List<GrowthEvent>> byDay = <int, List<GrowthEvent>>{};
    for (final GrowthEvent event in events) {
      final DateTime? at = event.occurredAt;
      if (at == null || at.year != year || at.month != month) continue;
      byDay.putIfAbsent(at.day, () => <GrowthEvent>[]).add(event);
    }

    final bool isCurrentMonth = today.year == year && today.month == month;

    // 周一起始的网格（Figma `WEEK_LABELS` 一二三四五六日）。
    final int startOffset = DateTime(year, month).weekday - 1;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int cellCount = ((startOffset + daysInMonth + 6) ~/ 7) * 7;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _GrowthMetrics.inset,
        0,
        _GrowthMetrics.inset,
        _GrowthMetrics.monthGridBottom,
      ),
      child: CareerlyCard(
        padding: const EdgeInsets.all(_GrowthMetrics.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 月份标题 + 「今天」快捷定位 + 月份切换（D97：Flutter 侧补充交互）。
            Row(
              children: <Widget>[
                Text('$year年$month月', style: AppTypography.growthGridMonthTitle),
                const Spacer(),
                if (showTodayAction) ...<Widget>[
                  CareerlyChip(
                    label: '今天',
                    tone: CareerlyChipTone.brand,
                    onTap: onGoToday,
                  ),
                  const SizedBox(width: _GrowthMetrics.monthNavGap),
                ],
                _MonthNavButton(
                  icon: Icons.chevron_left,
                  onTap: () => onShiftMonth(-1),
                ),
                const SizedBox(width: _GrowthMetrics.monthNavGap),
                _MonthNavButton(
                  icon: Icons.chevron_right,
                  onTap: () => onShiftMonth(1),
                ),
              ],
            ),
            const SizedBox(height: _GrowthMetrics.legendTop),
            // 图例 5 项 —— 短名对齐 Figma `EVENT_LABELS`，
            // 颜色 = 月网格体系（D91 映射表）。
            Wrap(
              spacing: _GrowthMetrics.legendGap,
              children: GrowthEventType.values.map((GrowthEventType type) {
                final _TypePalette palette = _paletteOf(type);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: _GrowthMetrics.legendDot,
                      height: _GrowthMetrics.legendDot,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.gridDot,
                      ),
                    ),
                    const SizedBox(width: _GrowthMetrics.legendDotGap),
                    Text(
                      palette.shortLabel,
                      style: AppTypography.growthGridLegendLabel,
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: _GrowthMetrics.gridHeaderBottom),
            Row(
              children: _dowLabels
                  .map(
                    (String label) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: _GrowthMetrics.dowLabelBottom,
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTypography.growthGridDowLabel,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: _GrowthMetrics.dayCellHeight,
              ),
              itemCount: cellCount,
              itemBuilder: (BuildContext context, int index) {
                final int? day =
                    index < startOffset || index >= startOffset + daysInMonth
                    ? null
                    : index - startOffset + 1;
                if (day == null) return const SizedBox.shrink();
                final List<GrowthEvent> dayEvents =
                    byDay[day] ?? const <GrowthEvent>[];
                final bool isToday = isCurrentMonth && day == today.day;
                final bool isSelected =
                    selectedDate.year == year &&
                    selectedDate.month == month &&
                    selectedDate.day == day;
                return _MonthDayCell(
                  day: day,
                  events: dayEvents,
                  isToday: isToday,
                  isSelected: isSelected,
                  // Phase 8A：**每一天都可点选**（无事件的日期同样可选中，
                  // 选中后当天事件区给空状态）—— 旧实现禁止点空日期。
                  onTap: () => onSelectDay(DateTime(year, month, day)),
                );
              },
            ),
            // ── 当天事件区 ─────────────────────────────────────────────
            // 选中日期恒有值（默认今天）⇒ 本区**恒渲染**；
            // 事件为空时渲染空状态，而不是隐藏本区（Phase 8A）。
            const SizedBox(height: _GrowthMetrics.selectedTop),
            Container(
              height: _GrowthMetrics.dividerHeight,
              color: AppColors.divider,
            ),
            const SizedBox(height: _GrowthMetrics.selectedHeaderTop),
            Text(
              '${selectedDate.month}月${selectedDate.day}日'
              ' · 周${_dowLabels[selectedDate.weekday - 1]}',
              style: AppTypography.growthGridDayHeader,
            ),
            const SizedBox(height: _GrowthMetrics.selectedHeaderBottom),
            _SelectedDayEvents(
              state: eventsState,
              selectedDate: selectedDate,
              today: today,
              onRetry: onRetryEvents,
            ),
          ],
        ),
      ),
    );
  }
}

/// 当天事件区（Figma `GrowthEventCard` 列表 + 当天空状态）。
///
/// 🔴 Phase 8A：**空事件也渲染本区**（空状态），不因无事件整块消失；
/// Loading / Error 只影响本区，**不影响日历**。
class _SelectedDayEvents extends StatelessWidget {
  const _SelectedDayEvents({
    required this.state,
    required this.selectedDate,
    required this.today,
    required this.onRetry,
  });

  final AsyncState<List<GrowthEvent>> state;
  final DateTime selectedDate;
  final DateTime today;
  final VoidCallback onRetry;

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return CareerlyAsyncStateView<List<GrowthEvent>>(
      state: state,
      compact: true,
      onRetry: onRetry,
      loadingMessage: '正在读取成长记录',
      // 空与否由「选中日」决定，不交给顶层 Empty —— 见类文档。
      builder: (BuildContext context, List<GrowthEvent> all) {
        final List<GrowthEvent> dayEvents = all
            .where(
              (GrowthEvent e) =>
                  e.occurredAt != null && _isSameDay(e.occurredAt!, selectedDate),
            )
            .toList();
        if (dayEvents.isEmpty) {
          return _DayEmptyNote(isToday: _isSameDay(selectedDate, today));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: dayEvents
              .map(
                (GrowthEvent event) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: _GrowthMetrics.selectedCardGap,
                  ),
                  child: _DayEventCard(event: event),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// 当天没有事件时的空状态。
///
/// 文案来源：今天那句**逐字来自产品侧**（2026-09-28 产品规则）；
/// 非今天那句为 Flutter 侧按同句式起草，与 D90 同类（空态文案由 Flutter 侧起草，
/// 待产品侧确认后替换）。
class _DayEmptyNote extends StatelessWidget {
  const _DayEmptyNote({required this.isToday});

  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.growthGridEventCardFill,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.growthGridEventCardBorder),
      ),
      padding: const EdgeInsets.all(_GrowthMetrics.dayEventPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isToday ? '今天还没有足迹' : '这一天还没有足迹',
            style: AppTypography.growthEventCardTitle,
          ),
          const SizedBox(height: _GrowthMetrics.dayEventTitleTop),
          Text(
            '完成一次职业分析，这里会留下你的成长记录。',
            style: AppTypography.growthEventCardSub,
          ),
        ],
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(_GrowthMetrics.monthNavPadding),
        child: Icon(
          icon,
          size: _GrowthMetrics.monthNavIconSize,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.day,
    required this.events,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final List<GrowthEvent> events;
  final bool isToday;
  final bool isSelected;

  /// 恒可点选（Phase 8A：空日期也要能被选中）。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasActivity = events.isNotEmpty;
    // Figma：有事件的日期最多显示 2 颗圆点，颜色按事件类型原样取（不去重）。
    final List<Color> dotColors = hasActivity
        ? events.take(2).map((GrowthEvent e) => _paletteOf(e.type).gridDot).toList()
        : const <Color>[];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderXs,
          color: isSelected
              ? AppColors.primaryBlue
              : isToday
              ? AppColors.growthGridTodayFill
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$day',
              style: isSelected
                  ? AppTypography.onSurfaceVariant(
                      AppTypography.growthGridDayNumber.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      AppColors.textInverse,
                    )
                  : isToday
                  ? AppTypography.onSurfaceVariant(
                      AppTypography.growthGridDayNumber.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      AppColors.primaryBlue,
                    )
                  : AppTypography.growthGridDayNumber,
            ),
            const SizedBox(height: _GrowthMetrics.dayNumberDotGap),
            SizedBox(
              height: _GrowthMetrics.dayDot,
              child: hasActivity
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dotColors.map((Color color) {
                        return Container(
                          width: _GrowthMetrics.dayDot,
                          height: _GrowthMetrics.dayDot,
                          margin: const EdgeInsets.symmetric(
                            horizontal: _GrowthMetrics.dayDotGap,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.growthGridSelectedDot
                                : color,
                          ),
                        );
                      }).toList(),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 月网格 · 当日事件卡（Figma `GrowthEventCard` L3064-3085）。
///
/// ⚠️ 原型的 `tag` 胶囊（`'86%'` 等）在模型里**没有对应字段**，不渲染
/// （与批 1 列表骨架同一处置理由）。
class _DayEventCard extends StatelessWidget {
  const _DayEventCard({required this.event});

  final GrowthEvent event;

  @override
  Widget build(BuildContext context) {
    final _TypePalette palette = _paletteOf(event.type);
    final String? delta = event.deltaLabel;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.growthGridEventCardFill,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.growthGridEventCardBorder),
      ),
      padding: const EdgeInsets.all(_GrowthMetrics.dayEventPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 图标圆：`${color}18` 底 + `${color}40` 1.5px 描边 + 8px 内点。
          Container(
            width: _GrowthMetrics.dayEventIcon,
            height: _GrowthMetrics.dayEventIcon,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.growthIconSurface(palette.gridDot),
              border: Border.all(
                color: AppColors.growthIconRing(palette.gridDot),
                width: _GrowthMetrics.dayEventIconRing,
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: _GrowthMetrics.dayEventIconDot,
              height: _GrowthMetrics.dayEventIconDot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.gridDot,
              ),
            ),
          ),
          const SizedBox(width: _GrowthMetrics.dayEventGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _GrowthMetrics.dayEventTagPaddingH,
                        vertical: _GrowthMetrics.dayEventTagPaddingV,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.growthTagSurface(palette.gridDot),
                        borderRadius: AppRadius.borderXs,
                      ),
                      child: Text(
                        palette.shortLabel,
                        style: AppTypography.onSurfaceVariant(
                          AppTypography.growthEventCardTag,
                          palette.gridDot,
                        ),
                      ),
                    ),
                    if (delta != null) ...<Widget>[
                      const SizedBox(width: _GrowthMetrics.dayEventDeltaGap),
                      Text(delta, style: AppTypography.growthEventCardDelta),
                    ],
                  ],
                ),
                const SizedBox(height: _GrowthMetrics.dayEventTitleTop),
                Text(event.title, style: AppTypography.growthEventCardTitle),
                if (event.description != null && event.description!.isNotEmpty)
                  Text(
                    event.description!,
                    style: AppTypography.growthEventCardSub,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 成长时间线（Figma L4058-4114）
// ═══════════════════════════════════════════════════════════════════════════

class _GrowthTimeline extends StatelessWidget {
  const _GrowthTimeline({required this.events});

  final List<GrowthEvent> events;

  /// Figma 时间线日期是**月精度**（`'2026.08'.replace('.', '/')` → `2026/08`）。
  static String? _formatMonth(DateTime? at) {
    if (at == null) return null;
    final String month = at.month.toString().padLeft(2, '0');
    return '${at.year}/$month';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _GrowthMetrics.inset,
        _GrowthMetrics.timelineTop,
        _GrowthMetrics.inset,
        0,
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < events.length; i++)
            _TimelineRow(
              event: events[i],
              isLast: i == events.length - 1,
              dateLabel: _formatMonth(events[i].occurredAt),
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.isLast,
    required this.dateLabel,
  });

  final GrowthEvent event;
  final bool isLast;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    final _TypePalette palette = _paletteOf(event.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 日期标签 —— 右对齐，56px。
          SizedBox(
            width: _GrowthMetrics.timelineDateWidth,
            child: Padding(
              padding: const EdgeInsets.only(
                top: _GrowthMetrics.timelineDateTop,
              ),
              child: Text(
                dateLabel ?? '',
                textAlign: TextAlign.right,
                style: AppTypography.growthTimelineDate,
              ),
            ),
          ),
          // 圆点 + 连接线 —— 44px（左右各 14px 内边距）。
          SizedBox(
            width: _GrowthMetrics.timelineRailWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _GrowthMetrics.timelineRailInset,
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: _GrowthMetrics.timelineDotTop),
                  Container(
                    width: _GrowthMetrics.timelineDot,
                    height: _GrowthMetrics.timelineDot,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.timelineDot,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: _GrowthMetrics.timelineLineWidth,
                        margin: const EdgeInsets.only(
                          top: _GrowthMetrics.timelineLineTop,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // Figma：起点 25% 处是类型色，到 100% 渐隐。
                            stops: const <double>[0.25, 1],
                            colors: <Color>[
                              palette.timelineLine,
                              palette.timelineLine.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 事件卡 —— 左上 4px、其余 20px 的不对称圆角。
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: _GrowthMetrics.timelineCardTop,
                bottom: _GrowthMetrics.timelineCardBottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(
                  _GrowthMetrics.timelineCardPadding,
                ),
                decoration: BoxDecoration(
                  color: palette.timelineCardBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(
                      _GrowthMetrics.timelineCardRadiusSharp,
                    ),
                    topRight: Radius.circular(_GrowthMetrics.timelineCardRadius),
                    bottomLeft: Radius.circular(
                      _GrowthMetrics.timelineCardRadius,
                    ),
                    bottomRight: Radius.circular(
                      _GrowthMetrics.timelineCardRadius,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 卡头：42px 圆形徽章 + 标题 + 日期（Figma 绝对定位还原）。
                    SizedBox(
                      height: _GrowthMetrics.timelineBadge,
                      width: double.infinity,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: _GrowthMetrics.timelineBadge,
                            height: _GrowthMetrics.timelineBadge,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: palette.timelineDot,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              palette.shortLabel,
                              style: AppTypography.growthTimelineBadge,
                            ),
                          ),
                          Positioned(
                            left: _GrowthMetrics.timelineBadgeTextLeft,
                            top: _GrowthMetrics.timelineTitleTop,
                            child: Text(
                              event.title,
                              style: AppTypography.growthTimelineTitle,
                            ),
                          ),
                          Positioned(
                            left: _GrowthMetrics.timelineBadgeTextLeft,
                            top: _GrowthMetrics.timelineDateTextTop,
                            child: Text(
                              dateLabel ?? '',
                              style: AppTypography.growthTimelineDate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (event.description != null &&
                        event.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: _GrowthMetrics.timelineDescTop,
                        ),
                        child: Text(
                          event.description!,
                          style: AppTypography.growthTimelineDesc,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 成长记录页的内部几何（Figma L3973-4114 逐位换算）。
abstract final class _GrowthMetrics {
  static const double inset = 20;
  static const double pageBottom = 40;
  static const double dividerHeight = 1;

  // 顶栏
  static const double headerInset = 24;
  static const double headerTop = 16;
  static const double headerBottom = 6;
  static const double headerGap = 12;
  static const double backButtonSize = 32;
  static const double backIconSize = 15;

  // 周日历条
  static const double weekStripTop = 12;
  static const double weekStripBottom = 16;
  static const double weekMonthLabelInset = 4;
  static const double weekMonthLabelBottom = 12;
  static const double weekCellWidth = 40;
  static const double weekDowGap = 8;
  static const double weekCircleSize = 40;
  static const double weekCircleStrokeWidth = 1;

  // 月网格
  static const double cardPadding = 16;
  static const double monthGridBottom = 16;
  static const double monthNavGap = 4;
  static const double monthNavPadding = 4;
  static const double monthNavIconSize = 16;
  static const double legendTop = 8;
  static const double legendGap = 10;
  static const double legendDot = 6;
  static const double legendDotGap = 2;
  static const double gridHeaderBottom = 8;
  static const double dowLabelBottom = 4;
  static const double dayCellHeight = 40;
  static const double dayNumberDotGap = 2;
  static const double dayDot = 4;
  static const double dayDotGap = 1;

  // 月网格 · 当日事件区
  static const double selectedTop = 12;
  static const double selectedHeaderTop = 12;
  static const double selectedHeaderBottom = 8;
  static const double selectedCardGap = 8;
  static const double dayEventPadding = 12;
  static const double dayEventIcon = 28;
  static const double dayEventIconRing = 1.5;
  static const double dayEventIconDot = 8;
  static const double dayEventGap = 12;
  static const double dayEventTagPaddingH = 5;
  static const double dayEventTagPaddingV = 1;
  static const double dayEventDeltaGap = 8;
  static const double dayEventTitleTop = 2;

  // 成长时间线
  /// 「全部记录」区标题与内容之间的间距。
  static const double timelineHeaderBottom = 8;

  static const double timelineTop = 12;
  static const double timelineDateWidth = 56;
  static const double timelineDateTop = 16;
  static const double timelineRailWidth = 44;
  static const double timelineRailInset = 14;
  static const double timelineDotTop = 18;
  static const double timelineDot = 10;
  static const double timelineLineWidth = 1.5;
  static const double timelineLineTop = 5;
  static const double timelineCardTop = 8;
  static const double timelineCardBottom = 20;
  static const double timelineCardPadding = 16;
  static const double timelineCardRadius = 20;
  static const double timelineCardRadiusSharp = 4;
  static const double timelineBadge = 42;
  static const double timelineBadgeTextLeft = 52;
  static const double timelineTitleTop = 3;
  static const double timelineDateTextTop = 25;
  static const double timelineDescTop = 10;
}
