import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_rollbar/flutter_rollbar.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RollbarHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        Logger.root.finest(
            '[BadCertificate] $host:$port - cert(subject: ${cert.subject}, issuer: ${cert.issuer}, start: ${cert.startValidity}, end: ${cert.endValidity}, sha1: ${cert.sha1})');
        return false;
      };
  }
}

class RollbarHttpClient implements http.Client {
  final http.Client _client = http.Client();

  Map<String, String> baseHeaders(Map<String, String> headers) {
    return {
      if (_clientHeader?.isNotEmpty ?? false) 'X-Flutter-Client': _clientHeader,
      ...headers ?? {},
    };
  }

  String _clientHeader = '';
  PackageInfo packageInfo;

  RollbarHttpClient() {
    HttpOverrides.global = RollbarHttpOverrides();
    _loadClientHeader();
  }

  _loadClientHeader() async {
    packageInfo = await PackageInfo.fromPlatform();
    _clientHeader = 'Version ${packageInfo.version}+$buildNumber';

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _clientHeader = '$_clientHeader / Android ${androidInfo.version.release} / model: ${androidInfo.model}';
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _clientHeader = '$_clientHeader / iOS ${iosInfo.systemVersion} / model: ${iosInfo.utsname.machine}';
    }
  }

  String get buildNumber {
    int asNumber = int.tryParse(packageInfo.buildNumber);
    if (asNumber == null) return packageInfo.buildNumber;
    return "${asNumber % 1000}";
  }

  @override
  void close() {
    _client.close();
  }

  Future<http.Response> _logRequest(Future<http.Response> requestFuture) {
    var startTime = DateTime.now();
    return requestFuture.then((response) {
      var endTime = DateTime.now();

      Rollbar().addTelemetry(
        RollbarNetworkTelemetry(
          url: response.request.url.toString(),
          method: response.request.method,
          statusCode: response.statusCode,
          startTime: startTime,
          endTime: endTime,
        ),
      );
      print(
          '(${DateTime.now()}) · Network · INFO: ${response.request.method} ${response.request.url} completed with ${response.statusCode} in ${endTime.difference(startTime).inMilliseconds / 1000}s');
      return response;
    });
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String> headers}) {
    return _logRequest(_client.head(url, headers: baseHeaders(headers)));
  }

  @override
  Future<http.Response> get(url, {Map<String, String> headers}) {
    return _logRequest(_client.get(url, headers: baseHeaders(headers)));
  }

  @override
  Future<http.Response> post(Uri url, {Map<String, String> headers, Object body, Encoding encoding}) {
    return _logRequest(_client.post(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<http.Response> put(url, {Map<String, String> headers, Object body, Encoding encoding}) {
    return _logRequest(_client.put(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<http.Response> patch(url, {Map<String, String> headers, Object body, Encoding encoding}) {
    return _logRequest(_client.patch(url, headers: baseHeaders(headers), body: body, encoding: encoding));
  }

  @override
  Future<http.Response> delete(Uri url, {Map<String, String> headers, Object body, Encoding encoding}) {
    return _logRequest(_client.delete(url, headers: baseHeaders(headers)));
  }

  @override
  Future<String> read(url, {Map<String, String> headers}) {
    return _client.read(url, headers: baseHeaders(headers));
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String> headers}) {
    return _client.readBytes(url, headers: baseHeaders(headers));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request);
  }
}
