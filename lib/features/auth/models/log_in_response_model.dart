import 'package:telware_cross_platform/core/models/user_model.dart';

class LogInResponseModel {
  final UserModel user;
  final String token;

  LogInResponseModel({
    required this.user,
    required this.token,
  });

  factory LogInResponseModel.fromMap(Map<String, dynamic> map) {
    return LogInResponseModel(
      user: UserModel.fromMap(map['user'] as Map<String,dynamic>),
      token: map['token'] as String,
    );
  }

  @override
  String toString() => 'LogInResponseModel(user: $user, token: $token)';
}
