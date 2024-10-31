import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});
  static const String route = '/splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const fontSize = 38.0;

    ref.listen<AuthState>(
      authViewModelProvider,
      (_, state) {
        // a callback function that takes the old and current state
        if (state == AuthState.authorized) {
          context.go(Routes.home);
        } else if (state == AuthState.unauthorized) {
          context.go(Routes.logIn);
        }
      },
    );

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: Dimensions.splashIconSize,
            height: Dimensions.splashIconSize,
            child: Image.asset(
              'assets/icon/app_icon_white.png',
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tel', style: TextStyle(fontSize: fontSize)),
              Text('Ware',
                  style: TextStyle(
                      fontSize: fontSize, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
