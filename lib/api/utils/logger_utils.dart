import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

class LoggerUtils {
  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      debugPrint('${rec.loggerName} ${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }
}