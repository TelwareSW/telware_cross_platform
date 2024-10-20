import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import '../models/story_model.dart';
import '../repository/user_repository_provider.dart';

class UserViewModelState {
  final List<UserModel> users;
  final bool isLoading;

  UserViewModelState({
    required this.users,
    required this.isLoading,
  });

  factory UserViewModelState.initial() {
    return UserViewModelState(users: [], isLoading: false);
  }

  UserViewModelState copyWith({
    List<UserModel>? users,
    bool? isLoading,
  }) {
    return UserViewModelState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserViewModel extends StateNotifier<UserViewModelState> {
  final UsersRepository _usersRepository;


  UserViewModel(this._usersRepository) : super(UserViewModelState.initial());


  Future<void> fetchUsers() async {
    try {
      final fetchedUsers = await _usersRepository.fetchAndSaveUsers();
      state = state.copyWith(users: List.from(fetchedUsers), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<StoryModel>> fetchUserStories(String userId) async {
    return await _usersRepository.fetchUserStoriesFromHive(userId);
  }

  Future<UserModel?> getUserById(String userId) async {
    return await _usersRepository.fetchUserFromHive(userId);
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _usersRepository.deleteUserFromHive(userId);

      final updatedUsers = state.users.where((user) => user.userId != userId).toList();
      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete user: $e');
      }
    }
  }

  Future<void> markStoryAsSeen(String userId, String storyId) async {
    try {
      final user = await getUserById(userId);
      if (user != null) {
        final updatedStories = user.stories.map((story) {
          if (story.storyId == storyId) {
            return story.copyWith(isSeen: true);
          }
          return story;
        }).toList();

        final updatedUser = user.copyWith(stories: updatedStories);
        await _usersRepository.updateUserInHive(updatedUser);

        final updatedUsers = state.users.map((u) {
          if (u.userId == userId) {
            return updatedUser;
          }
          return u;
        }).toList();

        state = state.copyWith(users: updatedUsers);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to mark story as seen: $e');
      }
    }
  }

}

final usersViewModelProvider = StateNotifierProvider<UserViewModel, UserViewModelState>((ref) {
  final usersRepository = ref.watch(usersRepositoryProvider);
  return UserViewModel(usersRepository);
});