import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';

part 'chats_view_model.g.dart';

@Riverpod(keepAlive: true)
class ChatsViewModel extends _$ChatsViewModel {
  final Map<String, ChatModel> _chatsMap = {};

  @override
  List<ChatModel> build() {
    return [];
  }
}