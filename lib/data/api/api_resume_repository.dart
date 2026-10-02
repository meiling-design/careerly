import '../../core/errors/app_error.dart';
import '../models/resume_file.dart';
import '../models/resume_profile.dart';
import '../repositories/resume_repository.dart';
import 'api_client.dart';

/// 简历与职业基线的真实 API 实现。
///
/// ## 端点分工（2026-10-02 起）
///
/// ```text
/// ✅ submitResumeText  粘贴文本 → POST /resume（multipart 的 text 字段）
/// ✅ submitResumeFile  文件 / 图片 → POST /resume（multipart 的 file 字段，图片走 OCR）
/// ✅ fetchProfile      GET  /resume → 文本 + 已解析的画像字段
/// ✅ buildBaseline     = fetchProfile（解析已在提交时完成，见下）
/// ❌ fetchVersions     多版本简历未建，当前只有一份基线
/// ```
///
/// ⚠️ **提交即解析** —— `POST /api/v1/resume` 在同一请求内跑完
/// ResumeAgent 并把 `profile` 落进 `careerly_resumes`。
/// 因此 [buildBaseline] 只把已存好的画像读回来，
/// 不再调用 LLM 做二次解析。
///
/// 三种输入（粘贴 / 文件 / 截图）在这条链路上**只差文本怎么读出来**，
/// 之后的解析与落库完全同一段后端代码 —— 不存在第二套 Profile 逻辑。
///
/// ⚠️ 两者都**不扣分析额度**（`CLAUDE.md` §5.2：只有「开始分析」才扣）。
class ApiResumeRepository implements ResumeRepository {
  ApiResumeRepository(this._client);

  final ApiClient _client;

  @override
  Future<void> submitResumeText(String text) async {
    // ⚠️ 该端点只收 multipart/form-data（FastAPI `Form`），不是 JSON body。
    await _client.postMultipart(
      '/api/v1/resume',
      fields: <String, String>{'text': text},
      timeout: ApiClient.resumeParseTimeout,
    );
  }

  @override
  Future<void> submitResumeFile(ResumeFileData file) async {
    await _client.postMultipart(
      '/api/v1/resume',
      files: <HttpMultipartFile>[
        HttpMultipartFile(
          field: 'file',
          filename: file.name,
          bytes: file.bytes,
        ),
      ],
      timeout: ApiClient.resumeParseTimeout,
    );
  }

  @override
  Future<ResumeProfile> buildBaseline() async {
    // 解析已在 submit 时完成（见类注释），这里只把画像读回来。
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
      // ⚠️ 字段名对齐后端 —— `profile` 是引擎 `ResumeProfile.model_dump()`：
      //    name / email / phone / skills / experience_years /
      //    roles / projects / education / certifications / raw_text
      // 此前按 workExperiences / projectExperiences / awards 去读，
      // 只有 skills 命中，Onboarding 确认页四行里三行恒为 0（2026-10-02 修）。
      workExperiences: _stringList(profile['roles']),
      projectExperiences: _projectNames(profile['projects']),
      skills: _stringList(profile['skills']),
      // awards / capabilities 后端**没有来源**（assets.py 明确 awards
      // 「not parsed」，画像里也没有能力分值）→ 保持空，不编造（D110）。
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

/// 字符串数组 → `List<String>`，去掉空白项。
///
/// 后端可能给出空串（LLM 抽取出空的 role / skill），保留会让确认页
/// 的条数把空条目也算进去。
List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return <String>[
    for (final dynamic e in value)
      if ('$e'.trim().isNotEmpty) '$e'.trim(),
  ];
}

/// 后端 `projects[]` 是**对象数组**（`{name, description, tech_stack,
/// highlights}`），取 `name` 作为摘要字符串。
///
/// 字符串条目原样保留 —— 防御旧数据 / 降级形态，避免脆性解析。
List<String> _projectNames(Object? value) {
  if (value is! List) return const <String>[];
  final List<String> names = <String>[];
  for (final dynamic item in value) {
    final String name = item is Map
        ? '${item['name'] ?? ''}'.trim()
        : '$item'.trim();
    if (name.isNotEmpty) names.add(name);
  }
  return names;
}
