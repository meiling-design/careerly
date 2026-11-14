
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
/// ✅ fetchProfile      GET  /resume → 当前文本 + 当前画像 + **全部版本**
/// ✅ fetchVersions     = fetchProfile().versions
/// ✅ setCurrentVersion PUT    /resume/versions/{id}/current
/// ✅ deleteVersion     DELETE /resume/versions/{id}
/// ✅ buildBaseline     = fetchProfile（解析已在提交时完成，见下）
/// ```
///
/// ## 多版本（2026-10-05 接通）
///
/// `POST /resume` 现在是**追加**一个版本并设为当前，而不是覆盖那份唯一基线
/// —— 「上传新简历后历史列表多出一张卡」由此成立。
/// 后端两条版本动作（设为当前 / 删除）落在 `/resume/versions/...`，
/// 与当前基线的读写分开：前者动的是**历史**，后者动的是**现在**。
///
/// `GET /resume` 返回的结构化画像属于当前基线；各版本上传的 PDF 原稿
/// 则由 `GET /resume/versions/{id}/original` 按用户权限单独读取。
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

    // 当前 profile 取自 careerly_resumes；历史版本原稿由
    // fetchVersionOriginalPdf(versionId) 按版本读取。
    return ResumeProfile(
      versions: _versions(map['versions'], fallbackUploadedAt: updatedAt),
      // ⚠️ 字段名对齐后端 —— `profile` 是引擎 `ResumeProfile.model_dump()`：
      //    name / email / phone / skills / experience_years /
      //    roles / projects / education / certifications / raw_text
      // 此前按 workExperiences / projectExperiences / awards 去读，
      // 只有 skills 命中，Onboarding 确认页四行里三行恒为 0（2026-10-02 修）。
      workExperiences: _stringList(profile['roles']),
      projectExperiences: _projectNames(profile['projects']),
      skills: _stringList(profile['skills']),
      // 姓名 / 邮箱 / 电话 —— 简历详情页的「基本信息」段与 PDF 卡头部读取它们。
      // 引擎 (`ResumeProfile.model_dump()`) 一直在返回这三个键，此处如实映射。
      fullName: profile['name'] as String?,
      email: profile['email'] as String?,
      phone: profile['phone'] as String?,
      // 工作年限 —— 「设置 → 个人信息」的「工作经验」一行读取它。
      // 与上面三项同一类：引擎一直在返回 `experience_years`（实测为 `5.0`），
      // 此前只是 Dart 映射丢掉它（2026-10-07 补）。
      // 取整用 `round()`：本字段只用于展示「N 年」（见 `ResumeProfile.experienceYears`）。
      experienceYears: (profile['experience_years'] as num?)?.round(),
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
  Future<List<int>> fetchVersionOriginalPdf(String versionId) async {
    return _client.getBytes('/api/v1/resume/versions/$versionId/original');
  }

  @override
  Future<void> setCurrentVersion(String versionId) async {
    // ⚠️ 这个调用会**改写后端分析用的基线**（`careerly_resumes`），
    // 所以它不只是换个显示 —— 下一次分析用的是新设为当前的那份简历。
    // 成功后 `ResumeProvider` 会重新 [fetchProfile]，由数据层决定谁是当前，
    // 本地不改 `isCurrent`（避免出现第二份真相）。
    await _client.put('/api/v1/resume/versions/$versionId/current');
  }

  @override
  Future<void> deleteVersion(String versionId) async {
    // 后端对「删当前版本」返回 409，会被 [ApiClient] 归一化成带
    // 「当前简历不能删除，请先设为其他版本」的 [AppError]，由页面提示。
    await _client.delete('/api/v1/resume/versions/$versionId');
  }
}

/// 版本列表 —— 读后端返回的 `versions`。
///
/// ⚠️ **回退分支不是多余的**：`versions` 是 2026-10-05 才加进
/// `GET /resume` 的键。老后端（或只跑 `PUT /resume` 存过文本的用户）
/// 没有它，此时按**单基线**合成一个当前版本，让「我的简历」照常显示
/// 那一份，而不是让整页掉进空态 —— 那会把「你有一份简历」显示成
/// 「你还没有简历」。
///
/// 键在、但列表为空同样走回退：那说明后端没给出版本，而不是用户没简历。
List<ResumeVersion> _versions(
  Object? value, {
  required DateTime? fallbackUploadedAt,
}) {
  if (value is List) {
    final List<ResumeVersion> parsed = <ResumeVersion>[
      // 逐项校验 `id` —— [ResumeVersion.fromJson] 对缺 id 是硬转换，
      // 一条脏数据就会让整页抛异常。
      for (final dynamic item in value)
        if (item is Map<String, dynamic> && item['id'] is String)
          ResumeVersion.fromJson(item),
    ];
    if (parsed.isNotEmpty) return parsed;
  }
  return <ResumeVersion>[
    ResumeVersion(
      id: 'current',
      label: '当前简历',
      uploadedAt: fallbackUploadedAt,
      isCurrent: true,
    ),
  ];
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
