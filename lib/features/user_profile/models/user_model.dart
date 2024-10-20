import 'package:telware_cross_platform/features/user_profile/models/story_model.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {

  @HiveField(0)
  List<StoryModel> stories;

  @HiveField(1)
  String userName;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String imageUrl;

  UserModel({
    required this.stories,
    required this.userName,
    required this.userId,
    required this.imageUrl,
  });

  UserModel copyWith({
    String? userId,
    String? userName,
    String? imageUrl,
    List<StoryModel>? stories,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      imageUrl: imageUrl ?? this.imageUrl,
      stories: stories ?? this.stories,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, userName: $userName, imageUrl: $imageUrl, stories: $stories)';
  }
}