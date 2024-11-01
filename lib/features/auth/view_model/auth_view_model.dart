// ignore_for_file: avoid_manual_providers_as_generated_provider_dependency
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/mock/token_mock.dart';
import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/models/signup_result.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_remote_repository.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:url_launcher/url_launcher.dart';

part 'auth_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() {
    return AuthState.init;
  }

  void init() async {
    await Future.delayed(const Duration(seconds: 1, microseconds: 50));

    String? token = ref.read(authLocalRepositoryProvider).getToken();
    ref.read(tokenProvider.notifier).update((_) => token);

    if (token == null) {
      // no previously stored token
      state = AuthState.unauthorized;
      return;
    }

    if (USE_MOCK_DATA) {
      const user = userMock;
      ref.read(userProvider.notifier).update((_) => user);
      state = AuthState.authorized;
      return;
    }

    // try getting updated user data
    final response = await ref.read(authRemoteRepositoryProvider).getMe(token);

    response.match((appError) {
      state = AuthState.fail(appError.error);
      // getting user data from local as remote failed
      final user = ref.read(authLocalRepositoryProvider).getMe();
      ref.read(userProvider.notifier).update((_) => user);
      if (user == null) {
        state = AuthState.unauthorized;
        return;
      }
      state = AuthState.authorized;
    }, (user) {
      ref.read(authLocalRepositoryProvider).setUser(user);
      ref.read(userProvider.notifier).update((_) => user);
      state = AuthState.authorized;
    });
  }

  bool isAuthenticated() {
    String? token = ref.read(tokenProvider);
    return token != null && token.isNotEmpty;
  }

  Future<SignupResult> signUp({
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String reCaptchaResponse,
  }) async {
    state = AuthState.loading;

    // if we are using mock data, we will not send the request to the server
    if (USE_MOCK_DATA) {
      state = AuthState.unauthenticated;
      return SignupResult(state: state);
    }

    final AppError? response = await ref
        .read(authRemoteRepositoryProvider)
        .signUp(
            email: email,
            phone: phone,
            password: password,
            confirmPassword: confirmPassword,
            reCaptchaResponse: reCaptchaResponse);
    if (response != null) {
      state = AuthState.fail(response.error);
    } else {
      state = AuthState
          .unauthenticated; // user is not authenticated yet, he needs to verify his email
    }
    return SignupResult(state: state, error: response);
  }

  Future<AuthState> verifyEmail({
    required String email,
    required String code,
  }) async {
    state = AuthState.loading;

    if (USE_MOCK_DATA) {
      state = AuthState.authenticated;
      ref.read(authLocalRepositoryProvider).setUser(userMock);
      ref.read(userProvider.notifier).update((_) => userMock);

      ref.read(authLocalRepositoryProvider).setToken(tokenMock);
      ref.read(tokenProvider.notifier).update((_) => tokenMock);
      return state;
    }

    final response = await ref
        .read(authRemoteRepositoryProvider)
        .verifyEmail(email: email, code: code);

    if (response != null) {
      state = AuthState.fail(response.error);
      return state;
    } else {
      state = AuthState.authenticated;
    }
    return state;
  }

  Future<AuthState> sendConfirmationCode({required String email}) async {
    state = AuthState.loading;

    if (USE_MOCK_DATA) {
      state = AuthState.success('Code sent successfully');
      return state;
    }

    final AppError? response = await ref
        .read(authRemoteRepositoryProvider)
        .sendConfirmationCode(email: email);

    if (response != null) {
      state = AuthState.fail(response.error);
    } else {
      state = AuthState.success('Code sent successfully');
    }
    return state;
  }

  void login({required String email, required String password}) async {
    state = AuthState.loading;

    if (USE_MOCK_DATA) {
      if (email == userMock.email && password == userMockPassword) {
        state = AuthState.authenticated;
        ref.read(authLocalRepositoryProvider).setUser(userMock);
        ref.read(userProvider.notifier).update((_) => userMock);

        ref.read(authLocalRepositoryProvider).setToken(tokenMock);
        ref.read(tokenProvider.notifier).update((_) => tokenMock);
        return;
      } else {
        state = AuthState.fail('Invalid email or password');
        return;
      }
    }

    final response = await ref
        .read(authRemoteRepositoryProvider)
        .logIn(email: email, password: password);

    response.match((appError) {
      if (appError.code == 403) {
        state = AuthState.unauthorized;
      } else {
        state = AuthState.fail(appError.error);
      }
    }, (logInResponse) {
      ref.read(authLocalRepositoryProvider).setUser(logInResponse.user);
      ref.read(userProvider.notifier).update((_) => logInResponse.user);

      ref.read(authLocalRepositoryProvider).setToken(logInResponse.token);
      ref.read(tokenProvider.notifier).update((_) => logInResponse.token);
      state = AuthState.authenticated;
    });
  }

  void forgotPassword(String email) async {
    debugPrint('forgot password start');
    state = AuthState.loading;
    if (USE_MOCK_DATA) {
      await Future.delayed(const Duration(seconds: 1));
      state = AuthState.success('A reset link will be sent to your email');
      return;
    }
    final appError =
        await ref.read(authRemoteRepositoryProvider).forgotPassword(email);
    if (appError != null) {
      state = AuthState.fail(appError.error);
    } else {
      state = AuthState.success('A reset link will be sent to your email');
    }
    debugPrint('forgot password end');
  }

  void googleLogIn() => _launchSocialAuth(GOOGLE_AUTH_URL);

  void githubLogIn() => _launchSocialAuth(GITHUB_AUTH_URL);

  Future<void> _launchSocialAuth(String authUrl) async {
    final Uri authUri = Uri.parse(authUrl);
    try {
      if (await canLaunchUrl(authUri)) {
        await launchUrl(authUri);
      } else {
        state = AuthState.fail('Couldn\'t launch authentication page');
      }
    } catch (e) {
      state = AuthState.fail('Couldn\'t launch authentication page');
    }
  }

  Future<void> authorizeOAuth(String secretSessionId) async {
    // get the user data
    final response =
        await ref.read(authRemoteRepositoryProvider).getMe(secretSessionId);

    response.match((appError) {
      state = AuthState.fail(appError.error);
    }, (user) {
      ref.read(authLocalRepositoryProvider).setUser(user);
      ref.read(userProvider.notifier).update((_) => user);

      ref.read(authLocalRepositoryProvider).setToken(secretSessionId);
      ref.read(tokenProvider.notifier).update((_) => secretSessionId);

      state = AuthState.authenticated;
    });
  }

  Future<void> logOut() async {
    state = AuthState.loading;

    if (USE_MOCK_DATA) {
      await Future.delayed(const Duration(seconds: 1));
      await ref.read(authLocalRepositoryProvider).deleteToken();
      ref.read(tokenProvider.notifier).update((_) => null);

      await ref.read(authLocalRepositoryProvider).deleteUser();
      ref.read(userProvider.notifier).update((_) => null);
      state = AuthState.unauthenticated;
      return;
    }

    final token = ref.read(tokenProvider);

    final appError = await ref
        .read(authRemoteRepositoryProvider)
        .logOut(token: token!, route: 'auth/logout');

    await _handleLogOutState(appError);
  }

  Future<void> logOutAllOthers() async {
    final token = ref.read(tokenProvider);

    final appError = await ref
        .read(authRemoteRepositoryProvider)
        .logOut(token: token!, route: 'auth/logout-others');

    if (appError != null) {
      state = AuthState.fail(appError.error);
    }
  }

  Future<void> logOutAll() async {
    state = AuthState.loading;
    final token = ref.read(tokenProvider);

    final appError = await ref
        .read(authRemoteRepositoryProvider)
        .logOut(token: token!, route: 'auth/logout-all');

    await _handleLogOutState(appError);
  }

  Future<void> _handleLogOutState(AppError? appError) async {
    if (appError == null) {
      // successful log out operation
      await ref.read(authLocalRepositoryProvider).deleteToken();
      ref.read(tokenProvider.notifier).update((_) => null);

      await ref.read(authLocalRepositoryProvider).deleteUser();
      ref.read(userProvider.notifier).update((_) => null);
      state = AuthState.unauthorized;
    } else {
      state = AuthState.fail(appError.error);
    }
  }
}
