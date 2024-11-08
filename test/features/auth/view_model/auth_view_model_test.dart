import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/features/auth/models/auth_response_model.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_remote_repository.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';

import 'auth_view_model_test.mocks.dart';

@GenerateMocks([AuthLocalRepository, AuthRemoteRepository])
void main() {
  late MockAuthLocalRepository mockAuthLocalRepository;
  late MockAuthRemoteRepository mockAuthRemoteRepository;
  late AuthViewModel authViewModel;
  late ProviderContainer container;

  setUpAll(() async {
    await dotenv.load(fileName: "lib/.env");
  });

  setUp(() {
    mockAuthLocalRepository = MockAuthLocalRepository();
    mockAuthRemoteRepository = MockAuthRemoteRepository();
    container = ProviderContainer(
      overrides: [
        authLocalRepositoryProvider.overrideWithValue(mockAuthLocalRepository),
        authRemoteRepositoryProvider.overrideWithValue(mockAuthRemoteRepository),
      ],
    );

    provideDummy<Either<AppError, UserModel>>(Right(userMock));
    provideDummy<Either<AppError, AuthResponseModel>>(Right(AuthResponseModel(token: 'test-token', user: userMock)));
    provideDummy<Either<AppError, UserModel>>(Left(AppError('Error')));

    authViewModel = container.read(authViewModelProvider.notifier);
  });


  group('AuthViewModel', () {
    // cheked
    test('init initializes the state correctly', () async {
      when(mockAuthLocalRepository.getToken()).thenReturn('test-token');
      when(mockAuthRemoteRepository.getMe('test-token')).thenAnswer(
        (_) async => Right(userMock),
      );

      await authViewModel.init();

      expect(container.read(authViewModelProvider).type, AuthStateType.authenticated);
      verify(mockAuthLocalRepository.getToken()).called(1);
      verify(mockAuthRemoteRepository.getMe('test-token')).called(1);
    });

    // cheked
    test('init handles missing token', () async {
      when(mockAuthLocalRepository.getToken()).thenReturn(null);

      await authViewModel.init();

      expect(container.read(authViewModelProvider).type, AuthStateType.unauthenticated);
      verify(mockAuthLocalRepository.getToken()).called(1);
    });

    // cheked
    test('init handles getMe from remote failure and local success', () async {
      when(mockAuthLocalRepository.getToken()).thenReturn('test-token');
      when(mockAuthRemoteRepository.getMe('test-token')).thenAnswer(
        (_) async => Left(AppError('Error')),
      );
      when(mockAuthLocalRepository.getMe()).thenReturn(userMock);

      await authViewModel.init();

      expect(container.read(authViewModelProvider).type, AuthStateType.authenticated);
      verify(mockAuthLocalRepository.getToken()).called(1);
      verify(mockAuthRemoteRepository.getMe('test-token')).called(1);
      verify(mockAuthLocalRepository.getMe()).called(1);
    });

    test('init handles getMe from remote failure and local failure', () async {
      when(mockAuthLocalRepository.getToken()).thenReturn('test-token');
      when(mockAuthRemoteRepository.getMe('test-token')).thenAnswer(
        (_) async => Left(AppError('Error')),
      );
      when(mockAuthLocalRepository.getMe()).thenReturn(null);

      await authViewModel.init();

      expect(container.read(authViewModelProvider).type, AuthStateType.unauthenticated);
      verify(mockAuthLocalRepository.getToken()).called(1);
      verify(mockAuthRemoteRepository.getMe('test-token')).called(1);
      verify(mockAuthLocalRepository.getMe()).called(1);
    });

    test('isAuthorized returns true when authenticated', () {
      container = ProviderContainer(
        overrides: [
          authLocalRepositoryProvider.overrideWithValue(mockAuthLocalRepository),
          authRemoteRepositoryProvider.overrideWithValue(mockAuthRemoteRepository),
          tokenProvider.overrideWith((ref) => 'test-token'),
        ],
      );
      authViewModel = container.read(authViewModelProvider.notifier);

      final result = authViewModel.isAuthorized();

      expect(result, true);
    });

    test('isAuthorized returns false when not authenticated', () {
      container = ProviderContainer(
        overrides: [
          authLocalRepositoryProvider.overrideWithValue(mockAuthLocalRepository),
          authRemoteRepositoryProvider.overrideWithValue(mockAuthRemoteRepository),
          tokenProvider.overrideWith((ref) => null),
        ],
      );
      authViewModel = container.read(authViewModelProvider.notifier);

      final result = authViewModel.isAuthorized();

      expect(result, false);
    });

    test('signUp status is unauthenticated on signUp sucess', () async {
      when(mockAuthRemoteRepository.signUp(
        email: anyNamed('email'),
        phone: anyNamed('phone'),
        password: anyNamed('password'),
        confirmPassword: anyNamed('confirmPassword'),
        reCaptchaResponse: anyNamed('reCaptchaResponse'),
      )).thenAnswer((_) async => Future.value(null));

      await authViewModel.signUp(
        email: 'test@example.com',
        phone: '1234567890',
        password: 'password',
        confirmPassword: 'password',
        reCaptchaResponse: 'response',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.unverified);
    });

    test('signUp status is fail on signUp fail', () async {
      when(mockAuthRemoteRepository.signUp(
        email: anyNamed('email'),
        phone: anyNamed('phone'),
        password: anyNamed('password'),
        confirmPassword: anyNamed('confirmPassword'),
        reCaptchaResponse: anyNamed('reCaptchaResponse'),
      )).thenAnswer((_) async => Future.value(AppError('Error')));

      await authViewModel.signUp(
        email: 'test@example.com',
        phone: '1234567890',
        password: 'password',
        confirmPassword: 'password',
        reCaptchaResponse: 'response',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.fail);
    });

    test('logIn sets state to authenticated on success', () async {
      when(mockAuthRemoteRepository.logIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(AuthResponseModel(
        token: 'test-token',
        user: userMock,
      )));

      await authViewModel.login(
        email: 'test@example.com',
        password: 'password',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.authenticated);
      verify(mockAuthRemoteRepository.logIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('logIn sets state to fail on failure', () async {
      when(mockAuthRemoteRepository.logIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Left(AppError('Error')));

      await authViewModel.login(
        email: 'test@example.com',
        password: 'password',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.fail);
      verify(mockAuthRemoteRepository.logIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('logIn sets state to unverified for unverified email log in attempt', () async {
      when(mockAuthRemoteRepository.logIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Left(AppError('Error', code: 403)));

      await authViewModel.login(
        email: 'test@example.com',
        password: 'password',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.unverified);
      verify(mockAuthRemoteRepository.logIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('logOut sets state to unauthenticated', () async {
      container = ProviderContainer(
        overrides: [
          authLocalRepositoryProvider.overrideWithValue(mockAuthLocalRepository),
          authRemoteRepositoryProvider.overrideWithValue(mockAuthRemoteRepository),
          tokenProvider.overrideWith((ref) => 'test-token'),
        ],
      );
      authViewModel = container.read(authViewModelProvider.notifier);

      when(mockAuthRemoteRepository.logOut(token: 'test-token', route: '/auth/logout')).thenAnswer((_) async => Future.value());
      when(mockAuthLocalRepository.deleteToken()).thenAnswer((_) async => Future.value());
      when(mockAuthLocalRepository.deleteUser()).thenAnswer((_) async => Future.value());

      await authViewModel.logOut();

      expect(container.read(authViewModelProvider).type, AuthStateType.unauthenticated);
      verify(mockAuthLocalRepository.deleteToken()).called(1);
      verify(mockAuthLocalRepository.deleteUser()).called(1);
    });

    test('logOut handles errors gracefully', () async {
      container = ProviderContainer(
        overrides: [
          authLocalRepositoryProvider.overrideWithValue(mockAuthLocalRepository),
          authRemoteRepositoryProvider.overrideWithValue(mockAuthRemoteRepository),
          tokenProvider.overrideWith((ref) => 'test-token'),
        ],
      );
      authViewModel = container.read(authViewModelProvider.notifier);

      when(mockAuthRemoteRepository.logOut(token: 'test-token', route: '/auth/logout')).thenAnswer((_) async => Future.value(AppError('Log out failed')));
      when(mockAuthLocalRepository.deleteToken()).thenAnswer((_) async => Future.value());
      when(mockAuthLocalRepository.deleteUser()).thenAnswer((_) async => Future.value());

      await authViewModel.logOut();

      expect(container.read(authViewModelProvider).type, AuthStateType.fail);
      verifyNever(mockAuthLocalRepository.deleteToken());
      verifyNever(mockAuthLocalRepository.deleteUser());
    });

    test('verifyEmail returns null on success', () async {
      when(mockAuthRemoteRepository.verifyEmail(
        email: anyNamed('email'),
        code: anyNamed('code'),
      )).thenAnswer((_) async => Future.value(null));

      await authViewModel.verifyEmail(
        email: 'test@example.com',
        code: '123456',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.verified);
    });

    test('verifyEmail returns AppError on failure', () async {
      when(mockAuthRemoteRepository.verifyEmail(
        email: anyNamed('email'),
        code: anyNamed('code'),
      )).thenAnswer((_) async => Future.value(AppError('Error')));

      await authViewModel.verifyEmail(
        email: 'test@example.com',
        code: '123456',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.fail);
    });

    test('sendConfirmationCode returns null on success', () async {
      when(mockAuthRemoteRepository.sendConfirmationCode(
        email: anyNamed('email'),
      )).thenAnswer((_) async => Future.value(null));

      await authViewModel.sendConfirmationCode(
        email: 'test@example.com',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.success);
    });

    test('sendConfirmationCode returns AppError on failure', () async {
      when(mockAuthRemoteRepository.sendConfirmationCode(
        email: anyNamed('email'),
      )).thenAnswer((_) async => Future.value(AppError('Error')));

      await authViewModel.sendConfirmationCode(
        email: 'test@example.com',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.fail);
    });

    test('forgotPassword returns null on success', () async {
      when(mockAuthRemoteRepository.forgotPassword(
        'test@example.com',
      )).thenAnswer((_) async => Future.value(null));

      await authViewModel.forgotPassword(
        'test@example.com',
      );

      expect(container.read(authViewModelProvider).message, 'A reset link will be sent to your email');
    });

    test('forgotPassword returns AppError on failure', () async {
      when(mockAuthRemoteRepository.forgotPassword(
        'test@example.com',
      )).thenAnswer((_) async => Future.value(AppError('Error')));

      await authViewModel.forgotPassword(
        'test@example.com',
      );

      expect(container.read(authViewModelProvider).type, AuthStateType.fail);
    });
  });
}