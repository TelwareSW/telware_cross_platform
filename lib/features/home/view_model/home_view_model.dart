import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/features/home/models/home_state.dart';
import 'package:telware_cross_platform/features/home/repository/home_remote_repository.dart';

part 'home_view_model.g.dart';

@Riverpod(keepAlive: true)
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    return HomeState();
  }

  /// Fetch search results and update `state` accordingly.
  Future<void> fetchSearchResults(
    String query,
    List<String> searchSpace,
    String filterType,
    bool isGlobalSearch,
  ) async {
    final repository = ref.read(homeRemoteRepositoryProvider);

    try {
      final result = await repository.searchRequest(
        query,
        searchSpace,
        filterType,
        isGlobalSearch,
      );

      if (result.appError != null) {
        debugPrint('Error: ${result.appError}');
      } else {
        state = state.copyWith(searchResults: result.searchResults);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  /// Fetch media suggestions and update `state` accordingly.
  Future<void> fetchMediaSuggestions(List<String> searchSpace) async {
    final repository = ref.read(homeRemoteRepositoryProvider);

    try {
      final media = await repository.getMediaSuggestion(searchSpace);

      if (media != null) {
        state = state.copyWith(mediaSuggestions: media);
      } else {
        debugPrint('Error: Failed to fetch media suggestions');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
