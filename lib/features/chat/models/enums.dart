enum EventType {
  sendMessage(event: 'SEND_MESSAGE'),
  sendAnnouncement(event: 'SEND_ANNOUNCEMENT'),
  editMessage(event: 'EDIT_MESSAGE'),
  deleteMessage(event: 'DELETE_MESSAGE'),
  replyOnMessage(event: 'REPLY_MESSAGE'),
  forwardMessage(event: 'FORWARD_MESSAGE'),
  readChat(event: 'READ_CHAT'),
  //////////////////////////////
  receiveMessage(event: 'RECEIVE_MESSAGE'),
  receiveReply(event: 'RECEIVE_REPLY'),
  receiveDraft(event: 'RECEIVE_DRAFT'),
  ;

  final String event;

  const EventType({required this.event});
}

enum DeleteMsgType {
  sendMessage(name: 'only-me'),
  sendAnnouncement(name: 'all')
  ;

  final String name;

  const DeleteMsgType({required this.name});
}