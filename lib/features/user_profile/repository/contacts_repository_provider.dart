import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import '../models/story_model.dart';

class ContactsRepository {
  final Box<UserModel> _userBox;

  ContactsRepository(this._userBox);

  Future<List<UserModel>> fetchContactsFromBackend() async {
    await Future.delayed(const Duration(seconds: 2));
    List<UserModel> users = [
      UserModel(
      userName: 'game of thrones',
      imageUrl:
      'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      stories: [
        StoryModel(
          storyId: 'idd11',
          createdAt: DateTime.now(),
          storyContent:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          isSeen: false,
          storyCaption: 'very good caption', seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id11',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id12',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
              storyCaption: 'very good  good  good caption', seens: [],

            ),
          ],
          userName: 'game of thrones',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          userId: 'id1',
        ),UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          userId: 'id2',
        ),],
        ),
        StoryModel(
          storyId: 'idd12',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          storyContent:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          isSeen: false,
          storyCaption: 'very good  good  good caption', seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          userId: 'id2',
        ),],

        ),
        StoryModel(
          storyId: 'idd13',
          createdAt: DateTime.now(),
          storyContent:
          'https://www.e3lam.com/images/large/2015/01/unnamed-14.jpg',
          isSeen: false, seens: [UserModel(
          stories: [
            StoryModel(
              storyId: 'id11',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id12',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
              storyCaption: 'very good  good  good caption', seens: [],

            ),
          ],
          userName: 'game of thrones',
          imageUrl:
          'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          userId: 'id1',
        ),UserModel(
          stories: [
            StoryModel(
              storyId: 'id21',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id22',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
            ),
            StoryModel(
              storyId: 'id23',
              createdAt: DateTime.now(),
              storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
            ),
          ],
          userName: 'rings of power',
          imageUrl:
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
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id12',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false,
            storyCaption: 'very good  good  good caption', seens: [],

          ),
        ],
        userName: 'game of thrones',
        imageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
        userId: 'id1',
      ),
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id21',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg', isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id22',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id23',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
          ),
        ],
        userName: 'rings of power',
        imageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        userId: 'id2',
      ),
      UserModel(
        stories: [
          StoryModel(
            storyId: 'id31',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false,
            storyCaption: 'very good  good  good caption', seens: [],

          ),
          StoryModel(
            storyId: 'id32',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',isSeen: false, seens: [],
          ),
          StoryModel(
            storyId: 'id33',
            createdAt: DateTime.now(),
            storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',isSeen: false, seens: [],
          ),
        ],
        userName: 'rings of power',
        imageUrl:
        'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        userId: 'id3',
      ),
    ];
    return users;
  }

  Future<void> saveContactsToHive(List<UserModel> contacts) async {
    for (var contact in contacts) {
      try{
        await _userBox.put(contact.userId,contact);
      }catch(e){
        if (kDebugMode) {
          print(e);
        }
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
