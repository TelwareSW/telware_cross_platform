import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/stories/utils/utils_functions.dart';

import '../constants/server_constants.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 1)
enum ChatType {
  @HiveField(0)
  oneToOne,
  @HiveField(1)
  group,
  @HiveField(2)
  channel,
}

@HiveType(typeId: 0)
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
    this.draft,
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
        other.draft == draft;
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
    draft.hashCode;
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
        'isPhotoBytesSet: ${photoBytes != null}\n'
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
    String? draft,
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
      draft: draft ?? this.draft,
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
      'draft': draft,
    };
  }

  static Future<ChatModel> fromMap(Map<String, dynamic> map) async {
    final chat = ChatModel(
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
    );
    await chat._setPhotoBytes();
    return chat;
  }

  String toJson() => json.encode(toMap());
}
