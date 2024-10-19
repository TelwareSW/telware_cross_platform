import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import '../models/story_model.dart';
import '../repository/user_repository_provider.dart';

class UserViewModelState {
  final List<UserModel> users;
  final bool isLoading;

  UserViewModelState({
    required this.users,
    required this.isLoading,
  });

  factory UserViewModelState.initial() {
    return UserViewModelState(users: [], isLoading: false);
  }

  UserViewModelState copyWith({
    List<UserModel>? users,
    bool? isLoading,
  }) {
    return UserViewModelState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserViewModel extends StateNotifier<UserViewModelState> {
  final UsersRepository _usersRepository;


  UserViewModel(this._usersRepository) : super(UserViewModelState.initial());


  Future<void> fetchUsers() async {
    try {
      final users = await _usersRepository.fetchAndSaveUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<StoryModel>> fetchUserStories(String userId) async {
    return await _usersRepository.fetchUserStoriesFromHive(userId);
  }

  Future<UserModel?> getUserById(String userId) async {
    return await _usersRepository.fetchUserFromHive(userId);
  }

}

final usersViewModelProvider = StateNotifierProvider<UserViewModel, UserViewModelState>((ref) {
  final usersRepository = ref.watch(usersRepositoryProvider);
  return UserViewModel(usersRepository);
});