import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plugin_qr_decode/flutter_plugin_qr_decode.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_plugin_qr_decode');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterPluginQrDecode.platformVersion, '42');
  });
}
