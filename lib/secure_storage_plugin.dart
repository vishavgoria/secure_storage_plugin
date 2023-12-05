
import 'dart:async';
import 'package:flutter/services.dart';
import 'AESUtils.dart';

class SecureStoragePlugin {
  static const MethodChannel _channel = MethodChannel('secure_storage');

  static Future<void> save(String key, String value, String secretKey) async {
    /*if we want to use Dart implementation of encryption we can use this method*/
    //final encryptedValue = AESUtils.encrypt(value, secretKey);

    /*Here we are using Native Encryption method to encrypt and save*/
    await _channel.invokeMethod('save', {'key': key, 'value': value, 'secret_key_alias':secretKey});
  }

  static Future<String?> read(String key, String secretKey) async {
    /*Here we are using Native Decryption method to read and decrypt*/
    final result = await _channel.invokeMethod('read', {'key': key,'secret_key_alias':secretKey});

    if (result != null) {

      /*if we want to use Dart implementation of decryption we can use this method and return*/
      //return AESUtils.decrypt(result, secretKey);

      return result;
    }
    return null;
  }
}
