import 'dart:typed_data';

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
  String userImageUrl;

  @HiveField(4)
  Uint8List? userImage;

  UserModel({
    required this.stories,
    required this.userName,
    required this.userId,
    required this.userImageUrl,
    this.userImage,
  });

  UserModel copyWith({
    String? userId,
    String? userName,
    String? userImageUrl,
    List<StoryModel>? stories,
    Uint8List? userImage,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      stories: stories ?? this.stories,
      userImage: userImage ?? this.userImage,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, userName: $userName, imageUrl: $userImageUrl, stories: $stories, userImage: $userImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! UserModel) return false;

    return userId == other.userId &&
        userName == other.userName &&
        userImageUrl == other.userImageUrl &&
        _listEquals(stories, other.stories) &&
        userImage == other.userImage;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        userName.hashCode ^
        userImageUrl.hashCode ^
        _listHashCode(stories) ^
        (userImage?.hashCode ?? 0);
  }

  bool _listEquals(List<StoryModel> list1, List<StoryModel> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  int _listHashCode(List<StoryModel> stories) {
    int hash = 0;
    for (var story in stories) {
      hash ^= story.hashCode; // Combine the hash codes of each StoryModel
    }
    return hash;
  }
}
