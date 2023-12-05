import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secure_storage_plugin_platform_interface.dart';

/// An implementation of [SecureStoragePluginPlatform] that uses method channels.
class MethodChannelSecureStoragePlugin extends SecureStoragePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_storage');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
