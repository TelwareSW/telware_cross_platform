import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/features/chat/models/emitted_event_models.dart';

class ChatLocalRepository {
  final Box<List<ChatModel>> _chatsBox;
  final Box<List<EmittedEvent>> _eventsBox;

  static const String _eventsBoxKey = 'eventsQueue';
  static const String _chatsBoxKey = 'eventsQueue';

  ChatLocalRepository({
    required Box<List<ChatModel>> chatsBox,
    required Box<List<EmittedEvent>> eventsBox,
  })  : _chatsBox = chatsBox,
        _eventsBox = eventsBox;

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

  // sets event queue
  Future<bool> setEventQueue(Queue<EmittedEvent> queue) async {
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
  Queue<EmittedEvent> getEventQueue() {
    final list = _eventsBox.get(_eventsBoxKey, defaultValue: []);
    final queue = Queue<EmittedEvent>.from(list ?? []);
    return queue;
  }
}
