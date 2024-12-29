import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';

import 'user_local_repository_test.mocks.dart';

@GenerateMocks([Box, ProviderRef])
void main() {
  late MockBox<UserModel> mockUserBox;
  late ProviderRef<UserLocalRepository> mockRefBox;
  late UserLocalRepository userLocalRepository;

  setUpAll(() async {
    await dotenv.load(fileName: "lib/.env");
  });

  setUp(() {
    mockUserBox = MockBox<UserModel>();
    mockRefBox = MockProviderRef<UserLocalRepository>();
    userLocalRepository = UserLocalRepository(
      userBox: mockUserBox,
      ref: mockRefBox,
    );
  });

  group('UserLocalRepository', () {
    test('changeNumber should update phone number', () async {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);
      when(mockUserBox.put('user', any)).thenAnswer((_) async {});

      final result = await userLocalRepository.changeNumber('1234567890');

      expect(result, isNull);
      verify(mockUserBox.get('user')).called(1);
      verify(mockUserBox.put('user', user.copyWith(phone: '1234567890')))
          .called(1);
    });

    test('changeNumber should return AppError if user not found', () async {
      when(mockUserBox.get('user')).thenReturn(null);

      final result = await userLocalRepository.changeNumber('1234567890');

      expect((result as AppError).error, 'User not found.');
      verify(mockUserBox.get('user')).called(1);
      verifyNever(mockUserBox.put('user', any));
    });

    test('changeNumber should return AppError if error occurs', () async {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);
      when(mockUserBox.put('user', any)).thenThrow(Exception());

      final result = await userLocalRepository.changeNumber('1234567890');

      expect((result as AppError).error,
          "Couldn't update phone number. Try again later.");
      verify(mockUserBox.get('user')).called(1);
      verify(mockUserBox.put('user', user.copyWith(phone: '1234567890')))
          .called(1);
    });

    test('updateBio should update bio', () async {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);
      when(mockUserBox.put('user', any)).thenAnswer((_) async {});

      final result = await userLocalRepository.updateBio('New bio');

      expect(result, isNull);
      verify(mockUserBox.get('user')).called(1);
      verify(mockUserBox.put('user', user.copyWith(bio: 'New bio'))).called(1);
    });

    test('updateBio should return AppError if user not found', () async {
      when(mockUserBox.get('user')).thenReturn(null);

      final result = await userLocalRepository.updateBio('New bio');

      expect((result as AppError).error, 'User not found.');
      verify(mockUserBox.get('user')).called(1);
      verifyNever(mockUserBox.put('user', any));
    });

    test('updateBio should return AppError if error occurs', () async {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);
      when(mockUserBox.put('user', any)).thenThrow(Exception());

      final result = await userLocalRepository.updateBio('New bio');

      expect(
          (result as AppError).error, "Couldn't update bio. Try again later.");
      verify(mockUserBox.get('user')).called(1);
      verify(mockUserBox.put('user', user.copyWith(bio: 'New bio'))).called(1);
    });

    test('updateScreenName should update screen name', () async {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);
      when(mockUserBox.put('user', any)).thenAnswer((_) async {});

      final result =
          await userLocalRepository.updateScreenName('New name');

      expect(result, isNull);
      verify(mockUserBox.get('user')).called(1);
      verify(mockUserBox.put(
              'user', user.copyWith(screenFirstName: 'New', screenLastName: 'name')))
          .called(1);
    });

    test('updateScreenName should return AppError if user not found', () async {
      when(mockUserBox.get('user')).thenReturn(null);

      final result =
          await userLocalRepository.updateScreenName('New screen name');

      expect((result as AppError).error, 'User not found.');
      verify(mockUserBox.get('user')).called(1);
      verifyNever(mockUserBox.put('user', any));
    });

    test('updateScreenName should return AppError if error occurs', () async {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);
      when(mockUserBox.put('user', any)).thenThrow(Exception());

      final result =
          await userLocalRepository.updateScreenName('New name');

      expect((result as AppError).error,
          "Couldn't update screen name. Try again later.");
      verify(mockUserBox.get('user')).called(1);
      verify(mockUserBox.put(
              'user', user.copyWith(screenFirstName: 'New', screenLastName: 'name')))
          .called(1);
    });

    test('changeUsername should update username', () async {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);
      when(mockUserBox.put('user', any)).thenAnswer((_) async {});

      final result = await userLocalRepository.changeUsername('new_username');

      expect(result, isNull);
      verify(mockUserBox.get('user')).called(1);
      verify(mockUserBox.put('user', user.copyWith(username: 'new_username')))
          .called(1);
    });

    test('changeUsername should return AppError if user not found', () async {
      when(mockUserBox.get('user')).thenReturn(null);

      final result = await userLocalRepository.changeUsername('new_username');

      expect((result as AppError).error, 'User not found.');
      verify(mockUserBox.get('user')).called(1);
      verifyNever(mockUserBox.put('user', any));
    });

    test('changeUsername should return AppError if error occurs', () async {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);
      when(mockUserBox.put('user', any)).thenThrow(Exception());

      final result = await userLocalRepository.changeUsername('new_username');

      expect((result as AppError).error,
          "Couldn't update username. Try again later.");
      verify(mockUserBox.get('user')).called(1);
      verify(mockUserBox.put('user', user.copyWith(username: 'new_username')))
          .called(1);
    });

    test(
        'checkUsernameUniqueness should return Right(true) if username is unique',
        () {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);

      final result =
          userLocalRepository.checkUsernameUniqueness('new_username');

      expect(result.isRight(), true);
      verify(mockUserBox.get('user')).called(1);
    });

    test(
        'checkUsernameUniqueness should return Left(AppError) if username is not unique',
        () {
      final user = mockUsers[0];
      when(mockUserBox.get('user')).thenReturn(user);

      final result = userLocalRepository.checkUsernameUniqueness(user.username);

      expect(result.isLeft(), true);
      expect((result as Left).value.error, 'Username is already taken.');
      verify(mockUserBox.get('user')).called(1);
    });

    test(
        'checkUsernameUniqueness should return Left(AppError) if user not found',
        () {
      when(mockUserBox.get('user')).thenReturn(null);

      final result =
          userLocalRepository.checkUsernameUniqueness('new_username');

      expect(result.isLeft(), true);
      expect((result as Left).value.error, 'User not found.');
      verify(mockUserBox.get('user')).called(1);
    });
  });

  test('setUser stores the user in the box', () async {
    final user = mockUsers[0];
    when(mockUserBox.put('user', user)).thenAnswer((_) async => Future.value());

    await userLocalRepository.setUser(user);

    verify(mockUserBox.put('user', user)).called(1);
  });

  test('getMe retrieves the user from the box', () {
    final user = mockUsers[0];
    when(mockUserBox.get('user')).thenReturn(user);

    final result = userLocalRepository.getUser();

    expect(result, user);
    verify(mockUserBox.get('user')).called(1);
  });

  test('deleteUser removes the user from the box', () async {
    when(mockUserBox.delete('user')).thenAnswer((_) async => Future.value());

    await userLocalRepository.deleteUser();

    verify(mockUserBox.delete('user')).called(1);
  });
}
