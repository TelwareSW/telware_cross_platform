import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
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
      })> searchRequest(
    String query,
    List<String> searchSpace,
    String filterType,
    bool isGlobalSearch,
  ) async {
    List<ChatModel> searchResults = [];
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.post(
        '/search-request',
        data: {
          'query': query,
          'searchSpace': searchSpace,
          'filter': {
            'type': filterType,
          },
          'isGlobalSearch': isGlobalSearch
        },
        options: Options(headers: {'X-Session-Token': sessionId}),
      );

      final results = response.data['data']['results'];

      for (final result in results) {
        final chatID = result['id'];
        final chatTitle = result['title'];
        final chatType = result['type'];
        final content = result['content'];

        // TODO: we need from the backend to give us
        // 1 - senderID
        // 2 - messageType
        // 3 - messageContentType
        // 4 - timestamp
        // 5 - userStates
        final MessageModel messageModel = MessageModel(
          content: createMessageContent(
              contentType: MessageContentType.text, text: content),
          senderId: 'unknown',
          messageType: MessageType.normal,
          messageContentType: MessageContentType.text,
          timestamp: DateTime.now(),
          userStates: {},
        );

        // TODO: we need from the backend to give us
        // 1 - photo url for the chat
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

      return (searchResults: searchResults, appError: null);
    } catch (e, stackTrace) {
      debugPrint('!!! error in fetching the search results');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return (
        searchResults: <ChatModel>[],
        appError: AppError('Failed to fetch search results', code: 500),
      );
    }
  }

  Future<List<MessageContent>?> getMediaSuggestion(
    List<String> searchSpace,
  ) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.post(
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
