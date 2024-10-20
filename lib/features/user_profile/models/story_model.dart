import 'package:hive/hive.dart';

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

  // Constructor
  StoryModel({
    required this.storyId,
    required this.isSeen,
    required this.createdAt,
    this.storyContentType = 'image',
    this.storyContent = 'placeholder for content',
  });

  StoryModel copyWith({
    String? storyId,
    bool? isSeen,
    String? storyContentType,
    String? storyContent,
    DateTime? createdAt,
  }) {
    return StoryModel(
      storyId: storyId ?? this.storyId,
      isSeen: isSeen ?? this.isSeen,
      storyContentType: storyContentType ?? this.storyContentType,
      storyContent: storyContent ?? this.storyContent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'StoryModel(storyId: $storyId, isSeen: $isSeen, storyContentType: $storyContentType, storyContent: $storyContent, createdAt: $createdAt)';
  }
}