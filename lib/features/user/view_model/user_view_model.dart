// ignore_for_file: avoid_manual_providers_as_generated_provider_dependency
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_remote_repository.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/features/stories/repository/contacts_remote_repository.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/repository/user_remote_repository.dart';

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

    final response =
        await ref.read(authRemoteRepositoryProvider).getMe(sessionId);

    response.fold(
      (appError) {
        state = UserState.fail(appError.error);
      },
      (user) {
        ref.read(authLocalRepositoryProvider).setUser(user);
        ref.read(userProvider.notifier).update((_) => user);
        state = UserState.authorized;
      },
    );
  }

  Future<void> updatePhoneNumber(String newPhoneNumber) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a successful update with mock data
      final updatedUser = userMock.copyWith(phone: newPhoneNumber);
      ref
          .read(authLocalRepositoryProvider)
          .setUser(updatedUser); // Persist the change
      ref.read(userProvider.notifier).update((_) => updatedUser);
      state = UserState.success('Phone number updated successfully');
      return;
    }

    final response = await ref
        .read(userRemoteRepositoryProvider)
        .changeNumber(newPhoneNumber: newPhoneNumber);

    response.fold(
      (appError) {
        state = UserState.fail(appError.error);
      },
      (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser =
              user.copyWith(phone: newPhoneNumber); // Create a new User object
          ref
              .read(authLocalRepositoryProvider)
              .setUser(updatedUser); // Persist the change
          ref
              .read(userProvider.notifier)
              .update((_) => updatedUser); // Update the state
        }
        state = UserState.success('Phone number updated successfully');
      },
    );
  }

  Future<void> updateBio(String newBio) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a successful update with mock data
      final updatedUser = userMock.copyWith(bio: newBio);
      ref
          .read(authLocalRepositoryProvider)
          .setUser(updatedUser); // Persist the change
      ref.read(userProvider.notifier).update((_) => updatedUser);
      state = UserState.success('Bio updated successfully');
      return;
    }

    final response =
        await ref.read(userRemoteRepositoryProvider).updateBio(newBio: newBio);

    response.fold(
      (appError) {
        state = UserState.fail(appError.error);
      },
      (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser =
              user.copyWith(bio: newBio); // Create a new User object
          ref
              .read(authLocalRepositoryProvider)
              .setUser(updatedUser); // Persist the change
          ref
              .read(userProvider.notifier)
              .update((_) => updatedUser); // Update the state
        }
        state = UserState.success('Bio updated successfully');
      },
    );
  }

  Future<void> updateUserInfo(
      String firstName, String lastName, String newBio) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a successful update with mock data
      final updatedUser =
          userMock.copyWith(screenFirstName: firstName, screenLastName: lastName, bio: newBio);
      ref.read(authLocalRepositoryProvider).setUser(updatedUser);
      ref.read(userProvider.notifier).update((_) => updatedUser);
      state = UserState.success('Screen name updated successfully');
      return;
    }

    await ref.read(userRemoteRepositoryProvider).updateScreenName(
          newScreenFirstName: firstName,
          newScreenLastName: lastName,
        );

    final response = await ref.read(userRemoteRepositoryProvider).updateBio(
          newBio: newBio,
        );

    response.fold(
      (appError) {
        state = UserState.fail(appError.error);
      },
      (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser =
              user.copyWith(screenFirstName: firstName, screenLastName: lastName, bio: newBio);
          ref.read(authLocalRepositoryProvider).setUser(updatedUser);
          ref.read(userProvider.notifier).update((_) => updatedUser);
        }
        state = UserState.success('Screen name updated successfully');
      },
    );
  }

  Future<void> updateEmail({required String newEmail}) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a successful update with mock data
      final updatedUser = userMock.copyWith(email: newEmail);
      ref.read(authLocalRepositoryProvider).setUser(updatedUser);
      ref.read(userProvider.notifier).update((_) => updatedUser);
      state = UserState.success('Email updated successfully');
      return;
    }

    final response = await ref.read(userRemoteRepositoryProvider).updateEmail(
          newEmail: newEmail,
        );

    response.fold(
      (appError) {
        state = UserState.fail(appError.error);
      },
      (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser = user.copyWith(email: newEmail);
          ref.read(authLocalRepositoryProvider).setUser(updatedUser);
          ref.read(userProvider.notifier).update((_) => updatedUser);
        }
        state = UserState.success('Email updated successfully');
      },
    );
  }

  Future<void> changeUsername(String newUsername) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a successful update with mock data
      final updatedUser = userMock.copyWith(username: newUsername);
      ref.read(authLocalRepositoryProvider).setUser(updatedUser);
      ref.read(userProvider.notifier).update((_) => updatedUser);
      state = UserState.success('Username updated successfully');
      return;
    }

    final response = await ref
        .read(userRemoteRepositoryProvider)
        .changeUsername(newUsername: newUsername);

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

  Future<bool> checkUsernameUniqueness(String username) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a mock check for username uniqueness
      final isUnique = username != "mock.user";
      state = isUnique
          ? UserState.success('Username is unique')
          : UserState.fail('Username is already taken');
      return true;
    }

    final response = await ref
        .read(userRemoteRepositoryProvider)
        .checkUsernameUniqueness(username: username);

    return response.fold(
      (appError) {
        state = UserState.fail(appError.error);
        return false;
      },
      (isUnique) {
        state = isUnique
            ? UserState.success('Username is unique')
            : UserState.fail('Username is already taken');
        return true;
      },
    );
  }

  Future<bool> updateProfilePicture(File storyImage) async {
    if (await ref.read(contactsRemoteRepositoryProvider).updateProfilePicture(storyImage) ==
        true) {
      await ref.read(authViewModelProvider.notifier).getMe();
      return true;
    }
    return false;
  }

  Future<bool> deleteProfilePicture() async {
    if (await ref.read(contactsRemoteRepositoryProvider).deleteProfilePicture() ==
        true) {
      await ref.read(authViewModelProvider.notifier).getMe();
      return true;
    }
    return false;
  }
  
  Future<void> changeLastSeenPrivacy(String newPrivacy) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a successful update with mock data
      final updatedUser = userMock.copyWith(lastSeenPrivacy: newPrivacy);
      ref.read(authLocalRepositoryProvider).setUser(updatedUser);
      ref.read(userProvider.notifier).update((_) => updatedUser);
      state = UserState.success('Last seen privacy updated successfully');
      return;
    }

    final response = await ref
        .read(userRemoteRepositoryProvider)
        .changeLastSeenPrivacy(privacy: newPrivacy);

    response.fold(
      (appError) {
        state = UserState.fail(appError.error);
      },
      (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser = user.copyWith(lastSeenPrivacy: newPrivacy);
          ref.read(authLocalRepositoryProvider).setUser(updatedUser);
          ref.read(userProvider.notifier).update((_) => updatedUser);
        }
        state = UserState.success('Last seen privacy updated successfully');
      },
    );
  }

  Future<void> changeProfilePhotoPrivacy(String newPrivacy) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a successful update with mock data
      final updatedUser = userMock.copyWith(picturePrivacy: newPrivacy);
      ref.read(authLocalRepositoryProvider).setUser(updatedUser);
      ref.read(userProvider.notifier).update((_) => updatedUser);
      state = UserState.success('Profile photo privacy updated successfully');
      return;
    }

    final response = await ref
        .read(userRemoteRepositoryProvider)
        .changeProfilePhotoPrivacy(privacy: newPrivacy);

    response.fold(
      (appError) {
        state = UserState.fail(appError.error);
      },
      (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser = user.copyWith(picturePrivacy: newPrivacy);
          ref.read(authLocalRepositoryProvider).setUser(updatedUser);
          ref.read(userProvider.notifier).update((_) => updatedUser);
        }
        state = UserState.success('Profile photo privacy updated successfully');
      },
    );
  }

  Future<void> changeInvitePermissions(String newPermissions) async {
    state = UserState.loading;

    if (USE_MOCK_DATA) {
      // Simulate a successful update with mock data
      final updatedUser =
          userMock.copyWith(invitePermissionsPrivacy: newPermissions);
      ref.read(authLocalRepositoryProvider).setUser(updatedUser);
      ref.read(userProvider.notifier).update((_) => updatedUser);
      state = UserState.success('Invite permissions updated successfully');
      return;
    }

    final response = await ref
        .read(userRemoteRepositoryProvider)
        .changeInvitePermissions(permissions: newPermissions);

    response.fold(
      (appError) {
        state = UserState.fail(appError.error);
      },
      (_) {
        // Update the user locally after successful update
        final user = ref.read(userProvider);
        if (user != null) {
          final updatedUser =
              user.copyWith(invitePermissionsPrivacy: newPermissions);
          ref.read(authLocalRepositoryProvider).setUser(updatedUser);
          ref.read(userProvider.notifier).update((_) => updatedUser);
        }
        state = UserState.success('Invite permissions updated successfully');
      },
    );
  }
}
