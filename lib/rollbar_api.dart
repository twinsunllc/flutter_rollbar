import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_rollbar/rollbar_types.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class RollbarApi {
  final http.Client _client = http.Client();
  Future<http.Response> sendReport({@required String accessToken, @required String message, @required List<RollbarTelemetry> telemetry, Map clientData, RollbarPerson person, String environment, Map<String, dynamic> metadata, Map<String, dynamic> additionalFields}) {
    Map<String, dynamic> data = {
      'environment': environment,
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'framework': 'flutter',
      'language': 'dart',
      'body': {
        'message': {
          'body': message,
          ...?metadata
        },
        'telemetry': telemetry.map((item) => item.toJson()).toList(),
      },
      'person': person?.toJson(),
      'client': clientData,
      'notifier': {
        'name': 'flutter_rollbar',
        'version': '0.0.1+1',
      }
    };

    assert(additionalFields == null || data.keys.toSet().intersection(additionalFields.keys.toSet()).isEmpty);
    additionalFields?.removeWhere((key, _) => data.containsKey(key));

    return _client.post(
      'https://api.rollbar.com/api/1/item/',
      body: json.encode({
      'access_token': accessToken,
      'data': {
        ...data,
        ...?additionalFields,
      }
    }),
    );
  }
}
