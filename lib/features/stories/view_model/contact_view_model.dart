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

  ContactViewModel(
      this._contactsLocalRepository, this._contactsRemoteRepository)
      : super(ContactViewModelState.initial());

  Future<void> fetchContacts() async {
    try {
      List<ContactModel> usersFromBackEnd =
          await _contactsRemoteRepository.fetchContactsFromBackend();
      await _contactsLocalRepository.saveContactsToHive(usersFromBackEnd);
      final contacts = _contactsLocalRepository.getAllContactsFromHive();
      state = state.copyWith(contacts: List.from(contacts), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteExpired() async {
    try {
      final allContacts = state.contacts;

      final currentDateTime = DateTime.now();

      for (final contact in allContacts) {
        final updatedStories = contact.stories.where((story) {
          final storyDateTime = story.createdAt;
          return currentDateTime
              .isBefore(storyDateTime.add(const Duration(hours: 24)));
        }).toList();
        final updatedContact = contact.copyWith(stories: updatedStories);
        await _contactsLocalRepository.updateContactInHive(updatedContact);
        final updatedContacts = state.contacts.map((u) {
          if (u.userId == contact.userId) {
            return updatedContact;
          }
          return u;
        }).toList();
        state = state.copyWith(contacts: updatedContacts);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to delete expired stories: $e');
      }
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
        debugPrint('Failed to delete contact: $e');
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
        await _contactsLocalRepository.updateContactInHive(updatedUser);

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
        debugPrint('Failed to mark story as seen: $e');
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
        debugPrint('Error saving story image: $e');
      }
    }
  }

  Future<bool> postStory(File storyImage, String storyCaption) async {
    return _contactsRemoteRepository.postStory(storyImage, storyCaption);
  }

  Future<bool> deleteStory(String storyId) async {
    return _contactsRemoteRepository.deleteStory(storyId);
  }

  Future<void> handleStoryImageAndSeenStatus(
      StoryModel story, ContactModel contact, Uint8List image) async {
    if (story.storyContent == null) {
      saveStoryImage(contact.userId, story.storyId, image);
    }
    if (!story.isSeen) {
      markStoryAsSeen(contact.userId, story.storyId);
    }
  }

  Future<List<ContactModel>> getListOfContactsFromHive(
      List<String> contactIds) async {
    List<ContactModel> seenUsers = [];
    for (String id in contactIds) {
      ContactModel? user = await getContactById(id);
      if (user != null) seenUsers.add(user);
    }
    return seenUsers;
  }
}

final usersViewModelProvider =
    StateNotifierProvider<ContactViewModel, ContactViewModelState>((ref) {
  final contactsLocalRepository = ref.watch(contactsLocalRepositoryProvider);
  final contactsRemoteRepository = ref.watch(contactsRemoteRepositoryProvider);
  return ContactViewModel(contactsLocalRepository, contactsRemoteRepository);
});
