import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});
  static const String route = '/splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const imageSize = 170.0;

    ref.listen<AuthState>(
      authViewModelProvider,
      (_, state) {
        // a callback function that takes the old and current state
        if (state == AuthState.authorized) {
          // todo: navigate to the home screen
        } else if (state == AuthState.unauthorized) {
          // todo: navigate to the log in screen
        }
      },
    );

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: imageSize,
          height: imageSize,
          child: Image.asset('assets/icon/splash_icon.png'),
        ),
      ),
    );
  }
}
