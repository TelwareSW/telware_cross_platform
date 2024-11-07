import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';

import 'auth_local_repository_test.mocks.dart';

@GenerateMocks([Box])

void main() {
  late MockBox<String> mockTokenBox;
  late MockBox<UserModel> mockUserBox;
  late AuthLocalRepository authLocalRepository;

  setUpAll(() async {
    await dotenv.load(fileName: "lib/.env");
  });

  setUp(() {
    mockTokenBox = MockBox<String>();
    mockUserBox = MockBox<UserModel>();
    authLocalRepository = AuthLocalRepository(
      tokenBox: mockTokenBox,
      userBox: mockUserBox,
    );
  });

  group('AuthLocalRepository', () {
    test('setToken stores the token in the box', () async {
      const token = 'test-token';
      when(mockTokenBox.put('token', token)).thenAnswer((_) async => Future.value());

      await authLocalRepository.setToken(token);

      verify(mockTokenBox.put('token', token)).called(1);
    });

    test('getToken retrieves the token from the box', () {
      const token = 'test-token';
      when(mockTokenBox.get('token')).thenReturn(token);

      final result = authLocalRepository.getToken();

      expect(result, token);
      verify(mockTokenBox.get('token')).called(1);
    });

    test('deleteToken removes the token from the box', () async {
      when(mockTokenBox.delete('token')).thenAnswer((_) async => Future.value());

      await authLocalRepository.deleteToken();

      verify(mockTokenBox.delete('token')).called(1);
    });

    test('setUser stores the user in the box', () async {
      final user = userMock;
      when(mockUserBox.put('user', user)).thenAnswer((_) async => Future.value());

      await authLocalRepository.setUser(user);

      verify(mockUserBox.put('user', user)).called(1);
    });

    test('getMe retrieves the user from the box', () {
      final user = userMock;
      when(mockUserBox.get('user')).thenReturn(user);

      final result = authLocalRepository.getMe();

      expect(result, user);
      verify(mockUserBox.get('user')).called(1);
    });

    test('deleteUser removes the user from the box', () async {
      when(mockUserBox.delete('user')).thenAnswer((_) async => Future.value());

      await authLocalRepository.deleteUser();

      verify(mockUserBox.delete('user')).called(1);
    });

    // Additional complex test cases

    test('getToken returns null if token does not exist', () {
      when(mockTokenBox.get('token')).thenReturn(null);

      final result = authLocalRepository.getToken();

      expect(result, isNull);
      verify(mockTokenBox.get('token')).called(1);
    });

    test('getMe returns null if user does not exist', () {
      when(mockUserBox.get('user')).thenReturn(null);

      final result = authLocalRepository.getMe();

      expect(result, isNull);
      verify(mockUserBox.get('user')).called(1);
    });

    test('setToken and getToken maintain data integrity', () async {
      const token = 'test-token';
      when(mockTokenBox.put('token', token)).thenAnswer((_) async => Future.value());
      when(mockTokenBox.get('token')).thenReturn(token);

      await authLocalRepository.setToken(token);
      final result = authLocalRepository.getToken();

      expect(result, token);
      verify(mockTokenBox.put('token', token)).called(1);
      verify(mockTokenBox.get('token')).called(1);
    });

    test('setUser and getMe maintain data integrity', () async {
      final user = userMock;
      when(mockUserBox.put('user', user)).thenAnswer((_) async => Future.value());
      when(mockUserBox.get('user')).thenReturn(user);

      await authLocalRepository.setUser(user);
      final result = authLocalRepository.getMe();

      expect(result, user);
      verify(mockUserBox.put('user', user)).called(1);
      verify(mockUserBox.get('user')).called(1);
    });
  });
}