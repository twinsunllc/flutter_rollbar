import 'package:flutter_rollbar/flutter_rollbar.dart';
import 'package:logging/logging.dart';

class RollbarLogging {
  static var _instance = RollbarLogging._internal();

  factory RollbarLogging() => _instance;
  List<Map> _logs = [];
  List<Map> get logs => _logs;

  RollbarLogging._internal() {
    Logger.root.level = Level.ALL;
  }

  Future initialize() async {
    Logger.root.onRecord.listen((LogRecord rec) {
      var pieces = ['(${rec.time}) · ${rec.loggerName?.isEmpty ?? true ? 'root' : rec.loggerName} · ${rec.level.name.toUpperCase()}: ${rec.message}'];
      if (rec.error != null) pieces.add(rec.error.toString());
      if (rec.stackTrace != null) pieces.add(rec.stackTrace.toString());
      var rollbarLevel = RollbarLogLevel.DEBUG;
      if (rec.level >= Level.SHOUT) {
        rollbarLevel = RollbarLogLevel.CRITICAL;
      } else if (rec.level >= Level.SEVERE) {
        rollbarLevel = RollbarLogLevel.ERROR;
      } else if (rec.level >= Level.CONFIG) {
        // includes Level.INFO
        rollbarLevel = RollbarLogLevel.INFO;
      } else {
        rollbarLevel = RollbarLogLevel.DEBUG;
      }

      Rollbar().addTelemetry(RollbarTelemetry(
        level: rollbarLevel,
        type: rec.error == null ? RollbarTelemetryType.LOG : RollbarTelemetryType.ERROR,
        message: rec.message,
        stack: rec.stackTrace?.toString(),
      ));

      print(pieces.join("\n"));
    });

    return Future.value();
  }
}
