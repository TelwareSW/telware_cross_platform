enum UserStateType {
  init,
  loading,
  unauthorized,
  authorized,
  fail,
  success,
}

class UserState {
  final UserStateType type;
  final String? message;

  const UserState._(this.type, [this.message]);

  static const init = UserState._(UserStateType.init);
  static const loading = UserState._(UserStateType.loading);
  static const unauthorized = UserState._(UserStateType.unauthorized);
  static const authorized = UserState._(UserStateType.authorized);

  static UserState fail(String message) => UserState._(UserStateType.fail, message);
  static UserState success(String message) => UserState._(UserStateType.success, message);
}
