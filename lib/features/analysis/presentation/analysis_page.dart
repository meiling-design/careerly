import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/back_navigation.dart';
import '../../../core/state/state.dart';
import '../../../data/models/analysis_project.dart';
import '../../../data/models/analysis_result.dart';
import '../../../data/models/job.dart';
import '../../../data/models/parsed_job.dart';
import '../../../data/models/quota_state.dart';
import '../../../data/models/resume_profile.dart';
import '../../../design_system/components/components.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../profile/state/resume_provider.dart';
import '../state/analysis_provider.dart';
import 'widgets/careerly_analysis_progress.dart';

/// 分析 Tab（Phase 6）。
///
/// 视觉真值来源：Figma `AnalysisHome`（`src/App.tsx` L1219-1486）、
/// `AnalysisResult`（L2120-2295）。
/// 结构：页头（小标 + 大标 + 新建/历史分段）→ 内容区按分段切换。
///
/// ## 视觉对齐备注（2026-09-22 本轮修正）
///
/// - **页面骨架**：Figma 分析页没有独立标题栏（与首页同型），
///   此前 `CareerlyScaffold(title: '分析')` 多渲染了一层标题栏 + 双重横向
///   内边距，已移除；页面自带 `px-5`（20）内边距。
/// - 卡片统一改用 [CareerlyCard] 的 **glass** 变体（Figma `Card` =
///   `rounded-3xl` + `S.glass`），此前是本地白底 + 灰描边，材质不对。
/// - 「粘贴 JD / 岗位 URL」两个入口改为 Figma 的**虚线描边**按钮、
///   **纵向堆叠**（此前是实线描边 + 横向并排）。
/// - 「岗位名称（选填）」输入框按 Figma 移除 —— 原型里岗位名由 JD
///   首行（截 30 字）自动推导；岗位链接沿用域名推导。
/// - 结果页 / 历史分析卡按 Figma 结构重建（Hero 磨砂清单面板、
///   岗位匹配列表 #1 渐变卡 + 其余磨砂卡、历史卡含岗位分解条）。
///   仅渲染真实数据可得的元素：「点击下载」（无导出能力）
///   「更新分析」Sheet、「最近一次分析」预览卡（需演示
///   数据）**有意未做**，与 D92「落点不存在的入口不渲染」同一处置。
///   结果页岗位卡已接岗位详情页（`/analysis/job/:jobId`）。
class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _jdController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _history = false;
  bool _addingJd = false;
  bool _addingUrl = false;
  bool _jobAdded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final AnalysisProvider provider = context.read<AnalysisProvider>();
      provider.load();
      provider.loadQuota();
      // 新建分析的第一步是「选择当前简历」（PRD §9.3 / IA §7.2），
      // 因此本页需要简历画像。
      //
      // ⚠️ **读取不等于扣额度**，也不等于发起分析
      // （`CLAUDE.md` §5.2：进分析页不扣）。
      context.read<ResumeProvider>().load();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _jdController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnalysisProvider provider = context.watch<AnalysisProvider>();
    // 分析进行中 → Back（系统 / 边缘右滑 / 顶部返回，三入口同一 Action）
    // 先弹「是否离开分析？」确认；确认离开后**不取消任务**、不回滚额度，
    // 任务继续在 `AnalysisProvider` 里跑，重新进入可以看到进度 / 结果。
    // （产品规则：分析进行中 Back 不应默认取消分析任务。）
    final bool analyzing =
        provider.analysisState is AsyncLoading<AnalysisProject>;
    return CareerlyBackScope(
      guard: analyzing ? const CareerlyBackGuard.analysisInProgress() : null,
      child: CareerlyScaffold(
        showAppBar: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Header(
              history: _history,
              onNew: () {
                setState(() {
                  _history = false;
                  _addingJd = false;
                  _addingUrl = false;
                });
                provider.showNewAnalysis();
              },
              onHistory: () => setState(() => _history = true),
            ),
            Expanded(
              child: _history
                  ? _HistoryView(
                      state: provider.state,
                      onRetry: provider.load,
                      onOpen: (AnalysisProject project) {
                        provider.showHistoryProject(project);
                        setState(() => _history = false);
                      },
                    )
                  : _NewView(
                      provider: provider,
                      titleController: _titleController,
                      jdController: _jdController,
                      urlController: _urlController,
                      addingJd: _addingJd,
                      addingUrl: _addingUrl,
                      jobAdded: _jobAdded,
                      onAddJd: () => setState(() => _addingJd = true),
                      onAddUrl: () {
                        // 打开空表单时清掉上一次抓取的失败红字 ——
                        // 否则会被读成「这次输入就错了」。
                        provider.clearJobUrlState();
                        setState(() => _addingUrl = true);
                      },
                      onCancelJd: () {
                        _jdController.clear();
                        setState(() => _addingJd = false);
                      },
                      onCancelUrl: () {
                        provider.clearJobUrlState();
                        _urlController.clear();
                        setState(() => _addingUrl = false);
                      },
                      onConfirmJd: () {
                        final String jd = _jdController.text.trim();
                        if (jd.isEmpty) return;
                        // Figma `handleAddJD`（L1231-1236）：
                        // 岗位名 = JD 首行（截 30 字），空则「新目标岗位」。
                        final String firstLine = jd.split('\n').first.trim();
                        _titleController.text = firstLine.isEmpty
                            ? '新目标岗位'
                            : (firstLine.length > 30
                                  ? firstLine.substring(0, 30)
                                  : firstLine);
                        setState(() {
                          _jobAdded = true;
                          _addingJd = false;
                        });
                      },
                      onConfirmUrl: () async {
                        final String value = _urlController.text.trim();
                        if (value.isEmpty) return;
                        // ③ 岗位 URL：抓取 → 回填 JD 文本框。
                        //
                        // ⚠️ 这条路径曾经是坏的：它把 URL **原样塞进 JD 框**，
                        // 再当 `rawJd` 发给 `/analysis` —— 等于把一条网址当
                        // 招聘描述去解析。现在改为先把链接交给后端的抓取端点
                        // （复用 work_agent 已有的爬虫），拿到真实 JD 正文再回填。
                        //
                        // 本地不再预判链接合法性（旧代码在非 http 开头时**静默
                        // return**，用户得不到任何反馈）。后端能补协议头
                        // （`zhipin.com/job/x` → `https://…`）、也能给出可执行的
                        // 中文提示，判断交给它一处做。
                        final ParsedJob? parsed = await provider.parseJobUrl(
                          value,
                        );
                        // 抓取途中用户可能点了取消、或切到了历史分析 ——
                        // 那时不能把结果偷偷写进一个已经关掉的表单。
                        if (!mounted || !_addingUrl) return;
                        if (parsed == null) {
                          // 失败：留在表单里显示原因 + 可重试
                          //（`AnalysisProvider.jobUrlState` 供 UI 读错误）。
                          return;
                        }
                        final String title = parsed.title.trim();
                        _titleController.text = title.isEmpty
                            ? '新目标岗位'
                            : title;
                        _jdController.text = parsed.description;
                        setState(() {
                          _jobAdded = true;
                          _addingUrl = false;
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 页头 + 分段切换
// ---------------------------------------------------------------------------

/// Figma `AnalysisHome` 头部（L1259-1282）：
/// `px-5 pt-3 pb-3`；小标 12/w500；大标 22/w700（`mb-0.5`）；
/// 分段容器 `mt-3 rounded-2xl p-1`（16）蓝底 0.08，段高 36 圆角 14。
class _Header extends StatelessWidget {
  const _Header({
    required this.history,
    required this.onNew,
    required this.onHistory,
  });

  final bool history;
  final VoidCallback onNew;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Figma：12px / w500 / textSecondary（`text-[12px] font-medium`）。
          Text(
            '分析',
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text('职业分析', style: AppTypography.title.copyWith(fontSize: 22)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueSurface,
              borderRadius: AppRadius.borderMd, // rounded-2xl = 16
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: _Segment('新建分析', !history, onNew)),
                Expanded(child: _Segment('历史分析', history, onHistory)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment(this.label, this.selected, this.onTap);

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadius.borderSm, // 选中段圆角 14
            boxShadow: selected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1F4F7EF5), // rgba(79,126,245,0.12)
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              fontSize: 13,
              color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 新建分析 —— 状态分发
// ---------------------------------------------------------------------------

class _NewView extends StatelessWidget {
  const _NewView({
    required this.provider,
    required this.titleController,
    required this.jdController,
    required this.urlController,
    required this.addingJd,
    required this.addingUrl,
    required this.jobAdded,
    required this.onAddJd,
    required this.onAddUrl,
    required this.onCancelJd,
    required this.onCancelUrl,
    required this.onConfirmJd,
    required this.onConfirmUrl,
  });

  final AnalysisProvider provider;
  final TextEditingController titleController;
  final TextEditingController jdController;
  final TextEditingController urlController;
  final bool addingJd;
  final bool addingUrl;
  final bool jobAdded;
  final VoidCallback onAddJd;
  final VoidCallback onAddUrl;
  final VoidCallback onCancelJd;
  final VoidCallback onCancelUrl;
  final VoidCallback onConfirmJd;
  final VoidCallback onConfirmUrl;

  @override
  Widget build(BuildContext context) {
    return switch (provider.analysisState) {
      // 「分析中」复合组件（D28 / Phase 6 补做）。进度读数由组件内部的
      // UI 时钟驱动（同 D73 两条时钟）；成功后由本分发切到结果页。
      // Mock 一次只允许 1 个 JD，故胶囊固定「× 1」。
      AsyncLoading<AnalysisProject>() => CareerlyAnalysisProgress(
        jobCount: 1,
        onExit: provider.exitAnalysis,
      ),
      AsyncFailure<AnalysisProject>() =>
        CareerlyAsyncStateView<AnalysisProject>(
          state: provider.analysisState,
          onRetry: provider.retryAnalysis,
          builder: (BuildContext context, AnalysisProject project) =>
              const SizedBox.shrink(),
        ),
      AsyncSuccess<AnalysisProject>(:final AnalysisProject data) => _ResultView(
        project: data,
        onNew: provider.showNewAnalysis,
      ),
      AsyncInitial<AnalysisProject>() => _FormView(
        provider: provider,
        titleController: titleController,
        jdController: jdController,
        urlController: urlController,
        addingJd: addingJd,
        addingUrl: addingUrl,
        jobAdded: jobAdded,
        onAddJd: onAddJd,
        onAddUrl: onAddUrl,
        onCancelJd: onCancelJd,
        onCancelUrl: onCancelUrl,
        onConfirmJd: onConfirmJd,
        onConfirmUrl: onConfirmUrl,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// 新建分析 —— 表单
// ---------------------------------------------------------------------------

class _FormView extends StatelessWidget {
  const _FormView({
    required this.provider,
    required this.titleController,
    required this.jdController,
    required this.urlController,
    required this.addingJd,
    required this.jobAdded,
    required this.addingUrl,
    required this.onAddJd,
    required this.onAddUrl,
    required this.onCancelJd,
    required this.onCancelUrl,
    required this.onConfirmJd,
    required this.onConfirmUrl,
  });

  final AnalysisProvider provider;
  final TextEditingController titleController;
  final TextEditingController jdController;
  final TextEditingController urlController;
  final bool addingJd;
  final bool addingUrl;
  final bool jobAdded;
  final VoidCallback onAddJd;
  final VoidCallback onAddUrl;
  final VoidCallback onCancelJd;
  final VoidCallback onCancelUrl;
  final VoidCallback onConfirmJd;
  final VoidCallback onConfirmUrl;

  @override
  Widget build(BuildContext context) {
    final QuotaState? quota = provider.quota;
    // 岗位链接抓取的 Loading / Error 两态（四态见 `CLAUDE.md` §5.5）：
    // 抓取是**表单内**的异步动作，所以状态就渲染在 URL 表单里 ——
    // 不遮全页、不弹 Sheet（用户还要看着自己粘的那条链接）。
    final bool urlLoading =
        provider.jobUrlState is AsyncLoading<ParsedJob>;
    final String? urlError = provider.jobUrlState.errorOrNull?.message;
    // Figma：`px-5 space-y-4`（横向 20 / 块距 16）+ `pb 104`。
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('基于你的职业经历，看看你与目标岗位的距离。', style: AppTypography.bodySmall),
          const SizedBox(height: 16),
          const _ResumeCard(),
          const SizedBox(height: 16),
          _JobsCard(
            jobAdded: jobAdded,
            addingJd: addingJd,
            addingUrl: addingUrl,
            urlLoading: urlLoading,
            urlError: urlError,
            titleController: titleController,
            jdController: jdController,
            urlController: urlController,
            onAddJd: onAddJd,
            onAddUrl: onAddUrl,
            onCancelJd: onCancelJd,
            onCancelUrl: onCancelUrl,
            onConfirmJd: onConfirmJd,
            onConfirmUrl: onConfirmUrl,
          ),
          if (quota != null) ...<Widget>[
            const SizedBox(height: 16),
            _QuotaBar(quota: quota),
          ],
          const SizedBox(height: 16),
          CareerlyButton(
            label: provider.canAnalyze
                ? (jobAdded ? '开始分析（1 个岗位）' : '开始分析')
                : '额度不足，暂不可分析',
            onPressed: provider.canAnalyze && jobAdded
                ? () => provider.startAnalysis(
                    title: titleController.text,
                    rawJd: jdController.text,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// 当前简历卡（PRD §9.3 / IA §7.2 新建分析的第一步）。
///
/// ## ⚠️ 这里曾是**硬编码的假数据**
///
/// 修复前该卡写死了 `Resume V3 · 2026.08.27 更新` 与
/// `5项 / 4段 / 6个` —— 那是 Figma 原型里的演示值。
/// `CLAUDE.md` §7 明令**不得编造产品数据**，D64 ⑥ 更逐字点名
/// 「`4/6/12/5` 不得搬进 Mock」，故改为读取 [ResumeProfile]：
///
/// ```text
/// 有简历  →  版本名 + 上传日期；三项读数取真实的 length
/// 无简历  →  Empty 态（**不是** `0项 / 0段 / 0个` —— 那也是一种编造）
/// ```
///
/// 与首页同款处置（D64 ⑥ / D75）：**取不到就留空，不回落**到演示值。
class _ResumeCard extends StatelessWidget {
  const _ResumeCard();

  @override
  Widget build(BuildContext context) {
    // 简历是「我的」的资产（PRD §14）；分析页**只读取当前简历**，不管理它。
    final ResumeProfile? profile = context.watch<ResumeProvider>().data;
    final ResumeVersion? version = profile?.currentVersion;

    return _Card(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              // Figma：w-10 h-10 rounded-xl（12）+ `S.primary` 渐变底。
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: AppRadius.borderXs,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '当前简历',
                      style: AppTypography.bodyStrong.copyWith(fontSize: 14),
                    ),
                    Text(
                      version == null ? '还没有上传简历' : _subtitle(version),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              // ⚠️ `更换` 是 Figma 画出的入口，但**尚未接线**
              // （挂起项 → `TODO.md` §3.1 · D82）。
              // 无简历时不显示：没有东西可换。
              if (version != null) const _ChangeBadge(),
            ],
          ),
          if (profile != null && version != null) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _ResumeStat('${profile.skills.length}项', '核心能力'),
                const SizedBox(width: 12),
                _ResumeStat('${profile.workExperiences.length}段', '经历'),
                const SizedBox(width: 12),
                _ResumeStat('${profile.projectExperiences.length}个', '项目'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// `2026 春招版 · 2026.08.27 更新`。
  ///
  /// 日期为手写格式化 —— 项目没有 `intl` 依赖，
  /// 也不为一行日期新引一个（`CLAUDE.md` §6.5）。
  static String _subtitle(ResumeVersion version) {
    final DateTime? at = version.uploadedAt;
    if (at == null) return version.label;
    final String month = at.month.toString().padLeft(2, '0');
    final String day = at.day.toString().padLeft(2, '0');
    return '${version.label} · ${at.year}.$month.$day 更新';
  }
}

/// 「更换」徽标。Figma L1302：12/w600 · `px-3 py-1.5` · 圆角 12 ·
/// 底 `rgba(79,126,245,0.10)` · 字色 primaryBlue。
class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSurfaceSoft,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        '更换',
        style: AppTypography.label.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

/// 简历读数格。Figma L1306-1310：圆角 12 · `py-2` 居中 ·
/// 底 `rgba(79,126,245,0.06)`；数值 14/w700 **渐变文字**（`gradText`）；
/// 标签 10px。
class _ResumeStat extends StatelessWidget {
  const _ResumeStat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlueSurfaceSubtle,
          borderRadius: AppRadius.borderXs,
        ),
        child: Column(
          children: <Widget>[
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) =>
                  AppColors.brandGradient.createShader(bounds),
              child: Text(
                value,
                style: AppTypography.bodyStrong.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white, // 渐变经 srcIn 替换
                ),
              ),
            ),
            Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _JobsCard extends StatelessWidget {
  const _JobsCard({
    required this.jobAdded,
    required this.addingJd,
    required this.addingUrl,
    required this.urlLoading,
    required this.urlError,
    required this.titleController,
    required this.jdController,
    required this.urlController,
    required this.onAddJd,
    required this.onAddUrl,
    required this.onCancelJd,
    required this.onCancelUrl,
    required this.onConfirmJd,
    required this.onConfirmUrl,
  });

  final bool jobAdded;
  final bool addingJd;
  final bool addingUrl;

  /// 岗位链接抓取中。
  final bool urlLoading;

  /// 岗位链接抓取失败的文案；`null` 表示无错误。
  final String? urlError;

  final TextEditingController titleController;
  final TextEditingController jdController;
  final TextEditingController urlController;
  final VoidCallback onAddJd;
  final VoidCallback onAddUrl;
  final VoidCallback onCancelJd;
  final VoidCallback onCancelUrl;
  final VoidCallback onConfirmJd;
  final VoidCallback onConfirmUrl;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('目标岗位', style: AppTypography.bodyStrong.copyWith(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            jobAdded ? '已添加 1 个目标岗位' : '还没有添加目标岗位',
            style: AppTypography.caption,
          ),
          if (jobAdded) ...<Widget>[
            const SizedBox(height: 12),
            // Figma 岗位 Chip：`rounded-full` 胶囊（L1326）。
            Wrap(
              children: <Widget>[
                _Pill(
                  titleController.text.trim().isEmpty
                      ? '新目标岗位'
                      : titleController.text.trim(),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Figma 布局：JD 表单/按钮与 URL 表单/按钮**纵向依次排列**
          // （L1362-1404），互不互斥。
          if (addingJd)
            // 输入实时驱动「添加岗位」的可用态。
            AnimatedBuilder(
              animation: jdController,
              builder: (BuildContext context, Widget? _) => _JdPasteForm(
                controller: jdController,
                onCancel: onCancelJd,
                onConfirm: onConfirmJd,
                canConfirm: jdController.text.trim().isNotEmpty,
              ),
            )
          else
            _DashedAddButton(
              label: '粘贴 JD 添加岗位',
              icon: Icons.add,
              color: AppColors.primaryBlue,
              borderColor: AppColors.inputBorderBrand,
              onTap: onAddJd,
            ),
          const SizedBox(height: 8), // Figma `mt-2`
          if (addingUrl)
            AnimatedBuilder(
              animation: urlController,
              builder: (BuildContext context, Widget? _) => _UrlPasteForm(
                controller: urlController,
                loading: urlLoading,
                errorText: urlError,
                onCancel: onCancelUrl,
                onConfirm: onConfirmUrl,
                canConfirm:
                    !urlLoading && urlController.text.trim().isNotEmpty,
              ),
            )
          else
            _DashedAddButton(
              label: '粘贴岗位 URL',
              icon: Icons.link,
              color: AppColors.primaryPurple,
              borderColor: AppColors.inputBorderPurple,
              onTap: onAddUrl,
            ),
        ],
      ),
    );
  }
}

/// 粘贴 JD 展开表单。Figma L1344-1361：
/// `rounded-2xl`(16) · 描边 `1.5px rgba(79,126,245,0.25)` ·
/// 底 `rgba(79,126,245,0.03)`；标题 12/w600；footer 上下分隔 +
/// 左右两钮（取消 13/w500 灰 / 添加岗位 13/w600 蓝）。
///
/// ⚠️ Figma 没有「岗位名称」输入框 —— 岗位名由 JD 首行推导
/// （页面在 `onConfirmJd` 里做）。
class _JdPasteForm extends StatelessWidget {
  const _JdPasteForm({
    required this.controller,
    required this.onCancel,
    required this.onConfirm,
    required this.canConfirm,
  });

  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool canConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputSurfaceBrand,
        border: Border.all(color: AppColors.inputBorderBrand, width: 1.5),
        borderRadius: AppRadius.borderMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '粘贴岗位 JD',
                  style: AppTypography.label.copyWith(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                CareerlyInput(
                  variant: CareerlyInputVariant.filled,
                  controller: controller,
                  hint:
                      '粘贴招聘描述（JD）内容…\n\n'
                      'Careerly 将自动提取岗位名称和要求，'
                      '用于与你的简历进行匹配分析。',
                  maxLines: 5,
                  maxLength: 5000,
                ),
              ],
            ),
          ),
          _FormFooter(
            cancelLabel: '取消',
            confirmLabel: '添加岗位',
            confirmColor: AppColors.primaryBlue,
            dividerColor: AppColors.primaryBlueDividerHairline,
            canConfirm: canConfirm,
            onCancel: onCancel,
            onConfirm: onConfirm,
          ),
        ],
      ),
    );
  }
}

/// 粘贴岗位链接展开表单。Figma L1375-1394：紫系同构，
/// 说明行 11px `rgba(156,163,175,0.8)`。
///
/// ## 抓取（③ 岗位 URL）
///
/// 点「添加岗位」后后端会真的去抓这条链接（秒级到数十秒），
/// 因此这一格必须自己交代四态（`CLAUDE.md` §5.5）：
///
/// ```text
/// Loading   抓取中 → 输入框禁用 + 转圈行 + 确认钮变「抓取中…」且不可点
/// Error     抓不到 → 输入框下方红字（CareerlyInput.errorText）+ 确认钮变「重试」
/// Empty     表单本身就是空态（hint 可见），不额外造一个空态 UI
/// Disabled  链接为空 / 抓取中 → 确认钮不可点（沿用 Figma 的 disabled 灰）
/// ```
///
/// 抓取失败时**保留输入框内容**：用户要么改链接、要么重试，
/// 不该被迫重新粘一遍。
class _UrlPasteForm extends StatelessWidget {
  const _UrlPasteForm({
    required this.controller,
    required this.loading,
    required this.errorText,
    required this.onCancel,
    required this.onConfirm,
    required this.canConfirm,
  });

  final TextEditingController controller;

  /// 抓取中。
  final bool loading;

  /// 抓取失败的文案；`null` 表示无错误。
  final String? errorText;

  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool canConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputSurfacePurple,
        border: Border.all(color: AppColors.inputBorderPurple, width: 1.5),
        borderRadius: AppRadius.borderMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '粘贴岗位链接',
                  style: AppTypography.label.copyWith(
                    fontSize: 12,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 8),
                CareerlyInput(
                  variant: CareerlyInputVariant.boxed,
                  tone: CareerlyInputTone.purple,
                  controller: controller,
                  enabled: !loading,
                  errorText: errorText,
                  hint: 'https://www.zhipin.com/job/...',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 8),
                if (loading)
                  const _UrlFetchingRow()
                else
                  Text(
                    '支持 Boss 直聘、拉勾、智联、猎聘等主流招聘平台链接',
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.helperTextFaint,
                    ),
                  ),
              ],
            ),
          ),
          _FormFooter(
            cancelLabel: '取消',
            // 按钮文案就是这条路的状态指示器：
            // 抓取中 → 不可点；失败 → 用户看到的下一步动作是「重试」。
            confirmLabel: loading
                ? '抓取中…'
                : (errorText == null ? '添加岗位' : '重试'),
            confirmColor: AppColors.primaryPurple,
            dividerColor: AppColors.primaryPurpleBorderFaint,
            canConfirm: canConfirm,
            onCancel: onCancel,
            onConfirm: onConfirm,
          ),
        ],
      ),
    );
  }
}

/// 「正在抓取岗位信息…」行。
///
/// 说明行位置上的临时替换 —— 抓取在这条路上是**秒级到数十秒**的等待，
/// 没有它用户会以为按钮点空了（点了没反应 = D108 的「失败无痕」同类）。
/// 小尺寸转圈沿用 [CareerlyAsyncStateView] 的写法（非确定型进度）。
class _UrlFetchingRow extends StatelessWidget {
  const _UrlFetchingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '正在抓取岗位信息…',
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            color: AppColors.primaryPurple,
          ),
        ),
      ],
    );
  }
}

/// 展开表单的 footer：顶部 1px 分隔 + 左右两钮（中间竖分隔）。
/// 文案色：取消 `textSecondary` w500 / 确认按 tone 着色 w600；
/// 不可确认时确认钮降为 `rgba(156,163,175,0.6)`（Figma disabled 色）。
class _FormFooter extends StatelessWidget {
  const _FormFooter({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
    required this.dividerColor,
    required this.canConfirm,
    required this.onCancel,
    required this.onConfirm,
  });

  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;
  final Color dividerColor;
  final bool canConfirm;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final Color confirmInk = canConfirm
        ? confirmColor
        : const Color(0x999CA3AF); // rgba(156,163,175,0.6)
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(height: 1, color: dividerColor),
        SizedBox(
          height: 44, // py-3 + 13px 行高
          child: Row(
            children: <Widget>[
              Expanded(
                child: _FooterAction(
                  label: cancelLabel,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  onTap: onCancel,
                ),
              ),
              Container(width: 1, color: dividerColor),
              Expanded(
                child: _FooterAction(
                  label: confirmLabel,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: confirmInk,
                  ),
                  onTap: canConfirm ? onConfirm : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({required this.label, required this.style, this.onTap});

  final String label;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Center(child: Text(label, style: style)),
      ),
    );
  }
}

/// 虚线描边添加按钮。Figma L1363-1371 / L1396-1403：
/// `h-9`（36）· `rounded-xl`（12）· `1.5px dashed` ·
/// 图标 14 + 文案 12/w600。Flutter [OutlinedButton] 不支持虚线，
/// 用 [CustomPainter] 按段绘制圆角矩形描边。
class _DashedAddButton extends StatelessWidget {
  const _DashedAddButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          foregroundPainter: _DashedRRectPainter(
            color: borderColor,
            radius: 12,
            strokeWidth: 1.5,
          ),
          child: Container(
            height: 36,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.label.copyWith(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 虚线圆角矩形描边画笔（Figma `border: 1.5px dashed`）。
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  // Figma 虚线节拍：`stroke-dasharray: 4 3`。
  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = math.min(distance + _dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// 额度条。Figma L1408-1418：`rounded-2xl`(16) `px-4 py-3`；
/// 可用：底 `rgba(79,126,245,0.06)` / 描边 `rgba(79,126,245,0.15)`；
/// 耗尽：红系同档。左 13/w600 · 右 13/w700；轨道 `h-1.5`
/// `rgba(229,231,235,0.8)`，填充 `S.primary`（品牌渐变）。
class _QuotaBar extends StatelessWidget {
  const _QuotaBar({required this.quota});
  final QuotaState quota;

  @override
  Widget build(BuildContext context) {
    final bool available = quota.canAnalyze;
    final double value = quota.isMember ? 1 : quota.remaining / quota.total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: available
            ? AppColors.primaryBlueSurfaceSubtle
            : AppColors.dangerSurfaceSubtle,
        border: Border.all(
          color: available
              ? AppColors.primaryBlueBorderFaint
              : AppColors.dangerBorderFaint,
        ),
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                available ? '免费体验' : '免费次数已用完',
                style: AppTypography.label.copyWith(
                  color: available ? AppColors.primaryBlue : AppColors.danger,
                ),
              ),
              Text(
                quota.isMember
                    ? '不限次数'
                    : '剩余 ${quota.remaining} / ${quota.total} 次',
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: available ? AppColors.primaryBlue : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CareerlyProgress(
            value: value,
            height: 6,
            trackColor: AppColors.homeMatchTrack, // rgba(229,231,235,0.8)
            gradient: available
                ? AppColors.brandGradient
                : const LinearGradient(
                    colors: <Color>[AppColors.danger, AppColors.danger],
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 分析结果
// ---------------------------------------------------------------------------

/// 分析结果页。真值来源：Figma `AnalysisResult`（L2120-2295）。
///
/// 结构：TopBar（返回 + 标题）→ 元信息行 → Hero 卡（渐变 + 装饰圆 +
/// 「较上次」徽标 + 磨砂「本次分析为你生成」清单）→ 岗位匹配列表
/// （#1 渐变卡 + 其余磨砂卡）→ 匹配依据 / 能力 Gap / 成长建议 →
/// 「更新分析」。
///
/// **有意未做**（不编造 / 落点不存在，同 D92 处置）：
/// 「点击下载」（无导出能力）、「查看最匹配岗位」（a-job 页未建）、
/// 「更新分析」Sheet（直接落新建分析）、成长空间数值双条
/// （Mock 只有 Gap 文案，没有 yours/target 数值）。
class _ResultView extends StatelessWidget {
  const _ResultView({required this.project, required this.onNew});
  final AnalysisProject project;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final AnalysisResult? result = project.latestResult;
    final AnalysisResult? previous = project.results.length >= 2
        ? project.results[project.results.length - 2]
        : null;
    final List<JobMatch> matches = (result?.matches ?? const <JobMatch>[])
      ..sort((JobMatch a, JobMatch b) => a.rank.compareTo(b.rank));
    final Map<String, int> previousScores = <String, int>{
      for (final JobMatch match in previous?.matches ?? const <JobMatch>[])
        match.jobId: match.score,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CareerlyTopBar(title: '分析结果', onBack: onNew),
          const SizedBox(height: 4),
          _ResultMetaLine(project: project, result: result),
          const SizedBox(height: 16),
          _ResultHero(topDelta: _topDelta(result, previous)),
          const SizedBox(height: 16),
          if (matches.isNotEmpty)
            _MatchList(
              project: project,
              matches: matches,
              previousScores: previousScores,
            ),
          _ResultSection('匹配依据', result?.top?.reasons ?? const <String>[]),
          _ResultSection('能力 Gap', result?.top?.gaps ?? const <String>[]),
          if (result?.top?.suggestion != null)
            _ResultSection('成长建议', <String>[result!.top!.suggestion!]),
          const SizedBox(height: 4),
          CareerlyButton(label: '更新分析', onPressed: onNew),
        ],
      ),
    );
  }

  /// 最高分相对上一次的变化；无上次结果时为 `null`。
  static int? _topDelta(AnalysisResult? result, AnalysisResult? previous) {
    if (result?.top == null || previous?.top == null) return null;
    return result!.top!.score - previous!.top!.score;
  }
}

/// 元信息行。Figma L2135：`基于 {简历} · {日期} · N 个目标岗位`，
/// 12px `#6b7280`。缺数据的段**整段省略**（不编造）。
class _ResultMetaLine extends StatelessWidget {
  const _ResultMetaLine({required this.project, required this.result});

  final AnalysisProject project;
  final AnalysisResult? result;

  @override
  Widget build(BuildContext context) {
    final ResumeVersion? version = context
        .watch<ResumeProvider>()
        .data
        ?.currentVersion;
    final List<String> parts = <String>[
      if (version != null) '基于 ${version.label}',
      if (result?.createdAt != null) _formatDate(result!.createdAt!),
      if (project.jobs.isNotEmpty) '${project.jobs.length} 个目标岗位',
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join(' · '),
      style: AppTypography.bodySmall.copyWith(fontSize: 12),
    );
  }

  static String _formatDate(DateTime at) {
    final String month = at.month.toString().padLeft(2, '0');
    final String day = at.day.toString().padLeft(2, '0');
    return '${at.year}.$month.$day';
  }
}

/// Hero 卡。Figma L2138-2172：高 175 · 圆角 24 · `153deg` 品牌渐变 ·
/// 投影 `0 16px 40px rgba(79,126,245,0.28)` · 右上装饰圆 144（白 0.08）·
/// 「较上次」徽标（白 0.20 底胶囊）· 磨砂清单面板（白 0.05 底 /
/// 白 0.29 描边）内 2×2 打勾项。
class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.topDelta});

  final int? topDelta;

  static const List<String> _checkItems = <String>[
    '匹配度报告',
    '能力分析',
    '能力 Gap',
    '成长建议',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.resultHeroGradient,
        borderRadius: AppRadius.borderXl,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x474F7EF5), // rgba(79,126,245,0.28)
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -32,
            right: -7,
            child: Container(
              width: 144,
              height: 144,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.resultHeroDecoration,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (topDelta != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onBrandSurface,
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          const TextSpan(
                            text: '较上次 ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: topDelta! > 0 ? '↑ +$topDelta%' : '—',
                            style: TextStyle(
                              color: topDelta! > 0
                                  ? AppColors.resultDeltaGreen
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      style: AppTypography.label.copyWith(fontSize: 12),
                    ),
                  ),
                const Spacer(),
                Container(
                  height: 94,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.resultPanelFill,
                    border: Border.all(color: AppColors.resultPanelBorder),
                    borderRadius: AppRadius.borderXl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '本次分析为你生成',
                        style: AppTypography.label.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 2×2 打勾项（固定两行，避免 GridView 在小屏溢出）。
                      Row(
                        children: <Widget>[
                          Expanded(child: _CheckItem(label: _checkItems[0])),
                          const SizedBox(width: 12),
                          Expanded(child: _CheckItem(label: _checkItems[1])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Expanded(child: _CheckItem(label: _checkItems[2])),
                          const SizedBox(width: 12),
                          Expanded(child: _CheckItem(label: _checkItems[3])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 打勾项：白 0.15 圆底 + 白勾 + 12/w500 白字。
class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 13,
          height: 13,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x26FFFFFF), // rgba(255,255,255,0.15)
          ),
          child: const Icon(Icons.check, size: 9, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// 岗位匹配列表。#1 渐变卡（L2207-2229），其余磨砂卡（L2232-2256）。
class _MatchList extends StatelessWidget {
  const _MatchList({
    required this.project,
    required this.matches,
    required this.previousScores,
  });

  final AnalysisProject project;
  final List<JobMatch> matches;
  final Map<String, int> previousScores;

  @override
  Widget build(BuildContext context) {
    final Map<String, Job> jobs = <String, Job>{
      for (final Job job in project.jobs) job.id: job,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < matches.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          _MatchCard(
            match: matches[i],
            job: jobs[matches[i].jobId],
            previousScore: previousScores[matches[i].jobId],
            isFirst: i == 0,
          ),
        ],
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.job,
    required this.previousScore,
    required this.isFirst,
  });

  final JobMatch match;
  final Job? job;
  final int? previousScore;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final int? delta = previousScore == null
        ? null
        : match.score - previousScore!;
    // 点击 → 岗位详情页（Figma L2199：结果页岗位卡 → `a-job`）。
    // job 为空（数据缺联）时不给手势，避免推出一个 Empty 态页面。
    final VoidCallback? openDetail = job == null
        ? null
        : () => context.push(AppRoutes.analysisJob(job!.id));
    if (isFirst) {
      return CareerlyPressFeedback(
        onTap: openDetail,
        child: Container(
          height: 87,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.resultHeroGradient,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            children: <Widget>[
              // 排名徽标：40×40 / r12 / 白 0.22。
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x38FFFFFF), // rgba(255,255,255,0.22)
                  borderRadius: AppRadius.borderXs,
                ),
                child: Text(
                  '#${match.rank}',
                  style: AppTypography.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.onBrandSurface,
                        borderRadius: AppRadius.borderPill,
                      ),
                      child: Text(
                        '最佳匹配',
                        style: AppTypography.label.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job?.displayName ?? '目标岗位',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${match.score}%',
                    style: AppTypography.numeric.copyWith(
                      fontSize: 26,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                  if (delta != null && delta > 0)
                    Text(
                      '↑ +$delta%',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    // #2+：磨砂玻璃卡。
    return _Card(
      onTap: openDetail,
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryBlueSurface,
              borderRadius: AppRadius.borderXs,
            ),
            child: Text(
              '#${match.rank}',
              style: AppTypography.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  job?.displayName ?? '目标岗位',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (previousScore != null)
                  Text(
                    '$previousScore% → ${match.score}%',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) =>
                    AppColors.homeMatchTextGradient.createShader(bounds),
                child: Text(
                  '${match.score}%',
                  style: AppTypography.numeric.copyWith(
                    fontSize: 22,
                    height: 1,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
              ),
              if (delta != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: delta > 0
                        ? AppColors.successSurface
                        : AppColors.neutralSurface,
                    borderRadius: AppRadius.borderPill,
                  ),
                  child: Text(
                    delta > 0 ? '↑ +$delta%' : '—',
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: delta > 0
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection(this.title, this.items);
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: AppTypography.bodyStrong.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            for (final String item in items)
              Text('• $item', style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 历史分析
// ---------------------------------------------------------------------------

/// 历史分析列表。真值来源：Figma `AnalysisHome` 的 history 分支
/// （L1443-1482）：引导语 + 卡片（日期 / 「一次分析 · N 个岗位」 /
/// 最高分渐变数字 / 变化 / 岗位分解条 / 简历版本 footer）。
class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.state,
    required this.onRetry,
    required this.onOpen,
  });
  final AsyncState<List<AnalysisProject>> state;
  final VoidCallback onRetry;
  final ValueChanged<AnalysisProject> onOpen;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 4),
          Text('记录你与不同目标岗位之间的变化。', style: AppTypography.bodySmall),
          const SizedBox(height: 16),
          CareerlyAsyncStateView<List<AnalysisProject>>(
            state: state,
            onRetry: onRetry,
            isEmpty: (List<AnalysisProject> projects) => projects.isEmpty,
            emptyTitle: '还没有分析记录',
            emptyMessage: '完成一次岗位分析后，结果会保存在这里。',
            builder: (BuildContext context, List<AnalysisProject> projects) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int i = 0; i < projects.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(height: 16),
                      _HistoryCard(
                        project: projects[i],
                        isFirst: i == 0,
                        onOpen: () => onOpen(projects[i]),
                      ),
                    ],
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.project,
    required this.isFirst,
    required this.onOpen,
  });

  final AnalysisProject project;
  final bool isFirst;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final AnalysisResult? result = project.latestResult;
    final AnalysisResult? previous = project.results.length >= 2
        ? project.results[project.results.length - 2]
        : null;
    final int? topScore = project.latestTopScore;
    final int? delta = (result?.top != null && previous?.top != null)
        ? result!.top!.score - previous!.top!.score
        : null;
    final DateTime? at = project.updatedAt ?? project.createdAt;
    final Map<String, JobMatch> matches = <String, JobMatch>{
      for (final JobMatch match in result?.matches ?? const <JobMatch>[])
        match.jobId: match,
    };

    return _Card(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (at != null)
                      Text(
                        _formatDate(at),
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '一次分析 · ${project.jobs.length} 个岗位',
                      style: AppTypography.bodyStrong.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (topScore != null)
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) =>
                          AppColors.homeMatchTextGradient.createShader(bounds),
                      child: Text(
                        '$topScore%',
                        style: AppTypography.numeric.copyWith(
                          fontSize: 24,
                          height: 1,
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (delta != null && delta > 0)
                    Text(
                      '↑ +$delta%',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  if (topScore != null)
                    Text(
                      '最高匹配',
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                ],
              ),
            ],
          ),
          if (project.jobs.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            // 岗位分解条：名称 12 / 80×6 轨道（品牌渐变填充）/ 百分比 12/w700。
            for (int i = 0; i < project.jobs.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < project.jobs.length - 1 ? 8 : 0,
                ),
                child: _HistoryJobRow(
                  job: project.jobs[i],
                  match: matches[project.jobs[i].id],
                ),
              ),
          ],
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.homeJobDivider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 简历版本标签：取不到就不渲染（不编造）。
              Builder(
                builder: (BuildContext context) {
                  final List<ResumeVersion> versions =
                      context.watch<ResumeProvider>().data?.versions ??
                      const <ResumeVersion>[];
                  ResumeVersion? version;
                  for (final ResumeVersion v in versions) {
                    if (v.id == result?.resumeVersionId) {
                      version = v;
                      break;
                    }
                  }
                  return Expanded(
                    child: Text(
                      version?.label ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
              if (isFirst && result != null)
                Text(
                  '查看本次分析 →',
                  style: AppTypography.label.copyWith(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime at) {
    final String month = at.month.toString().padLeft(2, '0');
    final String day = at.day.toString().padLeft(2, '0');
    return '${at.year}.$month.$day';
  }
}

/// 历史卡里的单条岗位分解行。Figma L1462-1470：
/// 名称 12/w500 · 轨道 `w-20 h-1.5`（80×6）· 填充 `S.primary` ·
/// 百分比 12/w700 primaryBlue 右对齐（宽 36）。
class _HistoryJobRow extends StatelessWidget {
  const _HistoryJobRow({required this.job, required this.match});

  final Job job;
  final JobMatch? match;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            job.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 80,
          height: 6,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.homeMatchTrack,
            borderRadius: AppRadius.borderPill,
          ),
          child: FractionallySizedBox(
            widthFactor: (match?.score ?? 0) / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderPill,
                gradient: AppColors.brandGradient,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            match == null ? '—' : '${match!.score}%',
            textAlign: TextAlign.right,
            style: AppTypography.label.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 共用
// ---------------------------------------------------------------------------

/// Glass 卡片（Figma `Card` = `rounded-3xl` + `S.glass`）。
/// 统一走 [CareerlyCard] 的 glass 变体，不再本地自绘白底灰边。
class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CareerlyCard(
      variant: CareerlyCardVariant.glass,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: child,
    );
  }
}

/// 岗位 Chip。Figma L1326：`rounded-full` · `px-3 py-1` ·
/// 底 `rgba(79,126,245,0.08)` · 12/w500 primaryBlue。
class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSurface,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
