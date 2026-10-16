import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'content_models.dart';

class ContentRepository {
  const ContentRepository(this._client);

  final ApiClient _client;

  Future<List<MasterclassCardModel>> listMasterclasses({
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/v1/masterclasses',
        cancelToken: cancelToken,
      );
      return ApiClient.unwrapList(response)
          .map(
            (item) =>
                MasterclassCardModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<MasterclassDetailModel> getMasterclass(
    String id, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/v1/masterclasses/$id',
        cancelToken: cancelToken,
      );
      return MasterclassDetailModel.fromJson(ApiClient.unwrap(response));
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<VideoModel> getVideo(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/v1/videos/$id',
        cancelToken: cancelToken,
      );
      return VideoModel.fromJson(ApiClient.unwrap(response));
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<bool> setLiked(String id, {required bool liked}) async {
    try {
      final response = liked
          ? await _client.dio.put<Map<String, dynamic>>('/v1/videos/$id/like')
          : await _client.dio.delete<Map<String, dynamic>>(
              '/v1/videos/$id/like',
            );
      return ApiClient.unwrap(response)['liked'] as bool;
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<ProgressResult> updateProgress(String id, int seconds) async {
    try {
      final response = await _client.dio.put<Map<String, dynamic>>(
        '/v1/videos/$id/progress',
        data: {'positionSeconds': seconds},
      );
      return ProgressResult.fromJson(ApiClient.unwrap(response));
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }
}
