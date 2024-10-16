import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(AuthLocalRepositoryRef ref) {
  return AuthLocalRepository(
    tokenBox: Hive.box<String>('token-box'),
    ref: ref,
  );
}

class AuthLocalRepository {
  // todo: create user box attribute

  final Box<String> _tokenBox;
  final ProviderRef<AuthLocalRepository> _ref;

  AuthLocalRepository({
    required Box<String> tokenBox,
    required ProviderRef<AuthLocalRepository> ref,
  }) : _tokenBox = tokenBox, _ref = ref;

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
}
