import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredTokens {
  const StoredTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

abstract interface class TokenStore {
  Future<StoredTokens?> read();
  Future<void> write(StoredTokens tokens);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'sitaara_access_token';
  static const _refreshKey = 'sitaara_refresh_token';
  final FlutterSecureStorage _storage;

  @override
  Future<StoredTokens?> read() async {
    final values = await _storage.readAll();
    final accessToken = values[_accessKey];
    final refreshToken = values[_refreshKey];
    if (accessToken == null || refreshToken == null) return null;
    return StoredTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> write(StoredTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: tokens.accessToken),
      _storage.write(key: _refreshKey, value: tokens.refreshToken),
    ]);
  }

  @override
  Future<void> clear() => _storage.deleteAll();
}
