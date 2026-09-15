import 'package:dio/dio.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:taska_admin/core/env.dart';
import 'package:taska_admin/core/services/local_storage.dart';
import 'package:taska_admin/core/utils/debug_utils.dart';
import 'package:taska_admin/core/utils/error_handler.dart';

class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugLog({
      'type': 'REQUEST',
      'method': options.method,
      'path': options.path,
      'baseUrl': options.baseUrl,
      'headers': options.headers,
      'queryParameters': options.queryParameters,
      'data': options.data,
    }, level: DebugLevel.network);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugLog({
      'type': 'RESPONSE',
      'statusCode': response.statusCode,
      'statusMessage': response.statusMessage,
      'method': response.requestOptions.method,
      'path': response.requestOptions.path,
      'data': response.data,
    }, level: DebugLevel.network);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugLog({
      'type': 'ERROR',
      'statusCode': err.response?.statusCode,
      'error': err.error?.toString(),
      'message': err.message,
      'method': err.requestOptions.method,
      'path': err.requestOptions.path,
      'data': err.response?.data,
    }, level: DebugLevel.network);
    super.onError(err, handler);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = localStorage.getItem('accessToken');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  dio.interceptors.add(DioLoggingInterceptor());

  return dio;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  try {
    final token = localStorage.getItem('accessToken');
    return token != null;
  } catch (e) {
    ErrorHandler.handle(e);
    return false;
  }
});
