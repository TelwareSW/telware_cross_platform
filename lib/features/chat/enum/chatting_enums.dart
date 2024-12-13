import 'package:hive/hive.dart';

part 'chatting_enums.g.dart';

enum EventType {
  sendMessage(event: 'SEND_MESSAGE'),
  pinMessageClient(event: 'PIN_MESSAGE_CLIENT'),
  unpinMessageClient(event: 'UNPIN_MESSAGE_CLIENT'),
  pinMessageServer(event: 'PIN_MESSAGE_SERVER'),
  unpinMessageServer(event: 'UNPIN_MESSAGE_SERVER'),
  sendAnnouncement(event: 'SEND_ANNOUNCEMENT'),
  updateDraft(event: 'UPDATE_DRAFT'),
  editMessageClient(event: 'EDIT_MESSAGE_CLIENT'),
  editMessageServer(event: 'EDIT_MESSAGE_SERVER'),
  deleteMessage(event: 'DELETE_MESSAGE'),
  replyOnMessage(event: 'REPLY_MESSAGE'),
  forwardMessage(event: 'FORWARD_MESSAGE'),
  readChat(event: 'READ_CHAT'),
  //////////////////////////////
  receiveMessage(event: 'RECEIVE_MESSAGE'),
  receiveReply(event: 'RECEIVE_REPLY'),

  createGroup(event: 'CREATE_GROUP_CHANNEL'),
  receiveCreateGroup(event: 'JOIN_GROUP_CHANNEL'),

  leaveGroup(event: 'LEAVE_GROUP_CHANNEL_CLIENT'),
  receiveLeaveGroup(event: 'LEAVE_GROUP_CHANNEL_SERVER'),

  deleteGroup(event: 'DELETE_GROUP_CHANNEL_CLIENT'),
  receiveDeleteGroup(event: 'DELETE_GROUP_CHANNEL_SERVER'),

  addMember(event: 'ADD_MEMBERS_CLIENT'),
  receiveAddMember(event: 'ADD_MEMBERS_SERVER'),

  addAdmin(event: 'ADD_ADMINS_CLIENT'),
  receiveAddAdmin(event: 'ADD_ADMIN_SERVER'),

  removeMember(event: 'REMOVE_MEMBERS_CLIENT'),
  receiveRemoveMember(event: 'REMOVE_MEMBERS_SERVER'),

  setPermissions(event: 'SET_PERMISSION_CLIENT'),
  receiveSetPermissions(event: 'SET_PERMISSION_SERVER'),

  ;

  final String event;

  const EventType({required this.event});
}

@HiveType(typeId: 5)
enum ChatType {
  @HiveField(0)
  private(type: 'private'),
  @HiveField(1)
  group(type: 'group'),
  @HiveField(2)
  channel(type: 'channel');

  static ChatType getType(String type) {
    switch (type) {
      case 'group':
        return ChatType.group;
      case 'channel':
        return ChatType.channel;
      default:
        return ChatType.private;
    }
  }

  final String type;
  const ChatType({required this.type});
}