// ignore_for_file: avoid_manual_providers_as_generated_provider_dependency
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_remote_repository.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/repository/user_remote_repository.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

part 'user_view_model.g.dart';

@Riverpod(keepAlive: true)
class UserViewModel extends _$UserViewModel {
  @override
  UserState build() {
    return UserState.init;
  }

  Future<void> init() async {
    final sessionId = ref.read(tokenProvider);

    if (sessionId == null) {
      state = UserState.unauthorized;
      return;
    }

    final response = await ref.read(authRemoteRepositoryProvider).getMe(sessionId);

    response.fold(
          (appError) {
        state = UserState.fail(appError.error);
      },
          (user) {
        ref.read(authLocalRepositoryProvider).setUser(user); // Update local storage
        ref.read(userProvider.notifier).update((_) => user);
        state = UserState.authorized;
      },
    );
  }

  Future<void> updatePhoneNumber(String newPhoneNumber) async {
    state = UserState.loading;

    final response = await ref.read(userRemoteRepositoryProvider).changeNumber(newPhoneNumber: newPhoneNumber);

    response.fold(
          (appError) {
        state = UserState.fail(appError.error);
      },
          (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser = user.copyWith(phone: newPhoneNumber); // Create a new User object
          ref.read(authLocalRepositoryProvider).setUser(updatedUser); // Persist the change
          ref.read(userProvider.notifier).update((_) => updatedUser); // Update the state
        }
        state = UserState.success('Phone number updated successfully');
      },
    );
  }

  Future<void> updateBio(String newBio) async {
    state = UserState.loading;

    final response = await ref.read(userRemoteRepositoryProvider).updateBio(newBio: newBio);

    response.fold(
          (appError) {
        state = UserState.fail(appError.error);
      },
          (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser = user.copyWith(bio: newBio); // Create a new User object
          ref.read(authLocalRepositoryProvider).setUser(updatedUser); // Persist the change
          ref.read(userProvider.notifier).update((_) => updatedUser); // Update the state
        }
        state = UserState.success('Bio updated successfully');
      },
    );
  }

  Future<void> updateScreenName(String firstName, String lastName) async {
    state = UserState.loading;

    final response = await ref.read(userRemoteRepositoryProvider).updateScreenName(
      newScreenFirstName: firstName,
      newScreenLastName: lastName,
    );

    response.fold(
          (appError) {
        state = UserState.fail(appError.error);
      },
          (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser = user.copyWith(screenName: "$firstName $lastName");
          ref.read(authLocalRepositoryProvider).setUser(updatedUser);
          ref.read(userProvider.notifier).update((_) => updatedUser);
        }
        state = UserState.success('Screen name updated successfully');
      },
    );
  }

  Future<void> changeUsername(String newUsername) async {
    state = UserState.loading;

    final response = await ref.read(userRemoteRepositoryProvider).changeUsername(newUsername: newUsername);

    response.fold(
          (appError) {
        state = UserState.fail(appError.error);
      },
          (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser = user.copyWith(username: newUsername);
          ref.read(authLocalRepositoryProvider).setUser(updatedUser);
          ref.read(userProvider.notifier).update((_) => updatedUser);
        }
        state = UserState.success('Username updated successfully');
      },
    );
  }

  Future<void> checkUsernameUniqueness(String username) async {
    state = UserState.loading;

    final response = await ref.read(userRemoteRepositoryProvider).checkUsernameUniqueness(username: username);

    response.fold(
          (appError) {
        state = UserState.fail(appError.error);
      },
          (isUnique) {
        state = isUnique ? UserState.success('Username is unique') : UserState.fail('Username is already taken');
      },
    );
  }
}
