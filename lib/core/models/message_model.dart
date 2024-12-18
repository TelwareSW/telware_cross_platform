import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';

import 'package:telware_cross_platform/features/chat/classes/message_content.dart';

part 'message_model.g.dart';

@HiveType(typeId: 6)
class MessageModel {
  @HiveField(0)
  final String senderId;
  @HiveField(1)
  final MessageType messageType;
  @HiveField(2)
  final MessageContentType messageContentType;
  @HiveField(3)
  final MessageContent? content;
  @HiveField(4)
  final DateTime? autoDeleteTimestamp;
  @HiveField(5)
  final DateTime timestamp;
  @HiveField(6)
  String? id;
  @HiveField(7)
  final Map<String, MessageState> userStates; // userID -> state of the message
  @HiveField(8)
  final bool isPinned;
  @HiveField(9)
  final String? parentMessage;
  @HiveField(10)
  final String localId;
  @HiveField(11)
  final bool isForward;
  @HiveField(12)
  final bool isAnnouncement;
  @HiveField(13)
  List<String> threadMessages;
  @HiveField(14)
  final bool isEdited;

//<editor-fold desc="Data Methods">
  MessageModel({
    this.autoDeleteTimestamp,
    required this.senderId,
    required this.messageType,
    required this.messageContentType,
    this.content,
    required this.timestamp,
    this.id,
    required this.userStates,
    this.parentMessage,
    this.localId = '',
    this.isPinned = false,
    this.isEdited = false,
    this.isForward = false,
    this.isAnnouncement = false,
    List<String>? threadMessages,
  }) : threadMessages = threadMessages ?? [];

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
        other.messageContentType == messageContentType &&
        other.parentMessage == parentMessage &&
        other.senderId == senderId &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.autoDeleteTimestamp == autoDeleteTimestamp &&
        other.id == id &&
        other.threadMessages == threadMessages &&
        other.isAnnouncement == isAnnouncement &&
        other.localId == localId &&
        other.isForward == isForward &&
        other.isEdited == isEdited &&
        other.userStates == userStates;
  }

  @override
  int get hashCode {
    return messageType.hashCode ^
        messageContentType.hashCode ^
        autoDeleteTimestamp.hashCode ^
        senderId.hashCode ^
        content.hashCode ^
        timestamp.hashCode ^
        id.hashCode ^
        isAnnouncement.hashCode ^
        parentMessage.hashCode ^
        isEdited.hashCode ^
        threadMessages.hashCode ^
        isForward.hashCode ^
        localId.hashCode ^
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
        'userStates: $userStates,\n'
        'messageType: ${messageType.name},\n'
        'messageContentType: ${messageContentType.name},\n'
        'localId: $localId\n'
        'isAnnouncement: $isAnnouncement\n'
        'isForward: $isForward\n'
        'isPinned: $isPinned\n'
        'isEdited: $isEdited\n'
        'threadMessages: $threadMessages'
        'parentMessage: $parentMessage'
        ')');
  }

  MessageModel copyWith({
    String? senderId,
    MessageContent? content,
    DateTime? timestamp,
    DateTime? autoDeleteTimestamp,
    String? id,
    String? photo,
    Uint8List? photoBytes,
    Map<String, MessageState>? userStates,
    MessageType? messageType,
    MessageContentType? messageContentType,
    String? localId,
    bool? isForward,
    bool? isPinned,
    bool? isAnnouncement,
    bool? isEdited,
    String? parentMessage,
    List<String>? threadMessages,
  }) {
    return MessageModel(
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      autoDeleteTimestamp: autoDeleteTimestamp ?? this.autoDeleteTimestamp,
      id: id ?? this.id,
      userStates: userStates ?? Map.from(this.userStates),
      messageType: messageType ?? this.messageType,
      messageContentType: messageContentType ?? this.messageContentType,
      localId: localId ?? this.localId,
      isForward: isForward ?? this.isForward,
      isPinned: isPinned ?? this.isPinned,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      threadMessages: threadMessages ?? this.threadMessages,
      parentMessage: parentMessage ?? this.parentMessage,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  Map<String, dynamic> toMap({bool forSender = false}) {
    final map = <String, dynamic>{
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'autoDeleteTimestamp': autoDeleteTimestamp?.microsecondsSinceEpoch,
      'id': id,
      'userStates': forSender
          ? userStates.map(
              (key, value) => MapEntry(key, value.toString().split('.').last))
          : null,
      'messageType': messageType.name,
      'messageContentType': messageContentType.name,
      'localId': localId,
      'isForward': isForward,
      'isPinned': isPinned,
      'isEdited': isEdited,
      'isAnnouncement': isAnnouncement,
      'threadMessages': threadMessages,
      'parentMessage': parentMessage,
    };

    return map;
  }

  static Future<MessageModel> fromMap(Map<String, dynamic> map) async {
    return MessageModel(
        senderId: map['senderId'] as String,
        content: map['content'] as MessageContent?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        id: map['messageId'] as String?,
        messageType: MessageType.getType(map['messageType']),
        messageContentType:
            MessageContentType.getType(map['messageContentType']),
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
        isForward: map['isForward'] ?? false,
        isPinned: map['isPinned'] ?? false,
        isAnnouncement: map['isAnnouncement'] ?? false,
        isEdited: map['isEdited'] ?? false,
        parentMessage: map['parentMessageId'] ?? '');
  }

  String toJson({bool forSender = false}) =>
      json.encode(toMap(forSender: forSender));
}