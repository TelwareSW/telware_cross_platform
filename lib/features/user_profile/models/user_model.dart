import 'package:telware_cross_platform/features/user_profile/models/story_model.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart'; // Hive code generation part

@HiveType(typeId: 0)
class UserModel {

  @HiveField(0)
  List<StoryModel> stories;

  @HiveField(1)
  String userName;

  @HiveField(2)
  String imageUrl;

  UserModel({
    required this.stories,
    required this.userName,
    required this.imageUrl,
  });


}