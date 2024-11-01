import 'package:telware_cross_platform/core/models/user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String token;

  AuthResponseModel({
    required this.user,
    required this.token,
  });

  factory AuthResponseModel.fromMap(Map<String, dynamic> map) {
    return AuthResponseModel(
      user: UserModel.fromMap(map['user'] as Map<String, dynamic>),
      token: map['sessionId'] as String,
    );
  }

  @override
  String toString() => 'LogInResponseModel(user: $user, token: $token)';
}
