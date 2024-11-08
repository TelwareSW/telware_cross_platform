import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_remote_repository.dart';

import 'auth_remote_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late AuthRemoteRepository authRemoteRepository;
  late Map<String, dynamic> userMap;

  setUpAll(() async {
    await dotenv.load(fileName: "lib/.env");
  });

  setUp(() {
    mockDio = MockDio();
    authRemoteRepository = AuthRemoteRepository(dio: mockDio);
    userMap = {
            "_id": "6723fc6d5ac56a140a4287bc",
            "provider": "local",
            "username": "ZmUzd2ZodTJ2cDg",
            "screenName": "",
            "email": "test@gmail.com",
            "phoneNumber": "+201175414463",
            "photo": "c4d4f9fffad90c31.png",
            "status": "offline",
            "isAdmin": false,
            "bio": "",
            "accountStatus": "active",
            "maxFileSize": 3145,
            "automaticDownloadEnable": true,
            "lastSeenPrivacy": "everyone",
            "readReceiptsEnablePrivacy": true,
            "storiesPrivacy": "everyone",
            "picturePrivacy": "everyone",
            "invitePermessionsPrivacy": "everyone",
            "stories": [
                "6723fd205ac56a140a4287ef",
                "6723fd225ac56a140a4287f3",
                "672406cd0d60b4e85dea75ad"
            ],
            "blockedUsers": [],
            "contacts": [],
            "chats": [],
            "providerId": "6723fc6d5ac56a140a4287bc",
            "__v": 0,
            "id": "6723fc6d5ac56a140a4287bc"
        };
  });

  group('AuthRemoteRepository', () {
    test('signUp returns null on success', () async {
      when(mockDio.post('/auth/signup', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/signup'),
                statusCode: 200,
                data: {'message': 'Success'},
              ));

      final result = await authRemoteRepository.signUp(
        email: 'test@example.com',
        phone: '1234567890',
        password: 'password',
        confirmPassword: 'password',
        reCaptchaResponse: 'response',
      );

      expect(result, isNull);
    });

    test('signUp returns AppError on failure', () async {
      when(mockDio.post('/auth/signup', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/signup'),
                statusCode: 400,
                data: {'message': 'Error'},
              ));

      final result = await authRemoteRepository.signUp(
        email: 'test@example.com',
        phone: '1234567890',
        password: 'password',
        confirmPassword: 'password',
        reCaptchaResponse: 'response',
      );

      expect(result, isA<AppError>());
    });

    test('signUp handles DioException', () async {
      when(mockDio.post('/auth/signup', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/signup'),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await authRemoteRepository.signUp(
        email: 'test@example.com',
        phone: '1234567890',
        password: 'password',
        confirmPassword: 'password',
        reCaptchaResponse: 'response',
      );

      expect(result, isA<AppError>());
    });

    test('verifyEmail returns null on success', () async {
      when(mockDio.post('/auth/verify', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/verify'),
                statusCode: 200,
                data: {'message': 'Success'},
              ));

      final result = await authRemoteRepository.verifyEmail(
        email: 'test@example.com',
        code: '123456',
      );

      expect(result, isNull);
    });

    test('verifyEmail returns AppError on failure', () async {
      when(mockDio.post('/auth/verify', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/verify'),
                statusCode: 400,
                data: {'message': 'Error'},
              ));

      final result = await authRemoteRepository.verifyEmail(
        email: 'test@example.com',
        code: '123456',
      );

      expect(result, isA<AppError>());
    });

    test('verifyEmail handles DioException', () async {
      when(mockDio.post('/auth/verify', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/verify'),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await authRemoteRepository.verifyEmail(
        email: 'test@example.com',
        code: '123456',
      );

      expect(result, isA<AppError>());
    });

    test('sendConfirmationCode returns null on success', () async {
      when(mockDio.post('/auth/send-confirmation', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/send-confirmation'),
                statusCode: 200,
                data: {'message': 'Success'},
              ));

      final result = await authRemoteRepository.sendConfirmationCode(
        email: 'test@example.com',
      );

      expect(result, isNull);
    });

    test('sendConfirmationCode returns AppError on failure', () async {
      when(mockDio.post('/auth/send-confirmation', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/send-confirmation'),
                statusCode: 400,
                data: {'message': 'Error'},
              ));

      final result = await authRemoteRepository.sendConfirmationCode(
        email: 'test@example.com',
      );

      expect(result, isA<AppError>());
    });

    test('sendConfirmationCode handles DioException', () async {
      when(mockDio.post('/auth/send-confirmation', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/send-confirmation'),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await authRemoteRepository.sendConfirmationCode(
        email: 'test@example.com',
      );

      expect(result, isA<AppError>());
    });

    test('getMe returns UserModel on success', () async {
      when(mockDio.get('/users/me', options: anyNamed('options')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/users/me'),
                statusCode: 200,
                data: {
                  'data': {
                    'user': userMap,
                  }
                },
              ));

      final result = await authRemoteRepository.getMe('session-id');
      debugPrint(userMock.toMap().toString());
      
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Expected a UserModel but got an error'),
        (user) => expect(user.username, 'ZmUzd2ZodTJ2cDg'),
      );
    });

    test('getMe returns AppError on failure', () async {
      when(mockDio.get('/users/me', options: anyNamed('options')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/users/me'),
                statusCode: 400,
                data: {'message': 'Error'},
              ));

      final result = await authRemoteRepository.getMe('session-id');

      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, isA<AppError>()),
        (user) => fail('Expected an error but got a UserModel'),
      );
    });

    test('getMe handles DioException', () async {
      when(mockDio.get('/users/me', options: anyNamed('options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/users/me'),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await authRemoteRepository.getMe('session-id');

      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, isA<AppError>()),
        (user) => fail('Expected an error but got a UserModel'),
      );
    });

    test('logIn returns AuthResponseModel on success', () async {
      when(mockDio.post('/auth/login', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/login'),
                statusCode: 200,
                data: {
                  'data': {
                    'sessionId': 'test-token',
                    'user': userMap
                  }
                },
              ));

      final result = await authRemoteRepository.logIn(
        email: 'test@example.com',
        password: 'password',
      );

      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Expected an AuthResponseModel but got an error'),
        (response) => expect(response.token, 'test-token'),
      );
    });

    test('logIn returns AppError on failure', () async {
      when(mockDio.post('/auth/login', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/login'),
                statusCode: 400,
                data: {'message': 'Error'},
              ));

      final result = await authRemoteRepository.logIn(
        email: 'test@example.com',
        password: 'password',
      );

      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, isA<AppError>()),
        (response) => fail('Expected an error but got an AuthResponseModel'),
      );
    });

    test('logIn handles DioException', () async {
      when(mockDio.post('/auth/login', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await authRemoteRepository.logIn(
        email: 'test@example.com',
        password: 'password',
      );

      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, isA<AppError>()),
        (response) => fail('Expected an error but got an AuthResponseModel'),
      );
    });

    test('logOut returns null on success', () async {
      when(mockDio.post(any, options: anyNamed('options')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/logout'),
                statusCode: 200,
                data: {'message': 'Success'},
              ));

      final result = await authRemoteRepository.logOut(
        token: 'test-token',
        route: '/auth/logout',
      );

      expect(result, isNull);
    });

    test('logOut returns AppError on failure', () async {
      when(mockDio.post(any, options: anyNamed('options')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/logout'),
                statusCode: 400,
                data: {'message': 'Error'},
              ));

      final result = await authRemoteRepository.logOut(
        token: 'test-token',
        route: '/auth/logout',
      );

      expect(result, isA<AppError>());
    });

    test('logOut handles DioException', () async {
      when(mockDio.post(any, options: anyNamed('options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/logout'),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await authRemoteRepository.logOut(
        token: 'test-token',
        route: '/auth/logout',
      );

      expect(result, isA<AppError>());
    });

    test('forgotPassword returns null on success', () async {
      when(mockDio.post('/auth/password/forget', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/password/forget'),
                statusCode: 200,
                data: {'message': 'Success'},
              ));

      final result = await authRemoteRepository.forgotPassword(
        'test@example.com',
      );

      expect(result, isNull);
    });

    test('forgotPassword returns AppError on failure', () async {
      when(mockDio.post('/auth/password/forget', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/password/forget'),
                statusCode: 400,
                data: {'message': 'Error'},
              ));

      final result = await authRemoteRepository.forgotPassword(
        'test@example.com',
      );

      expect(result, isA<AppError>());
    });

    test('forgotPassword handles DioException', () async {
      when(mockDio.post('/auth/password/forget', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/password/forget'),
        type: DioExceptionType.connectionTimeout,
      ));

      final result = await authRemoteRepository.forgotPassword(
        'test@example.com',
      );

      expect(result, isA<AppError>());
    });
  });
}
