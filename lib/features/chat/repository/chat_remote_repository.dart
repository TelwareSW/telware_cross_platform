import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

class ChatRemoteRepository {
  final Dio _dio;
  ChatRemoteRepository({required Dio dio}) : _dio = dio;

  Future<
      ({
        AppError? appError,
        List<ChatModel> chats,
        List<UserModel> users,
      })> getUserChats(String sessionId) async {
    try {
      final response = await _dio.get(
        '/chats',
        options: Options(
          headers: {'X-Session-Token': sessionId},
        ),
      );

      
    } catch (e) {
      debugPrint(e.toString());
    }
    return (chats: <ChatModel>[], users: <UserModel>[], appError: null);
  }

  Future<({
    AppError? appError,
    UserModel? otherUser
  })> getOtherUser(String id) async {
    try {
      return (appError: null, otherUser: userMock); 
    } catch (e) {
      debugPrint('!!! Faild to get other user data, ${e.toString()}'); 
      return (appError: AppError('This User was not Found', code: 404), otherUser: null); 
    }
  }
}
