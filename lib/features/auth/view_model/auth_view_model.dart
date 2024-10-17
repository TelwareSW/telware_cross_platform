import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/features/auth/repository/auth_local_repository.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';

part 'auth_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {

  @override
  AuthState build() {
    return AuthState.init;
  }

  void init() {
    String? token = ref.read(authLocalRepositoryProvider).getToken();

    if (token == null) { // no previously stored token
      state = AuthState.unauthorized;
      return;
    }

    // try getting updated user data
    // todo: get user data from remote
  }

  // todo: create the sign up function

  void login({required String email, required String password}) {
    // todo: implement login functionality
  }

  void loginWithGoogle() {}

  void loginWithFacebook() {}

  void loginWithGitHub() {}
}