import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/core/models/message_content.dart';
import 'package:telware_cross_platform/features/stories/utils/utils_functions.dart';

import '../constants/server_constants.dart';

part 'message_model.g.dart';


enum MessageState {
  sent,
  read,
}

enum MessageType {
  text,
  audio,
  image,
  video,
  file,
}

@HiveType(typeId: 6)
class MessageModel {
  @HiveField(0)
  final String senderId;
  @HiveField(1)
  final MessageType type;
  @HiveField(2)
  final MessageContent? content;
  @HiveField(3)

  final DateTime? autoDeleteTimestamp;
  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final Duration? autoDeleteDuration;
  @HiveField(6)
  String? id;
  @HiveField(7)
  final String? photo;
  @HiveField(8)
  Uint8List? photoBytes;
  @HiveField(9)
  final Map<String, MessageState> userStates;
  @HiveField(10)
  final MessageType messageType;

//<editor-fold desc="Data Methods">
  MessageModel({
    this.autoDeleteTimestamp,
    required this.senderId,
    required this.type,
    this.content,
    required this.timestamp,
    this.id,
    this.photo,
    this.photoBytes,
    required this.userStates,
  });

  Future<void> _setPhotoBytes() async {
    if (photo == null || photo!.isEmpty) return;

    String url =
        photo!.startsWith('http') ? photo! : '$API_URL_PICTURES/$photo';

    if (url.isEmpty) return;

    Uint8List? tempImage;
    try {
      tempImage = await downloadImage(url);
      if (tempImage != null) {
        photoBytes = tempImage;
      }
    } catch (e) {
      photoBytes = null;
    }
  }

  void updateUserState(String userId, MessageState state) {
    userStates[userId] = state;
  }

  bool isReadByAll() {
    return userStates.values.every((state) => state == MessageState.read);
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return other.messageType == messageType &&
        other.senderId == senderId &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.autoDeleteTimestamp == autoDeleteTimestamp &&
        other.id == id &&
        other.photo == photo &&
        other.photoBytes == photoBytes &&
        other.userStates == userStates;
  }

  @override
  int get hashCode {
    return messageType.hashCode ^
        autoDeleteTimestamp.hashCode ^
        senderId.hashCode ^
        content.hashCode ^
        timestamp.hashCode ^
        id.hashCode ^
        photo.hashCode ^
        photoBytes.hashCode ^
        userStates.hashCode;
  }

  @override
  String toString() {
    return ('MessageModel(\n'
        'senderId: $senderId,\n'
        'content: $content,\n'
        'timestamp: $timestamp,\n'
        'autoDeleteTimestamp: $autoDeleteTimestamp,\n'
        'id: $id,\n'
        'photo: $photo,\n'
        'userStates: $userStates,\n'
        'messageType: ${messageType.name},\n'
        'isPhotoBytesSet: ${photoBytes != null}\n'
        ')');
  }

  MessageModel copyWith({
    String? senderId,
    MessageType? type,
    MessageContent? content,
    DateTime? timestamp,
    DateTime? autoDeleteTimestamp,
    String? id,
    String? photo,
    Uint8List? photoBytes,
    Map<String, MessageState>? userStates,
  }) {
    return MessageModel(
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      autoDeleteTimestamp: autoDeleteTimestamp ?? this.autoDeleteTimestamp,
      id: id ?? this.id,
      photo: photo ?? this.photo,
      photoBytes: photoBytes ?? this.photoBytes,
      userStates: userStates ?? Map.from(this.userStates),
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap({bool forSender = false}) {
    final map = <String, dynamic>{
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'autoDeleteTimestamp': autoDeleteTimestamp?.microsecondsSinceEpoch,
      'id': id,
      'photo': photo,
      'userStates': forSender
          ? userStates.map(
              (key, value) => MapEntry(key, value.toString().split('.').last))
          : null,
      'messageType': messageType.name
    };

    return map;
  }

  static Future<MessageModel> fromMap(Map<String, dynamic> map) async {
    final message = MessageModel(
      senderId: map['senderId'] as String,
      content: map['content'] as MessageContent?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      id: map['messageId'] as String?,
      photo: map['photo'] as String?,
      autoDeleteTimestamp: map['autoDeleteTimeStamp'] != null
          ? DateTime.parse(map['autoDeleteTimeStamp'])
          : null,
      userStates: (map['userStates'] as Map<String, dynamic>?)!.map(
        (key, value) => MapEntry(
          key,
          MessageState.values.firstWhere(
            (e) => e.toString().split('.').last == value,
            orElse: () => MessageState.sent,
          ),
        ),
      ),
      type: map['type']! as MessageType,
    );
    await message._setPhotoBytes();
    return message;
  }

  String toJson({bool forSender = false}) =>
      json.encode(toMap(forSender: forSender));
}
