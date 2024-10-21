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
      userName: 'game of thrones',
      imageUrl:
      'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      stories: [
        StoryModel(
          storyId: 'idd11',
          createdAt: DateTime.now(),
          storyContent:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          isSeen: false,
          storyCaption: 'very good caption', seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id11',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id12',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
              storyCaption: 'very good  good  good caption', seens: [],

            ),
          ],
          userName: 'game of thrones',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          userId: 'id1',
        ),UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          userId: 'id2',
        ),],
        ),
        StoryModel(
          storyId: 'idd12',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          storyContent:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          isSeen: false,
          storyCaption: 'very good  good  good caption', seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          userId: 'id2',
        ),],

        ),
        StoryModel(
          storyId: 'idd13',
          createdAt: DateTime.now(),
          storyContent:
          'https://www.e3lam.com/images/large/2015/01/unnamed-14.jpg',
          isSeen: false, seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id11',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id12',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
              storyCaption: 'very good  good  good caption', seens: [],

            ),
          ],
          userName: 'game of thrones',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          userId: 'id1',
        ),UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          userId: 'id2',
        ),],
        ),
      ],
      userId: 'myUser',
    ),
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id11',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id12',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
            storyCaption: 'very good  good  good caption', seens: [],

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
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id22',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id23',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
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
            storyCaption: 'very good  good  good caption', seens: [],

          ),
          StoryModel(
            storyId: 'id32',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id33',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
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
