import 'package:flutter/foundation.dart';

void logAuthDebug(
  String context,
  Object error, [
  StackTrace? stackTrace,
]) {
  if (!kDebugMode) {
    return;
  }

  debugPrint('[Playce Auth] $context');
  debugPrint('[Playce Auth] error: $error');
  if (stackTrace != null) {
    debugPrint('[Playce Auth] stackTrace:\n$stackTrace');
  }
}

void logAuthDebugMessage(String message) {
  if (!kDebugMode) {
    return;
  }

  debugPrint('[Playce Auth] $message');
}
