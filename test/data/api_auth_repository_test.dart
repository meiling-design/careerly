 import 'dart:convert';

import 'package:careerly/data/api/api_auth_repository.dart';
import 'package:careerly/data/api/api_client.dart';
import 'package:careerly/data/api/token_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'deleteCareerData uses the authenticated endpoint and keeps session',
    () async {
      final TokenStore tokenStore = InMemoryTokenStore();
      final MockClient httpClient = MockClient((http.Request request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/api/v1/account/career-data');
        expect(request.headers['Authorization'], 'Bearer access-token');
        return http.Response(
          jsonEncode(<String, dynamic>{
            'success': true,
            'data': <String, dynamic>{
              'deleted': true,
              'account_retained': true,
              'deleted_rows': 6,
              'deleted_files': 1,
              'orphan_artifacts': 0,
              'warnings': <String>[],
            },
            'error': null,
            'meta': <String, dynamic>{},
          }),
          200,
          headers: const <String, String>{
            'content-type': 'application/json; charset=utf-8',
          },
        );
      });
      final ApiClient client = ApiClient(
        baseUrl: 'https://example.test',
        httpClient: httpClient,
        tokenStore: tokenStore,
      );
      addTearDown(client.dispose);
      await client.setSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      final result = await ApiAuthRepository(client).deleteCareerData();

      expect(result.deletedRows, 6);
      expect(result.deletedFiles, 1);
      expect(result.complete, isTrue);
      expect(client.hasSession, isTrue);
      expect((await tokenStore.read())?.accessToken, 'access-token');
      expect((await tokenStore.read())?.refreshToken, 'refresh-token');
    },
  );
}
