import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_remote_repository.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:fpdart/fpdart.dart';
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
        await ref.read(authRemoteRepositoryProvider).getUser();

    if (response != null) {
      state = AuthState.fail(response.error);
      // getting user data from remote failed
      final user = ref.read(authLocalRepositoryProvider).getUser();
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

  void signUp({
    required String email,
    required String phone,
    required String password,
    // todo(marwan): add the confirm password field
  }) async {
    state = AuthState.loading;

    final Either<AppError, String> response = await ref
        // ignore: avoid_manual_providers_as_generated_provider_dependency
        .read(authRemoteRepositoryProvider)
        .signUp(email: email, phone: phone, password: password);
    response.match(
      (l) {
        state = AuthState.unauthorized;
        return;
      },
      (r) {
        state = AuthState.authorized;
        return;
      },
    );
  }

  // todo(marwan): resend verification code function

  // todo(marwan): send the verification code to the back-end to verify it

  void login({required String email, required String password}) async {
    state = AuthState.loading;

    final appError = await ref
        .read(authRemoteRepositoryProvider)
        .logIn(email: email, password: password);

    if (appError != null) {
      state = AuthState.fail(appError.error);
    } else {
      state = AuthState.authorized;
    }
  }

  void forgotPassword(String email) async {
    state = AuthState.loading;
    final appError = await ref.read(authRemoteRepositoryProvider).forgotPassword(email);
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
    // delete the stored user data
    await ref.read(authLocalRepositoryProvider).deleteToken();
    await ref.read(authLocalRepositoryProvider).deleteUser();
    
    state = AuthState.init;
  }
}
