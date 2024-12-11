import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';

class HomeState {
  final List<ChatModel> searchResults;
  final List<MessageContent> mediaSuggestions;

  HomeState({
    this.searchResults = const [],
    this.mediaSuggestions = const [],
  });

  HomeState copyWith({
    List<ChatModel>? searchResults,
    List<MessageContent>? mediaSuggestions,
  }) {
    return HomeState(
      searchResults: searchResults ?? this.searchResults,
      mediaSuggestions: mediaSuggestions ?? this.mediaSuggestions,
    );
  }
}
