import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';

part 'user_remote_repository.g.dart';

@Riverpod(keepAlive: true)
UserRemoteRepository userRemoteRepository(UserRemoteRepositoryRef ref) {
  return UserRemoteRepository(ref: ref, dio: Dio(BASE_OPTIONS));
}

class UserRemoteRepository {
  final Dio _dio;
  final ProviderRef<UserRemoteRepository> _ref;

  UserRemoteRepository({
    required ProviderRef<UserRemoteRepository> ref,
    required Dio dio,
  })  : _dio = dio,
        _ref = ref;

  Future<String?> _getSessionId() async {
    final authLocalRepository = _ref.read(authLocalRepositoryProvider);
    return authLocalRepository.getSessionId();
  }

  Future<Either<AppError, void>> changeNumber({
    required String newPhoneNumber,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.post(
        '/users/phone',
        data: {
          'phoneNumber': newPhoneNumber,
        },
        options: Options(
          headers: {'X-Session-Token': sessionId},
        ),
      );

      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return Left(AppError(message));
      }
      return const Right(null);
    } on DioException catch (dioException) {
      return Left(handleDioException(dioException));
    } catch (error) {
      debugPrint('Change Number error:\n${error.toString()}');
      return Left(AppError("Couldn't change number now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> updateBio({
    required String newBio,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.put(
        '/users/bio',
        data: {
          'bio': newBio,
        },
        options: Options(
          headers: {'X-Session-Token': sessionId},
        ),
      );

      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return Left(AppError(message));
      }
      return const Right(null);
    } on DioException catch (dioException) {
      return Left(handleDioException(dioException));
    } catch (error) {
      debugPrint('Update Bio error:\n${error.toString()}');
      return Left(AppError("Couldn't update bio now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> updateScreenName({
    required String newScreenFirstName,
    required String newScreenLastName,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.put(
        '/users/screen-name',
        data: {
          'screenFirstName': newScreenFirstName,
          'screenLastName': newScreenLastName,
        },
        options: Options(
          headers: {'X-Session-Token': sessionId},
        ),
      );

      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return Left(AppError(message));
      }
      return const Right(null);
    } on DioException catch (dioException) {
      return Left(handleDioException(dioException));
    } catch (error) {
      debugPrint('Update Screen Name error:\n${error.toString()}');
      return Left(AppError("Couldn't update screen name now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> changeUsername({
    required String newUsername,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.put(
        '/users/username',
        data: {
          'username': newUsername,
        },
        options: Options(
          headers: {'X-Session-Token': sessionId},
        ),
      );

      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return Left(AppError(message));
      }
      return const Right(null);
    } on DioException catch (dioException) {
      return Left(handleDioException(dioException));
    } catch (error) {
      debugPrint('Change Username error:\n${error.toString()}');
      return Left(AppError("Couldn't change username now. Please, try again later."));
    }
  }

  Future<Either<AppError, bool>> checkUsernameUniqueness({
    required String username,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.get(
        '/users/username-unique',
        queryParameters: {
          'username': username,
        },
        options: Options(
          headers: {'X-Session-Token': sessionId},
        ),
      );

      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return Left(AppError(message));
      }
      final bool isUnique = response.data['data']['isUnique'] ?? false;
      return Right(isUnique);
    } on DioException catch (dioException) {
      return Left(handleDioException(dioException));
    } catch (error) {
      debugPrint('Check Username Uniqueness error:\n${error.toString()}');
      return Left(AppError("Couldn't check username uniqueness now. Please, try again later."));
    }
  }

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
      debugPrint('Unhandled Dio Exception');
    }
    return AppError(message ?? 'Unexpected server error.');
  }
}
