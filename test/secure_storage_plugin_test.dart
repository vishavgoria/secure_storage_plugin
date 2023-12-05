import 'package:flutter_test/flutter_test.dart';
import 'package:secure_storage_plugin/secure_storage_plugin.dart';
import 'package:secure_storage_plugin/secure_storage_plugin_platform_interface.dart';
import 'package:secure_storage_plugin/secure_storage_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecureStoragePluginPlatform
    with MockPlatformInterfaceMixin
    implements SecureStoragePluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SecureStoragePluginPlatform initialPlatform = SecureStoragePluginPlatform.instance;

  test('$MethodChannelSecureStoragePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSecureStoragePlugin>());
  });

  test('getPlatformVersion', () async {
    SecureStoragePlugin secureStoragePlugin = SecureStoragePlugin();
    MockSecureStoragePluginPlatform fakePlatform = MockSecureStoragePluginPlatform();
    SecureStoragePluginPlatform.instance = fakePlatform;

    expect(await secureStoragePlugin.getPlatformVersion(), '42');
  });
}
