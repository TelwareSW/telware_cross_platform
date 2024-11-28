import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';

class ChatLocalRepository {
  final Box<List<ChatModel>> _chatsBox;
  final Box<List<MessageEvent>> _eventsBox;
  final Box<Map<String, UserModel>> _otherUsersBox;

  static const String _eventsBoxKey = 'eventsQueue';
  static const String _chatsBoxKey = 'eventsQueue';
  static const String _otherUsersBoxKey = 'otherUsers';

  ChatLocalRepository({
    required Box<List<ChatModel>> chatsBox,
    required Box<List<MessageEvent>> eventsBox,
    required Box<Map<String, UserModel>> otherUsersBox,
  })  : _chatsBox = chatsBox,
        _eventsBox = eventsBox,
        _otherUsersBox = otherUsersBox;

  /////////////////////////////////////
  // set chats
  Future<bool> setChats(List<ChatModel> list) async {
    try {
      await _chatsBox.put(_chatsBoxKey, list);
      return true;
    } catch (e) {
      debugPrint('!!! exception on saving the chats list');
      return false;
    }
  }

  // get chats
  List<ChatModel> getChats() {
    final list = _chatsBox.get(_chatsBoxKey, defaultValue: []);
    return list ?? [];
  }

  /////////////////////////////////////
  // get other users
  Future<bool> setOtherUsers(Map<String, UserModel> otherUsers) async {
    try {
      await _otherUsersBox.put(_otherUsersBox, otherUsers);
      return true;
    } catch (e) {
      debugPrint('!!! exception on saving the other users list');
      return false;
    }
  }

  Map<String, UserModel> getOtherUsers() {
    return _otherUsersBox
            .get(_otherUsersBoxKey, defaultValue: <String, UserModel>{}) ??
        <String, UserModel>{};
  }

  /////////////////////////////////////
  // sets event queue
  Future<bool> setEventQueue(Queue<MessageEvent> queue) async {
    final list = queue.toList();

    try {
      await _eventsBox.put(_eventsBoxKey, list);
      return true;
    } catch (e) {
      debugPrint('!!! exception at storing the event queue');
      return false;
    }
  }

  // get event queue
  Queue<MessageEvent> getEventQueue() {
    final list = _eventsBox.get(_eventsBoxKey, defaultValue: []);
    final queue = Queue<MessageEvent>.from(list ?? []);
    return queue;
  }
}
