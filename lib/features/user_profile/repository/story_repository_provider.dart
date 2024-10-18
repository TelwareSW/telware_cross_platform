import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_model.dart';

class StoryRepository {
  final Box<StoryModel> _storyBox;

  StoryRepository(this._storyBox);

  // Fetch stories from the backend (mocked for now)
  Future<List<StoryModel>> fetchStoriesFromBackend() async {
    // Here, you'd typically make an API call to get the stories
    // Mocked data for demonstration purposes
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return [
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
    ];
  }

  // Save stories to Hive
  Future<void> saveStories(List<StoryModel> stories) async {
    for (var story in stories) {
      await _storyBox.add(story);
    }
  }

  // Get stories from Hive
  List<StoryModel> getStoriesFromHive() {
    return _storyBox.values.toList();
  }
}

final storyRepositoryProvider = Provider((ref) {
  final storyBox = Hive.box<StoryModel>('stories');
  return StoryRepository(storyBox);
});
