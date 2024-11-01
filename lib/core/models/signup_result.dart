import 'package:telware_cross_platform/core/models/app_error.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';

class SignupResult {
  final AuthState state;
  final AppError? error;

  SignupResult({required this.state, this.error});
}
