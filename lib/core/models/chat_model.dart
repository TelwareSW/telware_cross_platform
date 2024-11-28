import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/stories/utils/utils_functions.dart';

import '../constants/server_constants.dart';
import 'message_model.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 5)
enum ChatType {
  @HiveField(0)
  oneToOne,
  @HiveField(1)
  group,
  @HiveField(2)
  channel,
}

@HiveType(typeId: 4)
class ChatModel {
  @HiveField(14)
  final String chatID;
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
  final List<MessageModel> messages;

  ChatModel({
    required this.chatID,
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
        other.chatID == chatID &&
        other.userIds == userIds &&
        other.type == type &&
        other.photo == photo &&
        other.id == id &&
        other.admins == admins &&
        other.description == description &&
        other.lastMessageTimestamp == lastMessageTimestamp &&
        other.isArchived == isArchived &&
        other.isMuted == isMuted &&
        other.draft == draft &&
        other.isMentioned == isMentioned &&
        other.messages == messages; // Compare the messages list
  }

  @override
  int get hashCode {
    return title.hashCode ^
    chatID.hashCode ^
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
        'chatID: $chatID,\n'
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
    String? chatID,
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
    String? draft,
    bool? isMentioned,
    List<MessageModel>? messages, // Add this for message copy
  }) {
    return ChatModel(
      chatID: chatID ?? this.chatID,
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
      draft: draft ?? this.draft,
      isMentioned: isMentioned ?? this.isMentioned,
      messages: messages ?? this.messages, // Handle messages copy
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatID': chatID,
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
      'draft': draft,
      'isMentioned': isMentioned,
      'messages': messages.map((message) => message.toMap()).toList(), // Convert messages to Map
    };
  }

  static Future<ChatModel> fromMap(Map<String, dynamic> map) async {
    final chat = ChatModel(
      chatID: map['chatID'] as String,
      title: map['title'] as String,
      userIds: (map['userIds'] as List<dynamic>).cast<String>(),
      type: ChatType.values.firstWhere(
            (e) => e.toString().split('.').last == map['type'],
        orElse: () => ChatType.oneToOne,
      ),
      photo: map['photo'] as String?,
      id: map['id'] as String?,
      admins: (map['admins'] as List<dynamic>?)?.cast<String>(),
      description: map['description'] as String?,
      lastMessageTimestamp: map['lastMessageTimestamp'] != null
          ? DateTime.parse(map['lastMessageTimestamp'] as String)
          : null,
      isArchived: map['isArchived'] as bool? ?? false,
      isMuted: map['isMuted'] as bool? ?? false,
      draft: map['draft'] as String?,
      isMentioned: map['isMentioned'] as bool? ?? false,
      messages: await Future.wait(
          (map['messages'] as List<dynamic>)
              .map((msg) async => await MessageModel.fromMap(msg as Map<String, dynamic>))
      ), // Deserialize messages
    );
    await chat._setPhotoBytes();
    return chat;
  }

  String toJson() => json.encode(toMap());
}
