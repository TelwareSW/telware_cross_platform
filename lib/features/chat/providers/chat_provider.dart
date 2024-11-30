import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';

final chatProvider = Provider.family<ChatModel?, String>((ref, chatId) {
  return ref.watch(chatsViewModelProvider.notifier).getChatById(chatId);
});
