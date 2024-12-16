import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';

class ChatRemoteRepository {
  final Dio _dio;

  ChatRemoteRepository({required Dio dio}) : _dio = dio;

  Future<
      ({
        AppError? appError,
        List<ChatModel> chats,
        List<UserModel> users,
      })> getUserChats(String sessionId, String userID) async {
    List<ChatModel> chats = [];
    List<UserModel> users = [];

    try {
      final response = await _dio.get(
        '/chats',
        options: Options(headers: {'X-Session-Token': sessionId}),
      );

      final chatData = response.data['data']['chats'] as List? ?? [];
      final memberData = response.data['data']['members'] as List? ?? [];
      final lastMessageData =
          response.data['data']['lastMessages'] as List? ?? [];

      Map<String, UserModel> userMap = {};
      Map<String, MessageModel> lastMessageMap = {};
      for (var member in memberData) {
        userMap[member['id']] = UserModel(
          id: member['id'],
          username: member['username'],
          screenFirstName: member['screenFirstName'],
          screenLastName: member['screenLastName'],
          phone: member['phoneNumber'],
          photo: member['photo'],
          status: member['status'],
          bio: '',
          maxFileSize: 0,
          automaticDownloadEnable: false,
          lastSeenPrivacy: '',
          readReceiptsEnablePrivacy: false,
          storiesPrivacy: '',
          picturePrivacy: '',
          invitePermissionsPrivacy: '',
          photoBytes: null,
          email: '',
        );
      }
      // TODO: should contain is what is the type of the message content
      // I will assume that the response will contain the status of the message for each user of the chat containing this message.
      // They should also return the url of the sticker, gif, emoji
      // They should also send the type of message eg. normal ,forward, etc .
      for (var message in lastMessageData) {
        final lastMessage = message['lastMessage'];
        if (lastMessage is! Map || message['lastMessage'] == null) {
          continue;
        }

        Map<String, MessageState> userStates = {};
        MessageContentType contentType =
            MessageContentType.getType(lastMessage['contentType'] ?? 'text');
        MessageContent? content;

        final Map<String, String> userStatesMap =
            lastMessage['userStates'] ?? {};

        for (var entry in userStatesMap.entries) {
          userStates[entry.key] = MessageState.getType(entry.value);
        }

        // TODO: needs to be modified to match the response fields
        content = createMessageContent(
          contentType: contentType,
          text: lastMessage['content'],
          fileName: lastMessage['fileName'],
          mediaUrl: lastMessage['mediaUrl'],
        );

        // todo(ahmed): add (isForward, isPinned, isAnnouncement, parentMsgId) 
        // the connumicationType attribute is extra
        lastMessageMap[message['chatId']] = MessageModel(
          id: lastMessage['id'],
          senderId: lastMessage['senderId'],
          messageContentType: contentType,
          messageType: MessageType.getType(lastMessage['type'] ?? 'unknown'),
          content: content,
          timestamp: lastMessage['timestamp'] == null
              ? DateTime.parse(lastMessage['timestamp'])
              : DateTime.now(),
          userStates: userStates,
        );
      }

      // Iterate through chats and map users
      for (var chat in chatData) {
        final chatID = chat['chat']['id'];

        // todo(ahmed) make this list only for the normal members
        final members = (chat['chat']['members'] as List)
            .map((member) => member['user'] as String)
            .toList();

        final admins = (chat['chat']['members'] as List)
            .where((member) => member['Role'] == 'admin')
            .map((member) => member['user'] as String)
            .toList();

        final creators = (chat['chat']['members'] as List)
            .where((member) => member['Role'] == 'creator')
            .map((member) => member['user'] as String)
            .toList();

        // Create list of user IDs excluding current user
        final otherUserIDs = members.where((id) => id != userID).toList();
        final otherUsers = otherUserIDs.map((id) => userMap[id]).toList();
        final List<MessageModel> messages =
            lastMessageMap[chatID] == null ? [] : [lastMessageMap[chatID]!];
        String chatTitle = 'Invalid Chat';

        if (chat['chat']['type'] == 'private') {
          if (otherUsers.isEmpty) {
            continue;
          }
          chatTitle = otherUsers[0]?.username ?? 'Private Chat';
        } else if (chat['chat']['type'] == 'group') {
          chatTitle = 'Group Chat';
        } else if (chat['chat']['type'] == 'channel') {
          chatTitle = 'Channel';
        } else {
          chatTitle = 'My Chat';
          chatTitle = 'My Chat';
        }

        // Create chat model
        // Contains the last message only
        // todo(ahmed): store the creators list as well as the isMuted, isSeen, isDeleted and draft attributes
        // should it be sent in the first place if it is deleted?
        final chatModel = ChatModel(
          id: chatID,
          title: chatTitle,
          userIds: members,
          admins: admins,
          type: ChatType.getType(chat['chat']['type']),
          messages: messages,
          draft: chat['draft'],
          isMuted: chat['isMuted'],
        );

        chats.add(chatModel);
        users.addAll(otherUsers.whereType<UserModel>());
      }

      return (chats: chats, users: users, appError: null);
    } catch (e, stackTrace) {
      debugPrint('!!! error in recieving the chats');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return (
        chats: <ChatModel>[],
        users: <UserModel>[],
        appError: AppError('Failed to fetch chats', code: 500),
      );
    }
  }

// Fetch user details
  Future<UserModel?> getOtherUser(String sessionId, String userID) async {
    debugPrint('!!! The Other userID: $userID');
    try {
      final response = await _dio.get(
        '/users/$userID',
        options: Options(headers: {'X-Session-Token': sessionId}),
      );

      final data = response.data['data']['user'];

      return UserModel(
        username: data['username'] ?? 'Unknown User',
        screenFirstName: data['screenFirstName'] ?? '',
        screenLastName: data['screenLastName'] ?? '',
        email: data['email'] ?? '',
        photo: data['photo'] ?? '',
        // Default to an empty string or a placeholder URL
        status: data['status'] ?? 'offline',
        bio: data['bio'] ?? '',
        maxFileSize: data['maxFileSize'] ?? 0,
        // Assuming default is 0
        automaticDownloadEnable: data['automaticDownloadEnable'] ?? false,
        lastSeenPrivacy: data['lastSeenPrivacy'] ?? 'everyone',
        readReceiptsEnablePrivacy: data['readReceiptsEnablePrivacy'] ?? true,
        storiesPrivacy: data['storiesPrivacy'] ?? 'everyone',
        picturePrivacy: data['picturePrivacy'] ?? 'everyone',
        invitePermissionsPrivacy:
            data['invitePermissionsPrivacy'] ?? 'everyone',
        phone: data['phone'] ?? 'N/A',
        photoBytes: null,
        // Assuming photoBytes are handled separately
        id: data['id'] ?? 'unknown_id',
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to fetch user details: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<({AppError? appError, ChatModel? chat})> getChat(
      String sessionID, String chatID) async {
    try {
      return (appError: null, chat: null);
    } catch (e) {
      debugPrint('!!! Failed to get other user data, ${e.toString()}');
      return (appError: AppError('Chat was not found', code: 404), chat: null);
    }
  }

  Future<({AppError? appError, ChatModel? chat})> createChat(String sessionID,
      String name, String type, List<String> memberIDs) async {
    try {
      final response = await _dio.post(
        '/chats',
        data: {
          'name': name,
          'type': type,
          'members': memberIDs,
        },
        options: Options(headers: {'X-Session-Token': sessionID}),
      );

      final chatData = response.data['data'];

      final chatID = chatData['_id'];
      final members = (chatData['members'] as List).cast<String>();

      final chatModel = ChatModel(
        id: chatID,
        title: name,
        userIds: members,
        type: ChatType.getType(type),
        messages: [],
      );

      return (appError: null, chat: chatModel);
    } catch (e) {
      debugPrint('!!! Failed to create chat, ${e.toString()}');
      return (
        appError: AppError('Failed to create chat', code: 500),
        chat: null
      );
    }
  }

  Future<({AppError? appError, String? url})> uploadMedia(
      String sessionID, String filePath) async {
    try {
      final multipartFile = await MultipartFile.fromFile(filePath);
      final mediaData = FormData.fromMap({
        'file': multipartFile,
      });
      final response = await _dio.post(
        '/chats/media',
        data: mediaData,
        options: Options(headers: {'X-Session-Token': sessionID}),
      );

      debugPrint("upload media response: ${response.data}");

      return (
        appError: null,
        url: response.data['data']['mediaFileName'] as String?
      );
    } catch (e) {
      debugPrint('!!! Failed to upload media, ${e.toString()}');
      return (
        appError: AppError('Failed to upload media', code: 500),
        url: null
      );
    }
  }

  Future<({AppError? appError})> muteChat(
      String sessionID, String chatID, int muteUntil) async {
    try {
      final response = await _dio.post(
        '/chats/mute/:$chatID',
        data: {
          'duration': muteUntil,
        },
        options: Options(headers: {'X-Session-Token': sessionID}),
      );

      if (response.statusCode == 200) {
        return (appError: null);
      } else {
        return (
          appError: AppError('Failed to mute chat', code: response.statusCode)
        );
      }
    } catch (e) {
      debugPrint('!!! Failed to mute chat, ${e.toString()}');
      return (appError: AppError('Failed to mute chat', code: 500));
    }
  }

  Future<({AppError? appError})> unmuteChat(
      String sessionID, String chatID) async {
    try {
      final response = await _dio.post(
        '/chats/unmute/:$chatID',
        options: Options(headers: {'X-Session-Token': sessionID}),
      );

      if (response.statusCode == 200) {
        return (appError: null);
      } else {
        return (
          appError: AppError('Failed to unmute chat', code: response.statusCode)
        );
      }
    } catch (e) {
      debugPrint('!!! Failed to unmute chat, ${e.toString()}');
      return (appError: AppError('Failed to unmute chat', code: 500));
    }
  }

  // updateDraft
  Future<({AppError? appError})> updateDraft(
      String sessionID, String chatID, String draft) async {
    try {
      final response = await _dio.post(
        '/chats/draft/:$chatID',
        data: {
          'draft': draft,
        },
        options: Options(headers: {'X-Session-Token': sessionID}),
      );

      if (response.statusCode == 200) {
        return (appError: null);
      } else {
        return (
          appError:
              AppError('Failed to update draft', code: response.statusCode)
        );
      }
    } catch (e) {
      debugPrint('!!! Failed to update draft, ${e.toString()}');
      return (appError: AppError('Failed to update draft', code: 500));
    }
  }

  Future<({AppError? appError, String? draft})> getDraft(
      String sessionID, String userID, String chatID) async {
    try {
      final response = await _dio.get(
        '/chats/get-draft',
        queryParameters: {'userId': userID, 'chatId': chatID},
        options: Options(headers: {'X-Session-Token': sessionID}),
      );

      final draft = response.data['drafts'] as String;

      return (appError: null, draft: draft);
    } catch (e) {
      debugPrint('!!! Failed to get draft, ${e.toString()}');
      return (
        appError: AppError('Failed to get draft', code: 500),
        draft: null
      );
    }
  }

// TODO Implement Fetch Messages
}
