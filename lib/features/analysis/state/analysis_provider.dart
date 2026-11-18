import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/state/state.dart';
import '../../../data/api/analysis_task_store.dart';
import '../../../data/api/api_client.dart';
import '../../../data/models/analysis_project.dart';
import '../../../data/models/analysis_task.dart';
import '../../../data/models/job.dart';
import '../../../data/models/parsed_job.dart';
import '../../../data/models/quota_state.dart';
import '../../../data/repositories/analysis_repository.dart';

/// 分析状态。
///
/// 归属（Baseline §3.2）：**历史分析项目只属于「分析」**。
///
/// 能力范围（Phase 6 交付后）：
/// 读取项目列表 / 额度、发起与退出分析、岗位链接抓取、历史岗位库读取。
///
/// 额度语义（P1-03 / P1-05）：
/// - 发起分析时 `consume()` 是**本地乐观预占**；服务端同样原子预占；
/// - 分析失败 → [startAnalysis] 的回滚 + 重新读服务端额度；
/// - 退出分析页 → **不**回滚、**不**取消服务器任务，只停止本页轮询；
/// - 重新进入 → [restoreActiveTask] 查询真实任务状态，完成后刷新结果与额度。
class AnalysisProvider extends AsyncStateNotifier<List<AnalysisProject>> {
  AnalysisProvider(
    this._repository, {
    ActiveAnalysisTaskStore? taskStore,
  }) : _taskStore = taskStore ?? InMemoryActiveAnalysisTaskStore();

  final AnalysisRepository _repository;

  /// 当前进行中任务的持久化句柄（杀进程后恢复用）。
  final ActiveAnalysisTaskStore _taskStore;

  /// 总进度的单调基线：后端读数只允许前进，不允许回退。
  int _maxOverallProgress = 0;

  /// 真实后端数据源（只有它实现 [AnalysisProgressSource]）。
  AnalysisProgressSource? get _progressSource {
    final AnalysisRepository repository = _repository;
    // 两个 interface 类型互不相关，Dart 不会为 `is` 检查产生类型提升，
    // 因此这里必须显式转换（不是多余的转换）。
    return repository is AnalysisProgressSource
        ? repository as AnalysisProgressSource
        : null;
  }

  QuotaState? _quota;
  AsyncState<AnalysisProject> _analysisState =
      const AsyncState<AnalysisProject>.initial();
  String _lastTitle = '';
  String _lastJd = '';
  String _lastCompany = '';
  String _lastImportSource = 'paste';
  String? _lastSourceUrl;

  /// 本次分析运行的代际号。
  ///
  /// 「退出分析」（`CareerlyAnalysisProgress` 的退出确认 Sheet）会在
  /// Mock 的 `Future.delayed` 尚未 resolve 时重置状态；没有代际号，
  /// 迟到的结果会把用户强行拽回结果页（僵屍结果）。每次发起分析 `+1`，
  /// `await` 返回后代际不符则**丢弃**结果——额度已由 [exitAnalysis] 回滚，
  /// 这里不再重复处理。
  int _runId = 0;

  /// 引擎实时节点进度。见 [taskProgress]。
  ///
  /// 每次发起分析清零，终态（成功 / 失败 / 退出）也清零 —— 否则它会在
  /// 下一次分析开始前残留上一轮的步号，让「正在分析」页从第 4 步开始。
  AnalysisTaskProgress? _taskProgress;

  /// 当前额度状态。为 `null` 表示尚未读取。
  QuotaState? get quota => _quota;

  /// 是否还能发起分析（额度门禁）。
  ///
  /// 依据 Baseline §5，UI 用它 gate「开始分析」按钮。
  /// 额度未知时**保守返回 false**，避免 UI 误放行。
  bool get canAnalyze => _quota?.canAnalyze ?? false;

  AsyncState<AnalysisProject> get analysisState => _analysisState;

  /// 引擎**真实节点**的进度（P1-1b）。
  ///
  /// 为 `null` 表示「没有真实进度可报告」—— 要么还没开始（排队中），
  /// 要么数据源是 Mock（它背后没有 agent 流程）。两种情况都表示
  /// 「正在分析」页应退回组件内时钟驱动，而**不是**进度为 0%。
  AnalysisTaskProgress? get taskProgress => _taskProgress;

  AnalysisProject? get latestProject => _analysisState.dataOrNull;

  String get lastTitle => _lastTitle;

  String get lastJd => _lastJd;

  /// 岗位链接抓取的状态（③ 岗位 URL）。
  ///
  /// 与 [analysisState] 分开：抓取**不是分析**，它不占额度、不建任务，
  /// 结果只回填到表单里 —— 混进 [analysisState] 会让「分析中」的
  /// 进度页在用户还没开始分析时就弹出来。
  AsyncState<ParsedJob> _jobUrlState = const AsyncState<ParsedJob>.initial();

  AsyncState<ParsedJob> get jobUrlState => _jobUrlState;

  /// 历史岗位库的状态（PRD §9.3「从历史岗位中添加」）。
  ///
  /// 与 [analysisState] 分开，理由同 [jobUrlState]：读岗位库**不是分析** ——
  /// 它不扣额度、不建任务，混进 [analysisState] 会让「分析中」的进度页
  /// 在用户只是打开选择列表时就弹出来。
  ///
  /// 与 [jobUrlState] 分开，理由也是它们**互不相关**：抓取失败不该让
  /// 岗位库列表显示成 Error，反之亦然。
  AsyncState<List<Job>> _jobLibraryState =
      const AsyncState<List<Job>>.initial();

  AsyncState<List<Job>> get jobLibraryState => _jobLibraryState;

  /// 抓取一条岗位链接，供表单回填 JD 文本框。
  ///
  /// ⚠️ **不扣额度**（`CLAUDE.md` §5.2：只有「开始分析」扣）、
  /// **不建分析任务**。失败时把错误放进 [jobUrlState] 由 UI 展示，
  /// 并返回 `null`。
  ///
  /// ## 为什么这个方法是「有返回值」的（与 [startAnalysis] 不同）
  ///
  /// 回填动作是**页面级的**：成功要把 title / description 写进两个
  /// `TextEditingController`，而控制器归页面所有。让调用方 `await`
  /// 拿到 [ParsedJob] 再决定，比让页面去监听状态变化更不容易出现
  /// 「状态已变、控制器还没填」的中间态。
  ///
  /// 调用方**必须**在 `await` 之后重新确认表单是否还开着再落笔
  /// （用户可能在抓取途中点了取消）—— 见 `analysis_page.dart`。
  Future<ParsedJob?> parseJobUrl(String url) async {
    _jobUrlState = const AsyncState<ParsedJob>.loading(message: '正在抓取岗位信息…');
    notifyListeners();
    try {
      final ParsedJob parsed = await _repository.parseJobUrl(url);
      _jobUrlState = AsyncState<ParsedJob>.success(parsed);
      notifyListeners();
      return parsed;
    } catch (error, stackTrace) {
      _jobUrlState = AsyncState<ParsedJob>.failure(
        AppError.from(error, stackTrace),
      );
      notifyListeners();
      return null;
    }
  }

  /// 清空抓取状态（打开 / 取消 URL 表单时调用）。
  ///
  /// 不清的话，上一次失败的红字会留在新打开的空表单上，
  /// 看起来像是这次输入就错了。
  void clearJobUrlState() {
    if (_jobUrlState is AsyncInitial<ParsedJob>) return;
    _jobUrlState = const AsyncState<ParsedJob>.initial();
    notifyListeners();
  }

  /// 读取历史岗位库，供「从历史岗位添加」的选择列表展示。
  ///
  /// 端点 `GET /api/v1/analysis/jobs`（PRD §9.3：从本项目移除岗位
  /// **不删除**其历史岗位记录）。
  ///
  /// ⚠️ **不扣额度**（`CLAUDE.md` §5.2：只有「开始分析」扣）、
  /// **不建分析任务**。与 [parseJobUrl] 同款处置 —— 用显式 try/catch
  /// 把错误写进 state，让选择列表能如实渲染 Error + Retry
  /// （`CLAUDE.md` §5.5 四态），而不是静默失败给一个空列表。
  ///
  /// 不引入代际号：本方法与 [startAnalysis] 不同，它不会把用户
  /// 从当前界面拽走 —— 弹层关闭后结果自然作废。
  Future<void> loadJobLibrary() async {
    _jobLibraryState = const AsyncState<List<Job>>.loading(
      message: '正在读取历史岗位…',
    );
    notifyListeners();
    try {
      final List<Job> jobs = await _repository.fetchJobLibrary();
      _jobLibraryState = AsyncState<List<Job>>.success(jobs);
    } catch (error, stackTrace) {
      _jobLibraryState = AsyncState<List<Job>>.failure(
        AppError.from(error, stackTrace),
      );
    }
    notifyListeners();
  }

  /// 读取历史分析项目列表。
  Future<void> load() => execute(_repository.fetchProjects);

  /// 读取额度。
  ///
  /// **读取额度不代表扣减。** 依据 Baseline §5，
  /// 上传简历 / 粘贴 JD / 进入分析页面都不扣额度，
  /// 只有真正点击「开始分析」才扣减。
  ///
  /// 额度读取失败**不会**把项目列表推到 Error 状态——
  /// 两者是独立关注点，额度失败只影响门禁。
  Future<void> loadQuota() async {
    final QuotaState? value = await ErrorHandler.guard(_repository.fetchQuota);
    if (value == null) {
      if (kDebugMode) {
        debugPrint('[Careerly] 额度读取失败，保持 canAnalyze=false');
      }
      return;
    }
    _quota = value;
    notifyListeners();
  }

  /// 创建单岗位分析。额度只在这里扣减，失败时立即回滚。
  ///
  /// ## 两条执行路径（P1-1b，2026-10-05）
  ///
  /// ```text
  /// 数据源实现 AnalysisProgressSource（真实后端）
  ///   → 202 + 轮询：进度来自引擎**真实节点**，节点慢则动画等待
  /// 否则（Mock）
  ///   → 同步 analyze()：进度由「正在分析」组件内的时钟驱动（原行为）
  /// ```
  ///
  /// **为什么不统一成一条**：Mock 背后没有 agent 流程 —— 它的「分析」
  /// 是一次 `Future.delayed`，没有 `crawl` / `routing` 可言。强行统一只能
  /// 靠编造节点名，那是 `CLAUDE.md` §7 禁止的「编造产品数据」。
  /// 能力按实现者区分，比假装统一更诚实。
  ///
  /// ⚠️ 这**取代**了 D73「进度读数由组件内部 UI 时钟驱动」在本屏的适用性：
  /// 实测引擎单是 `routing` 一个节点就可能跑 100 秒以上，而组件内时钟
  /// 固定 7.3 秒就定形「分析完成」—— 那是一个真实的行为缺陷。
  Future<void> startAnalysis({
    required String title,
    required String rawJd,
    String company = '',
    String importSource = 'paste',
    String? sourceUrl,
  }) async {
    _lastTitle = title;
    _lastJd = rawJd;
    _lastCompany = company;
    _lastImportSource = importSource;
    _lastSourceUrl = sourceUrl;

    if (rawJd.trim().isEmpty) {
      _setAnalysisFailure(
        const ParseError(message: '岗位 JD 不能为空，请粘贴岗位描述后重试', source: 'jd'),
      );
      return;
    }
    if (!canAnalyze) {
      _setAnalysisFailure(QuotaError(remaining: _quota?.remaining ?? 0));
      return;
    }

    _quota = _quota!.consume();
    final int run = ++_runId;
    _taskProgress = null;
    _maxOverallProgress = 0;
    _setAnalysisLoading(progress: 0.0, message: '准备岗位信息');

    // 能力探测：只有真实后端能报节点进度（见 AnalysisProgressSource 的文档）。
    final AnalysisProgressSource? source = _progressSource;
    try {
      final AnalysisProject? project = source != null
          ? await _runWithRealProgress(
              source,
              run: run,
              title: title,
              rawJd: rawJd,
              company: company,
              importSource: importSource,
              sourceUrl: sourceUrl,
            )
          : await _runWithLocalClock(
              run: run,
              title: title,
              rawJd: rawJd,
              company: company,
              importSource: importSource,
              sourceUrl: sourceUrl,
            );
      if (project == null) {
        // 用户已离开当前页面：结果作废。但**不**回滚额度 ——
        // 后端任务仍在跑，预占仍然有效（P1-05）。
        return;
      }
      _taskProgress = null;
      _analysisState = AsyncState<AnalysisProject>.success(project);
      _replaceProjects(<AnalysisProject>[project, ..._projects]);
      // 任务完成后以后端额度为准（预占已转为消耗）。
      await loadQuota();
    } catch (error, stackTrace) {
      if (run != _runId) return; // 已退出：失败也作废
      _quota = _quota!.rollback();
      _taskProgress = null;
      unawaited(_taskStore.clear());
      _setAnalysisFailure(AppError.from(error, stackTrace));
      // 后端失败时会释放预占；重新读一次避免本地与后端漂移。
      await loadQuota();
    }
    notifyListeners();
  }

  /// 真实后端路径：202 拿句柄 → 轮询 → 取结果。
  ///
  /// 返回 `null` 表示本次运行已被取代（用户退出 / 又发起了一次），
  /// 调用方应直接丢弃结果。⚠️ 退出**不**回滚额度：后端预占仍然有效，
  /// 任务继续跑，重新进入时 [restoreActiveTask] 会接上同一条任务。
  Future<AnalysisProject?> _runWithRealProgress(
    AnalysisProgressSource source, {
    required int run,
    required String title,
    required String rawJd,
    required String company,
    required String importSource,
    required String? sourceUrl,
  }) async {
    AnalysisTask task = await source.startAnalysisTask(
      title: title,
      rawJd: rawJd,
      company: company,
      source: importSource,
      sourceUrl: sourceUrl,
    );
    if (run != _runId) return null;
    // 句柄必须先落盘：进程此刻被杀，下次进入仍能恢复同一条任务。
    await _taskStore.write(task.taskId);
    _applyTaskProgress(task);

    while (!task.isTerminal) {
      await Future<void>.delayed(ApiClient.analysisPollInterval);
      if (run != _runId) return null;
      task = await source.fetchAnalysisTask(task.taskId);
      if (run != _runId) return null;
      _applyTaskProgress(task);
    }

    await _taskStore.clear();

    if (task.isFailed) {
      // 后端的 errorMessage 已是给用户看的中文（P1-2 归一化过），原样上屏。
      throw UnknownError(
        message: task.errorMessage ?? '分析失败，请稍后重试',
        detail: task.errorCode ?? 'ANALYSIS_FAILED',
      );
    }

    if (task.isCancelled) {
      throw UnknownError(
        message: task.errorMessage ?? '分析已取消',
        detail: task.errorCode ?? 'ANALYSIS_CANCELLED',
      );
    }

    final String? projectId = task.projectId;
    if (projectId == null) {
      throw const UnknownError(
        message: '分析已完成，但没有返回结果',
        detail: 'AnalysisTask.projectId == null',
      );
    }
    final AnalysisProject? project = await _repository.fetchProject(projectId);
    if (run != _runId) return null;
    if (project == null) {
      throw const UnknownError(
        message: '分析结果读取失败，请稍后重试',
        detail: 'fetchProject returned null',
      );
    }
    return project;
  }

  /// Mock 路径：原行为逐字保留（进度由组件内时钟驱动，这里只是
  /// 同步等待期间的状态标记）。
  Future<AnalysisProject?> _runWithLocalClock({
    required int run,
    required String title,
    required String rawJd,
    required String company,
    required String importSource,
    required String? sourceUrl,
  }) async {
    _setAnalysisLoading(progress: 0.45, message: '理解岗位要求');
    final AnalysisProject project = await _repository.analyze(
      title: title,
      rawJd: rawJd,
      company: company,
      source: importSource,
      sourceUrl: sourceUrl,
    );
    if (run != _runId) return null;
    _setAnalysisLoading(progress: 0.8, message: '建立能力匹配');
    return project;
  }

  /// 把一次任务快照翻译成 UI 状态并通知监听者。
  ///
  /// 总进度**只信任后端**的 `overallProgress`（按 5 步权重汇总），
  /// 并做单调夹紧：轮询乱序 / 网络重放都不允许进度条倒退。
  void _applyTaskProgress(AnalysisTask task) {
    _taskProgress = task.progress;

    final int? reported = task.progress?.overallProgress;
    // 旧后端没有 overallProgress 时才退回到「已完成的步数」估算；
    // 这仍是**后端状态**的换算，不是前端计时器。
    final int fallback = task.progress == null
        ? 0
        : ((task.progress!.steps.where((AnalysisStepProgress s) => s.isCompleted)
                        .length) /
                    (task.progress!.totalSteps ?? 5) *
                    100)
            .round();
    final int value = reported ?? fallback;
    // 完成前封顶 99：只有后端确认 5 步全部 SUCCEEDED 才允许 100。
    final int capped = task.isCompleted ? value : value.clamp(0, 99);
    if (capped > _maxOverallProgress) {
      _maxOverallProgress = capped;
    }

    _setAnalysisLoading(
      progress: _maxOverallProgress / 100,
      message: task.isCompleted ? '分析完成' : '正在分析',
    );
  }

  /// 恢复上一次未完成的分析（杀进程 / 刷新后重新进入）。
  ///
  /// 只信任后端：用持久化的 `taskId` 重新查询真实状态，然后继续轮询。
  /// 任务已终结时按终态落到结果页 / 失败态；没有可恢复任务则什么也不做。
  Future<void> restoreActiveTask() async {
    if (_analysisState is AsyncLoading<AnalysisProject>) return;
    final AnalysisProgressSource? source = _progressSource;
    if (source == null) {
      await _taskStore.clear();
      return;
    }

    String? taskId;
    try {
      taskId = await _taskStore.read();
    } catch (_) {
      return;
    }
    if (taskId == null || taskId.isEmpty) return;

    final int run = ++_runId;
    _taskProgress = null;
    _maxOverallProgress = 0;
    _setAnalysisLoading(progress: 0, message: '正在恢复分析进度');

    try {
      AnalysisTask task = await source.fetchAnalysisTask(taskId);
      if (run != _runId) return;
      if (!task.isTerminal) {
        _applyTaskProgress(task);
        while (!task.isTerminal) {
          await Future<void>.delayed(ApiClient.analysisPollInterval);
          if (run != _runId) return;
          task = await source.fetchAnalysisTask(task.taskId);
          if (run != _runId) return;
          _applyTaskProgress(task);
        }
      }

      await _taskStore.clear();
      _taskProgress = null;

      if (task.isCompleted && task.projectId != null) {
        final AnalysisProject? project =
            await _repository.fetchProject(task.projectId!);
        if (run != _runId) return;
        if (project != null) {
          _analysisState = AsyncState<AnalysisProject>.success(project);
          _replaceProjects(<AnalysisProject>[project, ..._projects]);
        } else {
          _setAnalysisFailure(const UnknownError(
            message: '分析结果读取失败，请稍后重试',
            detail: 'restore: fetchProject returned null',
          ));
        }
      } else if (task.isFailed) {
        _setAnalysisFailure(UnknownError(
          message: task.errorMessage ?? '分析失败，请稍后重试',
          detail: task.errorCode ?? 'ANALYSIS_FAILED',
        ));
      } else if (task.isCancelled) {
        _analysisState = const AsyncState<AnalysisProject>.initial();
      }
      unawaited(loadQuota());
    } catch (_) {
      // 恢复失败不弹错：回到表单，用户仍可重新发起。
      await _taskStore.clear();
      _taskProgress = null;
      _analysisState = const AsyncState<AnalysisProject>.initial();
    }
    notifyListeners();
  }

  Future<void> retryAnalysis() => startAnalysis(
    title: _lastTitle,
    rawJd: _lastJd,
    company: _lastCompany,
    importSource: _lastImportSource,
    sourceUrl: _lastSourceUrl,
  );

  /// 退出进行中的分析（进度页退出确认 Sheet 的「退出」）。
  ///
  /// ## P1-05 语义（2026-11-18 修订）
  ///
  /// 「退出分析页面」只表示**用户不再等待当前页面的结果**，不代表服务器
  /// 停止执行任务。因此这里刻意**不**做三件事：
  ///
  /// ```text
  /// ❌ 不调用后端 cancel      —— 任务继续跑，重新进入还能看到进度 / 结果
  /// ❌ 不回滚本地额度         —— 服务端已原子预占，退出不释放
  /// ❌ 不清理 activeTaskId    —— 重新进入时 restoreActiveTask 要接上同一条任务
  /// ```
  ///
  /// 仍然要做的是：代际号 `+1` 停掉本页轮询、把迟到的结果 / 失败作废，
  /// 状态回到「新建分析」表单。重新进入分析页时 [restoreActiveTask]
  /// 会查询任务真实状态，完成后再刷新结果与额度。
  ///
  /// 真正的「取消分析」是另一件事，走后端显式 cancel 入口；
  /// 不在本批次范围内，也不由退出按钮隐式触发。
  void exitAnalysis() {
    _runId++; // 停止当前页面的轮询；迟到响应不会再改状态
    // 不清 `_taskStore`：重新进入要恢复同一条任务。
    //
    // 不清掉的话，下一次分析的「正在分析」页会从上一轮遗留的步号开始。
    _taskProgress = null;
    _maxOverallProgress = 0;
    _analysisState = const AsyncState<AnalysisProject>.initial();
    notifyListeners();
    // 刻意**不**在这里 loadQuota：退出与「立即开始下一次分析」很容易
    // 并发，迟到的额度响应会把新任务的乐观预占覆盖回旧值。
    // 重新进入分析页时 initState 会重新读取；任务完成时 restore 也会刷新。
  }

  void showNewAnalysis() {
    _analysisState = const AsyncState<AnalysisProject>.initial();
    notifyListeners();
  }

  void showHistoryProject(AnalysisProject project) {
    _analysisState = AsyncState<AnalysisProject>.success(project);
    notifyListeners();
  }

  void _setAnalysisLoading({
    required double progress,
    required String message,
  }) {
    _analysisState = AsyncState<AnalysisProject>.loading(
      progress: progress,
      message: message,
    );
    notifyListeners();
  }

  void _setAnalysisFailure(AppError error) {
    _analysisState = AsyncState<AnalysisProject>.failure(error);
    notifyListeners();
  }

  List<AnalysisProject> get _projects =>
      state.dataOrNull ?? const <AnalysisProject>[];

  void _replaceProjects(List<AnalysisProject> projects) {
    setSuccess(List<AnalysisProject>.unmodifiable(projects));
  }
}
