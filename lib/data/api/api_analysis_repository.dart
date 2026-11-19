import '../../core/errors/app_error.dart';
import '../models/analysis_job_input.dart';
import '../models/analysis_project.dart';
import '../models/analysis_task.dart';
import '../models/job.dart';
import '../models/parsed_job.dart';
import '../models/quota_state.dart';
import '../repositories/analysis_repository.dart';
import 'api_client.dart';

/// 分析数据访问的真实 API 实现。
///
/// 契约：`docs/careerly/BACKEND_API_CONTRACT.md` §1/§2。
/// 失败时抛 [AppError]（由 State 层归一化），与接口注释一致。
///
/// 同时实现 [AnalysisProgressSource]：只有真实后端有节点可报告
/// （理由见该接口的文档）。
class ApiAnalysisRepository
    implements AnalysisRepository, AnalysisProgressSource {
  ApiAnalysisRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AnalysisProject>> fetchProjects() async {
    final dynamic data = await _client.get('/api/v1/analysis/projects');
    return (data as List<dynamic>)
        .map((dynamic e) => AnalysisProject.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async {
    try {
      final dynamic data = await _client.get(
        '/api/v1/analysis/projects/$projectId',
      );
      return AnalysisProject.fromJson(data as Map<String, dynamic>);
    } on NetworkError catch (e) {
      // 404（PROJECT_NOT_FOUND）→ null：「项目不存在」是合法状态，不是错误。
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Job>> fetchJobLibrary() async {
    final dynamic data = await _client.get('/api/v1/analysis/jobs');
    return (data as List<dynamic>)
        .map((dynamic e) => Job.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ParsedJob> parseJobUrl(String url) async {
    // 后端在这个请求里同步跑爬虫（SPA 站要起 Playwright），
    // 必须用加长超时 —— 见 [ApiClient.jobUrlParseTimeout]。
    //
    // 失败（422 INVALID_URL / 502 JOB_FETCH_FAILED）由 [ApiClient]
    // 的 envelope 分支抛成 AppError，后端的中文提示原样上到 UI。
    final dynamic data = await _client.post(
      '/api/v1/analysis/jobs/parse-url',
      body: <String, dynamic>{'url': url},
      timeout: ApiClient.jobUrlParseTimeout,
    );
    return ParsedJob.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
    List<AnalysisJobInput>? jobs,
  }) async {
    // 同步接口（决策 C2）：实测约 210s，必须用加长超时。
    final dynamic data = await _client.post(
      '/api/v1/analysis',
      body: _analysisBody(
        title: title,
        rawJd: rawJd,
        company: company,
        source: source,
        sourceUrl: sourceUrl,
        jobs: jobs,
      ),
      timeout: ApiClient.analysisTimeout,
    );
    return AnalysisProject.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<AnalysisTask> startAnalysisTask({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
    List<AnalysisJobInput>? jobs,
    String? projectId,
    String? resumeVersionId,
  }) async {
    // 这个请求**立刻**返回 202 + taskId（引擎在后台跑），
    // 所以用普通超时即可，不需要 [ApiClient.analysisTimeout] 那种加长等待。
    final dynamic data = await _client.post(
      '/api/v1/analysis/tasks',
      body: _analysisBody(
        title: title,
        rawJd: rawJd,
        company: company,
        source: source,
        sourceUrl: sourceUrl,
        jobs: jobs,
        projectId: projectId,
        resumeVersionId: resumeVersionId,
      ),
    );
    return AnalysisTask.fromJson(data as Map<String, dynamic>);
  }

  /// 分析请求体。多岗位时优先发 `jobs`；同时保留首个岗位的旧字段，
  /// 让尚未升级的后端仍能完成一次单岗位分析（不会 422）。
  static Map<String, dynamic> _analysisBody({
    required String title,
    required String rawJd,
    required String company,
    required String source,
    required String? sourceUrl,
    required List<AnalysisJobInput>? jobs,
    String? projectId,
    String? resumeVersionId,
  }) {
    final AnalysisJobInput? first = jobs == null || jobs.isEmpty
        ? null
        : jobs.first;
    return <String, dynamic>{
      'title': first?.title ?? title,
      'rawJd': first?.rawJd ?? rawJd,
      'company': first?.company ?? company,
      'source': first?.source ?? source,
      'sourceUrl': ?(first?.sourceUrl ?? sourceUrl),
      'projectId': ?projectId,
      'resumeVersionId': ?resumeVersionId,
      if (jobs != null && jobs.isNotEmpty)
        'jobs': jobs.map((AnalysisJobInput j) => j.toJson()).toList(),
    };
  }

  @override
  Future<AnalysisTask> fetchAnalysisTask(String taskId) async {
    // 轮询用的读接口：引擎在另一个线程里跑，这个 GET 本身很快。
    final dynamic data = await _client.get('/api/v1/analysis/tasks/$taskId');
    return AnalysisTask.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<AnalysisTask> cancelAnalysisTask(String taskId) async {
    final dynamic data = await _client.post(
      '/api/v1/analysis/tasks/$taskId/cancel',
    );
    return AnalysisTask.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<QuotaState> fetchQuota() async {
    final dynamic data = await _client.get('/api/v1/quota');
    return QuotaState.fromJson(data as Map<String, dynamic>);
  }
}
