class AppError {
  final String error;
  final String? emailError;
  final String? phoneNumberError;
  final String? passwordError;
  final String? confirmPasswordError;
  final int? code;

  AppError(this.error,
      {this.code,
      this.emailError,
      this.phoneNumberError,
      this.passwordError,
      this.confirmPasswordError});
}
