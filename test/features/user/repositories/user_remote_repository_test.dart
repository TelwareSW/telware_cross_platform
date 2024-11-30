import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/features/user/repository/user_remote_repository.dart';

import 'user_remote_repository_test.mocks.dart';

@GenerateMocks([Dio, ProviderRef])
void main() {
  late MockDio mockDio;
  late UserRemoteRepository userRemoteRepository;
  late ProviderRef<UserRemoteRepository> mockRefBox;
  late Map<String, dynamic> userMap;

  setUpAll(() async {
    await dotenv.load(fileName: "lib/.env");
  });

  setUp(() {
    mockDio = MockDio();
    mockRefBox = MockProviderRef<UserRemoteRepository>();
    userRemoteRepository = UserRemoteRepository(dio: mockDio, ref: mockRefBox);
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

  group('userRemoteRepository', () {
    test('updateEmail returns Right(null) on success', () async {
      const newEmail = 'newemail@example.com';
      when(mockRefBox.read(tokenProvider)).thenAnswer((_) => 'sessionId');
      when(mockDio.patch(
        '/users/email',
        data: {'email': newEmail},
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/users/email'),
            statusCode: 200,
          ));

      final result = await userRemoteRepository.updateEmail(newEmail: newEmail);

      expect(result.isRight(), true);
    });

    test('updateEmail returns Left(AppError) on failure', () async {
      const newEmail = 'newemail@example.com';
      when(mockRefBox.read(tokenProvider)).thenAnswer((_) => 'sessionId');
      when(mockDio.patch(
        '/users/email',
        data: {'email': newEmail},
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/users/email'),
            statusCode: 400,
            data: {'message': 'Error'},
          ));

      final result = await userRemoteRepository.updateEmail(newEmail: newEmail);

      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.error, 'Error'),
        (_) => fail('Expected an error'),
      );
    });
  });
}
