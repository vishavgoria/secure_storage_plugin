
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class AESUtils {
  static String encrypt(String value, String secretKey) {
    final key = generateKey(secretKey);
    final iv = generateIV();

    final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc, padding: null));
    final encryptedValue = encrypter.encrypt(value, iv: IV.fromUtf8(iv));

    return encryptedValue.base64;
  }

  static String decrypt(String encryptedValue, String secretKey) {
    final key = generateKey(secretKey);
    final iv = generateIV();

    final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc, padding: null));
    final decryptedValue = encrypter.decrypt64(encryptedValue, iv: IV.fromUtf8(iv));

    return decryptedValue;
  }

  static String generateKey(String secretKey) {
    final keyBytes = utf8.encode(secretKey);
    final digest = sha256.convert(keyBytes);
    return digest.toString();
  }

  static String generateIV() {
    // Generate a random IV for each encryption
    final random = Random.secure();
    final iv = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(iv);
  }
}
