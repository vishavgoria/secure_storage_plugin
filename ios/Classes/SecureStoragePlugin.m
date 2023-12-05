#import "SecureStoragePlugin.h"
#import <Flutter/Flutter.h>
#import "FlutterSecureStoragePlugin.h"

@implementation SecureStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"secure_storage"
            binaryMessenger:[registrar messenger]];
  SecureStoragePlugin* instance = [[SecureStoragePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"save" isEqualToString:call.method]) {
    [self save:call result:result];
  } else if ([@"read" isEqualToString:call.method]) {
    [self read:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)save:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *key = call.arguments[@"key"];
    NSString *value = call.arguments[@"value"];
    NSString *secretKeyAliasR = call.arguments[@"secret_key_alias"];

    if (key != nil && value != nil) {
        // Encrypt the value using AES encryption
        NSString *encryptedValue = [self encrypt:value secretKeyAlias:secretKeyAliasR];

        // Save the encrypted value in secure storage
        FlutterSecureStoragePlugin *secureStorage = [FlutterSecureStoragePlugin new];
        [secureStorage setString:encryptedValue forKey:key];

        result(nil);
    } else {
        result([FlutterError errorWithCode:@"InvalidArguments"
                                   message:@"Key or value is null"
                                   details:nil]);
    }
}

- (void)read:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *key = call.arguments[@"key"];
    NSString *secretKeyAliasR = call.arguments[@"secret_key_alias"];

    if (key != nil) {
        // Retrieve the encrypted value from secure storage
        FlutterSecureStoragePlugin *secureStorage = [FlutterSecureStoragePlugin new];
        NSString *encryptedValue = [secureStorage stringForKey:key];

        // Decrypt the value using AES decryption
        NSString *decryptedValue = [self decrypt:encryptedValue];

        result(decryptedValue);
    } else {
        result([FlutterError errorWithCode:@"InvalidArguments"
                                   message:@"Key is null"
                                   details:nil]);
    }
}


- (NSString *)encrypt:(NSString *)value secretKeyAlias:(NSString *)secretKeyAlias {

    NSString *key = @"your_secret_key";
    NSString *iv = @"your_initialization_vector";

    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [secretKeyAlias dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];


    NSMutableData *encryptedData = [NSMutableData dataWithLength:[valueData length] + kCCBlockSizeAES128];
    size_t encryptedLength = 0;

    CCCryptorStatus result = CCCrypt(
        kCCEncrypt,
        kCCAlgorithmAES,
        kCCOptionPKCS7Padding,
        keyData.bytes,
        kCCKeySizeAES256,
        ivData.bytes,
        valueData.bytes,
        valueData.length,
        encryptedData.mutableBytes,
        encryptedData.length,
        &encryptedLength
    );

    if (result == kCCSuccess) {
        encryptedData.length = encryptedLength;
        return [encryptedData base64EncodedStringWithOptions:0];
    } else {
        // Handle encryption failure
        return nil;
    }
}

- (NSString *)decrypt:(NSString *)encryptedValue secretKeyAlias:(NSString *)secretKeyAlias{

    NSString *key = @"your_secret_key";
    NSString *iv = @"your_initialization_vector";

    NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:encryptedValue options:0];
    NSData *keyData = [secretKeyAlias dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *decryptedData = [NSMutableData dataWithLength:[encryptedData length] + kCCBlockSizeAES128];
    size_t decryptedLength = 0;

    CCCryptorStatus result = CCCrypt(
        kCCDecrypt,
        kCCAlgorithmAES,
        kCCOptionPKCS7Padding,
        keyData.bytes,
        kCCKeySizeAES256,
        ivData.bytes,
        encryptedData.bytes,
        encryptedData.length,
        decryptedData.mutableBytes,
        decryptedData.length,
        &decryptedLength
    );

    if (result == kCCSuccess) {
        decryptedData.length = decryptedLength;
        return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    } else {
        // Handle decryption failure
        return nil;
    }
}


@end
