import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';

class HomeState {
  final List<ChatModel> searchResults;
  final List<ChatModel> localSearchResultsChats;
  final List<MessageModel> localSearchResultsMessages;
  final List<List<MapEntry<int, int>>> localSearchResultsChatTitleMatches;
  final List<List<MapEntry<int, int>>> localSearchResultsChatMessagesMatches;
  final List<ChatModel> groupsGlobalSearchResults;
  final List<UserModel> usersGlobalSearchResults;
  final List<ChatModel> channelsGlobalSearchResults;
  final List<MessageContent> mediaSuggestions;

  HomeState({
    this.searchResults = const [],
    this.localSearchResultsChats = const [],
    this.localSearchResultsMessages = const [],
    this.localSearchResultsChatTitleMatches = const [],
    this.localSearchResultsChatMessagesMatches = const [],
    this.groupsGlobalSearchResults = const [],
    this.usersGlobalSearchResults = const [],
    this.channelsGlobalSearchResults = const [],
    this.mediaSuggestions = const [],
  });

  HomeState copyWith({
    List<ChatModel>? searchResults,
    List<ChatModel>? localSearchResultsChats,
    List<MessageModel>? localSearchResultsMessages,
    List<List<MapEntry<int, int>>>? localSearchResultsChatTitleMatches,
    List<List<MapEntry<int, int>>>? localSearchResultsChatMessagesMatches,
    List<ChatModel>? groupsGlobalSearchResults,
    List<UserModel>? usersGlobalSearchResults,
    List<ChatModel>? channelsGlobalSearchResults,
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
      groupsGlobalSearchResults:
          groupsGlobalSearchResults ?? this.groupsGlobalSearchResults,
      usersGlobalSearchResults:
          usersGlobalSearchResults ?? this.usersGlobalSearchResults,
      channelsGlobalSearchResults:
          channelsGlobalSearchResults ?? this.channelsGlobalSearchResults,
      mediaSuggestions: mediaSuggestions ?? this.mediaSuggestions,
    );
  }
}
