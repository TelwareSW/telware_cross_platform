import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

import 'package:telware_cross_platform/core/models/user_model.dart';

import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';

class ChatLocalRepository {
  final Box<List> _chatsBox;
  final Box<List> _eventsBox;
  final Box<Map> _otherUsersBox;

  static const String _eventsBoxKey = 'eventsQueue';
  static const String _chatsBoxKey = 'chatsList';
  static const String _otherUsersBoxKey = 'otherUsers';

  ChatLocalRepository({
    required Box<List> chatsBox,
    required Box<List> eventsBox,
    required Box<Map> otherUsersBox,
  })  : _chatsBox = chatsBox,
        _eventsBox = eventsBox,
        _otherUsersBox = otherUsersBox;

  /////////////////////////////////////
  // set chats
  Future<bool> setChats(List<ChatModel> list) async {
    debugPrint('!!! set chats locally called');
    try {
      await _chatsBox.put(_chatsBoxKey, list);
      return true;
    } catch (e) {
      debugPrint('!!! exception on saving the chats list');
      debugPrint(e.toString());
      return false;
    }
  }

  // get chats
  List<ChatModel> getChats() {
    final list = _chatsBox.get(_chatsBoxKey, defaultValue: []);
    final chats =
        list?.map((element) => element as ChatModel).toList() ?? <ChatModel>[];
    return chats;
  }

  /////////////////////////////////////
  // get other users
  Future<bool> setOtherUsers(Map<String, UserModel> otherUsers) async {
    try {
      await _otherUsersBox.put(_otherUsersBoxKey, otherUsers);
      return true;
    } catch (e) {
      debugPrint('!!! exception on saving the other users list');
      debugPrint(e.toString());
      return false;
    }
  }

  Map<String, UserModel> getOtherUsers() {
    final map = _otherUsersBox
        .get(_otherUsersBoxKey, defaultValue: <String, UserModel>{});
    final otherUsersMap =
        map?.map((key, value) => MapEntry(key as String, value as UserModel)) ??
            <String, UserModel>{};

    return otherUsersMap;
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
    final eventsList =
        list?.map((element) => element as MessageEvent).toList() ?? <MessageEvent>[];
    final queue = Queue<MessageEvent>.from(eventsList);
    return queue;
  }
}
