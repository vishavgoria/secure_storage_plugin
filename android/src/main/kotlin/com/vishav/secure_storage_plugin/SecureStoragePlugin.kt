package com.vishav.secure_storage_plugin

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/** SecureStoragePlugin */
class SecureStoragePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull binding: FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "secure_storage")
    channel.setMethodCallHandler(this)
    context = binding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "save" -> save(call, result)
      "read" -> read(call, result)
      else -> result.notImplemented()
    }
  }

  private fun save(call: MethodCall, result: Result) {
    val key = call.argument<String>("key")
    val value = call.argument<String>("value")
    val secretKeyAlias = call.argument<String>("secret_key_alias")

    if (key != null && value != null) {
      // Encrypt the value using AES encryption
      val encryptedValue = encrypt(value,secretKeyAlias)

      // Save the encrypted value in secure storage
      val secureStorage = FlutterSecureStoragePlugin(context)
      secureStorage.putString(key, encryptedValue)

      result.success(null)
    } else {
      result.error("InvalidArguments", "Key or value is null", null)
    }
  }

  private fun encrypt(value: String, secretKeyAlias: String): String {
    try {
      val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
      val keySpec = KeyGenParameterSpec.Builder(secretKeyAlias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
        .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
        .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
        .build()

      keyGenerator.init(keySpec)
      val secretKey = keyGenerator.generateKey()

      val cipher = Cipher.getInstance("AES/GCM/NoPadding")
      cipher.init(Cipher.ENCRYPT_MODE, secretKey)

      val encryptedBytes = cipher.doFinal(value.toByteArray(Charsets.UTF_8))
      val iv = cipher.iv

      // Combine IV and encrypted data and encode as Base64
      val combined = ByteArray(iv.size + encryptedBytes.size)
      System.arraycopy(iv, 0, combined, 0, iv.size)
      System.arraycopy(encryptedBytes, 0, combined, iv.size, encryptedBytes.size)

      return Base64.encodeToString(combined, Base64.DEFAULT)
    } catch (e: Exception) {
      e.printStackTrace()
      // Handle the exception appropriately
    }
    return ""
  }



  private fun read(call: MethodCall, result: Result) {
    val key = call.argument<String>("key")
    val secretKeyAlias = call.argument<String>("secret_key_alias")

    if (key != null) {
      // Retrieve the encrypted value from secure storage
      val secureStorage = FlutterSecureStoragePlugin(context)
      val encryptedValue = secureStorage.getString(key)

      // Decrypt the value using AES decryption
      val decryptedValue = decrypt(encryptedValue,secretKeyAlias)

      result.success(decryptedValue)
    } else {
      result.error("InvalidArguments", "Key is null", null)
    }
  }

  private fun decrypt(encryptedValue: String, secretKeyAlias:String): String {
    try {
      val keyStore = KeyStore.getInstance("AndroidKeyStore")
      keyStore.load(null)

      val secretKey = keyStore.getKey(secretKeyAlias, null) as SecretKey

      val combined = Base64.decode(encryptedValue, Base64.DEFAULT)

      val cipher = Cipher.getInstance("AES/GCM/NoPadding")
      val ivSize = 12 // GCM nonce size is 12 bytes
      val iv = combined.copyOfRange(0, ivSize)
      val encryptedBytes = combined.copyOfRange(ivSize, combined.size)

      val spec = GCMParameterSpec(128, iv)
      cipher.init(Cipher.DECRYPT_MODE, secretKey, spec)

      val decryptedBytes = cipher.doFinal(encryptedBytes)
      return String(decryptedBytes, Charsets.UTF_8)
    } catch (e: Exception) {
      e.printStackTrace()
      // Handle the exception appropriately
    }
    return ""
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "secure_storage")
      channel.setMethodCallHandler(SecureStoragePlugin())
    }
  }
}

