
import 'package:dio/dio.dart';
import 'package:taska_admin/core/utils/debug_utils.dart';

class ErrorHandler {
  static void handle(dynamic error, [StackTrace? trace]) {
 
      debugLog('Exception occurred: $error', level: DebugLevel.error);
  
  }
}

Duration? Function(int, Object) retryFunc(int max, {Duration duration = const Duration(seconds: 1)}) {
  return (count, error) {
    if (count > max) return null;
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return duration;
      }
    }
    return null;
  };
}