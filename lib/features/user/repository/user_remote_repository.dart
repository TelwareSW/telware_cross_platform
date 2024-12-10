import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';

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
    return _ref.read(tokenProvider);
  }

  // fetch users
  Future<Either<AppError, List<UserModel>>> fetchUsers() async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.get(
        '/users',
        options: Options(
          headers: {'X-Session-Token': sessionId},
        ),
      );
      if (response.statusCode! >= 400) {
        final String message = response.data?['message'] ?? 'Unexpected Error';
        return Left(AppError(message));
      }

      final List<dynamic> users = response.data?['data']['users'] ?? [];

      var filteredUsers = await Future.wait(
          (users).map((user) => UserModel.fromMap(user)).toList());

      filteredUsers = await Future.wait(filteredUsers.map((user) async {
        if (user.photo != null) {
          return user.copyWith(photo: await downloadAndSaveFile(user.photo!));
        }
        return user;
      }).toList());
      return Right(filteredUsers);
    } on DioException catch (dioException) {
      return Left(handleDioException(dioException));
    } catch (error) {
      debugPrint('Fetch Users error:\n${error.toString()}');
      return Left(
          AppError("Couldn't fetch users now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> changeNumber({
    required String newPhoneNumber,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.patch(
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
      return Left(
          AppError("Couldn't change number now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> updateBio({
    required String newBio,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.patch(
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
      return Left(
          AppError("Couldn't update bio now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> updateScreenName({
    required String newScreenFirstName,
    required String newScreenLastName,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.patch(
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
      return Left(AppError(
          "Couldn't update screen name now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> updateEmail({
    required String newEmail,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.patch(
        '/users/email',
        data: {
          'email': newEmail,
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
      debugPrint('Update Email error:\n${error.toString()}');
      return Left(
          AppError("Couldn't update email now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> changeUsername({
    required String newUsername,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.patch(
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
      return Left(
          AppError("Couldn't change username now. Please, try again later."));
    }
  }

  Future<Either<AppError, bool>> checkUsernameUniqueness({
    required String username,
  }) async {
    try {
      final response =
          await _dio.get('/users/username/check', queryParameters: {
        'username': username,
      });

      if (response.statusCode! >= 400) {
        return const Right(false);
      }
      return const Right(true);
    } on DioException catch (dioException) {
      return Left(handleDioException(dioException));
    } catch (error) {
      debugPrint('Check Username Uniqueness error:\n${error.toString()}');
      return Left(AppError(
          "Couldn't check username uniqueness now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> changeLastSeenPrivacy({
    required String privacy,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.patch(
        '/users/privacy/last-seen',
        data: {
          'privacy': privacy,
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
      debugPrint('Change last seen privacy error:\n${error.toString()}');
      return Left(AppError(
          "Couldn't change last seen privacy now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> changeProfilePhotoPrivacy({
    required String privacy,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.patch(
        '/users/privacy/picture',
        data: {
          'privacy': privacy,
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
      debugPrint('Change profile photo privacy error:\n${error.toString()}');
      return Left(AppError(
          "Couldn't change profile photo privacy now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> changeInvitePermissions({
    required String permissions,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.patch(
        '/users/privacy/invite-permissions',
        data: {
          'privacy': permissions,
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
      debugPrint('Change invite permissions error:\n${error.toString()}');
      return Left(AppError(
          "Couldn't change invite permissions now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> blockUser({required String userId}) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.post(
        '/users/block/$userId',
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
      debugPrint('block user error:\n${error.toString()}');
      return Left(
          AppError("Couldn't block user now. Please, try again later."));
    }
  }

  Future<Either<AppError, void>> unblockUser({required String userId}) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _dio.delete(
        '/users/block/$userId',
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
      debugPrint('block user error:\n${error.toString()}');
      return Left(
          AppError("Couldn't block user now. Please, try again later."));
    }
  }

  AppError handleDioException(DioException dioException) {
    String? message;
    if (dioException.response != null) {
      message =
          dioException.response!.data?['message'] ?? 'Unexpected server Error';
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
