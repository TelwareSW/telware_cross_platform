import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/models/story_model.dart';
import 'package:http/http.dart' as http;

part 'contacts_remote_repository.g.dart';

@Riverpod(keepAlive: true)
ContactsRemoteRepository contactsRemoteRepository(
    ContactsRemoteRepositoryRef ref) {
  return ContactsRemoteRepository(ref);
}

class ContactsRemoteRepository {
  final ProviderRef _ref;

  ContactsRemoteRepository(this._ref);

  Future<List<ContactModel>> fetchContactsStoriesFromBackend() async {
    List<ContactModel> users = [];
    if (USE_MOCK_DATA_STORIES == false) {
      users = [
        ContactModel(
          stories: [
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
              'https://lh3.googleusercontent.com/a/ACg8ocKeItFVrUykUDNu3JhxVKxnZzFGyRuHK5godnf1zwEZPgcRRFo=s96-c',
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
    } else {
      String storiesUrl = '$API_URL/users/contacts/stories';
      final String sessionToken = _ref.read(tokenProvider) ?? '';
      try {
        final storiesRequest =
            http.MultipartRequest('GET', Uri.parse(storiesUrl))
              ..headers['X-Session-Token'] = sessionToken;
        final streamedResponse = await storiesRequest.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final List<dynamic> contactsData = responseData['data'];

          users = contactsData.map((contactJson) {
            return ContactModel.fromJson(contactJson);
          }).toList();
        } else {
          throw Exception('Failed to load contacts: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching contacts: $error');
        rethrow;
      }
    }
    return users;
  }

  Future<ContactModel?> fetchMyStoriesFromBackend() async {
    String storiesUrl = '$API_URL/users/stories';
    String userUrl = '$API_URL/users/me';
    final String sessionToken = _ref.read(tokenProvider) ?? '';

    if (USE_MOCK_DATA) {
      return ContactModel(
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
      );
    }

    try {
      final storiesRequest = http.MultipartRequest('GET', Uri.parse(storiesUrl))
        ..headers['X-Session-Token'] = sessionToken;
      final storiesResponse = await storiesRequest.send();
      if (storiesResponse.statusCode == 200) {
        final storiesResponseBody =
            await storiesResponse.stream.bytesToString();
        final userRequest = http.MultipartRequest('GET', Uri.parse(userUrl))
          ..headers['X-Session-Token'] = sessionToken;
        final userResponse = await userRequest.send();
        if (userResponse.statusCode == 200) {
          final userResponseBody = await userResponse.stream.bytesToString();
          final Map<String, dynamic> storiesJson =
              json.decode(storiesResponseBody);
          final List<dynamic> storiesList = storiesJson['data']['stories'];
          final List<StoryModel> parsedStories = storiesList
              .map((storyJson) =>
                  StoryModel.fromJson(storyJson as Map<String, dynamic>))
              .toList();
          final Map<String, dynamic> userJson = json.decode(userResponseBody);
          final userData = userJson['data']['user'];
          return ContactModel(
            stories: parsedStories,
            userName: userData['username'],
            userId: 'myUser',
            userImageUrl: userData['photo'],
          );
        } else {
          print('Failed to fetch user data: ${userResponse.statusCode}');
          return ContactModel(stories: [], userName: 'myUser', userId: 'myUser', userImageUrl: '');
        }
      } else {
        print('Failed to fetch stories: ${storiesResponse.statusCode}');
        return ContactModel(stories: [], userName: 'myUser', userId: 'myUser', userImageUrl: '');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
        return ContactModel(stories: [], userName: 'myUser', userId: 'myUser', userImageUrl: '');
      }
    }

    return null;
  }

  Future<bool> postStory(File storyImage, String? caption) async {
    String uploadUrl = '${dotenv.env['API_URL']}/users/stories';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('POST', uri);
    request.headers['X-Session-Token'] = _ref.read(tokenProvider) ?? '';
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
        debugPrint('Error occurred: $e');
      }
      return false;
    }
  }

  Future<bool> updateProfilePicture(File storyImage) async {
    String uploadUrl = '${dotenv.env['API_URL']}/users/picture';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('PATCH', uri);
    request.headers['X-Session-Token'] = _ref.read(tokenProvider)!;
    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      storyImage.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    try {
      var response = await request.send();
      debugPrint('** status Code: ${response.statusCode.toString()}');
      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error occurred: $e');
      }
      return false;
    }
  }

  Future<bool> deleteProfilePicture() async {
    String uploadUrl = '${dotenv.env['API_URL']}/users/picture';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('DELETE', uri);
    request.headers['X-Session-Token'] = _ref.read(tokenProvider)!;

    try {
      var response = await request.send();
      return response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error occurred: $e');
      }
      return false;
    }
  }

  Future<ContactModel?> getContact(String contactId) async {
    String uploadUrl = '${dotenv.env['BASE_URL']}/users/$contactId';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('GET', uri);

    request.headers['X-Session-Token'] = _ref.read(tokenProvider)!;

    try {
      var response = await request.send();

      if (response.statusCode != 200) {
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
        debugPrint('Error occurred: $e');
      }
      return null;
    }
  }

  Future<bool> markStoryAsSeen(String storyId) async {
    String uploadUrl = '${dotenv.env['API_URL']}/stories/$storyId/views';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('POST', uri);
    request.headers['X-Session-Token'] = _ref.read(tokenProvider)!;
    try {
      var response = await request.send();
      print(response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  Future<bool> deleteStory(String storyId) async {
    String uploadUrl = '${dotenv.env['API_URL']}/users/stories/$storyId';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('DELETE', uri);
    request.headers['X-Session-Token'] = _ref.read(tokenProvider)!;
    try {
      var response = await request.send();
      print(response.statusCode);
      return response.statusCode == 204;
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }
}
