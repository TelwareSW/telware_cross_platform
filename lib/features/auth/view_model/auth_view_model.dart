import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_remote_repository.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/models/app_error.dart';

part 'auth_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() {
    return AuthState.init;
  }

  void init() async {
    String? token = ref.read(authLocalRepositoryProvider).getToken();

    if (token == null) {
      // no previously stored token
      state = AuthState.unauthorized;
      return;
    }

    // try getting updated user data
    // todo: get user data from remote
    // ignore: avoid_manual_providers_as_generated_provider_dependency
    final Either<AppError, UserModel> res =
        await ref.read(authRemoteRepositoryProvider).getUser();

    res.match(
      (l) {
        // getting user data from remote failed
        final user = ref.read(authLocalRepositoryProvider).getUser();
        if (user == null) {
          state = AuthState.unauthorized;
          return;
        }
        state = AuthState.authorized;
        return;
      },
      (r) {
        // getting user data from remote succeeded
        state = AuthState.authorized;
        return;
      },
    );
  }

  // todo: create the sign up function
  void signUp(
      {required String email,
      required String phone,
      required String password}) async {
    state = AuthState.loading;

    final Either<AppError, String> res = await ref
        // ignore: avoid_manual_providers_as_generated_provider_dependency
        .read(authRemoteRepositoryProvider)
        .signUp(email: email, phone: phone, password: password);
    res.match(
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

  void login({required String email, required String password}) {
    // todo: implement login functionality
  }

  void loginWithGoogle() {}

  void loginWithFacebook() {}

  void loginWithGitHub() {}
}
