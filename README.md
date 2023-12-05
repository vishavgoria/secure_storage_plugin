# secure_storage_plugin

Secure Plugin.

## Getting Started

# Secure Storage Plugin for Flutter

This Flutter plugin provides a secure solution for encrypting and storing sensitive information in your mobile applications. It includes methods for saving and retrieving data using Dart code for encryption and platform channels for enhanced security.

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/vishavgoria/secure_storage_plugin.git

1.1 place the plugin in the flutter project to use
    my_flutter_project/
    |-- lib/
    |-- secure_storage_plugin/
    |   |-- lib/
    |       |-- secure_storage_plugin.dart
    |-- pubspec.yaml


1.2 Integrate into Your Flutter Project:
     dependencies:
      secure_storage_plugin:
        path: ./secure_storage_plugin


2. OR USING GIT REPOSITORY
 You can use direct git repository to integrate plugin in your flutter project by adding dependency in pubsec.yaml file

  dependencies:
    secure_storage_plugin:
      git:
        url: git://github.com/yourusername/secure_storage_plugin.git

3.  Usage
    Import the Plugin

    import 'package:secure_storage_plugin/secure_storage_plugin.dart';

4. Create an Instance
   SecureStoragePlugin secureStorage = SecureStoragePlugin();

5. Save Sensitive Data
   Using Dart Code (AESUtil)
   secureStorage.ssave(String key, String value, String secretKey)

   If you wnat to utilize Dart implementation of encryption you can use this method calling below.
     final encryptedValue = AESUtils.encrypt(value, secretKey);

   If you want to use Native implementation of encryption you can use this method calling below.
     await _channel.invokeMethod('save', {'key': key, 'value': value, 'secret_key_alias':secretKey});



6. Same point 5 process will be used for Decryption.

7. In this plugin we have utilized best encrytion AES algorithm for Encryption/Decryption.


      





