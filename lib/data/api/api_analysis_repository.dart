import '../../core/errors/app_error.dart';
import '../models/analysis_project.dart';
import '../models/job.dart';
import '../models/quota_state.dart';
import '../repositories/analysis_repository.dart';
import 'api_client.dart';

/// 分析数据访问的真实 API 实现。
///
/// 契约：`docs/careerly/BACKEND_API_CONTRACT.md` §1/§2。
/// 失败时抛 [AppError]（由 State 层归一化），与接口注释一致。
class ApiAnalysisRepository implements AnalysisRepository {
  ApiAnalysisRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AnalysisProject>> fetchProjects() async {
    final dynamic data = await _client.get('/api/v1/analysis/projects');
    return (data as List<dynamic>)
        .map((dynamic e) =>
            AnalysisProject.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async {
    try {
      final dynamic data =
          await _client.get('/api/v1/analysis/projects/$projectId');
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
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
  }) async {
    // 同步接口（决策 C2）：实测约 210s，必须用加长超时。
    final dynamic data = await _client.post(
      '/api/v1/analysis',
      body: <String, dynamic>{'title': title, 'rawJd': rawJd},
      timeout: ApiClient.analysisTimeout,
    );
    return AnalysisProject.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<QuotaState> fetchQuota() async {
    final dynamic data = await _client.get('/api/v1/quota');
    return QuotaState.fromJson(data as Map<String, dynamic>);
  }
}
