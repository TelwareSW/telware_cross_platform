import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';

part 'home_remote_repository.g.dart';

@Riverpod(keepAlive: true)
HomeRemoteRepository homeRemoteRepository(HomeRemoteRepositoryRef ref) {
  return HomeRemoteRepository(ref: ref, dio: Dio(CHAT_BASE_OPTIONS));
}

class HomeRemoteRepository {
  final Dio _dio;
  final ProviderRef<HomeRemoteRepository> _ref;

  HomeRemoteRepository({
    required ProviderRef<HomeRemoteRepository> ref,
    required Dio dio,
  })  : _dio = dio,
        _ref = ref;

  Future<String?> _getSessionId() async {
    return _ref.read(tokenProvider);
  }

  Future<
      ({
        AppError? appError,
        List<ChatModel> searchResults,
        List<ChatModel> groupsGlobalSearchResults,
        List<UserModel> usersGlobalSearchResults,
        List<ChatModel> channelsGlobalSearchResults,
      })> searchRequest(
    String query,
    List<String> searchSpace,
    String filterType,
    bool isGlobalSearch,
  ) async {
    List<ChatModel> searchResults = [];
    List<ChatModel> groupsGlobalSearchResults = [];
    List<UserModel> usersGlobalSearchResults = [];
    List<ChatModel> channelsGlobalSearchResults = [];
    try {
      final sessionId = await _getSessionId();
      debugPrint('query: $query');
      debugPrint('searchSpace: ${searchSpace.join(',')}');
      debugPrint('filterType: $filterType');
      debugPrint('isGlobalSearch: $isGlobalSearch');

      final response = await _dio.post(
        '/search/search-request',
        data: {
          'query': query,
          'searchSpace': searchSpace.join(','),
          'filter': filterType == 'music' || filterType == 'voice'
              ? 'audio'
              : filterType,
          'isGlobalSearch': isGlobalSearch
        },
        options: Options(headers: {'X-Session-Token': sessionId}),
      );

      final results = response.data['data']['searchResult'];
      final globalResults = response.data['data']['globalSearchResult'];

      for (final result in results) {
        final chatID = result['chatId']['id'];
        final chatTitle = result['chatId']['name'];
        final chatType = result['chatId']['type'];
        final content = result['content'];
        final contentType = MessageContentType.getType(result['contentType']);
        final numberOfMembers = result['chatId']['numberOfMembers'];

        final messageContent = createMessageContent(
          contentType: contentType,
          text: content,
          fileName: content,
        );
        final threadMessages =
            (result['threadMessages'] as List).map((e) => e as String).toList();
        final MessageModel messageModel = MessageModel(
          content: messageContent,
          senderId: result['senderId'],
          messageType: MessageType.normal,
          messageContentType: contentType,
          timestamp: result['timestamp'] == null
              ? DateTime.parse(result['timestamp'])
              : DateTime.now(),
          isForward: result['isForward'],
          isAnnouncement: result['isAnnouncement'],
          isEdited: result['isEdited'],
          isPinned: result['isPinned'],
          threadMessages: threadMessages,
          userStates: {},
        );

        final chatModel = ChatModel(
          id: chatID,
          title: chatTitle,
          userIds: [],
          type: ChatType.getType(chatType),
          messages: [messageModel],
          photo: null,
        );

        searchResults.add(chatModel);
      }

      final groups = globalResults['groups'];
      final users = globalResults['users'];
      final channels = globalResults['channels'];

      for (final group in groups) {
        final chatModel = ChatModel(
          id: group['id'],
          title: group['name'],
          userIds: [],
          type: ChatType.getType(group['type']),
          messages: [],
          photo: null,
        );
        groupsGlobalSearchResults.add(chatModel);
      }

      for (final channel in channels) {
        final chatModel = ChatModel(
          id: channel['id'],
          title: channel['name'],
          userIds: [],
          type: ChatType.getType(channel['type']),
          messages: [],
          photo: null,
        );
        channelsGlobalSearchResults.add(chatModel);
      }
      //TODO: get email
      for (final user in users) {
        final userModel = UserModel(
          username: user['username'],
          screenFirstName: user['screenFirstName'],
          screenLastName: user['screenLastName'],
          email: '',
          status: user['accountStatus'],
          bio: user['bio'],
          maxFileSize: 0,
          automaticDownloadEnable: false,
          lastSeenPrivacy: '',
          readReceiptsEnablePrivacy: false,
          storiesPrivacy: '',
          picturePrivacy: '',
          invitePermissionsPrivacy: '',
          phone: user['phoneNumber'],
          id: user['id'],
        );

        usersGlobalSearchResults.add(userModel);
      }

      return (
        searchResults: searchResults,
        groupsGlobalSearchResults: groupsGlobalSearchResults,
        usersGlobalSearchResults: usersGlobalSearchResults,
        channelsGlobalSearchResults: channelsGlobalSearchResults,
        appError: null
      );
    } catch (e, stackTrace) {
      debugPrint('!!! error in fetching the search results');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return (
        searchResults: <ChatModel>[],
        groupsGlobalSearchResults: <ChatModel>[],
        usersGlobalSearchResults: <UserModel>[],
        channelsGlobalSearchResults: <ChatModel>[],
        appError: AppError('Failed to fetch search results', code: 500),
      );
    }
  }

  Future<List<MessageContent>?> getMediaSuggestion(
    List<String> searchSpace,
  ) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.get(
        '/media/suggestions',
        data: {
          'searchSpace': searchSpace,
        },
        options: Options(headers: {'X-Session-Token': sessionId}),
      );
      List<MessageContent> media = [];

      final suggestions = response.data['data']['suggestions'];
      for (final suggestion in suggestions) {
        final MessageContent content = createMessageContent(
            contentType: MessageContentType.getType(suggestion['type']),
            mediaUrl: suggestion['url']);
        media.add(content);
      }
      return media;
    } catch (e, stackTrace) {
      debugPrint('Failed to fetch media suggestions: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
