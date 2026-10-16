import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/api_models.dart';
import '../storage/token_store.dart';

class ApiClient {
  ApiClient({required this._tokenStore, String? baseUrl})
    : _refreshDio = Dio(_options(baseUrl)),
      dio = Dio(_options(baseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _authorize, onError: _handleError),
    );
  }

  final TokenStore _tokenStore;
  final Dio _refreshDio;
  final Dio dio;
  final StreamController<void> _sessionExpired =
      StreamController<void>.broadcast();
  Future<String>? _refreshInFlight;

  Stream<void> get sessionExpired => _sessionExpired.stream;

  /// Performs an idempotent read with one bounded retry for transient failures.
  /// Mutating requests deliberately do not use this helper.
  Future<Response<T>> get<T>(
    String path, {
    CancelToken? cancelToken,
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await dio.get<T>(
          path,
          cancelToken: cancelToken,
          options: options,
          queryParameters: queryParameters,
        );
      } on DioException catch (error) {
        if (attempt > 0 || !_isTransientReadFailure(error)) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (cancelToken?.isCancelled ?? false) {
          throw DioException.requestCancelled(
            requestOptions: error.requestOptions,
            reason: cancelToken?.cancelError,
          );
        }
      }
    }
  }

  static bool _isTransientReadFailure(DioException error) {
    final status = error.response?.statusCode;
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (status != null && status >= 500 && status <= 599);
  }

  static BaseOptions _options(String? baseUrl) => BaseOptions(
    baseUrl: baseUrl ?? AppConfig.apiUri.toString(),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 10),
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    headers: const {'Accept': Headers.jsonContentType},
  );

  Future<void> _authorize(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await _tokenStore.read();
    if (tokens != null && options.extra['public'] != true) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final canRefresh =
        error.response?.statusCode == 401 &&
        request.extra['public'] != true &&
        request.extra['retried'] != true &&
        !request.path.endsWith('/v1/auth/refresh');
    if (!canRefresh) {
      handler.next(error);
      return;
    }

    try {
      final accessToken = await _refreshAccessToken();
      request.extra['retried'] = true;
      request.headers['Authorization'] = 'Bearer $accessToken';
      handler.resolve(await dio.fetch<dynamic>(request));
    } catch (_) {
      await _tokenStore.clear();
      _sessionExpired.add(null);
      handler.next(error);
    }
  }

  Future<String> _refreshAccessToken() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;
    final future = _performRefresh();
    _refreshInFlight = future;
    return future.whenComplete(() => _refreshInFlight = null);
  }

  Future<String> _performRefresh() async {
    final tokens = await _tokenStore.read();
    if (tokens == null) {
      throw const ApiException(
        code: 'SIGNED_OUT',
        message: 'Please sign in again.',
      );
    }

    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/v1/auth/refresh',
      data: {'refreshToken': tokens.refreshToken},
    );
    final session = SessionModel.fromJson(_data(response.data));
    await _tokenStore.write(
      StoredTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session.accessToken;
  }

  static Map<String, dynamic> unwrap(Response<Map<String, dynamic>> response) =>
      _data(response.data);

  static List<dynamic> unwrapList(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is List<dynamic>) return data;
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'The service returned an unexpected response.',
    );
  }

  static Map<String, dynamic> _data(Map<String, dynamic>? envelope) {
    final data = envelope?['data'];
    if (data is Map<String, dynamic>) return data;
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'The service returned an unexpected response.',
    );
  }

  static ApiException mapError(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map<String, dynamic> &&
          body['error'] is Map<String, dynamic>) {
        final apiError = body['error'] as Map<String, dynamic>;
        final meta = body['meta'];
        return ApiException(
          code: apiError['code'] as String? ?? 'REQUEST_FAILED',
          message:
              apiError['message'] as String? ??
              'Something went wrong. Please try again.',
          fields:
              (apiError['fields'] as Map?)?.cast<String, dynamic>() ?? const {},
          requestId: meta is Map ? meta['requestId'] as String? : null,
          statusCode: error.response?.statusCode,
        );
      }
      return ApiException(
        code: 'NETWORK_ERROR',
        message:
            error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout
            ? 'The request timed out. Please try again.'
            : 'Could not reach Sitaara. Check your connection and try again.',
        statusCode: error.response?.statusCode,
      );
    }
    return const ApiException(
      code: 'UNKNOWN_ERROR',
      message: 'Something went wrong. Please try again.',
    );
  }
}
