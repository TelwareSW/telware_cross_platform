import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import '../models/story_model.dart';
import '../repository/contacts_repository_provider.dart';

class ContactViewModelState {
  final List<UserModel> contacts;
  final bool isLoading;

  ContactViewModelState({
    required this.contacts,
    required this.isLoading,
  });

  factory ContactViewModelState.initial() {
    return ContactViewModelState(contacts: [], isLoading: false);
  }

  ContactViewModelState copyWith({
    List<UserModel>? contacts,
    bool? isLoading,
  }) {
    return ContactViewModelState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ContactViewModel extends StateNotifier<ContactViewModelState> {
  final ContactsRepository _contactsRepository;


  ContactViewModel(this._contactsRepository) : super(ContactViewModelState.initial());


  Future<void> fetchContacts() async {
    try {
      final fetchedContacts = await _contactsRepository.fetchAndSaveContacts();
      state = state.copyWith(contacts: List.from(fetchedContacts), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<StoryModel>> fetchContactStories(String userId) async {
    return await _contactsRepository.fetchContactStoriesFromHive(userId);
  }

  Future<UserModel?> getContactById(String contactId) async {
    return await _contactsRepository.fetchContactFromHive(contactId);
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await _contactsRepository.deleteContactsFromHive(contactId);

      final updatedContacts = state.contacts.where((contact) => contact.userId != contactId).toList();
      state = state.copyWith(contacts: updatedContacts);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete contact: $e');
      }
    }
  }

  Future<void> markStoryAsSeen(String userId, String storyId) async {
    try {
      final user = await getContactById(userId);
      if (user != null) {
        final updatedStories = user.stories.map((story) {
          if (story.storyId == storyId) {
            return story.copyWith(isSeen: true);
          }
          return story;
        }).toList();

        final updatedUser = user.copyWith(stories: updatedStories);
        await _contactsRepository.updateContactsInHive(updatedUser);

        final updatedUsers = state.contacts.map((u) {
          if (u.userId == userId) {
            return updatedUser;
          }
          return u;
        }).toList();

        state = state.copyWith(contacts: updatedUsers);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to mark story as seen: $e');
      }
    }
  }

}

final usersViewModelProvider = StateNotifierProvider<ContactViewModel, ContactViewModelState>((ref) {
  final contactsRepository = ref.watch(contactsRepositoryProvider);
  return ContactViewModel(contactsRepository);
});