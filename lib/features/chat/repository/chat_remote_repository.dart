import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';

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

      final chatData = response.data['data']['chats'] as List;
      final memberData = response.data['data']['members'] as List;

      Map<String, UserModel> userMap = {};
      for (var member in memberData) {
        userMap[member['_id']] = UserModel(
          id: member['_id'],
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

      // Iterate through chats and map users
      for (var chat in chatData) {
        final chatID = chat['_id'];

        final members = (chat['members'] as List).cast<String>();

        // Create list of user IDs excluding current user
        final otherUserIDs = members.where((id) => id != userID).toList();
        final otherUsers = otherUserIDs.map((id) => userMap[id]).toList();
        String chatTitle = 'Invalid Chat';
        if (chat['type'] == 'private') {
          chatTitle = otherUsers[0]?.username ?? 'Private Chat';
        } else if (chat['type'] == 'group') {
          chatTitle = 'Group Chat';
        } else if (chat['type'] == 'channel') {
          chatTitle = 'Channel';
        } else {
          chatTitle = 'My Chat';
        }
        // Create chat model
        final chatModel = ChatModel(
          id: chatID,
          title: chatTitle,
          userIds: members,
          type: ChatType.getType(chat['type']),
          // Messages are fetched later
          messages: [],
        );

        chats.add(chatModel);
        users.addAll(otherUsers.whereType<UserModel>());
      }

      return (chats: chats, users: users, appError: null);
    } catch (e) {
      debugPrint(e.toString());
      return (
        chats: <ChatModel>[],
        users: <UserModel>[],
        appError: AppError('Failed to fetch chats', code: 500),
      );
    }
  }

// Fetch user details
  Future<UserModel?> getOtherUser(String sessionId, String userID) async {
    try {
      final response = await _dio.get(
        '/users/$userID',
        options: Options(headers: {'X-Session-Token': sessionId}),
      );

      final data = response.data['data'];

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
      debugPrint('Failed to fetch user details: ${e.toString()}');
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

// TODO Implement Fetch Messages
}
