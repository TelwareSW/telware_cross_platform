import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';

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
  Future<bool> setChats(List<ChatModel> list, String userId) async {
    debugPrint('!!! set chats locally called');
    try {
      await _chatsBox.put(_chatsBoxKey+userId, updateMessagesFilePath(list));
      debugPrint('@@@ did put chats use key: ${_chatsBoxKey+userId} and length of: ${list.length}');
      return true;
    } catch (e) {
      debugPrint('!!! exception on saving the chats list');
      debugPrint(e.toString());
      return false;
    }
  }

  // get chats
  List<ChatModel> getChats(String userId) {
    final list = _chatsBox.get(_chatsBoxKey+userId, defaultValue: []);
    debugPrint('@@@ did get chats use key: ${_chatsBoxKey+userId}');
    final chats =
        list?.map((element) => element as ChatModel).toList() ?? <ChatModel>[];
    //set the chats with the updated messages
    setChats(updateMessagesFilePath(chats), userId);
    return chats;
  }

  Future<void> clearChats(String userId) async {
    await _chatsBox.delete(_chatsBoxKey+userId);
  }

  /////////////////////////////////////
  // get other users
  Future<bool> setOtherUsers(Map<String, UserModel> otherUsers, String userId) async {
    try {
      debugPrint("!!! set other users locally called");
      // debugPrint("other users: $otherUsers");
      await _otherUsersBox.put(_otherUsersBoxKey+userId, otherUsers);
      return true;
    } catch (e) {
      debugPrint('!!! exception on saving the other users list');
      debugPrint(e.toString());
      return false;
    }
  }

  Map<String, UserModel> getOtherUsers(String userId) {
    final map = _otherUsersBox
        .get(_otherUsersBoxKey+userId, defaultValue: <String, UserModel>{});
    final otherUsersMap =
        map?.map((key, value) => MapEntry(key as String, value as UserModel)) ??
            <String, UserModel>{};

    return otherUsersMap;
  }

  void clearOtherUsers(String userId) async {
    await _otherUsersBox.delete(_otherUsersBoxKey+userId);
  }

  /////////////////////////////////////
  // sets event queue
  Future<bool> setEventQueue(Queue<MessageEvent> queue, String userId) async {
    final list = queue.toList();

    try {
      await _eventsBox.put(_eventsBoxKey+userId, list);
      debugPrint('%%% stored ${list.length}');
      return true;
    } catch (e) {
      debugPrint('!!! exception at storing the event queue');
      return false;
    }
  }

  // get event queue
  Queue<MessageEvent> getEventQueue(String userId) {
    final list = _eventsBox.get(_eventsBoxKey+userId, defaultValue: []);
    debugPrint('%%% received ${list?.length}');

    final eventsList =
        list?.map((element) => element as MessageEvent).toList() ??
            <MessageEvent>[];
    final queue = Queue<MessageEvent>.from(eventsList);
    return queue;
  }

  Future<void> clearEventQueue(String userId) async {
    await _eventsBox.delete(_eventsBoxKey+userId);
  }
}
