import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/models/story_model.dart';
import 'package:http/http.dart' as http;
import '../../auth/repository/auth_local_repository.dart';

part 'contacts_remote_repository.g.dart';
@Riverpod(keepAlive: true)
ContactsRemoteRepository contactsRemoteRepository(ContactsRemoteRepositoryRef ref) {
  final authLocalRepository = ref.read(authLocalRepositoryProvider);
  return ContactsRemoteRepository(authLocalRepository);
}
class ContactsRemoteRepository {
  late final AuthLocalRepository authLocalRepository;
  ContactsRemoteRepository(this.authLocalRepository);


  Future<List<ContactModel>> fetchContactsFromBackend() async {
    await Future.delayed(const Duration(seconds: 2));
    List<ContactModel> users = [
    ];
    return users;
  }

  Future<bool> postStory(File storyImage, String? caption) async {
    String uploadUrl = 'http://testing.telware.tech:3000/api/v1/users/stories';
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
    String uploadUrl = 'http://testing.telware.tech:3000/api/v1/users/picture';
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('PATCH', uri);
    request.headers['X-Session-Token'] = authLocalRepository.getToken() ?? '410b860a-de14-4cbe-b5f2-7cff8518a2f7';
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

  Future<bool> markStoryAsSeen(String storyId) async {
    String uploadUrl = 'http://testing.telware.tech:3000/api/v1/stories/:storyId/views';
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

