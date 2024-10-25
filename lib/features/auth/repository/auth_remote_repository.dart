import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/features/auth/models/auth_response_model.dart';

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

  Future<AppError?> signUp({
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String reCaptchaResponse,
  }) async {
    try {
      final response = await _dio.post('/auth/sign-up', data: {
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        'reCaptchaResponse': reCaptchaResponse,
      });

      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return AppError(message);
      }
    } on DioException catch (dioException) {
      return handleDioException(dioException);
    } catch (error) {
      debugPrint('Sign Up error:\n${error.toString()}');
      return AppError("Couldn't sign up now. Please, try again later.");
    }
    return null;
  }

  Future<AppError?> verifyEmail(
      {required String email, required String code}) async {
    try {
      final response = await _dio.post('/auth/verify',
          data: {'email': email, 'verificationCode': code});

      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return AppError(message);
      }
      final AuthResponseModel verificationResponse = AuthResponseModel.fromMap(
          (response.data['data']) as Map<String, dynamic>);

      _ref.read(authLocalRepositoryProvider).setUser(verificationResponse.user);
      _ref
          .read(authLocalRepositoryProvider)
          .setToken(verificationResponse.token);
    } on DioException catch (dioException) {
      return handleDioException(dioException);
    } catch (error) {
      debugPrint('Verify Email error:\n${error.toString()}');
      return AppError("Couldn't verify email now. Please, try again later.");
    }
    return null;
  }

  Future<AppError?> sendConfirmationCode({required String email}) async {
    try {
      final response =
          await _dio.post('/auth/send-confirmation', data: {'email': email});

      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return AppError(message);
      }
    } on DioException catch (dioException) {
      return handleDioException(dioException);
    } catch (error) {
      debugPrint('Resend Confirmation Code error:\n${error.toString()}');
      return AppError("Couldn't request resend now. Please, try again later.");
    }
    return null;
  }

  Future<AppError?> getMe() async {
    final token = _ref.read(tokenProvider);
    try {
      final response = await _dio.get(
        '/users/me',
        options: Options(
          headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
        ),
      );

      if (response.statusCode! > 200 || response.statusCode! < 200) {
        final message = response.data['message'];
        return AppError(message);
      }

      final user = UserModel.fromMap(response.data['data']['user']);
      _ref.read(authLocalRepositoryProvider).setUser(user);
    } on DioException catch (dioException) {
      return handleDioException(dioException);
    } catch (error) {
      debugPrint('Get user error:\n${error.toString()}');
      return AppError('Failed to connect, check your internet connection.');
    }
    return null;
  }

  Future<AppError?> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode! > 200 || response.statusCode! < 200) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        if (response.statusCode == 403) {
          return AppError(message, code: 403);
        }
        return AppError(message);
      }

      // todo(ahmed): check response body from the back side
      final AuthResponseModel logInResponse = AuthResponseModel.fromMap(
          (response.data['data']) as Map<String, dynamic>);

      _ref.read(authLocalRepositoryProvider).setUser(logInResponse.user);
      _ref.read(authLocalRepositoryProvider).setToken(logInResponse.token);
    } on DioException catch (dioException) {
      return handleDioException(dioException);
    } catch (e) {
      debugPrint('Log in error:\n${e.toString()}');
      return AppError('Couldn\'t log in now. Please, try again later.');
    }
    return null;
  }

  Future<AppError?> logOut(
      {required String token, required String route}) async {
    try {
      final response = await _dio.post(
        route,
        options: Options(
          headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
        ),
      );

      if (response.statusCode! > 200 || response.statusCode! < 200) {
        final message = response.data['message'];
        return AppError(message);
      }
    } on DioException catch (dioException) {
      return handleDioException(dioException);
    } catch (e) {
      debugPrint('Log out error:\n${e.toString()}');
      return AppError('Couldn\'t perform action now. Please, try again later.');
    }
    return null;
  }

  Future<AppError?> forgotPassword(String email) async {
    try {
      final response =
          await _dio.post('/auth/forgot-password', data: {email: email});

      if (response.statusCode! > 200 || response.statusCode! < 200) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return AppError(message);
      }
    } on DioException catch (dioException) {
      return handleDioException(dioException);
    } catch (e) {
      debugPrint('Log in error:\n${e.toString()}');
      return AppError('Couldn\'t log in now. Please, try again later.');
    }
    return null;
  }

  // todo(marwan): ask for verification code resend

  // todo(marwan): verify user. send the verification code to the back-end to check it

  AppError handleDioException(DioException dioException) {
    String? message;
    if (dioException.response != null) {
      message = (dioException.response!.data)['data']['message'];
      debugPrint(message);
    } else if (dioException.type == DioExceptionType.connectionTimeout ||
        dioException.type == DioExceptionType.connectionError ||
        dioException.type == DioExceptionType.unknown) {
      message = 'Failed to connect, check your internet connection.';
      debugPrint('Server is not reachable: ${dioException.message}');
    } else {
      message = 'Something wrong happened. Please, try again later.';
      debugPrint(message);
      debugPrint('here Unhandled Dio Exception');
    }
    return AppError(message ?? 'Unexpected server error.');
  }
}
