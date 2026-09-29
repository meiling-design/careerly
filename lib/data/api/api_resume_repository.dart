import '../../core/errors/app_error.dart';
import '../models/resume_file.dart';
import '../models/resume_profile.dart';
import '../repositories/resume_repository.dart';
import 'api_client.dart';

/// 简历与职业基线的真实 API 实现。
///
/// ## 后端现状（P3 之前的范围说明）
///
/// 后端当前只有「简历基线文本」一个资源（`PUT/GET /api/v1/resume`）：
///
/// ```text
/// ✅ submitResumeText  粘贴文本 → PUT /resume（保存基线，分析时直接使用）
/// ✅ fetchProfile      GET /resume → 文本 + 已保存的画像字段
/// ✅ buildBaseline     = fetchProfile（解析发生在分析链路内部，见下）
/// ❌ submitResumeFile  文件上传解析未建（后端 P3），改用粘贴文本
/// ❌ fetchVersions     多版本简历未建（后端 P3），当前只有一份基线
/// ```
///
/// ⚠️ 「解析」语义：后端没有独立的简历解析端点——`POST /analysis`
/// 在分析链路内自动完成简历解析（ResumeAgent），并把 `capabilitySnapshot`
/// 写回分析结果。因此 [buildBaseline] 不需要也不应该调用 LLM 做额外解析。
class ApiResumeRepository implements ResumeRepository {
  ApiResumeRepository(this._client);

  final ApiClient _client;

  @override
  Future<void> submitResumeText(String text) async {
    await _client.put('/api/v1/resume', body: <String, dynamic>{'text': text});
  }

  @override
  Future<void> submitResumeFile(ResumeFileData file) async {
    // 后端 multipart 解析端点未建（P3）。给出明确的中文指引而不是静默失败。
    throw const AIError(
      message: '简历文件上传暂未接入，请改用「粘贴简历文本」',
      isRetryable: false,
      detail: 'backend P3: resume file upload endpoint not built',
    );
  }

  @override
  Future<ResumeProfile> buildBaseline() async {
    // 基线 = 已保存的简历文本；解析发生在分析链路内部（见类注释）。
    return fetchProfile();
  }

  @override
  Future<ResumeProfile> fetchProfile() async {
    final dynamic data = await _client.get('/api/v1/resume');
    if (data == null) return ResumeProfile.empty;

    final Map<String, dynamic> map = data as Map<String, dynamic>;
    final String text = (map['text'] as String? ?? '').trim();
    if (text.isEmpty) return ResumeProfile.empty;

    final Map<String, dynamic> profile =
        (map['profile'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final DateTime? updatedAt = map['updatedAt'] == null
        ? null
        : DateTime.tryParse(map['updatedAt'] as String);

    // 后端目前是单版本基线：合成一个「当前简历」版本项，
    // 让 hasBaseline（versions.isNotEmpty）如实为 true。
    return ResumeProfile(
      versions: <ResumeVersion>[
        ResumeVersion(
          id: 'current',
          label: '当前简历',
          uploadedAt: updatedAt,
          isCurrent: true,
        ),
      ],
      workExperiences: _stringList(profile['workExperiences']),
      projectExperiences: _stringList(profile['projectExperiences']),
      skills: _stringList(profile['skills']),
      awards: _stringList(profile['awards']),
      capabilities: (profile['capabilities'] as Map<String, dynamic>? ??
              <String, dynamic>{})
          .map(
            (String k, dynamic v) =>
                MapEntry<String, int>(k, (v as num).round()),
          ),
      updatedAt: updatedAt,
    );
  }

  @override
  Future<List<ResumeVersion>> fetchVersions() async {
    // 单版本基线：有则一项，无则空（不编造历史版本）。
    return (await fetchProfile()).versions;
  }

  @override
  Future<void> setCurrentVersion(String versionId) async {
    // 单版本基线下只有 'current' 一个版本，设置当前恒成立——no-op。
    if (versionId != 'current') {
      throw const ParseError(
        message: '指定的简历版本不存在',
        detail: 'backend stores a single baseline; only "current" exists',
        source: 'resume',
      );
    }
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((dynamic e) => '$e').toList(growable: false);
}
