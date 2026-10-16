import 'package:dio/dio.dart';

import '../../../core/models/api_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_store.dart';

class AuthRepository {
  const AuthRepository(this._client);

  final ApiClient _client;

  Future<SessionModel> register({
    required String email,
    required String password,
  }) => _authenticate('/v1/auth/register', email: email, password: password);

  Future<SessionModel> login({
    required String email,
    required String password,
  }) => _authenticate('/v1/auth/login', email: email, password: password);

  Future<SessionModel> _authenticate(
    String path, {
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        path,
        data: {'email': email.trim(), 'password': password},
        options: Options(extra: const {'public': true}),
      );
      return SessionModel.fromJson(ApiClient.unwrap(response));
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<MeModel> me() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/v1/me');
      return MeModel.fromJson(ApiClient.unwrap(response));
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<void> logout(StoredTokens tokens) async {
    try {
      await _client.dio.post<void>(
        '/v1/auth/logout',
        data: {'refreshToken': tokens.refreshToken},
      );
    } catch (error) {
      final mapped = ApiClient.mapError(error);
      if (!mapped.isUnauthorized && mapped.code != 'NETWORK_ERROR') rethrow;
    }
  }
}
