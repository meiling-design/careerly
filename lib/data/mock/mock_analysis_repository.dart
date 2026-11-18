import '../../core/errors/app_error.dart';
import '../models/analysis_project.dart';
import '../models/analysis_result.dart';
import '../models/job.dart';
import '../models/parsed_job.dart';
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

  /// ⚠️ **明确抛「尚未接入」，不编造一条 JD。**
  ///
  /// 这里**没有**爬虫，也没有 JD 可返回。可选的两条路都不可接受：
  ///
  /// ```text
  /// 返回空 ParsedJob  →  表单看起来「成功了」但 JD 框是空的，
  ///                      用户点「开始分析」撞上「JD 不能为空」——
  ///                      失败点被挪到两步之后，是 D108 的「失败无痕」；
  /// 返回一段假 JD     →  CLAUDE.md §7 明令不得编造产品数据，
  ///                      而且假 JD 与真抓到的 JD 在 UI 上无从分辨。
  /// ```
  ///
  /// 因此与 `MockResumeRepository.setCurrentVersion` 同款处置：
  /// **显式报错**，UI 走 Error 态把「尚未接入」如实说出来。
  ///
  /// 注意：**演示模式（`demoData`）也不例外** —— 这条路径的产出会被用户
  /// 当作真实岗位送进分析，不是「看样例」的展示位。
  @override
  Future<ParsedJob> parseJobUrl(String url) async {
    await _config.simulate();
    throw const UnknownError(
      message: '岗位链接抓取尚未接入',
      detail: 'MockAnalysisRepository.parseJobUrl',
    );
  }

  @override
  Future<AnalysisProject> analyze({
    required String title,
    required String rawJd,
    String company = '',
    String source = 'paste',
    String? sourceUrl,
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
      company: company,
      rawJd: rawJd,
      source: source,
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
      // P1-02：Mock 也写快照 —— 页面读取的是**快照**，不是当前岗位。
      // 这样「修改岗位 JD 后旧分析不变」的行为在 Mock 下同样可验证。
      jobSnapshots: <JobSnapshot>[
        JobSnapshot(
          jobId: job.id,
          title: job.title,
          company: job.company,
          rawJd: rawJd,
          source: source,
          sourceUrl: sourceUrl,
          importMethod: source,
          capturedAt: now,
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
