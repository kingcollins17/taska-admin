import 'dart:developer' as dev;

class ErrorHandler {
  static void handle(dynamic error, [StackTrace? trace]) {
    if (error is Exception) {
      dev.log('Exception occurred: $error', stackTrace: trace);
    } else if (error is Error) {
      dev.log('Error occurred: $error', stackTrace: trace ?? error.stackTrace);
    } else {
      dev.log('Unknown error: $error', stackTrace: trace);
    }
  }
}