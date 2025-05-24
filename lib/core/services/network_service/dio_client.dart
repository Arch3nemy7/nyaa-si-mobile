import 'package:dio/dio.dart';
import '../../exceptions/dio_exception.dart';

import 'api_config.dart';
import 'api_interceptor.dart';

class DioClient {
  DioClient({
    required Dio dio,
    required this.apiConfig,
  }) : _dio = dio,
       apiInterceptor = ApiInterceptor() {
    _setupDio();
  }

  final Dio _dio;
  final ApiConfig apiConfig;
  final ApiInterceptor apiInterceptor;

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: apiConfig.baseUrl,
      connectTimeout: apiConfig.connectTimeout,
      receiveTimeout: apiConfig.receiveTimeout,
      headers: apiConfig.headers,
    );

    _dio.interceptors.clear();
    _dio.interceptors.add(apiInterceptor);
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<Response<dynamic>> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    final String message = error.message ?? 'Unknown error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout: $message');
      case DioExceptionType.badResponse:
        final int? statusCode = error.response?.statusCode;
        // ignore: always_specify_types
        final responseData = error.response?.data;
        String errorMsg = 'Server error';

        if (responseData != null && responseData is Map<String, dynamic>) {
          try {
            errorMsg =
                responseData['message']?.toString() ??
                'Server error message missing';
          } catch (e) {
            errorMsg = 'Failed to parse server error message';
          }
        } else if (responseData != null) {
          errorMsg = responseData.toString();
        }

        return ServerException(
          '$errorMsg (${statusCode ?? 'unknown status'})',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');
      case DioExceptionType.connectionError:
        return NetworkException('Connection error: $message');
      case DioExceptionType.badCertificate:
        return NetworkException('Bad certificate');
      case DioExceptionType.unknown:
        return NetworkException('Unknown error: $message');
    }
  }
}
