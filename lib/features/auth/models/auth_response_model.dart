import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String token;

  AuthResponseModel({
    required this.user,
    required this.token,
  });

  static Future<AuthResponseModel> fromMap(Map<String, dynamic> map) async {
    map.forEach(
      (key, value) {
        debugPrint(
            'key: $key, value: $value, value type: ${value.runtimeType}');
      },
    );
    return AuthResponseModel(
      user: await UserModel.fromMap(map['user'] as Map<String, dynamic>),
      token: map['sessionId'] as String,
    );
  }

  @override
  String toString() => 'LogInResponseModel(user: $user, token: $token)';
}
