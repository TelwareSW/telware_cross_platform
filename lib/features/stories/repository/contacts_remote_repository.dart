import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/models/story_model.dart';
import 'package:http/http.dart' as http;
import '../../auth/repository/auth_local_repository.dart';

part 'contacts_remote_repository.g.dart';

@Riverpod(keepAlive: true)
ContactsRemoteRepository contactsRemoteRepository(
    ContactsRemoteRepositoryRef ref) {
  final authLocalRepository = ref.read(authLocalRepositoryProvider);
  return ContactsRemoteRepository(authLocalRepository);
}

class ContactsRemoteRepository {
  late final AuthLocalRepository authLocalRepository;
  ContactsRemoteRepository(this.authLocalRepository);

  Future<List<ContactModel>> fetchContactsFromBackend() async {
    await Future.delayed(const Duration(seconds: 2));
    List<ContactModel> users = [
      ContactModel(
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
              storyCaption: 'very good caption',
              seenIds: ['id1', 'id2']),
          StoryModel(
            storyId: 'idd12',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
            isSeen: false,
            storyCaption: 'very good  good  good caption',
            seenIds: ['id2'],
          ),
          StoryModel(
            storyId: 'idd13',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://www.e3lam.com/images/large/2015/01/unnamed-14.jpg',
            isSeen: false,
            seenIds: ['id1', 'id2'],
          ),
        ],
        userId: 'myUser',
      ),
      ContactModel(
        stories: [
          StoryModel(
            storyId: 'id11',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
            isSeen: false,
            seenIds: [],
          ),
          StoryModel(
            storyId: 'id12',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
            isSeen: false,
            storyCaption: 'very good  good  good caption',
            seenIds: [],
          ),
        ],
        userName: 'game of thrones',
        userImageUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
        userId: 'id1',
      ),
      ContactModel(
        stories: [
          StoryModel(
            storyId: 'id21',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
            isSeen: false,
            seenIds: [],
          ),
          StoryModel(
            storyId: 'id22',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
            isSeen: false,
            seenIds: [],
          ),
          StoryModel(
            storyId: 'id23',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
            isSeen: false,
            seenIds: [],
          ),
        ],
        userName: 'rings of power',
        userImageUrl:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        userId: 'id2',
      ),
      ContactModel(
        stories: [
          StoryModel(
            storyId: 'id31',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
            isSeen: false,
            storyCaption: 'very good  good  good caption',
            seenIds: [],
          ),
          StoryModel(
            storyId: 'id32',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
            isSeen: false,
            seenIds: [],
          ),
          StoryModel(
            storyId: 'id33',
            createdAt: DateTime(2024, 10, 21, 12, 0),
            storyContentUrl:
                'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
            isSeen: false,
            seenIds: [],
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

  Future<bool> postStory(File storyImage, String? caption) async {
    String uploadUrl = '${dotenv.env['BASE_URL']}/users/stories';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('POST', uri);
    request.headers['X-Session-Token'] = authLocalRepository.getToken() ?? '';
    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      storyImage.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    if (caption != null) {
      request.fields['caption'] = caption;
    }

    try {
      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      return false;
    }
  }

  Future<bool> updateProfilePicture(File storyImage) async {
    String uploadUrl = '${dotenv.env['API_URL']}/users/picture';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('PATCH', uri);
    request.headers['X-Session-Token'] = authLocalRepository.getToken()!;
    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      storyImage.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    try {
      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      return false;
    }
  }

  Future<bool> deleteProfilePicture() async {
    String uploadUrl = '${dotenv.env['API_URL']}/users/picture';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('DELETE', uri);
    request.headers['X-Session-Token'] = authLocalRepository.getToken()!;

    try {
      var response = await request.send();
      return response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      return false;
    }
  }

  Future<ContactModel?> getContact(String contactId) async {
    String uploadUrl =
        '${dotenv.env['BASE_URL']}/users/$contactId';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('GET', uri);

    request.headers['X-Session-Token'] = authLocalRepository.getToken()!;

    try {
      var response = await request.send();


      if(response.statusCode != 200){
        return null;
      }
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      ContactModel user = ContactModel(
        stories: [],
        userName: jsonResponse['data']['user']['username'],
        userId: jsonResponse['data']['user']['id'],
        userImageUrl: jsonResponse['data']['user']['photo'],
      );
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      return null;
    }
  }

  Future<bool> markStoryAsSeen(String storyId) async {
    String uploadUrl =
        '${dotenv.env['BASE_URL']}/stories/:storyId/views';
    // var uri = Uri.parse(uploadUrl);
    // var request = http.MultipartRequest('POST', uri);
    // String? token = authLocalRepository.getToken();
    // if (token != null) {
    //   request.headers['Authorization'] = 'Bearer $token';
    // }
    // try {
    //   var response = await request.send();
    //   return response.statusCode == 200;
    // } catch (e) {
    //   print('Error occurred: $e');
    //   return false;
    // }
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool> deleteStory(String storyId) async {
    // String uploadUrl = '\${domain}:\${port}/users/stories/$storyId';
    // var uri = Uri.parse(uploadUrl);
    // var request = http.MultipartRequest('DELETE', uri);
    // String? token = authLocalRepository.getToken();
    // if (token != null) {
    //   request.headers['Authorization'] = 'Bearer $token';
    // }
    // try {
    //   var response = await request.send();
    //   return response.statusCode == 204;
    // } catch (e) {
    //   print('Error occurred: $e');
    //   return false;
    // }
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
