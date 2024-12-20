import 'dart:convert';

import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // Private constructor
  EncryptionService._internal();

  // Singleton instance
  static EncryptionService? _instance;

  // Getter for the singleton instance
  static EncryptionService get instance {
    return _instance ??= EncryptionService._internal();
  }

  String encrypt({
    required String msg,
    required String? encryptionKey,
    required String? initializationVector,
    required ChatType chatType,
  }) {
    if (chatType != ChatType.private ||
        encryptionKey == null ||
        initializationVector == null) {
      return msg;
    }

    final key = Key.fromBase16(encryptionKey);
    final iv = IV.fromBase16(initializationVector);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encrypt(msg, iv: iv);

    return encrypted.base16;
  }

  String decrypt({
    required String msg,
    required String? encryptionKey,
    required String? initializationVector,
    required ChatType chatType,
  }) {
    if (chatType != ChatType.private ||
        encryptionKey == null ||
        initializationVector == null) {
      return msg;
    }

    final key = Key.fromBase16(encryptionKey);
    final iv = IV.fromBase16(initializationVector);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final decryptedBytes =
        encrypter.decryptBytes(Encrypted.fromBase16(msg), iv: iv);

    return utf8.decode(decryptedBytes);
  }
}
