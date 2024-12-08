import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/stories/utils/utils_functions.dart';

import '../constants/server_constants.dart';
import 'message_model.dart';

part 'chat_model.g.dart';


@HiveType(typeId: 4)
class ChatModel {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final List<String> userIds;
  @HiveField(2)
  final String? photo;
  @HiveField(3)
  final ChatType type;
  @HiveField(4)
  Uint8List? photoBytes;
  @HiveField(5)
  String? id;
  @HiveField(6)
  final List<String>? admins;
  @HiveField(7)
  final String? description;
  @HiveField(8)
  final DateTime? lastMessageTimestamp;
  @HiveField(9)
  final bool isArchived;
  @HiveField(10)
  final bool isMuted;
  @HiveField(11)
  final String? draft;
  @HiveField(12)
  final bool isMentioned;
  @HiveField(13)
  List<MessageModel> messages;
  @HiveField(14)
  final DateTime? muteUntil; // Add this field

  ChatModel({
    required this.title,
    required this.userIds,
    this.photo,
    required this.type,
    this.id,
    this.photoBytes,
    this.admins,
    this.description,
    this.lastMessageTimestamp,
    this.isArchived = false,
    this.isMuted = false,
    this.isMentioned = false,
    this.draft,
    required this.messages,
    this.muteUntil, // Initialize this field
  });

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

  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.userIds == userIds &&
        other.type == type &&
        other.photo == photo &&
        other.id == id &&
        other.admins == admins &&
        other.description == description &&
        other.lastMessageTimestamp == lastMessageTimestamp &&
        other.isArchived == isArchived &&
        other.isMuted == isMuted &&
        other.muteUntil == muteUntil &&
        other.draft == draft &&
        other.isMentioned == isMentioned &&
        other.messages == messages;
  }

  @override
  int get hashCode {
    return title.hashCode ^
    userIds.hashCode ^
    type.hashCode ^
    photo.hashCode ^
    id.hashCode ^
    admins.hashCode ^
    description.hashCode ^
    lastMessageTimestamp.hashCode ^
    isArchived.hashCode ^
    isMuted.hashCode ^
    draft.hashCode ^
    isMentioned.hashCode ^
    messages.hashCode; // Include messages in hashCode
  }

  @override
  String toString() {
    return ('ChatModel(\n'
        'title: $title,\n'
        'userIds: $userIds,\n'
        'type: $type,\n'
        'photo: $photo,\n'
        'id: $id,\n'
        'admins: $admins,\n'
        'description: $description,\n'
        'lastMessageTimestamp: $lastMessageTimestamp,\n'
        'isArchived: $isArchived,\n'
        'isMuted: $isMuted,\n'
        'draft: $draft,\n'
        'isMentioned: $isMentioned,\n'
        'messages: $messages,\n' // Add messages to the string representation
        ')');
  }

  ChatModel copyWith({
    String? title,
    List<String>? userIds,
    String? photo,
    ChatType? type,
    String? id,
    Uint8List? photoBytes,
    List<String>? admins,
    String? description,
    DateTime? lastMessageTimestamp,
    bool? isArchived,
    bool? isMuted,
    DateTime? muteUntil, // Add this parameter
    String? draft,
    bool? isMentioned,
    List<MessageModel>? messages,
  }) {
    return ChatModel(
      title: title ?? this.title,
      userIds: userIds ?? this.userIds,
      photo: photo ?? this.photo,
      type: type ?? this.type,
      id: id ?? this.id,
      photoBytes: photoBytes ?? this.photoBytes,
      admins: admins ?? this.admins,
      description: description ?? this.description,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      muteUntil: muteUntil ?? this.muteUntil, // Copy this field
      draft: draft ?? this.draft,
      isMentioned: isMentioned ?? this.isMentioned,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'userIds': userIds,
      'type': type.toString().split('.').last,
      'photo': photo,
      'id': id,
      'admins': admins,
      'description': description,
      'lastMessageTimestamp': lastMessageTimestamp?.toIso8601String(),
      'isArchived': isArchived,
      'isMuted': isMuted,
      'muteUntil': muteUntil?.toIso8601String(), // Add this field
      'draft': draft,
      'isMentioned': isMentioned,
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }


  String toJson() => json.encode(toMap());

  String getChatTypeString() {
    switch (type) {
      case ChatType.private:
        return 'private';
      case ChatType.group:
        return 'group';
      case ChatType.channel:
        return 'channel';
      default:
        return 'unknown';
    }
  }
}
