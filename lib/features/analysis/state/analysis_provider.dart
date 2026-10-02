import 'package:flutter/foundation.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/state/state.dart';
import '../../../data/models/analysis_project.dart';
import '../../../data/models/parsed_job.dart';
import '../../../data/models/quota_state.dart';
import '../../../data/repositories/analysis_repository.dart';

/// 分析状态。
///
/// 归属（Baseline §3.2）：**历史分析项目只属于「分析」**。
///
/// Phase 1 只提供「读取项目列表 + 读取额度」两项能力。
/// 分析引擎、JD 解析、匹配计算、扣减额度全部**未实现**——
/// Phase 1 §八明确禁止，Phase 6 才做。
class AnalysisProvider extends AsyncStateNotifier<List<AnalysisProject>> {
  AnalysisProvider(this._repository);

  final AnalysisRepository _repository;

  QuotaState? _quota;
  AsyncState<AnalysisProject> _analysisState =
      const AsyncState<AnalysisProject>.initial();
  String _lastTitle = '';
  String _lastJd = '';

  /// 本次分析运行的代际号。
  ///
  /// 「退出分析」（`CareerlyAnalysisProgress` 的退出确认 Sheet）会在
  /// Mock 的 `Future.delayed` 尚未 resolve 时重置状态；没有代际号，
  /// 迟到的结果会把用户强行拽回结果页（僵屍结果）。每次发起分析 `+1`，
  /// `await` 返回后代际不符则**丢弃**结果——额度已由 [exitAnalysis] 回滚，
  /// 这里不再重复处理。
  int _runId = 0;

  /// 当前额度状态。为 `null` 表示尚未读取。
  QuotaState? get quota => _quota;

  /// 是否还能发起分析（额度门禁）。
  ///
  /// 依据 Baseline §5，UI 用它 gate「开始分析」按钮。
  /// 额度未知时**保守返回 false**，避免 UI 误放行。
  bool get canAnalyze => _quota?.canAnalyze ?? false;

  AsyncState<AnalysisProject> get analysisState => _analysisState;

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
  Future<void> startAnalysis({
    required String title,
    required String rawJd,
  }) async {
    _lastTitle = title;
    _lastJd = rawJd;

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
    _setAnalysisLoading(progress: 0.15, message: '准备岗位信息');
    try {
      _setAnalysisLoading(progress: 0.45, message: '理解岗位要求');
      final AnalysisProject project = await _repository.analyze(
        title: title,
        rawJd: rawJd,
      );
      if (run != _runId) return; // 已退出：结果作废，额度已回滚
      _setAnalysisLoading(progress: 0.8, message: '建立能力匹配');
      _analysisState = AsyncState<AnalysisProject>.success(project);
      _replaceProjects(<AnalysisProject>[project, ..._projects]);
    } catch (error, stackTrace) {
      if (run != _runId) return; // 已退出：失败也作废
      _quota = _quota!.rollback();
      _setAnalysisFailure(AppError.from(error, stackTrace));
    }
    notifyListeners();
  }

  Future<void> retryAnalysis() =>
      startAnalysis(title: _lastTitle, rawJd: _lastJd);

  /// 退出进行中的分析（进度页退出确认 Sheet 的「退出」）。
  ///
  /// 语义（Phase 6 补做时定，待验收确认）：
  /// - 分析被中止 = 本次分析**没有交付**，按 Baseline §5 的失败口径
  ///   **回滚额度**（与 `_repository.analyze` 抛错同路）；
  /// - 代际号 `+1`，迟到的结果 / 失败一律作废（防僵屍结果）；
  /// - 状态回到「新建分析」表单（[AsyncInitial]），不是历史列表——
  ///   用户的输入语境还在表单侧。
  ///
  /// ⚠️ 仅当分析**进行中**才回滚；已成功 / 已失败后再调是幂等空操作。
  void exitAnalysis() {
    final bool wasLoading = _analysisState is AsyncLoading<AnalysisProject>;
    _runId++;
    if (wasLoading) {
      _quota = _quota!.rollback();
    }
    _analysisState = const AsyncState<AnalysisProject>.initial();
    notifyListeners();
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
