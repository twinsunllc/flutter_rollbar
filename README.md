# Flutter Rollbar

## About

Rollbar reporting for flutter

## Usage

```dart
import 'package:flutter_rollbar/flutter_rollbar.dart';

Rollbar()
    ..accessToken = '<post_client_item token>'
    ..environment = 'local'
    ..person = RollbarPerson(id: '3', username: 'A Real Person');

Rollbar().addTelemetry(
    RollbarTelemetry(
        level: RollbarLogLevel.INFO,
        type: RollbarTelemetryType.LOG,
        message: 'Counter: $_counter',
    ),
);
var metaData = {'module': 'flutter-app'};
Rollbar().publishReport(RollbarMessageReport('A Report', metaData));

// or post an Error & StackTrace to Rollbar
Rollbar().publishReport(RollbarTraceErrorReport(error, stackTrace));
```