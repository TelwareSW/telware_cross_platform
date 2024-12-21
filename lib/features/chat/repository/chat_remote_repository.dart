import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/services/encryption_service.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';

class ChatRemoteRepository {
  final Dio _dio;

  ChatRemoteRepository({required Dio dio}) : _dio = dio;

  Future<
      ({
        AppError? appError,
        List<ChatModel> chats,
        Map<String, UserModel> users,
      })> getUserChats(String sessionId, String userID, bool isAdmin) async {
    List<ChatModel> chats = [];

    if (isAdmin) {
      return _getAllGroups(sessionId, userID);
    }

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
      Map<String, Map> lastMessageMap = {};
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

      for (var message in lastMessageData) {
        final lastMessage = message['lastMessage'];
        if (lastMessage is! Map || message['lastMessage'] == null) {
          continue;
        }

        lastMessageMap[message['chatId']] = lastMessage;
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
        final List<MessageModel> messages = lastMessageMap[chatID] == null
            ? []
            : [
                _creataLastMsg(
                  lastMessage: lastMessageMap[chatID]!,
                  encryptionKey: chat['chat']['encryptionKey'],
                  initializationVector: chat['chat']['initializationVector'],
                  chatType: ChatType.getType(chat['chat']['type']),
                  isFiltered: chat['chat']['type'] != 'private'
                      ? chat['chat']['isFilterd']
                      : false,
                )
              ];
        String chatTitle = 'Invalid Chat';

        bool messagingPermission = true;
        if (chat['chat']['type'] == 'private') {
          if (otherUsers.isEmpty) {
            continue;
          }

          chatTitle =
              '${otherUsers[0]?.screenFirstName} ${otherUsers[0]?.screenLastName}';
          if (chatTitle.isEmpty) {
            chatTitle = (otherUsers[0]?.username != null &&
                    otherUsers[0]!.username.isNotEmpty)
                ? otherUsers[0]!.username
                : 'Private Chat';
          }
        } else if (chat['chat']['type'] == 'group') {
          chatTitle = chat['chat']['name'] ?? 'Group Chat';
          messagingPermission = chat['chat']['messagingPermission'];
        } else if (chat['chat']['type'] == 'channel') {
          chatTitle = chat['chat']['name'] ?? 'Channel';
          messagingPermission = chat['chat']['messagingPermission'];
        } else {
          chatTitle = 'Error in chat';
        }

        // todo(ahmed): store the creators list as well as the isSeen, isDeleted attributes
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
            creators: creators,
            messagingPermission: messagingPermission,
            encryptionKey: chat['chat']['encryptionKey'],
            isFiltered: chat['chat']['type'] != 'private'
                ? chat['chat']['isFilterd']
                : false,
            initializationVector: chat['chat']['initializationVector']);

        chats.add(chatModel);
      }

      return (chats: chats, users: userMap, appError: null);
    } catch (e, stackTrace) {
      debugPrint('!!! error in recieving the chats');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return (
        chats: <ChatModel>[],
        users: <String, UserModel>{},
        appError: AppError('Failed to fetch chats', code: 500),
      );
    }
  }

  Future<
      ({
        AppError? appError,
        List<ChatModel> chats,
        Map<String, UserModel> users,
      })> _getAllGroups(String sessionId, String userID) async {
    List<ChatModel> chats = [];

    try {
      final response = await _dio.get(
        '/users/all-groups',
        options: Options(headers: {'X-Session-Token': sessionId}),
      );

      final groupsData =
          response.data['data']['groupsAndChannels'] as List? ?? [];

      // Iterate through chats and map users
      for (var group in groupsData) {
        // todo(ahmed) make this list only for the normal members
        final members = (group['members'] as List)
            .map((member) => member['user'] as String)
            .toList();

        final admins = (group['members'] as List)
            .where((member) => member['Role'] == 'admin')
            .map((member) => member['user'] as String)
            .toList();

        final creators = (group['members'] as List)
            .where((member) => member['Role'] == 'creator')
            .map((member) => member['user'] as String)
            .toList();

        String chatTitle = 'Invalid Chat';

        bool messagingPermission = true;
        if (group['type'] == 'group') {
          chatTitle = group['name'] ?? 'Group Chat';
          messagingPermission = group['messagingPermission'];
        } else if (group['type'] == 'channel') {
          chatTitle = group['name'] ?? 'Channel';
          messagingPermission = group['messagingPermission'];
        } else {
          chatTitle = 'Error in chat';
        }

        // todo(ahmed): store the creators list as well as the isSeen, isDeleted attributes
        // should it be sent in the first place if it is deleted?
        final chatModel = ChatModel(
          id: group['id'],
          title: chatTitle,
          userIds: members,
          admins: admins,
          type: ChatType.getType(group['type']),
          messages: [],
          creators: creators,
          downloadingPermission: group['downloadingPermission'],
          isFiltered: group['isFilterd'],
          messagingPermission: messagingPermission,
          photo: group['picture'],
          createdAt: group['createdAt'] != null
              ? DateTime.parse(group['createdAt'])
              : DateTime.now(),
        );

        chats.add(chatModel);
      }

      return (chats: chats, users: <String, UserModel>{}, appError: null);
    } catch (e, stackTrace) {
      debugPrint('!!! error in receiving the groups for admin');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return (
        chats: <ChatModel>[],
        users: <String, UserModel>{},
        appError: AppError('Failed to fetch groups for admin', code: 500),
      );
    }
  }

  MessageModel _creataLastMsg({
    required Map<dynamic, dynamic> lastMessage,
    required String? encryptionKey,
    required String? initializationVector,
    required ChatType chatType,
    required bool isFiltered,
  }) {
    Map<String, MessageState> userStates = {};
    MessageContentType contentType =
        MessageContentType.getType(lastMessage['contentType'] ?? 'text');
    MessageContent? content;

    final Map<String, String> userStatesMap = lastMessage['userStates'] ?? {};

    for (var entry in userStatesMap.entries) {
      userStates[entry.key] = MessageState.getType(entry.value);
    }

    final encryptionService = EncryptionService.instance;

    String text = encryptionService.decrypt(
      chatType: chatType,
      msg: lastMessage['content'],
      encryptionKey: encryptionKey,
      initializationVector: initializationVector,
    );

    if (isFiltered && lastMessage['isAppropriate'] == false) {
      text = 'This message has been filtered';
    }

    // TODO: needs to be modified to match the response fields
    content = createMessageContent(
      contentType: contentType,
      text: text,
      fileName: lastMessage['fileName'],
      mediaUrl: lastMessage['mediaUrl'],
    );

    final threadMessages = (lastMessage['threadMessages'] as List)
        .map((e) => e as String)
        .toList();

    // the connumicationType attribute is extra
    return MessageModel(
      id: lastMessage['id'],
      senderId: lastMessage['senderId'],
      messageContentType: contentType,
      messageType: MessageType.getType(lastMessage['type'] ?? 'unknown'),
      content: content,
      timestamp: lastMessage['timestamp'] != null
          ? DateTime.parse(lastMessage['timestamp'])
          : DateTime.now(),
      userStates: userStates,
      isForward: lastMessage['isForward'] ?? false,
      isPinned: lastMessage['isPinned'] ?? false,
      isAnnouncement: lastMessage['isAnnouncement'],
      threadMessages: threadMessages,
      parentMessage: lastMessage['parentMessageId'],
      isAppropriate: lastMessage['isAppropriate'],
      isEdited: lastMessage['isEdited'],
    );
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
    } catch (e) {
      debugPrint('Failed to fetch user details');
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

  Future<({AppError? appError})> filterGroup(
      String sessionID, String chatID) async {
    try {
      final response = await _dio.patch(
        '/chats/groups/filter/$chatID',
        options: Options(headers: {'X-Session-Token': sessionID}),
      );

      debugPrint("message: ${response.data['message']}");

      return (appError: null);
    } catch (e) {
      debugPrint('!!! Failed to filter $chatID, ${e.toString()}');
      return (appError: AppError('Failed to filter', code: 500));
    }
  }

  Future<({AppError? appError})> unFilterGroup(
      String sessionID, String chatID) async {
    try {
      final response = await _dio.patch(
        '/chats/groups/unfilter/$chatID',
        options: Options(headers: {'X-Session-Token': sessionID}),
      );

      debugPrint("message: ${response.data['message']}");

      return (appError: null);
    } catch (e) {
      debugPrint('!!! Failed to unFilter $chatID, ${e.toString()}');
      return (appError: AppError('Failed to unFilter', code: 500));
    }
  }

// TODO Implement Fetch Messages
}
