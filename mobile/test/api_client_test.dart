import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitaara/core/network/api_client.dart';
import 'package:sitaara/core/storage/token_store.dart';

void main() {
  test('safe reads retry one transient server failure', () async {
    var calls = 0;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    server.listen((request) async {
      calls++;
      request.response.headers.contentType = ContentType.json;
      if (calls == 1) {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        request.response.write(
          jsonEncode({
            'error': {'code': 'UNAVAILABLE', 'message': 'Try again.'},
            'meta': {'requestId': 'first'},
          }),
        );
      } else {
        request.response.write(
          jsonEncode({
            'data': {'ok': true},
            'meta': {'requestId': 'second'},
          }),
        );
      }
      await request.response.close();
    });

    final client = ApiClient(
      tokenStore: _MemoryTokenStore(null),
      baseUrl: 'http://${server.address.host}:${server.port}',
    );
    final response = await client.get<Map<String, dynamic>>('/read');

    expect(ApiClient.unwrap(response)['ok'], isTrue);
    expect(calls, 2);
  });

  test('concurrent unauthorized requests share one refresh rotation', () async {
    var refreshCalls = 0;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path == '/v1/auth/refresh') {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 100));
        request.response.write(
          jsonEncode({
            'data': {
              'user': {
                'id': '00000000-0000-4000-8000-000000000001',
                'email': 'parent@example.com',
              },
              'onboardingState': 'needs_family',
              'accessToken': 'new-access',
              'refreshToken': 'new-refresh',
              'accessTokenExpiresAt': '2026-10-16T12:15:00Z',
              'refreshTokenExpiresAt': '2026-11-15T12:00:00Z',
            },
            'meta': {'requestId': 'refresh'},
          }),
        );
      } else if (request.headers.value(HttpHeaders.authorizationHeader) ==
          'Bearer new-access') {
        request.response.write(
          jsonEncode({
            'data': {'ok': true},
            'meta': {'requestId': 'ok'},
          }),
        );
      } else {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.write(
          jsonEncode({
            'error': {
              'code': 'UNAUTHORIZED',
              'message': 'Unauthorized.',
              'fields': <String, dynamic>{},
            },
            'meta': {'requestId': 'unauthorized'},
          }),
        );
      }
      await request.response.close();
    });

    final store = _MemoryTokenStore(
      const StoredTokens(
        accessToken: 'expired-access',
        refreshToken: 'old-refresh',
      ),
    );
    final client = ApiClient(
      tokenStore: store,
      baseUrl: 'http://${server.address.host}:${server.port}',
    );

    final responses = await Future.wait([
      client.dio.get<Map<String, dynamic>>('/protected'),
      client.dio.get<Map<String, dynamic>>('/protected'),
    ]);

    expect(responses, hasLength(2));
    expect(refreshCalls, 1);
    expect((await store.read())?.accessToken, 'new-access');
    expect((await store.read())?.refreshToken, 'new-refresh');
  });
}

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore(this.tokens);

  StoredTokens? tokens;

  @override
  Future<void> clear() async => tokens = null;

  @override
  Future<StoredTokens?> read() async => tokens;

  @override
  Future<void> write(StoredTokens value) async => tokens = value;
}
