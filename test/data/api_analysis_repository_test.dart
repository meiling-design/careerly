import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/api/api_analysis_repository.dart';
import 'package:careerly/data/api/api_client.dart';
import 'package:careerly/data/models/analysis_job_input.dart';
import 'package:careerly/data/models/parsed_job.dart';

/// ③ 岗位 URL —— `POST /api/v1/analysis/jobs/parse-url` 的契约钉住测试。
///
/// 这条链路的价值不在「返回 200」，而在**抓不到时用户看得见原因**：
///
/// ```text
/// ① 端点与请求体 —— body 是 {"url": ...}，不是 {title, rawJd}
/// ② 字段映射     —— description 落进 JD 框、title 落进岗位名
/// ③ 失败不静默   —— 502 JOB_FETCH_FAILED 必须抛错，
///                   且**后端的中文提示原样上到 UI**（用户要看到
///                   「请确认链接可公开访问，或直接粘贴 JD 文本」
///                   这种可执行的下一步，而不是一句「请求失败」）
/// ```
void main() {
  ApiAnalysisRepository repoWith(_FakeBackend backend) => ApiAnalysisRepository(
    ApiClient(baseUrl: 'http://test.local', httpClient: backend),
  );

  group('ApiAnalysisRepository.parseJobUrl', () {
    test('POST /api/v1/analysis/jobs/parse-url，body 是 {url}', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'url': 'https://www.zhipin.com/job/detail/abc123',
          'title': '高级 Python 后端工程师',
          'company': '某某科技',
          'description': '岗位职责：负责服务端设计…',
        },
      );

      await repoWith(backend).parseJobUrl('https://www.zhipin.com/job/detail/abc123');

      expect(backend.lastPath, '/api/v1/analysis/jobs/parse-url');
      expect(backend.lastMethod, 'POST');
      // ⚠️ 不能是 {title, rawJd} —— 那是 `POST /analysis` 的形状。
      // 抓取端点只收一条链接，回填由前端做（用户看得到、改得动）。
      expect(backend.lastBody, <String, dynamic>{
        'url': 'https://www.zhipin.com/job/detail/abc123',
      });
    });

    test('解析后端 ParsedJob：title / company / description 逐字落位', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'url': 'https://www.lagou.com/jobs/123.html',
          'title': '后端工程师',
          'company': '某某科技',
          'description': '任职要求：5 年以上 Python 经验。',
        },
      );

      final ParsedJob job = await repoWith(
        backend,
      ).parseJobUrl('www.lagou.com/jobs/123.html');

      expect(job.url, 'https://www.lagou.com/jobs/123.html', reason: '后端补过协议头');
      expect(job.title, '后端工程师');
      expect(job.company, '某某科技');
      expect(job.description, '任职要求：5 年以上 Python 经验。');
    });

    test('后端缺 company → 空串，不抛错', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'url': 'https://example.com/job/1',
          'title': '岗位',
          'description': 'JD 正文',
        },
      );

      final ParsedJob job = await repoWith(backend).parseJobUrl('https://example.com/job/1');

      expect(job.company, isEmpty);
    });

    test('502 JOB_FETCH_FAILED → 抛错，且后端的可执行提示原样上到 UI', () async {
      final _FakeBackend backend = _FakeBackend(
        statusCode: 502,
        envelope: <String, dynamic>{
          'success': false,
          'data': null,
          'error': <String, dynamic>{
            'code': 'JOB_FETCH_FAILED',
            'message': '未能从该链接抓取到岗位信息。请确认链接可公开访问，或直接粘贴 JD 文本',
          },
        },
      );

      // 关键：**不是**静默返回一个空 ParsedJob —— 那会让用户对着空表单
      // 反复点「添加岗位」，不知道发生了什么（D108 的「失败无痕」）。
      await expectLater(
        repoWith(backend).parseJobUrl('https://www.zhipin.com/job/detail/abc123'),
        throwsA(
          isA<AppError>().having(
            (AppError e) => e.message,
            'message',
            contains('或直接粘贴 JD 文本'),
          ),
        ),
      );
    });

    test('422 INVALID_URL → 抛错并保留后端文案', () async {
      final _FakeBackend backend = _FakeBackend(
        statusCode: 422,
        envelope: <String, dynamic>{
          'success': false,
          'data': null,
          'error': <String, dynamic>{
            'code': 'INVALID_URL',
            'message': '请提供以 http:// 或 https:// 开头的有效岗位链接',
          },
        },
      );

      await expectLater(
        repoWith(backend).parseJobUrl('这不是一个链接'),
        throwsA(
          isA<AppError>().having(
            (AppError e) => e.message,
            'message',
            contains('有效岗位链接'),
          ),
        ),
      );
    });
  });

  test('update task sends project, resume version, and stable job id', () async {
    final _FakeBackend backend = _FakeBackend(
      payload: <String, dynamic>{'taskId': 'task-1', 'status': 'processing'},
      statusCode: 202,
    );

    await repoWith(backend).startAnalysisTask(
      title: '工程师',
      rawJd: '负责服务端开发',
      projectId: 'project-1',
      resumeVersionId: 'resume-v2',
      jobs: const <AnalysisJobInput>[
        AnalysisJobInput(
          jobId: 'job-1',
          title: '工程师',
          rawJd: '负责服务端开发',
        ),
      ],
    );

    expect(backend.lastPath, '/api/v1/analysis/tasks');
    expect(backend.lastBody?['projectId'], 'project-1');
    expect(backend.lastBody?['resumeVersionId'], 'resume-v2');
    expect(backend.lastBody?['jobs'], <Map<String, dynamic>>[
      <String, dynamic>{
        'title': '工程师',
        'rawJd': '负责服务端开发',
        'jobId': 'job-1',
        'company': '',
        'source': 'paste',
      },
    ]);
  });
}

/// 假后端：记录请求形态（路径 / 方法 / 解码后的 body），
/// 返回可编排的状态码与 envelope。
class _FakeBackend extends http.BaseClient {
  _FakeBackend({this.payload, this.envelope, this.statusCode = 200});

  /// 成功时塞进 `data` 的内容。
  final Map<String, dynamic>? payload;

  /// 需要自定义整个 envelope（失败分支）时给这个。
  final Map<String, dynamic>? envelope;

  final int statusCode;

  String? lastPath;
  String? lastMethod;
  Map<String, dynamic>? lastBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastPath = request.url.path;
    lastMethod = request.method;
    if (request is http.Request) {
      lastBody = jsonDecode(request.body) as Map<String, dynamic>;
    }

    final Map<String, dynamic> body =
        envelope ??
        <String, dynamic>{
          'success': true,
          'data': payload,
          'error': null,
        };
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[utf8.encode(jsonEncode(body))]),
      statusCode,
      headers: const <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }
}
