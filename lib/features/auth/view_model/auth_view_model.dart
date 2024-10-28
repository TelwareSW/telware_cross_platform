import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_remote_repository.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';

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

    if (token == null) {
      // no previously stored token
      state = AuthState.unauthorized;
      return;
    }

    // try getting updated user data
    final AppError? response =
        await ref.read(authRemoteRepositoryProvider).getMe();

    if (response != null) {
      state = AuthState.fail(response.error);
      // getting user data from remote failed
      final user = ref.read(authLocalRepositoryProvider).getMe();
      if (user == null) {
        state = AuthState.unauthorized;
        return;
      }
      state = AuthState.authorized;
    } else {
      // getting user data from remote succeeded
      state = AuthState.authorized;
    }
  }

  Future<AuthState> signUp({
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String reCaptchaResponse,
  }) async {
    state = AuthState.loading;
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
    return state;
  }

  Future<AuthState> verifyEmail(
      {required String email, required String code}) async {
    state = AuthState.loading;

    final AppError? response = await ref
        .read(authRemoteRepositoryProvider)
        .verifyEmail(email: email, code: code);

    if (response != null) {
      state = AuthState.unauthenticated;
    } else {
      state = AuthState.authenticated;
    }
    return state;
  }

  Future<AuthState> sendConfirmationCode({required String email}) async {
    state = AuthState.loading;

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

    final appError = await ref
        .read(authRemoteRepositoryProvider)
        .logIn(email: email, password: password);

    if (appError != null) {
      if (appError.code == 403) {
        state = AuthState.unauthenticated;
      } else {
        state = AuthState.fail(appError.error);
      }
    } else {
      state = AuthState.authorized;
    }
  }

  void forgotPassword(String email) async {
    state = AuthState.loading;
    final appError =
        await ref.read(authRemoteRepositoryProvider).forgotPassword(email);
    if (appError != null) {
      state = AuthState.fail(appError.error);
    } else {
      state = AuthState.success('A reset link will be sent to your email');
    }
  }

  void loginWithGoogle() {}

  void loginWithFacebook() {}

  void loginWithGitHub() {}

  Future<void> logOut() async {
    state = AuthState.loading;
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
      await ref.read(authLocalRepositoryProvider).deleteUser();
      state = AuthState.unauthorized;
    } else {
      state = AuthState.fail(appError.error);
    }
  }
}
