import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:careerly/data/api/api_career_assets_repository.dart';
import 'package:careerly/data/api/api_client.dart';
import 'package:careerly/data/api/api_home_summary_repository.dart';
import 'package:careerly/data/api/api_profile_repository.dart';
import 'package:careerly/data/models/career_assets.dart';
import 'package:careerly/data/models/home_summary.dart';
import 'package:careerly/data/models/user_profile.dart';

/// P3-5a：三个新 API 仓储的契约钉住测试。
///
/// 钉住三件事：
/// 1. 请求路径 —— 后端按这个契约路由；
/// 2. envelope 解包后的模型解析 —— 字段名全部 camelCase；
/// 3. 空态语义 —— 后端空数组解析为空集合，不是错误。
void main() {
  group('ApiCareerAssetsRepository', () {
    test('fetchAssets 请求 /api/v1/career/assets', () async {
      final _FakeBackend backend = _FakeBackend();
      final ApiCareerAssetsRepository repo = ApiCareerAssetsRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      await repo.fetchAssets();

      expect(backend.lastPath, '/api/v1/career/assets');
    });

    test('解析后端 CareerAssets JSON（含空数组空态）', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'workExperiences': <dynamic>[
            <String, dynamic>{'id': 'w1', 'title': '后端工程师'},
          ],
          'projects': <dynamic>[],
          'skillGroups': <dynamic>[],
          'awards': <dynamic>[],
          'capabilities': <dynamic>[
            <String, dynamic>{
              'name': '云原生',
              'score': 55,
              'delta': 15,
              'previousScore': 40,
            },
          ],
          'spanLabel': '工作经验 5 年',
          'monthlyAdded': 2,
        },
      );
      final ApiCareerAssetsRepository repo = ApiCareerAssetsRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      final CareerAssets assets = await repo.fetchAssets();

      expect(assets.workExperiences, hasLength(1));
      expect(assets.capabilities, hasLength(1));
      expect(assets.capabilities.first.name, '云原生');
      expect(assets.capabilities.first.score, 55);
      expect(assets.capabilities.first.delta, 15);
      expect(assets.capabilities.first.previousScore, 40);
      // 空数组是合法空态，不是错误。
      expect(assets.projects, isEmpty);
      expect(assets.awards, isEmpty);
    });
  });

  group('ApiHomeSummaryRepository', () {
    test('fetchSummary 请求 /api/v1/home/summary', () async {
      final _FakeBackend backend = _FakeBackend();
      final ApiHomeSummaryRepository repo = ApiHomeSummaryRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      await repo.fetchSummary();

      expect(backend.lastPath, '/api/v1/home/summary');
    });

    test('解析后端 HomeSummary JSON（dailyContent 可空）', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'headline': '当前匹配 84 分',
          'subheadline': '比上次 +6 分',
          'suggestions': <dynamic>['补充 Kubernetes 生产经验'],
          'matchChanges': <dynamic>[
            <String, dynamic>{
              'jobId': 'j1',
              'jobTitle': '高级 Python 后端工程师',
              'company': null,
              'score': 84,
              'delta': 6,
            },
          ],
          'recentGrowth': <dynamic>['建立职业基线'],
          'dailyContent': null,
          'hasBaseline': true,
        },
      );
      final ApiHomeSummaryRepository repo = ApiHomeSummaryRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      final HomeSummary summary = await repo.fetchSummary();

      expect(summary.headline, '当前匹配 84 分');
      expect(summary.hasBaseline, isTrue);
      expect(summary.suggestions, <String>['补充 Kubernetes 生产经验']);
      expect(summary.matchChanges, hasLength(1));
      expect(summary.matchChanges.first.jobTitle, '高级 Python 后端工程师');
      expect(summary.matchChanges.first.delta, 6);
      expect(summary.recentGrowth, <String>['建立职业基线']);
      expect(summary.dailyContent, isNull);
    });
  });

  group('ApiProfileRepository', () {
    test('fetchUserProfile 请求 /api/v1/profile', () async {
      final _FakeBackend backend = _FakeBackend();
      final ApiProfileRepository repo = ApiProfileRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      await repo.fetchUserProfile();

      expect(backend.lastPath, '/api/v1/profile');
    });

    test('解析后端 UserProfile JSON（handle 为脱敏手机号）', () async {
      final _FakeBackend backend = _FakeBackend(
        payload: <String, dynamic>{
          'displayName': '张三',
          'handle': '139****0002',
          'membershipLabel': '免费版',
        },
      );
      final ApiProfileRepository repo = ApiProfileRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      final UserProfile profile = await repo.fetchUserProfile();

      expect(profile.displayName, '张三');
      expect(profile.handle, '139****0002');
      expect(profile.membershipLabel, '免费版');
    });
  });
}

/// 假后端：记录请求路径，返回可编排的 envelope 响应。
class _FakeBackend extends http.BaseClient {
  _FakeBackend({Map<String, dynamic>? payload})
      : _data = payload ?? <String, dynamic>{};

  final dynamic _data;
  String? lastPath;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastPath =
        '${request.url.path}${request.url.hasQuery ? '?${request.url.query}' : ''}';
    final Map<String, dynamic> body = <String, dynamic>{
      'success': true,
      'data': _data,
      'error': null,
    };
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[utf8.encode(jsonEncode(body))]),
      200,
      request: request is http.Request ? request : null,
      headers: const <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }
}
