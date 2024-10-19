enum AuthStateType {
  init,
  loading,
  fail,
  success,
  unauthorized,
  authorized,
}

class AuthState {
  final AuthStateType type;
  final String? message;

  const AuthState._(this.type, [this.message]);

  static const init = AuthState._(AuthStateType.init);
  static const loading = AuthState._(AuthStateType.loading);
  static const unauthorized = AuthState._(AuthStateType.unauthorized);
  static const authorized = AuthState._(AuthStateType.authorized);
  
  static AuthState fail(String message) =>
      AuthState._(AuthStateType.fail, message);
  static AuthState success(String message) =>
      AuthState._(AuthStateType.success, message);
}
