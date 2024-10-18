import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';

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
  // todo: create user box attribute

  final Box<String> _tokenBox;
  final Box<UserModel> _userBox;
  final ProviderRef<AuthLocalRepository> _ref;

  AuthLocalRepository({
    required Box<String> tokenBox,
    required Box<UserModel> userBox,
    required ProviderRef<AuthLocalRepository> ref,
  })  : _tokenBox = tokenBox,
        _userBox = userBox,
        _ref = ref;

  void setToken(String token) async {
    await _tokenBox.put('token', token);
    _ref.read(tokenProvider.notifier).update((_) => token);
  }

  String? getToken() {
    String? token = _tokenBox.get('token');
    _ref.read(tokenProvider.notifier).update((_) => token);
    return token;
  }

  // todo: create the user setting and getting methods
  void setUser(UserModel user) async {
    await _userBox.put('user', user);
    _ref.read(userProvider.notifier).update((_) => user);
  }

  UserModel? getUser() {
    UserModel? user = _userBox.get('user');
    _ref.read(userProvider.notifier).update((_) => user);
    return user;
  }
}
