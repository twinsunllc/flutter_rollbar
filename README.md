# Flutter Rollbar

## About

Rollbar reporting for flutter

## Usage

### Basic Example

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

Rollbar().publishReport(message: 'A Report');
```

### Error Handling and Logging integration

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rollbar/flutter_rollbar.dart';
import 'package:logging/logging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() async {
    Rollbar()
      ..accessToken = '<post_client_item token>'
      ..environment = 'local'
      ..person = RollbarPerson(id: '3', username: 'A Real Person');
    await RollbarLogging().initialize();
    runApp(MyApp());
  }, (error, stackTrace) {
    Logger('main').severe('Error: $error', error, stackTrace);
    Rollbar().publishReport(message: 'Application Error: $error');
  });

  FlutterError.onError = (FlutterErrorDetails details) {
    if (const bool.fromEnvironment('dart.vm.product')) {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };
}
```

`RollbarHttpClient` is a drop-in replacement for the `Client` from `http` that will add network telemetry and logging.
