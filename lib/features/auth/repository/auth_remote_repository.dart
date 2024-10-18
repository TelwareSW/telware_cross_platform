import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:fpdart/fpdart.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:flutter/foundation.dart';

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
  }) async {
    try {
      final res = await _dio.post('/auth/sign-up', data: {
        'email': email,
        'phone': phone,
        'password': password,
      });

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
      final res = await _dio.get('/auth/user',
          options: Options(
            headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
          ));

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
}
