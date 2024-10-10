import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_ohos/flutter_secure_storage_ohos_method_channel.dart';

void main() {
  MethodChannelFlutterSecureStorageOhos platform = MethodChannelFlutterSecureStorageOhos();
  const MethodChannel channel = MethodChannel('flutter_secure_storage_ohos');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
