import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import '../models/story_model.dart';
import '../utils/utils_functions.dart';

class ContactsRepository {
  final Box<UserModel> _userBox;

  ContactsRepository(this._userBox);

  Future<List<UserModel>> fetchContactsFromBackend() async {
    await Future.delayed(const Duration(seconds: 2));
    List<UserModel> users = [
      UserModel(
      userName: 'game of thrones',
      userImageUrl:
      'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      stories: [
        StoryModel(
          storyId: 'idd11',
          createdAt: DateTime(2024, 10, 21, 12, 0),
          storyContentUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          isSeen: false,
          storyCaption: 'very good caption', seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id11',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id12',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
              storyCaption: 'very good  good  good caption', seens: [],

            ),
          ],
          userName: 'game of thrones',
          userImageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          userId: 'id1',
        ),UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          userImageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          userId: 'id2',
        ),],
        ),
        StoryModel(
          storyId: 'idd12',
          createdAt: DateTime(2024, 10, 21, 12, 0),
          storyContentUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          isSeen: false,
          storyCaption: 'very good  good  good caption', seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          userImageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          userId: 'id2',
        ),],

        ),
        StoryModel(
          storyId: 'idd13',
          createdAt: DateTime(2024, 10, 21, 12, 0),
          storyContentUrl:
          'https://www.e3lam.com/images/large/2015/01/unnamed-14.jpg',
          isSeen: false, seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id11',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id12',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
              storyCaption: 'very good  good  good caption', seens: [],

            ),
          ],
          userName: 'game of thrones',
          userImageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          userId: 'id1',
        ),UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime(2024, 10, 21, 12, 0),
              storyContentUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          userImageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          userId: 'id2',
        ),],
        ),
      ],
      userId: 'myUser',
    ),
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id11',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id12',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
            storyCaption: 'very good  good  good caption', seens: [],

          ),
        ],
        userName: 'game of thrones',
        userImageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
        userId: 'id1',
      ),
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id21',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id22',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id23',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
          ),
        ],
        userName: 'rings of power',
        userImageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        userId: 'id2',
      ),
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id31',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false,
            storyCaption: 'very good  good  good caption', seens: [],

          ),
          StoryModel(
            storyId: 'id32',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id33',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
          ),
        ],
        userName: 'rings of power',
        userImageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        userId: 'id3',
      ),
    ];
    return users;
  }

  Future<void> saveContactsToHive(List<UserModel> contacts) async {
    for (UserModel contact in contacts) {
      final existingContact = _userBox.get(contact.userId);
      if (existingContact == null || contact != existingContact || existingContact.userImage == null) {
        if(contact.userImage == null && existingContact !=null) return;
        await _updateContactInHive(contact);
      }
    }
  }

  Future<void> _updateContactInHive(UserModel contact) async {
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


  Future<List<StoryModel>> fetchContactStoriesFromHive(String userId) async {
    final contact = _userBox.get(userId);
    return contact?.stories ?? [];
  }

  Future<UserModel?> fetchContactFromHive(String userId) async {
    return _userBox.get(userId);
  }

  List<UserModel> getAllContactsFromHive() {
    return _userBox.values.toList();
  }

  Future<List<UserModel>> fetchAndSaveContacts() async {
    final contactsFromBackend = await fetchContactsFromBackend();
    await saveContactsToHive(contactsFromBackend);
    return getAllContactsFromHive();
  }

  Future<void> deleteContactsFromHive(String userId) async {
    final box = await Hive.openBox<UserModel>('contacts');
    await box.delete(userId);
  }

  Future<void> updateContactsInHive(UserModel updatedContact) async {
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
}

final contactsRepositoryProvider  = Provider((ref) {
  final userBox = Hive.box<UserModel>('contacts');
  return ContactsRepository(userBox);
});
