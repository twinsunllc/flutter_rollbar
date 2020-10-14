library flutter_rollbar;

import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_rollbar/rollbar_api.dart';
import 'package:flutter_rollbar/rollbar_types.dart';
import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';

export './rollbar_types.dart';
export './rollbar_api.dart';

class Rollbar {
  static var _instance = Rollbar._internal();

  factory Rollbar() => _instance;

  static void reset() {
    _instance?.dispose();
    _instance = Rollbar._internal();
  }

  final _api = RollbarApi();

  List<RollbarTelemetry> _telemetry = [];
  List<RollbarTelemetry> get telemetry => _telemetry;

  RollbarPerson person;
  String environment;
  String accessToken;

  Rollbar._internal();

  void addTelemetry(RollbarTelemetry telemetry) {
    _telemetry.add(telemetry);
  }

  Future publishReport({@required String message, Map<String, dynamic> metadata}) async {
    var packageInfo = await PackageInfo.fromPlatform();

    var clientData = <String, dynamic>{
      'code_version': packageInfo.buildNumber,
      'name_version': packageInfo.version,
      'version_code': packageInfo.buildNumber,
      'version_name': packageInfo.version,
    };

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      clientData['android'] = {
        'phone_model': androidInfo.model,
        'android_version': androidInfo.version.release,
        'code_version': packageInfo.buildNumber,
        'version_code': packageInfo.buildNumber,
        'version_name': packageInfo.version,
        'package_name': packageInfo.packageName,
        'app_name': packageInfo.appName,
      };
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      clientData['ios'] = {
        'ios_version': iosInfo.systemVersion,
        'device_code': iosInfo.utsname.machine,
        'code_version': packageInfo.version,
        'short_version': packageInfo.buildNumber,
        'bundle_identifier': packageInfo.packageName,
        'app_name': packageInfo.appName,
      };
    }

    assert(metadata == null || metadata.containsKey('body') == false);
    metadata?.remove('body');

    return _api.sendReport(accessToken: accessToken, telemetry: telemetry, message: message, clientData: clientData, person: person, environment: environment, metadata: metadata);
  }

  void dispose() {}
}
