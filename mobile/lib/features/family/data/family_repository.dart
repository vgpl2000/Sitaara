import '../../../core/models/api_models.dart';
import '../../../core/network/api_client.dart';

class FamilyRepository {
  const FamilyRepository(this._client);

  final ApiClient _client;

  Future<FamilyModel> createFamily({
    required String role,
    required String childName,
    required DateTime dateOfBirth,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/v1/families',
        data: {
          'role': role,
          'child': {
            'name': childName.trim(),
            'dateOfBirth': dateOfBirth.toIso8601String().substring(0, 10),
          },
        },
      );
      return FamilyModel.fromJson(ApiClient.unwrap(response));
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<FamilyModel> redeemInvite({
    required String role,
    required String code,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/v1/invites/redeem',
        data: {'role': role, 'code': code.trim().toUpperCase()},
      );
      return FamilyModel.fromJson(ApiClient.unwrap(response));
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<InviteModel> createInvite() async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/v1/invites',
      );
      return InviteModel.fromJson(ApiClient.unwrap(response));
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }
}
