import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:careerly/core/errors/app_error.dart';
import 'package:careerly/data/api/api_client.dart';
import 'package:careerly/data/api/token_store.dart';

/// TokenStore 契约测试：对**每一种**实现跑同一组断言。
///
/// 这样 [SecureTokenStore] 日后若换 storage 实现，语义仍然被钉住 ——
/// 「换实现不换语义」正是抽象这一层存在的理由。
void _contractSuite(String name, TokenStore Function() create) {
  group(name, () {
    test('未保存过时 read 返回 null', () async {
      expect(await create().read(), isNull);
    });

    test('save → read 往返一致', () async {
      final TokenStore store = create();
      await store.save(accessToken: 'a1', refreshToken: 'r1');
      final Tokens? t = await store.read();
      expect(t, isNotNull);
      expect(t!.accessToken, 'a1');
      expect(t.refreshToken, 'r1');
    });

    test('save 传 null refreshToken 时保留既有 refresh', () async {
      final TokenStore store = create();
      await store.save(accessToken: 'a1', refreshToken: 'r1');
      // 典型的 refresh 轮换：只换 access，refresh 沿用旧值。
      await store.save(accessToken: 'a2');
      final Tokens t = (await store.read())!;
      expect(t.accessToken, 'a2');
      expect(t.refreshToken, 'r1', reason: 'refresh 不能被悄悄抹掉');
    });

    test('clear 后 read 返回 null', () async {
      final TokenStore store = create();
      await store.save(accessToken: 'a1', refreshToken: 'r1');
      await store.clear();
      expect(await store.read(), isNull);
    });

    test('空 accessToken 视为无效会话', () async {
      final TokenStore store = create();
      await store.save(accessToken: '', refreshToken: 'r1');
      expect((await store.read())?.isValid, isFalse);
    });
  });
}

/// 记录最后一次请求的 Authorization 头，用于验证「凭据有没有带上」。
class _SpyClient extends http.BaseClient {
  final List<http.Request> sent = <http.Request>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final http.Request snapshot = http.Request(request.method, request.url)
      ..headers.addAll(request.headers);
    sent.add(snapshot);

    final Map<String, dynamic> envelope = <String, dynamic>{
      'success': true,
      'data': <String, dynamic>{'ok': true},
      'error': null,
      'meta': <String, dynamic>{},
    };
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[
        utf8.encode(jsonEncode(envelope)),
      ]),
      200,
      request: request,
      headers: const <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }
}

void main() {
  _contractSuite('InMemoryTokenStore（契约）', () => InMemoryTokenStore());

  group('冷启动会话恢复（D-B）', () {
    test('同一 TokenStore 的新 ApiClient 能恢复凭据并带上 Authorization',
        () async {
      // ── 进程 1：登录成功，凭据落盘 ──
      final TokenStore store = InMemoryTokenStore();
      final ApiClient first = ApiClient(
        baseUrl: 'http://example.test',
        httpClient: _SpyClient(),
        tokenStore: store,
      );
      await first.setSession(accessToken: 'access_1', refreshToken: 'refresh_1');
      expect(first.hasSession, isTrue);

      // ── 进程被杀 ──
      first.dispose();

      // ── 进程 2：全新 ApiClient 实例，只有持久化的 store 是共同状态 ──
      //
      // 这正是冷启动的形状：内存里什么都没有，唯一能找回身份的就是 TokenStore。
      final _SpyClient spy = _SpyClient();
      final ApiClient second = ApiClient(
        baseUrl: 'http://example.test',
        httpClient: spy,
        tokenStore: store,
      );
      expect(second.hasSession, isFalse, reason: '恢复前不该凭空持有令牌');

      expect(await second.restoreSession(), isTrue);
      expect(second.hasSession, isTrue);

      await second.get('/api/v1/resume');
      expect(
        spy.sent.single.headers['Authorization'],
        'Bearer access_1',
        reason: '恢复后的第一个请求必须带着 recovery 到的 access token',
      );
    });

    test('从未登录过的应用冷启动不会恢复出会话', () async {
      final ApiClient client = ApiClient(
        baseUrl: 'http://example.test',
        httpClient: _SpyClient(),
        tokenStore: InMemoryTokenStore(),
      );
      expect(await client.restoreSession(), isFalse);
      expect(client.hasSession, isFalse);
    });

    test('登出后冷启动不再持有凭据', () async {
      final TokenStore store = InMemoryTokenStore();
      final ApiClient first = ApiClient(
        baseUrl: 'http://example.test',
        httpClient: _SpyClient(),
        tokenStore: store,
      );
      await first.setSession(accessToken: 'access_1', refreshToken: 'refresh_1');

      // 登出：内存 + 持久层一起清 —— 只清一个都会导致冷启动「复活」。
      await first.clearSession();
      first.dispose();

      final ApiClient second = ApiClient(
        baseUrl: 'http://example.test',
        httpClient: _SpyClient(),
        tokenStore: store,
      );
      expect(await second.restoreSession(), isFalse);
      expect(second.hasSession, isFalse);
    });

    test('恢复后 401 → refresh 成功 → 重试请求带上新令牌', () async {
      final TokenStore store = InMemoryTokenStore();
      // 第一次 401，第二次（refresh 请求）成功，第三次（重试）成功。
      final _RotatingClient http_ = _RotatingClient();
      final ApiClient client = ApiClient(
        baseUrl: 'http://example.test',
        httpClient: http_,
        tokenStore: store,
      );
      await client.setSession(accessToken: 'expired', refreshToken: 'refresh_1');

      final dynamic data = await client.get('/api/v1/resume');
      expect(data, isNotNull, reason: '401 应在 refresh 后自动重试成功');

      expect(http_.paths, <String>[
        '/api/v1/resume',
        '/api/v1/auth/refresh',
        '/api/v1/resume',
      ]);
      // 重试必须带新令牌，否则会再次 401 陷入死循环。
      expect(http_.authHeaders.last, 'Bearer refreshed');
      // 新令牌必须回写持久层，否则下次冷启动又从过期令牌开始。
      expect((await store.read())!.accessToken, 'refreshed');
    });

    test('refresh 也失败则清除会话（不留半个登录态）', () async {
      final TokenStore store = InMemoryTokenStore();
      final _AlwaysUnauthorized http_ = _AlwaysUnauthorized();
      final ApiClient client = ApiClient(
        baseUrl: 'http://example.test',
        httpClient: http_,
        tokenStore: store,
      );
      await client.setSession(accessToken: 'expired', refreshToken: 'refresh_1');

      await expectLater(client.get('/api/v1/resume'), throwsA(isA<AuthError>()));
      expect(client.hasSession, isFalse);
      expect(await store.read(), isNull, reason: '凭据必须连同持久层一起清掉');
    });
  });
}

/// 第一个业务请求 401，refresh 成功，重试 200。
class _RotatingClient extends http.BaseClient {
  final List<String> paths = <String>[];
  final List<String?> authHeaders = <String?>[];
  int _calls = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    paths.add(request.url.path);
    authHeaders.add(request.headers['Authorization']);
    _calls++;

    final http.BaseRequest current = request;
    return switch (request.url.path) {
      '/api/v1/auth/refresh' => _json(
          200,
          <String, dynamic>{
            'success': true,
            'data': <String, dynamic>{
              'access_token': 'refreshed',
              'refresh_token': 'refresh_2',
            },
            'error': null,
          },
          current,
        ),
      _ => _calls == 1
          ? _json(401, <String, dynamic>{
              'success': false,
              'data': null,
              'error': <String, dynamic>{
                'code': 'INVALID_TOKEN',
                'message': '令牌已失效',
              },
            },
            current,
          )
          : _json(200, <String, dynamic>{
              'success': true,
              'data': <String, dynamic>{'text': 'R'},
              'error': null,
            }, current),
    };
  }

  http.StreamedResponse _json(
    int status,
    Map<String, dynamic> body,
    http.BaseRequest request,
  ) {
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[utf8.encode(jsonEncode(body))]),
      status,
      request: request,
      headers: const <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }
}

/// 一切皆 401 —— 模拟 refresh token 也已过期。
class _AlwaysUnauthorized extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'success': false,
      'data': null,
      'error': <String, dynamic>{
        'code': 'INVALID_TOKEN',
        'message': '令牌已失效',
      },
    };
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[utf8.encode(jsonEncode(body))]),
      401,
      request: request,
      headers: const <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }
}
