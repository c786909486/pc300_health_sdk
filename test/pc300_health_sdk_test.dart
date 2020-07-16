import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc300_health_sdk/health_device_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('pc300_health_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await HealthDataSdk.platformVersion, '42');
  });
}
