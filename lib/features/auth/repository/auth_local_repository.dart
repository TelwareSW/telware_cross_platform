import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

import '../../../core/constants/server_constants.dart';
import '../../stories/utils/utils_functions.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(AuthLocalRepositoryRef ref) {
  return AuthLocalRepository(
    tokenBox: Hive.box<String>('auth-token'),
    userBox: Hive.box<UserModel>('auth-user'),
  );
}

class AuthLocalRepository {
  final Box<String> _tokenBox;
  final Box<UserModel> _userBox;

  AuthLocalRepository({
    required Box<String> tokenBox,
    required Box<UserModel> userBox,
  })  : _tokenBox = tokenBox,
        _userBox = userBox;

  Future<void> setToken(String token) async {
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
  Future<void> setUser(UserModel user) async {
    print('** user photo: ${user.photo}');
    print('** user photo isNull: ${user.photo == null}');
    if (user.photo?.isNotEmpty ?? false) {
      Uint8List? imageBytes = await _fetchUserImage(user.photo!);
      print('** setUser imageBytes');
      if (imageBytes != null) {
        final userWithImage = user.copyWith(photoBytes: imageBytes);
        await _userBox.put('user', userWithImage);
      }
    } else {
      await _userBox.put('user', user);
    }
  }

  Future<Uint8List?> _fetchUserImage(String photoUrl) async {
    final imageUrl = photoUrl.startsWith('https')
        ? photoUrl
        : '$API_URL_PICTURES/$photoUrl';

    return await downloadImage(imageUrl);
  }

  UserModel? getMe() {
    UserModel? user = _userBox.get('user');
    return user;
  }

  Future<void> deleteUser() async {
    await _userBox.delete('user');
  }
}
