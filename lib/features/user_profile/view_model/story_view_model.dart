import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/story_model.dart';
import '../repository/story_repository_provider.dart';

class StoryViewModel extends StateNotifier<List<StoryModel>> {
  final StoryRepository _storyRepository;

  StoryViewModel(this._storyRepository) : super([]);

  // Fetch stories from the backend and update the state
  Future<void> fetchStories() async {
    final stories = await _storyRepository.fetchStoriesFromBackend();
    state = stories;
    await _storyRepository.saveStories(stories);
  }

  // Load stories from Hive and update the state
  void loadStoriesFromHive() {
    // Fetch stories from Hive
    final box = Hive.box<StoryModel>('stories');
    state = box.values.toList(); // Update the state directly
  }
}

final storyViewModelProvider =
StateNotifierProvider<StoryViewModel, List<StoryModel>>((ref) {
  final repository = ref.watch(storyRepositoryProvider);
  return StoryViewModel(repository);
});