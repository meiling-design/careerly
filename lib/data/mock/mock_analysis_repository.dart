import '../models/analysis_project.dart';
import '../models/analysis_result.dart';
import '../models/job.dart';
import '../models/quota_state.dart';
import '../repositories/analysis_repository.dart';
import 'demo_analysis_fixture.dart';
import 'mock_config.dart';

/// [AnalysisRepository] 的 Mock 实现。
///
/// ⚠️ **分析项目与历史岗位默认返回空列表。**
///
/// `fetchQuota` 例外——它返回 [QuotaState.free]（3 次），
/// 因为这是 Baseline §5 已锁定的产品规则，不是编造的数据。
///
/// Phase 1 不实现分析引擎、不实现 JD 解析、不实现匹配计算。
class MockAnalysisRepository implements AnalysisRepository {
  MockAnalysisRepository({MockConfig? config})
    : _config = config ?? MockSettings.config;

  final MockConfig _config;
  final List<AnalysisProject> _projects = <AnalysisProject>[];

  @override
  Future<List<AnalysisProject>> fetchProjects() async {
    await _config.simulate();
    if (_config.demoData) {
      // 演示模式：返回 Figma 原型样例项目（`DemoAnalysisFixture`）。
      return <AnalysisProject>[DemoAnalysisFixture.demoProject];
    }
    return List<AnalysisProject>.unmodifiable(_projects);
  }

  @override
  Future<AnalysisProject?> fetchProject(String projectId) async {
    await _config.simulate();
    for (final AnalysisProject project in _projects) {
      if (project.id == projectId) return project;
    }
    return null;
  }

  @override
  Future<List<Job>> fetchJobLibrary() async {
    await _config.simulate();
    return const <Job>[];
  }

  @override
  Future<QuotaState> fetchQuota() async {
    await _config.simulate();
    // Baseline §5：免费用户 3 次完整分析。
    return QuotaState.free;
  }

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
  }) async {
    await _config.simulate();
    if (_config.demoData) {
      // 演示模式：直接返回 Figma 原型样例（4 岗位 × 2 版本）。
      // ⚠️ 忽略用户输入的单个岗位 —— 这是「看样例」的演示路径，
      // 不是真实分析行为。
      return DemoAnalysisFixture.demoProject;
    }
    final DateTime now = DateTime.now();
    final String projectId = 'mock-project-${_projects.length + 1}';
    final Job job = Job(
      id: '$projectId-job',
      title: title.trim().isEmpty ? '未命名岗位' : title.trim(),
      rawJd: rawJd,
      source: 'paste',
      createdAt: now,
    );
    final AnalysisResult result = AnalysisResult(
      id: '$projectId-result-1',
      projectId: projectId,
      version: 1,
      matches: <JobMatch>[
        JobMatch(
          jobId: job.id,
          score: 0,
          rank: 1,
          reasons: const <String>['Mock 分析已完成，等待真实能力模型接入'],
          gaps: const <String>['暂未接入真实能力 Gap 计算'],
          suggestion: '补充更多经历后再次分析',
        ),
      ],
      createdAt: now,
    );
    final AnalysisProject project = AnalysisProject(
      id: projectId,
      name: job.title,
      jobs: <Job>[job],
      results: <AnalysisResult>[result],
      createdAt: now,
      updatedAt: now,
    );
    _projects.insert(0, project);
    return project;
  }
}
