import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/stories/utils/utils_functions.dart';

import '../constants/server_constants.dart';

part 'message_model.g.dart';

enum MessageState {
  sent,
  read,
}

@HiveType(typeId: 6)
class MessageModel {
  @HiveField(0)
  final String senderName;
  @HiveField(1)
  final String? content;
  @HiveField(2)
  final DateTime timestamp;
  @HiveField(3)
  final Duration? autoDeleteDuration;
  @HiveField(4)
  String? id;
  @HiveField(5)
  final String? photo;
  @HiveField(6)
  Uint8List? photoBytes;
  @HiveField(7)
  final Map<String, MessageState> userStates;

  MessageModel({
    required this.senderName,
    this.content,
    required this.timestamp,
    this.autoDeleteDuration,
    this.id,
    this.photo,
    this.photoBytes,
    Map<String, MessageState>? userStates,
  }) : userStates = userStates ?? {};

  Future<void> _setPhotoBytes() async {
    if (photo == null || photo!.isEmpty) return;

    String url = photo!.startsWith('http')
        ? photo!
        : '$API_URL_PICTURES/$photo';

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

    return other.senderName == senderName &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.id == id &&
        other.photo == photo &&
        other.photoBytes == photoBytes &&
        other.userStates == userStates;
  }

  @override
  int get hashCode {
    return senderName.hashCode ^
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
        'senderName: $senderName,\n'
        'content: $content,\n'
        'timestamp: $timestamp,\n'
        'autoDeleteDuration: $autoDeleteDuration,\n'
        'id: $id,\n'
        'photo: $photo,\n'
        'userStates: $userStates,\n'
        'isPhotoBytesSet: ${photoBytes != null}\n'
        ')');
  }

  MessageModel copyWith({
    String? senderName,
    String? content,
    DateTime? timestamp,
    Duration? autoDeleteDuration,
    String? id,
    String? photo,
    Uint8List? photoBytes,
    Map<String, MessageState>? userStates,
  }) {
    return MessageModel(
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      autoDeleteDuration: autoDeleteDuration ?? this.autoDeleteDuration,
      id: id ?? this.id,
      photo: photo ?? this.photo,
      photoBytes: photoBytes ?? this.photoBytes,
      userStates: userStates ?? Map.from(this.userStates),
    );
  }

  Map<String, dynamic> toMap({bool forSender = false}) {
    final map = <String, dynamic>{
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'autoDeleteDuration': autoDeleteDuration?.inSeconds,
      'id': id,
      'photo': photo,
      'userStates': forSender
          ? userStates.map((key, value) => MapEntry(key, value.toString().split('.').last))
          : null,
    };

    return map;
  }

  static Future<MessageModel> fromMap(Map<String, dynamic> map) async {
    final message = MessageModel(
      senderName: map['senderName'] as String,
      content: map['content'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      autoDeleteDuration: map['autoDeleteDuration'] != null
          ? Duration(seconds: map['autoDeleteDuration'] as int)
          : null,
      id: map['id'] as String?,
      photo: map['photo'] as String?,
      userStates: (map['userStates'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          key,
          MessageState.values.firstWhere(
                (e) => e.toString().split('.').last == value,
            orElse: () => MessageState.sent,
          ),
        ),
      ),
    );
    await message._setPhotoBytes();
    return message;
  }

  String toJson({bool forSender = false}) => json.encode(toMap(forSender: forSender));
}
