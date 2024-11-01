enum AuthStateType {
  init,
  loading,
  fail,
  success,
  unauthenticated,
  authenticated,
  unverified,
  verified,
}

class AuthState {
  final AuthStateType type;
  final String? message;

  const AuthState._(this.type, [this.message]);

  static const init = AuthState._(AuthStateType.init);
  static const loading = AuthState._(AuthStateType.loading);
  static const unauthenticated = AuthState._(AuthStateType.unauthenticated);
  static const authenticated = AuthState._(AuthStateType.authenticated);
  static const unverified = AuthState._(AuthStateType.unverified);
  static const verified = AuthState._(AuthStateType.verified);

  static AuthState fail(String message) =>
      AuthState._(AuthStateType.fail, message);

  static AuthState success(String message) =>
      AuthState._(AuthStateType.success, message);
}
