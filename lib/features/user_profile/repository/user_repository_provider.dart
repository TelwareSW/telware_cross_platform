import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import '../models/story_model.dart';

class UsersRepository {
  final Box<UserModel> _userBox;

  UsersRepository(this._userBox);

  Future<List<UserModel>> fetchUsersFromBackend() async {
    await Future.delayed(Duration(seconds: 2));
    List<UserModel> users = [
      UserModel(
        stories: [
          StoryModel(
            userName: 'rings of power',
            userImageUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          ),
          StoryModel(
            userName: 'game of thrones',
            userImageUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
            createdAt: DateTime.now().subtract(Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
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
            userName: 'rings of power',
            userImageUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          ),
          StoryModel(
            userName: 'game of thrones',
            userImageUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
            createdAt: DateTime.now().subtract(Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          ),
          StoryModel(
            userName: 'rings of power',
            userImageUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          ),
        ],
        userName: 'rings of power',
        imageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        userId: 'id2',
      ),
    ];
    return users;
  }

  Future<void> saveUsersToHive(List<UserModel> users) async {
    for (var user in users) {
      try{
        await _userBox.put(user.userId,user);
      }catch(e){
        print(e);
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

}

final usersRepositoryProvider  = Provider((ref) {
  final userBox = Hive.box<UserModel>('users');
  return UsersRepository(userBox);
});
