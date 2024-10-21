import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:collection/collection.dart';

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
  String storyContentUrl;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String storyCaption;

  @HiveField(6)
  List<UserModel> seens;

  @HiveField(7)
  Uint8List? storyContent;

  // Constructor
  StoryModel({
    required this.storyId,
    required this.isSeen,
    required this.createdAt,
    required this.seens,
    this.storyContentType = 'image',
    this.storyContentUrl = 'placeholder for content',
    this.storyCaption = '',
    this.storyContent,
  });

  StoryModel copyWith({
    String? storyId,
    bool? isSeen,
    String? storyContentType,
    String? storyContentUrl,
    DateTime? createdAt,
    String? storyCaption,
    List<UserModel>? seens,
    Uint8List? storyContent,
  }) {
    return StoryModel(
      storyId: storyId ?? this.storyId,
      isSeen: isSeen ?? this.isSeen,
      storyContentType: storyContentType ?? this.storyContentType,
      storyContentUrl: storyContentUrl ?? this.storyContentUrl,
      createdAt: createdAt ?? this.createdAt,
      storyCaption: storyCaption ?? this.storyCaption,
      seens: seens ?? this.seens,
      storyContent: storyContent ?? this.storyContent,
    );
  }

  @override
  String toString() {
    return 'StoryModel(storyId: $storyId, isSeen: $isSeen, storyContentType: $storyContentType, storyContentUrl: $storyContentUrl, createdAt: $createdAt, storyContent: $storyContent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! StoryModel) return false;

    if (storyContent == null) return false;

    return storyId == other.storyId &&
        storyContentUrl == other.storyContentUrl &&
        isSeen == other.isSeen &&
        createdAt == other.createdAt &&
        storyCaption == other.storyCaption &&
        storyContent == other.storyContent &&
        const ListEquality().equals(seens, other.seens);
  }

  @override
  int get hashCode =>
      storyId.hashCode ^
      storyContentUrl.hashCode ^
      isSeen.hashCode ^
      createdAt.hashCode ^
      storyCaption.hashCode ^
      const ListEquality().hash(seens) ^
      (storyContent?.hashCode ?? 0);
}
