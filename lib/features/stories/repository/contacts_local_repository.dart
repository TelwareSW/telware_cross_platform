import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import '../models/story_model.dart';
import '../utils/utils_functions.dart';

part 'contacts_local_repository.g.dart';

@Riverpod(keepAlive: true)
ContactsLocalRepository contactsLocalRepository(
    ContactsLocalRepositoryRef ref) {
  final userBox = Hive.box<ContactModel>('contacts');
  return ContactsLocalRepository(userBox);
}

class ContactsLocalRepository {
  final Box<ContactModel> _userBox;

  ContactsLocalRepository(this._userBox);

  Future<void> saveContactsToHive(List<ContactModel> contacts) async {
    for (ContactModel contact in contacts) {
      final existingContact = _userBox.get(contact.userId);
      if (existingContact == null ||
          contact != existingContact ||
          existingContact.userImage == null) {
        if (existingContact!= null &&
            contact.userImage == null &&
            existingContact.userImage != null &&
            existingContact.userImageUrl == contact.userImageUrl) { //the difference is the existing has teh image bytes only
          contact.userImage=existingContact.userImage;
        }
        await _saveContactImageInHive(contact);
      }
    }
  }

  Future<void> _saveContactImageInHive(ContactModel contact) async {
    try {
      Uint8List? imageBytes = await downloadImage(contact.userImageUrl);
      final contactWithImage = contact.copyWith(userImage: imageBytes);
      await _userBox.put(contact.userId, contactWithImage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating contact in Hive: $e');
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

  Future<void> updateContactInHive(ContactModel updatedContact) async {
    try {
      final existingContact = _userBox.get(updatedContact.userId);

      if (existingContact != null) {
        await _userBox.put(updatedContact.userId, updatedContact);
      } else {
        if (kDebugMode) {
          debugPrint('User not found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update user in Hive: $e');
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
            break;
          }
        }
        await updateContactInHive(user);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving story image to Hive: $e');
      }
    }
  }
}
