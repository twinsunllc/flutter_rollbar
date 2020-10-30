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
}

class RollbarTelemetry {
  final RollbarLogLevel level;
  final RollbarTelemetryType type;
  final String source;
  final int timestamp;
  final String message;
  final String stack;

  RollbarTelemetry(
      {@required this.level,
      @required this.type,
      this.source = 'client',
      int timestamp,
      @required this.message,
      this.stack})
      : this.timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

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

class RollbarPerson {
  final String id, email, username;

  RollbarPerson({@required this.id, this.email, this.username});

  Map toJson() => {
        'id': id,
        'email': email,
        'username': username,
      };
}

abstract class RollbarErrorReport {
  Map<String, dynamic> toJson();
}

class RollbarTraceErrorReport with RollbarErrorReport {
  final StackTrace _stackTrace;
  final Object _error;

  RollbarTraceErrorReport(this._error, this._stackTrace);

  Iterable _stackTraceFrames() {
    if (_stackTrace?.toString()?.isEmpty ?? true) {
      return null;
    }

    RegExp regExp = RegExp(
        r'^\s*(?:#\d+)?\s*(.*?)\s*\((.+?)(?::(\d+)(?::(\d+))?)?\)$',
        multiLine: true);
    Iterable<Match> matches = regExp.allMatches(_stackTrace.toString());
    return matches.map((match) => {
          "method": match.group(1),
          "filename": match.group(2),
          "lineno": int.tryParse(match.group(3)),
          "colno": int.tryParse(match.group(4)),
        });
  }

  Map _exception() {
    String clazz = _error.runtimeType.toString();
    String message = _error.toString();
    if (message.startsWith(clazz)) {
      message = message.substring(clazz.length + 1).trim();
    }
    return {
      "class": clazz,
      "message": message,
    };
  }

  Map<String, dynamic> traceJson() => {
        'exception': {
          ..._exception(),
        },
        'frames': [...?_stackTraceFrames()],
      };

  @override
  Map<String, dynamic> toJson() => {
        'trace': {
          ...traceJson(),
        },
      };
}

class RollbarTraceChainErrorReport with RollbarErrorReport {
  final Iterable<RollbarTraceErrorReport> traceChain;

  RollbarTraceChainErrorReport(this.traceChain);
  @override
  Map<String, dynamic> toJson() => {
        'trace_chain': traceChain.map((trace) => trace.traceJson()),
      };
}

class RollbarMessageReport with RollbarErrorReport {
  final String _message;
  Map<String, dynamic> metadata;
  RollbarMessageReport(this._message, {this.metadata});

  @override
  Map<String, dynamic> toJson() {
    assert(metadata == null || metadata.containsKey('body') == false);
    metadata?.remove('body');

    return {
      'message': {"body": _message, ...?metadata}
    };
  }
}
