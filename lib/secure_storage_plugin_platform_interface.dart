import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'secure_storage_plugin_method_channel.dart';

abstract class SecureStoragePluginPlatform extends PlatformInterface {
  /// Constructs a SecureStoragePluginPlatform.
  SecureStoragePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SecureStoragePluginPlatform _instance = MethodChannelSecureStoragePlugin();

  /// The default instance of [SecureStoragePluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelSecureStoragePlugin].
  static SecureStoragePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SecureStoragePluginPlatform] when
  /// they register themselves.
  static set instance(SecureStoragePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
