import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import '../models/story_model.dart';
import '../repository/contacts_local_repository.dart';
import '../repository/contacts_remote_repository.dart';

class ContactViewModelState {
  final List<ContactModel> contacts;
  final bool isLoading;

  ContactViewModelState({
    required this.contacts,
    required this.isLoading,
  });

  factory ContactViewModelState.initial() {
    return ContactViewModelState(contacts: [], isLoading: false);
  }

  ContactViewModelState copyWith({
    List<ContactModel>? contacts,
    bool? isLoading,
  }) {
    return ContactViewModelState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ContactViewModel extends StateNotifier<ContactViewModelState> {
  final ContactsLocalRepository _contactsLocalRepository;
  final ContactsRemoteRepository _contactsRemoteRepository;

  ContactViewModel(this._contactsLocalRepository, this._contactsRemoteRepository)
      : super(ContactViewModelState.initial());

  Future<void> fetchContacts() async {
    try {
      List<ContactModel> usersFromBackEnd = await _contactsRemoteRepository.fetchContactsFromBackend();
      await _contactsLocalRepository.saveContactsToHive(usersFromBackEnd);
      final contacts = _contactsLocalRepository.getAllContactsFromHive();
      state = state.copyWith(
          contacts: List.from(contacts), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<StoryModel>> getContactStories(String userId) async {
    return await _contactsLocalRepository.getContactStoriesFromHive(userId);
  }

  Future<ContactModel?> getContactById(String contactId) async {
    return await _contactsLocalRepository.getContactFromHive(contactId);
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await _contactsLocalRepository.deleteContactFromHive(contactId);

      final updatedContacts = state.contacts
          .where((contact) => contact.userId != contactId)
          .toList();
      state = state.copyWith(contacts: updatedContacts);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete contact: $e');
      }
    }
  }

  Future<void> markStoryAsSeen(String userId, String storyId) async {
    try {
      _contactsRemoteRepository.markStoryAsSeen(storyId);
      final user = await getContactById(userId);
      if (user != null) {
        final updatedStories = user.stories.map((story) {
          if (story.storyId == storyId) {
            return story.copyWith(isSeen: true);
          }
          return story;
        }).toList();

        final updatedUser = user.copyWith(stories: updatedStories);
        await _contactsLocalRepository.updateContactsInHive(updatedUser);

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

  Future<void> saveStoryImage(
      String userId, String storyId, Uint8List imageData) async {
    try {
      await _contactsLocalRepository.saveStoryImageLocally(
          userId, storyId, imageData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving story image: $e');
      }
    }
  }

  Future<bool> postStory(File storyImage, String storyCaption) async {
    return _contactsRemoteRepository.postStory(storyImage, storyCaption);
  }

  Future<bool> deleteStory(String storyId) async {
    return _contactsRemoteRepository.deleteStory(storyId);
  }
}

final usersViewModelProvider =
    StateNotifierProvider<ContactViewModel, ContactViewModelState>((ref) {
  final contactsLocalRepository = ref.watch(contactsLocalRepositoryProvider);
  final contactsRemoteRepository = ref.watch(contactsRemoteRepositoryProvider);
  return ContactViewModel(contactsLocalRepository,contactsRemoteRepository);
});
