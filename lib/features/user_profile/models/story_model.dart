import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';

part 'story_model.g.dart';

@HiveType(typeId: 1)
class StoryModel {
  @HiveField(0)
  String storyId;

  @HiveField(1)
  bool isSeen;

  @HiveField(2)
  String storyContentType;

  @HiveField(3)
  String storyContent;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String storyCaption;

  @HiveField(6)
  List<UserModel> seens;

  // Constructor
  StoryModel({
    required this.storyId,
    required this.isSeen,
    required this.createdAt,
    required this.seens,
    this.storyContentType = 'image',
    this.storyContent = 'placeholder for content',
    this.storyCaption = '',
  });

  StoryModel copyWith({
    String? storyId,
    bool? isSeen,
    String? storyContentType,
    String? storyContent,
    DateTime? createdAt,
    String? storyCaption,
    List<UserModel>? seens
  }) {
    return StoryModel(
      storyId: storyId ?? this.storyId,
      isSeen: isSeen ?? this.isSeen,
      storyContentType: storyContentType ?? this.storyContentType,
      storyContent: storyContent ?? this.storyContent,
      createdAt: createdAt ?? this.createdAt,
      storyCaption: storyCaption ?? this.storyCaption,
      seens: seens ?? this.seens,
    );
  }

  @override
  String toString() {
    return 'StoryModel(storyId: $storyId, isSeen: $isSeen, storyContentType: $storyContentType, storyContent: $storyContent, createdAt: $createdAt)';
  }
}
