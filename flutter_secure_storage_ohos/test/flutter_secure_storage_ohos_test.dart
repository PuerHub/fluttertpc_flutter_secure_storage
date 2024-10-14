import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_ohos/flutter_secure_storage_ohos.dart';
import 'package:flutter_secure_storage_ohos/flutter_secure_storage_ohos_platform_interface.dart';
import 'package:flutter_secure_storage_ohos/flutter_secure_storage_ohos_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSecureStorageOhosPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSecureStorageOhosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSecureStorageOhosPlatform initialPlatform = FlutterSecureStorageOhosPlatform.instance;

  test('$MethodChannelFlutterSecureStorageOhos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSecureStorageOhos>());
  });

  test('getPlatformVersion', () async {
    FlutterSecureStorageOhos flutterSecureStorageOhosPlugin = FlutterSecureStorageOhos();
    MockFlutterSecureStorageOhosPlatform fakePlatform = MockFlutterSecureStorageOhosPlatform();
    FlutterSecureStorageOhosPlatform.instance = fakePlatform;

    expect(await flutterSecureStorageOhosPlugin.getPlatformVersion(), '42');
  });
}
