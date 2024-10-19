import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:fpdart/fpdart.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/features/auth/models/log_in_response_model.dart';

import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';

part 'auth_remote_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRemoteRepository authRemoteRepository(AuthRemoteRepositoryRef ref) {
  return AuthRemoteRepository(ref: ref, dio: Dio(BASE_OPTIONS));
}

class AuthRemoteRepository {
  final ProviderRef<AuthRemoteRepository> _ref;
  final Dio _dio;

  AuthRemoteRepository({
    required ProviderRef<AuthRemoteRepository> ref,
    required Dio dio,
  })  : _ref = ref,
        _dio = dio;

  Future<Either<AppError, String>> signUp({
    required String email,
    required String phone,
    required String password,
    // todo(marwan): add the confirm password field
  }) async {
    try {
      final res = await _dio.post('/auth/sign-up', data: {
        'email': email,
        'phone': phone,
        'password': password,
      });

      // todo(marwan): this is not how the respond look
      // you can check the api documentation here:
      // https://app.clickup.com/9012337468/v/dc/8cjuptw-2832/8cjuptw-4012
      final details = res.data['details'];
      if (res.statusCode != 201) {
        return Left(AppError(details));
      }

      return Right(details);
    } on DioException catch (dioError) {
      String details;

      if (dioError.response != null) {
        details = dioError.response!.data['details'];
      } else if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        details =
            "Couldn't connect to the server, check your internet connection.";
      } else {
        details = 'Unhandled Dio Exception';
      }

      debugPrint(details);
      return Left(AppError(details));
    } catch (error) {
      debugPrint('Sign Up error:\n${error.toString()}');
      return Left(AppError("Couldn't sign up now. Please, try again later."));
    }
  }

  Future<Either<AppError, UserModel>> getUser() async {
    final token = _ref.read(tokenProvider);
    try {
      // todo(marwan): update the url to match the api documentation
      final res = await _dio.get('/auth/user',
          options: Options(
            headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
          ));

      // todo(marwan): you will need to get the user property of the re.data to get the user data
      // check api documentation
      final user = UserModel.fromMap(res.data);
      _ref.read(authLocalRepositoryProvider).setUser(user);
      return Right(user);
    } on DioException catch (dioError) {
      String details;

      if (dioError.response != null) {
        details = dioError.response!.data['details'];
      } else if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        details =
            "Couldn't connect to the server, check your internet connection.";
      } else {
        details = 'Unhandled Dio Exception';
      }

      debugPrint(details);
      return Left(AppError(details));
    } catch (error) {
      debugPrint('Get user error:\n${error.toString()}');
      return Left(AppError('An error occurred while fetching user data'));
    }
  }

  Future<AppError?> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio
          .post('/auth/log-in', data: {"email": email, "password": password});

      if (response.statusCode != 200) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return AppError(message);
      }

      // todo(ahmed): check response body from the back side
      final LogInResponseModel logInResponse = LogInResponseModel.fromMap(
          (response.data['data']) as Map<String, dynamic>);
      
      _ref.read(authLocalRepositoryProvider).setUser(logInResponse.user);
      _ref.read(authLocalRepositoryProvider).setToken(logInResponse.token);
      return null;
    } on DioException catch (dioException) {
      String? details;
      if (dioException.response != null) {
        details = (dioException.response!.data)['data']['message'];
        debugPrint(details);
      } else if (dioException.type == DioExceptionType.connectionTimeout ||
          dioException.type == DioExceptionType.connectionError ||
          dioException.type == DioExceptionType.unknown) {
        details = 'Failed to connect, check your internet connection.';
        debugPrint('Server is not reachable: ${dioException.message}');
      } else {
        details = 'Something wrong happened. Please, try again later.';
        debugPrint(details);
        debugPrint('here Unhandled Dio Exception');
      }
      return AppError(details ?? 'Unexpected server error.');
    } catch (e) {
      debugPrint('Log in error:\n${e.toString()}');
      return AppError('Couldn\'t log in now. Please, try again later.');
    }
  }
}
