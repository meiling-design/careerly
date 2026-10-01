import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:careerly/data/api/api_client.dart';
import 'package:careerly/data/api/api_growth_repository.dart';
import 'package:careerly/data/models/growth_event.dart';

/// P2-5：ApiGrowthRepository 的契约钉住测试。
///
/// 钉住三件事：
/// 1. 请求路径与 query 拼装（type / from / to）—— 后端按这个契约路由；
/// 2. envelope 解包后的 `[GrowthEvent]` 解析 —— `type` 是 Dart enum 名，
///    `occurredAt` 是 ISO-8601，`delta` 可空；
/// 3. `data` 不是 List 时返回空列表而不是炸掉（防御性）。
void main() {
  group('ApiGrowthRepository', () {
    test('fetchEvents 不带 type 时请求裸路径', () async {
      final _FakeBackend backend = _FakeBackend();
      final ApiGrowthRepository repo = ApiGrowthRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      await repo.fetchEvents();

      expect(backend.lastPath, '/api/v1/growth/events');
    });

    test('fetchEvents 带 type 时透传 Dart enum 名', () async {
      final _FakeBackend backend = _FakeBackend();
      final ApiGrowthRepository repo = ApiGrowthRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      await repo.fetchEvents(type: GrowthEventType.matchScore);

      // ⚠️ 契约 §2.8：type 必须是 enum 的 .name（matchScore），
      // 不是中文 label，也不是全小写 —— 后端按枚举名精确匹配。
      expect(backend.lastPath, '/api/v1/growth/events?type=matchScore');
    });

    test('fetchTimeline 拼装 from/to 区间', () async {
      final _FakeBackend backend = _FakeBackend();
      final ApiGrowthRepository repo = ApiGrowthRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      await repo.fetchTimeline(
        from: DateTime.utc(2026, 8, 1),
        to: DateTime.utc(2026, 8, 31),
      );

      expect(backend.lastPath, startsWith('/api/v1/growth/timeline?'));
      expect(backend.lastPath, contains('from=2026-08-01T00%3A00%3A00.000Z'));
      expect(backend.lastPath, contains('to=2026-08-31T00%3A00%3A00.000Z'));
    });

    test('解析后端 GrowthEvent JSON 列表', () async {
      final _FakeBackend backend = _FakeBackend(events: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'gev_1',
          'type': 'capability',
          'title': '云原生能力提升',
          'description': '40 → 48',
          'delta': 8,
          'occurredAt': '2026-10-01T07:30:00+00:00',
        },
        <String, dynamic>{
          'id': 'gev_0',
          'type': 'experience',
          'title': '建立职业基线',
          'description': null,
          'delta': null,
          'occurredAt': '2026-10-01T07:00:00+00:00',
        },
      ]);
      final ApiGrowthRepository repo = ApiGrowthRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      final List<GrowthEvent> events = await repo.fetchEvents();

      expect(events, hasLength(2));
      expect(events[0].type, GrowthEventType.capability);
      expect(events[0].delta, 8);
      expect(events[0].deltaLabel, '+8');
      expect(events[0].isPositive, isTrue);
      expect(events[0].occurredAt, isNotNull);
      expect(events[1].type, GrowthEventType.experience);
      expect(events[1].delta, isNull);
      expect(events[1].deltaLabel, isNull);
    });

    test('data 非 List 时返回空列表（防御性）', () async {
      final _FakeBackend backend = _FakeBackend(rawData: <String, dynamic>{
        'unexpected': 'shape',
      });
      final ApiGrowthRepository repo = ApiGrowthRepository(
        ApiClient(baseUrl: 'http://test.local', httpClient: backend),
      );

      expect(await repo.fetchEvents(), isEmpty);
    });
  });
}

/// 假后端：记录请求路径，返回可编排的 envelope 响应。
class _FakeBackend extends http.BaseClient {
  _FakeBackend({List<Map<String, dynamic>>? events, dynamic rawData})
      : _data = rawData ?? (events ?? <Map<String, dynamic>>[]);

  final dynamic _data;
  String? lastPath;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastPath = '${request.url.path}${request.url.hasQuery ? '?${request.url.query}' : ''}';
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
