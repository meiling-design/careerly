import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:careerly/data/api/api_client.dart';
import 'package:careerly/data/api/api_resume_repository.dart';
import 'package:careerly/data/models/resume_file.dart';
import 'package:careerly/data/models/resume_profile.dart';

/// 简历资产链路（`POST /api/v1/resume` + `GET /api/v1/resume`）的契约测试。
///
/// 钉住三件事：
/// 1. **端点与传输形态** —— 提交走 multipart（后端该端点只收 form/file，
///    不收 JSON），文本走 `text` 字段、文件走 `file` 字段；
/// 2. **boundary 不由我们手写** —— `Content-Type` 必须由 http 生成
///    （手写成 `application/json` 后端会解析不出字段，这是接通时踩过的坑）；
/// 3. **字段映射** —— `roles[] → workExperiences`、
///    `projects[].name → projectExperiences`、`skills[] → skills`。
void main() {
  ApiResumeRepository repoWith(_FakeBackend backend) => ApiResumeRepository(
    ApiClient(baseUrl: 'http://test.local', httpClient: backend),
  );

  group('提交简历（POST /api/v1/resume）', () {
    test('submitResumeText 走 multipart 的 text 字段', () async {
      final _FakeBackend backend = _FakeBackend();
      await repoWith(backend).submitResumeText('张三 后端工程师');

      expect(backend.lastPath, '/api/v1/resume');
      expect(backend.lastMethod, 'POST');
      expect(backend.isMultipart, isTrue, reason: '该端点只收 multipart/form-data');
      expect(backend.fields['text'], '张三 后端工程师');
      expect(backend.fileField, isNull, reason: '文本路径不应带文件');
    });

    test('submitResumeFile 走 multipart 的 file 字段并带上原始字节', () async {
      final _FakeBackend backend = _FakeBackend();
      final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

      await repoWith(backend).submitResumeFile(
        ResumeFileData(
          name: '张三-产品经理.pdf',
          extension: 'pdf',
          sizeBytes: bytes.length,
          bytes: bytes,
        ),
      );

      expect(backend.lastPath, '/api/v1/resume');
      expect(backend.fileField, 'file');
      expect(backend.fileName, '张三-产品经理.pdf');
      expect(backend.fileLength, bytes.length);
    });

    test('Content-Type 由 http 生成（含 boundary），不被手写覆盖', () async {
      final _FakeBackend backend = _FakeBackend();
      await repoWith(
        backend,
      ).submitResumeText('随便一段简历文本');

      expect(
        backend.contentType,
        allOf(contains('multipart/form-data'), contains('boundary=')),
        reason: '手写 Content-Type 会让后端 multipart 解析失败',
      );
    });
  });

  group('读取职业基线（GET /api/v1/resume）', () {
    test('roles / projects[].name / skills 映射到 ResumeProfile 的对应字段', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'text': '张三 后端工程师',
          'updatedAt': '2026-10-02T10:00:00Z',
          'profile': <String, dynamic>{
            'name': '张三',
            'skills': <dynamic>['Python', 'Kafka', ''],
            'experience_years': 6.0,
            'roles': <dynamic>['后端工程师', '高级后端工程师'],
            'projects': <dynamic>[
              <String, dynamic>{
                'name': '电商中台订单服务',
                'description': 'FastAPI + MySQL',
                'tech_stack': <dynamic>['FastAPI', 'MySQL'],
                'highlights': <dynamic>['QPS 1.2 万'],
              },
              <String, dynamic>{'name': '实时风控引擎'},
            ],
          },
        },
      );

      final ResumeProfile profile = await repoWith(backend).fetchProfile();

      expect(backend.lastPath, '/api/v1/resume');
      expect(profile.hasBaseline, isTrue, reason: '有文本即有基线');
      // ⚠️ 这两条是 2026-10-02 修复的字段映射；修之前恒为空。
      expect(profile.workExperiences, <String>['后端工程师', '高级后端工程师']);
      expect(profile.projectExperiences, <String>['电商中台订单服务', '实时风控引擎']);
      expect(profile.skills, <String>['Python', 'Kafka'], reason: '空白项被丢弃');
      // ⚠️ 2026-10-07 补的映射。后端一直在返回 `experience_years`，
      // 此前 Dart 侧把它丢掉了 —— 「设置 → 个人信息」的「工作经验」一行
      // 因此恒为空。`6.0` → `6`（收成整年，只用于展示）。
      expect(profile.experienceYears, 6);
      // 后端没有来源 → 保持空，不编造（D110）。
      expect(profile.awards, isEmpty);
      expect(profile.capabilities, isEmpty);
    });

    test('后端返回 null（尚无基线）→ ResumeProfile.empty', () async {
      final _FakeBackend backend = _FakeBackend();
      final ResumeProfile profile = await repoWith(backend).fetchProfile();

      expect(profile.isEmpty, isTrue);
      expect(profile.hasBaseline, isFalse);
      expect(profile.experienceYears, isNull);
    });

    test('画像里缺 experience_years → null，不编造 0 年', () async {
      // ⚠️ 这一条区分「没解析出」与「解析出 0 年」—— 后端对后者会明确给
      // `0.0`。若缺键时回落成 `0`，页面会把「不知道」显示成「0 年」。
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'text': '张三 后端工程师',
          'profile': <String, dynamic>{'name': '张三'},
        },
      );

      final ResumeProfile profile = await repoWith(backend).fetchProfile();

      expect(profile.experienceYears, isNull);
    });

    test('experience_years 为 0.0 时保留 0（与缺键区分）', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'text': '应届生',
          'profile': <String, dynamic>{'name': '应届生', 'experience_years': 0.0},
        },
      );

      final ResumeProfile profile = await repoWith(backend).fetchProfile();

      expect(profile.experienceYears, 0);
    });

    test('有画像但文本为空 → 仍视为无基线', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'text': '   ',
          'profile': <String, dynamic>{
            'skills': <dynamic>['Python'],
          },
        },
      );

      final ResumeProfile profile = await repoWith(backend).fetchProfile();

      expect(profile.hasBaseline, isFalse);
      expect(profile.skills, isEmpty);
    });
  });

  test('读取某版本原始 PDF 时返回二进制原稿', () async {
    final Uint8List original = Uint8List.fromList(<int>[
      0x25, 0x50, 0x44, 0x46, 0x2d, 0x31, 0x2e, 0x37,
    ]);
    final _FakeBackend backend = _FakeBackend(pdfPayload: original);

    final List<int> fetched = await repoWith(
      backend,
    ).fetchVersionOriginalPdf('version-123');

    expect(backend.lastPath, '/api/v1/resume/versions/version-123/original');
    expect(backend.lastMethod, 'GET');
    expect(fetched, original);
  });

  group('ResumeFileData.allowedExtensions', () {
    test('与后端 _ALLOWED_RESUME_SUFFIXES 一致：收图片与 txt，不收旧式 doc', () {
      expect(
        ResumeFileData.allowedExtensions,
        <String>{'pdf', 'docx', 'txt', 'png', 'jpg', 'jpeg', 'webp', 'bmp'},
      );
      expect(
        ResumeFileData.allowedExtensions,
        isNot(contains('doc')),
        reason: '.doc 是旧二进制格式，后端必拒 —— 放行等于必然失败',
      );
    });
  });
}

/// 假后端：记录请求形态（multipart 字段 / 文件 / 头），返回可编排的 envelope。
class _FakeBackend extends http.BaseClient {
  _FakeBackend({Map<String, dynamic>? payload, this.pdfPayload})
    : _data = payload;

  final Map<String, dynamic>? _data;
  final Uint8List? pdfPayload;

  String? lastPath;
  String? lastMethod;
  bool isMultipart = false;
  Map<String, String> fields = const <String, String>{};
  String? fileField;
  String? fileName;
  int? fileLength;
  String? contentType;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastPath = request.url.path;
    lastMethod = request.method;

    if (request is http.MultipartRequest) {
      isMultipart = true;
      fields = Map<String, String>.from(request.fields);
      if (request.files.isNotEmpty) {
        final http.MultipartFile file = request.files.first;
        fileField = file.field;
        fileName = file.filename;
        fileLength = file.length;
      }
      // finalize 会把 boundary 写进 headers，故必须先 finalize 再读。
      await request.finalize().toBytes();
    }
    contentType = request.headers['content-type'];

    if (lastPath?.endsWith('/original') == true && pdfPayload != null) {
      return http.StreamedResponse(
        Stream<List<int>>.value(pdfPayload!),
        200,
        headers: const <String, String>{'content-type': 'application/pdf'},
      );
    }

    final Map<String, dynamic> body = <String, dynamic>{
      'success': true,
      'data': _data,
      'error': null,
    };
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[
        utf8.encode(jsonEncode(body)),
      ]),
      200,
      headers: const <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }
}
