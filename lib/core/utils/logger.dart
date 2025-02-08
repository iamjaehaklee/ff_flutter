import 'package:flutter/foundation.dart';

/// A utility class for consistent logging across the application
class Logger {
  static const String _tag = '[FactFinder]';
  
  /// Log debug message
  static void d(String message, [String? tag]) {
    if (kDebugMode) {
      print('${tag ?? _tag} 🔵 $message');
    }
  }

  /// Log info message
  static void i(String message, [String? tag]) {
    if (kDebugMode) {
      print('${tag ?? _tag} ℹ️ $message');
    }
  }

  /// Log success message
  static void s(String message, [String? tag]) {
    if (kDebugMode) {
      print('${tag ?? _tag} ✅ $message');
    }
  }

  /// Log warning message
  static void w(String message, [String? tag]) {
    if (kDebugMode) {
      print('${tag ?? _tag} ⚠️ $message');
    }
  }

  /// Log error message
  static void e(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('${tag ?? _tag} 🔴 $message');
      if (error != null) {
        print('${tag ?? _tag} Error: $error');
      }
      if (stackTrace != null) {
        print('${tag ?? _tag} Stack trace:\n$stackTrace');
      }
    }
  }
}