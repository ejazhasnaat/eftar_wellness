import 'package:flutter/foundation.dart';

typedef LogSink = void Function(String message, {Object? error, StackTrace? stackTrace});

class AppLogger {
  static LogSink sink = _defaultSink;

  static void _defaultSink(String message, {Object? error, StackTrace? stackTrace}) {
    final prefix = error == null ? '[INFO]' : '[ERROR]';
    // ignore: avoid_print
    debugPrint('$prefix $message${error == null ? '' : ' :: $error'}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static void info(String message) => sink(message);
  static void warn(String message) => sink('WARN: $message');
  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      sink(message, error: error, stackTrace: stackTrace);

  /// Allows plugging a different sink, e.g. Sentry:
  /// AppLogger.sink = (msg, {error, stackTrace}) => Sentry.captureMessage(...)
  static void setSink(LogSink newSink) => sink = newSink;
}
