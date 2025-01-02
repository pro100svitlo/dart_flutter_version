import 'dart:io';

import 'package:flutter/foundation.dart';

/// A simple logger that logs messages only in debug mode.
const logger = Logger._();

/// A simple logger that logs messages only in debug mode.
///
/// This logger provides methods to log informational and error messages.
/// In test or release builds, all logging is suppressed to ensure
/// optimal performance and security.
class Logger {
  /// Private constructor for implementing the singleton pattern.
  const Logger._();

  /// Logs an informational message.
  ///
  /// [message] The message to log.
  void info(String message) {
    if (_canPrint) {
      print('ℹ️ [INFO] $message');
    }
  }

  /// Logs an error message.
  ///
  /// [message] The message to log.
  void error(String message) {
    if (_canPrint) {
      print('🐞 [ERROR] $message');
    }
  }

  bool get _canPrint {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }

    return kDebugMode;
  }
}
