import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(AuthLocalRepositoryRef ref) {
  return AuthLocalRepository(
    tokenBox: Hive.box<String>('auth-token'),
    userBox: Hive.box<UserModel>('auth-user'),
    ref: ref,
  );
}

class AuthLocalRepository {
  final Box<String> _tokenBox;
  final Box<UserModel> _userBox;

  AuthLocalRepository({
    required Box<String> tokenBox,
    required Box<UserModel> userBox,
    required ProviderRef<AuthLocalRepository> ref,
  })  : _tokenBox = tokenBox,
        _userBox = userBox;

  void setToken(String token) async {
    await _tokenBox.put('token', token);
  }

  String? getToken() {
    String? token = _tokenBox.get('token');
    return token;
  }

  Future<void> deleteToken() async {
    await _tokenBox.delete('token');
  }

  // todo: create the user setting and getting methods
  void setUser(UserModel user) async {
    await _userBox.put('user', user);
  }

  UserModel? getMe() {
    UserModel? user = _userBox.get('user');
    return user;
  }

  Future<void> deleteUser() async {
    await _userBox.delete('user');
  }
}
