import 'dart:convert';
import 'dart:typed_data';

import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/api/api.dart';
import 'package:careerly/data/models/analysis_project.dart';
import 'package:careerly/data/models/analysis_result.dart';
import 'package:careerly/data/models/job.dart';
import 'package:careerly/data/models/quota_state.dart';
import 'package:careerly/data/models/resume_file.dart';
import 'package:careerly/data/models/resume_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flutter ↔ FastAPI **真实联调**（默认跳过）。
///
/// ## 为什么默认跳过
///
/// 这份用例会真实访问后端并发起一次真实 LLM 分析（约 200s），
/// 属于「联调动作」而非常规回归。`flutter test` 跑全量时**必须**跳过它，
/// 否则 CI 会因为网络 / 后端未启动而红。
///
/// ## 怎么跑
///
/// ```bash
/// # 1) 启动后端（后端仓库 work_agent）
/// uvicorn app.api.server:app --host 127.0.0.1 --port 8000
///
/// # 2) 真机 / 模拟器把 127.0.0.1 换成宿主机地址
/// flutter test --dart-define=CAREERLY_REAL_BACKEND=true \
///              --dart-define=CAREERLY_API_BASE_URL=http://127.0.0.1:8000 \
///              test/real_backend_integration_test.dart
/// ```
///
/// ## 钉住什么
///
/// 契约 `docs/careerly/BACKEND_API_CONTRACT.md` §1/§2 在**真实 HTTP** 上的
/// 落地情况：register/login（手机号身份 D85）、简历资产提交
/// （PDF 经 multipart 上传、提交即解析落库）、额度扣减、分析全链路
/// （含 C4 能力快照）、项目详情与岗位库、以及两类错误路径
/// （无 token → [AuthError]；不支持的简历格式 → [ParseError]）。
void main() {
  const bool enabled = bool.fromEnvironment(
    'CAREERLY_REAL_BACKEND',
    defaultValue: false,
  );
  const String baseUrl = String.fromEnvironment(
    'CAREERLY_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  test(
    '真实后端联调：$baseUrl',
    () async {
      final ApiClient client = ApiClient(baseUrl: baseUrl);
      final ApiAuthRepository auth = ApiAuthRepository(client);
      final ApiResumeRepository resume = ApiResumeRepository(client);
      final ApiAnalysisRepository analysis = ApiAnalysisRepository(client);

      // 每次运行换一个手机号，避免撞历史数据。
      final String phone =
          '139${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // ── 1. 认证（手机号 + 密码，2026-10-04 取代 D85） ─────────────
      await auth.register(name: '联调账号', phone: phone, password: _password);
      expect(client.hasSession, isTrue, reason: 'register 应写入会话');

      await auth.login(phone: phone, password: _password);
      expect(client.hasSession, isTrue, reason: 'login 应写入会话');

      // ── 2. 简历资产（POST /resume：提交即解析落库） ────────────────
      final Uint8List resumePdf = _makePdf(_resumePdfText);
      await resume.submitResumeFile(
        ResumeFileData(
          name: 'careerly-integration-resume.pdf',
          extension: 'pdf',
          sizeBytes: resumePdf.length,
          bytes: resumePdf,
        ),
      );
      final ResumeProfile profile = await resume.fetchProfile();
      expect(profile.hasBaseline, isTrue, reason: '提交后应有基线');
      expect(
        profile.skills,
        contains('Python'),
        reason: 'PDF 提取出的技能应由 ResumeAgent 解析并经 API 映射回来',
      );
      expect(
        profile.workExperiences,
        isNotEmpty,
        reason: 'roles[] 应映射到 workExperiences（2026-10-02 字段映射修复）',
      );

      // ── 3. 额度 ──────────────────────────────────────────────────
      final QuotaState quotaBefore = await analysis.fetchQuota();
      expect(quotaBefore.total, greaterThanOrEqualTo(3));

      // ── 4. 分析（真实 LLM，约 200s） ─────────────────────────────
      final AnalysisProject project = await analysis.analyze(
        title: '高级后端工程师',
        rawJd: _jd,
      );
      expect(project.results, isNotEmpty, reason: '分析应产出结果');

      final AnalysisResult result = project.results.first;
      expect(result.capabilitySnapshot, isNotEmpty, reason: 'C4：能力快照不应为空');
      expect(result.matches.first.score, inInclusiveRange(0, 100));
      expect(project.jobs.first.title, '高级后端工程师');
      expect(project.jobs.first.source, 'paste');

      // ── 5. 列表 / 详情 / 岗位库 ──────────────────────────────────
      final List<AnalysisProject> projects = await analysis.fetchProjects();
      expect(projects.any((AnalysisProject p) => p.id == project.id), isTrue);

      final AnalysisProject? detail = await analysis.fetchProject(project.id);
      expect(detail, isNotNull);
      expect(detail!.results, isNotEmpty);

      // 「项目不存在」是合法状态 → null，不是异常。
      expect(await analysis.fetchProject('proj_missing'), isNull);

      final List<Job> library = await analysis.fetchJobLibrary();
      expect(library, isNotEmpty);

      // ── 6. 额度扣减 ──────────────────────────────────────────────
      final QuotaState quotaAfter = await analysis.fetchQuota();
      expect(quotaAfter.used, quotaBefore.used + 1);

      // ── 7. 错误路径 ──────────────────────────────────────────────
      //
      // ⚠️ 这一组**必须** `await expectLater(...)`，不能写成 `expect(...)`。
      // `expect` 拿到 Future 时只登记异步断言就立刻返回，body 会继续往下跑，
      // 于是三个请求并发在飞的同时第 145 行 `dispose()` 已经执行
      // （`ApiClient.dispose()` = `_http.close()`）——
      // 后到的那两个 multipart 响应会被掐断，`AuthError` / `ParseError`
      // 因此退化成 `NetworkError: Connection closed before full header was
      // received`，用例随机变红。串行 await 之后错误类型才是后端真实返回的那一种。
      final ApiClient anon = ApiClient(baseUrl: baseUrl);
      await expectLater(
        ApiAnalysisRepository(anon).fetchQuota(),
        throwsA(isA<AuthError>()),
        reason: '无 token 必须被拒绝',
      );
      await expectLater(
        ApiResumeRepository(anon).submitResumeFile(
          ResumeFileData(
            name: 'a.pdf',
            extension: 'pdf',
            sizeBytes: 0,
            bytes: Uint8List(0),
          ),
        ),
        throwsA(isA<AuthError>()),
        reason: '简历资产提交同样要鉴权：无 token 必须被拒绝',
      );

      // 不支持的格式由后端拒绝（Flutter 白名单与后端逐项一致，
      // 这里验证后端那一侧确实会挡下来）。
      await expectLater(
        resume.submitResumeFile(
          ResumeFileData(
            name: 'legacy.doc',
            extension: 'doc',
            sizeBytes: 4,
            bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
          ),
        ),
        throwsA(isA<ParseError>()),
        reason: '.doc 是旧二进制格式，后端应回 UNSUPPORTED_FORMAT(422)',
      );

      // ── 8. 第三方登录契约（2026-10-04：只建接缝，不做真实对接） ────
      //
      // 这一步**刻意断言「失败」**：项目没有任何第三方开放平台凭据，
      // 后端在未配置时回 501 `OAUTH_NOT_CONFIGURED`、配了但未实现时回
      // 501 `OAUTH_UNAVAILABLE`。两种都必须被客户端识别成**可读的错误**，
      // 而不是静默超时、也不是被误判成凭据失效（那会强制退出登录）。
      //
      // ⚠️ 若哪天这里不再抛错，说明真的接上了 OAuth ——
      // 那时应当把断言改成「换码成功」，而不是删掉它。
      await expectLater(
        auth.signInWithOAuth(provider: 'wechat'),
        throwsA(
          // 必须落到中性的 [NetworkError]（保留服务端原文 message），
          // **不能**是 [AuthError] —— 后者在 `ApiClient` 里有一条
          // 「刷新令牌 → 失败则清会话」的路径，会把「点了下未上线的
          // 微信按钮」升级成**强制退出登录**。
          isA<NetworkError>().having(
            (NetworkError e) => e.detail,
            'detail',
            startsWith('OAUTH_'),
          ),
        ),
        reason: '未配置的第三方登录必须报出可识别的错误，不能假装成功',
      );

      client.dispose();
      anon.dispose();
    },
    skip: enabled
        ? false
        : '默认跳过：需要真实后端，'
              '用 --dart-define=CAREERLY_REAL_BACKEND=true 启用',
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

// ── 样例数据 ────────────────────────────────────────────────────────────

/// 联调账号的密码。
///
/// ⚠️ 它只存在于这个**默认跳过**的联调文件里，且每次运行都会新建一个
/// 随机手机号 —— 不是任何真实账号的凭据。后端收到后会 bcrypt 哈希入库。
const String _password = 'careerly-it-2026';

// ASCII text keeps the generated PDF fixture portable and readable by Helvetica.
const String _resumePdfText = '''
Alex Morgan | Senior Backend Engineer | 6 years
Email: alex.morgan@example.com
Skills: Python, Go, FastAPI, MySQL, Redis, Docker, Kafka
Experience:
- Senior Backend Engineer at CommerceCo (2021-present)
- Backend Engineer at SaaSCo (2019-2021)
Projects:
- E-commerce order platform: FastAPI, MySQL sharding, Kafka
- Real-time risk engine: Go and Redis, 4 million requests per day
''';

const String _jd = '''
岗位职责：负责核心业务后端服务的设计与开发，使用 Python/Go 构建高并发 API，
参与系统架构设计与性能优化，主导微服务拆分与治理。
任职要求：5 年以上后端开发经验，精通 Python 或 Go，深入理解 MySQL 与 Redis，
熟悉 Docker 与 Kubernetes，具备大规模分布式系统设计与调优经验，
有技术团队带领经验者优先。
''';

Uint8List _makePdf(String text) {
  final String content = <String>[
    'BT',
    '/F1 10 Tf',
    '50 760 Td',
    for (final String line in text.trim().split('\n')) ...<String>[
      '(${line.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)')}) Tj',
      '0 -14 Td',
    ],
    'ET',
  ].join('\n');

  final List<String> objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] '
        '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    '<< /Length ${ascii.encode(content).length} >>\nstream\n$content\nendstream',
  ];
  final StringBuffer pdf = StringBuffer('%PDF-1.4\n');
  final List<int> offsets = <int>[0];
  for (int i = 0; i < objects.length; i++) {
    offsets.add(pdf.length);
    pdf
      ..write('${i + 1} 0 obj\n')
      ..write('${objects[i]}\n')
      ..write('endobj\n');
  }

  final int xrefOffset = pdf.length;
  pdf
    ..write('xref\n0 ${objects.length + 1}\n')
    ..write('0000000000 65535 f \n');
  for (final int offset in offsets.skip(1)) {
    pdf.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  pdf
    ..write('trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n')
    ..write('startxref\n$xrefOffset\n%%EOF\n');
  return Uint8List.fromList(ascii.encode(pdf.toString()));
}
