import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import '../models/story_model.dart';
import '../utils/utils_functions.dart';

class ContactsLocalRepository {
  final Box<ContactModel> _userBox;

  ContactsLocalRepository(this._userBox);



  Future<void> saveContactsToHive(List<ContactModel> contacts) async {
    for (ContactModel contact in contacts) {
      final existingContact = _userBox.get(contact.userId);
      if (existingContact == null ||
          contact != existingContact ||
          existingContact.userImage == null) {
        if (contact.userImage == null && existingContact?.userImage != null) {
          return;
        }
        await _updateContactInHive(contact);
      }
    }
  }

  Future<void> _updateContactInHive(ContactModel contact) async {
    try {
      Uint8List? imageBytes = await downloadImage(contact.userImageUrl);
      final contactWithImage = contact.copyWith(userImage: imageBytes);
      await _userBox.put(contact.userId, contactWithImage);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating contact in Hive: $e');
      }
    }
  }

  Future<List<StoryModel>> getContactStoriesFromHive(String userId) async {
    final contact = _userBox.get(userId);
    return contact?.stories ?? [];
  }

  Future<ContactModel?> getContactFromHive(String userId) async {
    return _userBox.get(userId);
  }

  List<ContactModel> getAllContactsFromHive() {
    return _userBox.values.toList();
  }

  Future<void> deleteContactFromHive(String userId) async {
    final box = await Hive.openBox<ContactModel>('contacts');
    await box.delete(userId);
  }

  Future<void> updateContactsInHive(ContactModel updatedContact) async {
    try {
      final existingContact = _userBox.get(updatedContact.userId);

      if (existingContact != null) {
        await _userBox.put(updatedContact.userId, updatedContact);
      } else {
        if (kDebugMode) {
          print('User not found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user in Hive: $e');
      }
      throw Exception('Error updating user in Hive');
    }
  }

  Future<void> saveStoryImageLocally(
      String userId, String storyId, Uint8List imageData) async {
    try {
      final user = await getContactFromHive(userId);
      if (user != null) {
        for (var story in user.stories) {
          if (story.storyId == storyId) {
            story.storyContent = imageData;
            break; // Exit loop since we've found the matching story
          }
        }
        await updateContactsInHive(user);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving story image to Hive: $e');
      }
    }
  }
}

final contactsLocalRepositoryProvider = Provider((ref) {
  final userBox = Hive.box<ContactModel>('contacts');
  return ContactsLocalRepository(userBox);
});