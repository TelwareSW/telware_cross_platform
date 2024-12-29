import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';

part 'user_local_repository.g.dart';

@Riverpod(keepAlive: true)
UserLocalRepository userLocalRepository(UserLocalRepositoryRef ref) {
  return UserLocalRepository(
    userBox: Hive.box<UserModel>('auth-user'),
    // Same box as in auth_local_repository
    ref: ref,
  );
}

class UserLocalRepository {
  final Box<UserModel> _userBox;

  UserLocalRepository({
    required Box<UserModel> userBox,
    required ProviderRef<UserLocalRepository> ref,
  }) : _userBox = userBox;

  Future<AppError?> changeNumber(String newPhoneNumber) async {
    try {
      final user = _userBox.get('user');
      if (user != null) {
        final updatedUser = user.copyWith(phone: newPhoneNumber);
        await _userBox.put('user', updatedUser);
      } else {
        return AppError("User not found.");
      }
    } catch (error) {
      return AppError("Couldn't update phone number. Try again later.");
    }
    return null;
  }

  Future<AppError?> updateBio(String newBio) async {
    try {
      final user = _userBox.get('user');
      if (user != null) {
        final updatedUser = user.copyWith(bio: newBio);
        await _userBox.put('user', updatedUser);
      } else {
        return AppError("User not found.");
      }
    } catch (error) {
      return AppError("Couldn't update bio. Try again later.");
    }
    return null;
  }

  Future<AppError?> updateScreenName(String newScreenName) async {
    try {
      final user = _userBox.get('user');
      if (user != null) {
        final first = newScreenName.split(' ')[0];
        final last = newScreenName.split(' ')[1];
        final updatedUser = user.copyWith(screenFirstName: first, screenLastName: last);
        await _userBox.put('user', updatedUser);
      } else {
        return AppError("User not found.");
      }
    } catch (error) {
      return AppError("Couldn't update screen name. Try again later.");
    }
    return null;
  }

  Future<AppError?> changeUsername(String newUsername) async {
    try {
      final user = _userBox.get('user');
      if (user != null) {
        final updatedUser = user.copyWith(username: newUsername);
        await _userBox.put('user', updatedUser);
      } else {
        return AppError("User not found.");
      }
    } catch (error) {
      return AppError("Couldn't update username. Try again later.");
    }
    return null;
  }

  Either<AppError, bool> checkUsernameUniqueness(String username) {
    final user = _userBox.get('user');
    if (user != null) {
      if (user.username == username) {
        return Left(AppError("Username is already taken."));
      }
      return const Right(true);
    }
    return Left(AppError("User not found."));
  }

  // Retrieves the current user
  UserModel? getUser() {
    return _userBox.get('user');
  }

  // Saves the updated user data
  Future<void> setUser(UserModel user) async {
    await _userBox.put('user', user);
  }

  // Deletes user data
  Future<void> deleteUser() async {
    await _userBox.delete('user');
  }
}
