import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';

class HomeState {
  final List<ChatModel> searchResults;
  List<ChatModel> localSearchResultsChats;
  List<MessageModel> localSearchResultsMessages;
  List<List<MapEntry<int, int>>> localSearchResultsChatTitleMatches;
  List<List<MapEntry<int, int>>> localSearchResultsChatMessagesMatches;
  final List<ChatModel> globalSearchResults;
  final List<MessageContent> mediaSuggestions;

  HomeState({
    this.searchResults = const [],
    this.localSearchResultsChats = const [],
    this.localSearchResultsMessages = const [],
    this.localSearchResultsChatTitleMatches = const [],
    this.localSearchResultsChatMessagesMatches = const [],
    this.globalSearchResults = const [],
    this.mediaSuggestions = const [],
  });

  HomeState copyWith({
    List<ChatModel>? searchResults,
    List<ChatModel>? localSearchResultsChats,
    List<MessageModel>? localSearchResultsMessages,
    List<List<MapEntry<int, int>>>? localSearchResultsChatTitleMatches,
    List<List<MapEntry<int, int>>>? localSearchResultsChatMessagesMatches,
    List<ChatModel>? globalSearchResults,
    List<MessageContent>? mediaSuggestions,
  }) {
    return HomeState(
      searchResults: searchResults ?? this.searchResults,
      localSearchResultsChats:
          localSearchResultsChats ?? this.localSearchResultsChats,
      localSearchResultsMessages:
          localSearchResultsMessages ?? this.localSearchResultsMessages,
      localSearchResultsChatTitleMatches: localSearchResultsChatTitleMatches ??
          this.localSearchResultsChatTitleMatches,
      localSearchResultsChatMessagesMatches:
          localSearchResultsChatMessagesMatches ??
              this.localSearchResultsChatMessagesMatches,
      globalSearchResults: globalSearchResults ?? this.globalSearchResults,
      mediaSuggestions: mediaSuggestions ?? this.mediaSuggestions,
    );
  }
}
