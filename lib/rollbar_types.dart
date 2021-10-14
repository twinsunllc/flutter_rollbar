import 'package:meta/meta.dart';

class RollbarLogLevel {
  final String name;

  const RollbarLogLevel(this.name);

  @override
  String toString() => name;

  static const RollbarLogLevel CRITICAL = RollbarLogLevel('critical');
  static const RollbarLogLevel ERROR = RollbarLogLevel('error');
  static const RollbarLogLevel WARNING = RollbarLogLevel('warning');
  static const RollbarLogLevel INFO = RollbarLogLevel('info');
  static const RollbarLogLevel DEBUG = RollbarLogLevel('debug');
}

class RollbarTelemetryType {
  final String name;

  const RollbarTelemetryType(this.name);

  @override
  String toString() => name;

  static const RollbarTelemetryType LOG = RollbarTelemetryType('log');
  static const RollbarTelemetryType ERROR = RollbarTelemetryType('error');
  static const RollbarTelemetryType NETWORK = RollbarTelemetryType('network');
}

class RollbarTelemetry {
  final RollbarLogLevel level;
  final RollbarTelemetryType type;
  final String source;
  final int timestamp;
  final String message;
  final String stack;

  RollbarTelemetry({
    @required this.level,
    @required this.type,
    this.source = 'client',
    int timestamp,
    @required this.message,
    this.stack,
  }) : this.timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map toJson() => {
        'level': level.name,
        'type': type.name,
        'source': source,
        'timestamp_ms': timestamp,
        'body': {
          'message': message,
          'stack': stack,
        },
      };
}

class RollbarNetworkTelemetry extends RollbarTelemetry {
  RollbarNetworkTelemetry({
    @required this.url,
    @required this.method,
    @required this.statusCode,
    @required this.startTime,
    @required this.endTime,
  }) : super(level: RollbarLogLevel.INFO, type: RollbarTelemetryType.NETWORK, message: '');

  final String url;
  final String method;
  final int statusCode;
  final DateTime startTime;
  final DateTime endTime;

  Map toJson() => {
        'level': level.name,
        'type': type.name,
        'source': source,
        'timestamp_ms': timestamp,
        'body': {
          'url': url,
          'method': method,
          'status_code': statusCode,
          'start_time_ms': startTime.millisecondsSinceEpoch,
          'end_time_ms': endTime.millisecondsSinceEpoch,
        }
      };
}

class RollbarPerson {
  final String id, email, username;

  RollbarPerson({@required this.id, this.email, this.username});

  Map toJson() => {
        'id': id,
        'email': email,
        'username': username,
      };
}
