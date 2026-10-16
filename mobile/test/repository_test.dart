import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitaara/core/network/api_client.dart';
import 'package:sitaara/core/storage/token_store.dart';
import 'package:sitaara/features/auth/data/auth_repository.dart';
import 'package:sitaara/features/content/data/content_repository.dart';

void main() {
  late HttpServer server;
  late ApiClient client;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    client = ApiClient(
      tokenStore: _MemoryTokenStore(),
      baseUrl: 'http://${server.address.host}:${server.port}',
    );
  });

  tearDown(() => server.close(force: true));

  test('auth repository restores the typed current user', () async {
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'data': {
            'id': 'user-1',
            'email': 'parent@example.test',
            'onboardingState': 'needs_family',
            'family': null,
          },
          'meta': {'requestId': 'me'},
        }),
      );
      await request.response.close();
    });

    final me = await AuthRepository(client).me();

    expect(me.email, 'parent@example.test');
    expect(me.onboardingState, 'needs_family');
  });

  test('content repository maps the library response', () async {
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'data': [
            {
              'id': 'masterclass-1',
              'slug': 'everyday-parenting',
              'title': 'Everyday Parenting',
              'description': 'Practical lessons.',
              'thumbnailUrl': 'https://example.test/poster.jpg',
              'videoCount': 5,
              'totalDurationSeconds': 900,
              'me': {'percent': 20, 'completedVideos': 1, 'likedVideos': 2},
              'partner': null,
            },
          ],
          'meta': {'requestId': 'library'},
        }),
      );
      await request.response.close();
    });

    final items = await ContentRepository(client).listMasterclasses();

    expect(items, hasLength(1));
    expect(items.single.videoCount, 5);
    expect(items.single.me.likedVideos, 2);
  });
}

class _MemoryTokenStore implements TokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<StoredTokens?> read() async => null;

  @override
  Future<void> write(StoredTokens value) async {}
}
