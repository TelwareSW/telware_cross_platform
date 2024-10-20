import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import '../models/story_model.dart';

class UsersRepository {
  final Box<UserModel> _userBox;

  UsersRepository(this._userBox);

  Future<List<UserModel>> fetchUsersFromBackend() async {
    await Future.delayed(const Duration(seconds: 2));
    List<UserModel> users = [
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id11',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false,
          ),
          StoryModel(
            storyId: 'id12',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
          ),
        ],
        userName: 'game of thrones',
        imageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
        userId: 'id1',
      ),
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id21',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false,
          ),
          StoryModel(
            storyId: 'id22',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
          ),
          StoryModel(
            storyId: 'id23',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false,
          ),
        ],
        userName: 'rings of power',
        imageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        userId: 'id2',
      ),
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id31',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false,
          ),
          StoryModel(
            storyId: 'id32',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
          ),
          StoryModel(
            storyId: 'id33',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false,
          ),
        ],
        userName: 'rings of power',
        imageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        userId: 'id3',
      ),
    ];
    return users;
  }

  Future<void> saveUsersToHive(List<UserModel> users) async {
    for (var user in users) {
      try{
        await _userBox.put(user.userId,user);
      }catch(e){
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  Future<List<StoryModel>> fetchUserStoriesFromHive(String userId) async {
    final user = _userBox.get(userId);
    return user?.stories ?? []; // Return user's stories
  }

  Future<UserModel?> fetchUserFromHive(String userId) async {
    return _userBox.get(userId); // Return user by userId
  }

  List<UserModel> getAllUsersFromHive() {
    return _userBox.values.toList();
  }

  Future<List<UserModel>> fetchAndSaveUsers() async {
    final usersFromBackend = await fetchUsersFromBackend();
    await saveUsersToHive(usersFromBackend);
    return getAllUsersFromHive();
  }

  Future<void> deleteUserFromHive(String userId) async {
    final box = await Hive.openBox<UserModel>('users');
    await box.delete(userId);
  }

  Future<void> updateUserInHive(UserModel updatedUser) async {
    try {
      final existingUser = _userBox.get(updatedUser.userId);

      if (existingUser != null) {
        await _userBox.put(updatedUser.userId, updatedUser);
      } else {
        if (kDebugMode) {
          print('User not found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user in Hive: $e');
      }
      throw Exception('Error updating user in Hive');
    }
  }
}

final usersRepositoryProvider  = Provider((ref) {
  final userBox = Hive.box<UserModel>('users');
  return UsersRepository(userBox);
});
