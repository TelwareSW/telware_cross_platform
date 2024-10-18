import 'package:hive/hive.dart';

part 'story_model.g.dart'; // Hive code generation part

@HiveType(typeId: 0)
class StoryModel {
  @HiveField(0)
  String userName;

  @HiveField(1)
  String userImageUrl;

  @HiveField(2)
  String storyContentType;

  @HiveField(3)
  String storyContent;

  @HiveField(4)
  DateTime createdAt;

  // Constructor
  StoryModel({
    required this.userName,
    required this.userImageUrl,
    required this.createdAt,
    this.storyContentType = 'image',
    this.storyContent = 'placeholder for content',
  });

  // Setters and Getters are optional if you want to provide controlled access
  String get getUserName => userName;
  set setUserName(String userName) => this.userName = userName;

  String get getUserImageUrl => userImageUrl;
  set setUserImageUrl(String userImageUrl) => this.userImageUrl = userImageUrl;

  DateTime get getCreatedAt => createdAt;
  set setCreatedAt(DateTime createdAt) => this.createdAt = createdAt;

  String get getStoryContentType => storyContentType;
  set setStoryContentType(String storyContentType) =>
      this.storyContentType = storyContentType;

  String get getStoryContent => storyContent;
  set setStoryContent(String storyContent) => this.storyContent = storyContent;
}