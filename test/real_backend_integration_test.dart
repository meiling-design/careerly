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
/// 落地情况：register/login（手机号身份 D85）、简历基线、额度扣减、
/// 分析全链路（含 C4 能力快照）、项目详情与岗位库、以及两类错误路径
/// （无 token → [AuthError]；文件上传未实现 → 明确提示）。
void main() {
  const bool enabled =
      bool.fromEnvironment('CAREERLY_REAL_BACKEND', defaultValue: false);
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

      // ── 1. 认证（手机号身份，D85） ───────────────────────────────
      await auth.register(name: '联调账号', phone: phone);
      expect(client.hasSession, isTrue, reason: 'register 应写入会话');

      await auth.login(phone: phone);
      expect(client.hasSession, isTrue, reason: 'login 应写入会话');

      // ── 2. 简历基线 ──────────────────────────────────────────────
      await resume.submitResumeText(_resumeText);
      final ResumeProfile profile = await resume.fetchProfile();
      expect(profile.hasBaseline, isTrue, reason: '保存后应有基线');

      // ── 3. 额度 ──────────────────────────────────────────────────
      final QuotaState quotaBefore = await analysis.fetchQuota();
      expect(quotaBefore.total, greaterThanOrEqualTo(3));

      // ── 4. 分析（真实 LLM，约 200s） ─────────────────────────────
      final AnalysisProject project =
          await analysis.analyze(title: '高级后端工程师', rawJd: _jd);
      expect(project.results, isNotEmpty, reason: '分析应产出结果');

      final AnalysisResult result = project.results.first;
      expect(result.capabilitySnapshot, isNotEmpty,
          reason: 'C4：能力快照不应为空');
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
      final ApiClient anon = ApiClient(baseUrl: baseUrl);
      expect(
        ApiAnalysisRepository(anon).fetchQuota(),
        throwsA(isA<AuthError>()),
        reason: '无 token 必须被拒绝',
      );
      expect(
        ApiResumeRepository(anon).submitResumeFile(
          ResumeFileData(
            name: 'a.pdf',
            extension: 'pdf',
            sizeBytes: 0,
            bytes: Uint8List(0),
          ),
        ),
        throwsA(
          isA<AppError>().having(
            (AppError e) => e.isRetryable,
            'isRetryable',
            isFalse,
          ),
        ),
        reason: '文件上传未实现应给出不可重试的明确提示',
      );

      client.dispose();
      anon.dispose();
    },
    skip: enabled ? false : '默认跳过：需要真实后端，'
        '用 --dart-define=CAREERLY_REAL_BACKEND=true 启用',
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

// ── 样例数据 ────────────────────────────────────────────────────────────

const String _resumeText = '''
张三 | 后端工程师 | 6 年经验 | zhangsan@example.com
技能：Python、Go、FastAPI、MySQL、Redis、Docker、Kafka、微服务架构
经历：
- 某电商 后端工程师（2021-至今）：负责订单与库存服务，QPS 峰值 1.2 万，
  主导单体拆分为 6 个微服务，引入 Redis 多级缓存将 P99 从 800ms 降至 120ms。
- 某 SaaS 公司 后端工程师（2019-2021）：设计多租户计费系统，支撑 300+ 企业客户。
项目：
- 电商中台订单服务：FastAPI + MySQL 分库分表 + Kafka 异步解耦。
- 实时风控引擎：Go + Redis，规则热更新，日均处理 400 万次请求。
''';

const String _jd = '''
岗位职责：负责核心业务后端服务的设计与开发，使用 Python/Go 构建高并发 API，
参与系统架构设计与性能优化，主导微服务拆分与治理。
任职要求：5 年以上后端开发经验，精通 Python 或 Go，深入理解 MySQL 与 Redis，
熟悉 Docker 与 Kubernetes，具备大规模分布式系统设计与调优经验，
有技术团队带领经验者优先。
''';
