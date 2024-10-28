import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/view/screen/splash_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/log_in_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/sign_up_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/verification_screen.dart';
import 'package:telware_cross_platform/features/home/view/screen/home_screen.dart';

class Routes {
  static const String home = HomeScreen.route;
  static const String splash = SplashScreen.route;
  static const String logIn = LogInScreen.route;
  static const String signUp = SignUpScreen.route;
  static const String verification = VerificationScreen.route;

  static GoRouter appRouter(bool isAuthenticated) => GoRouter(
        initialLocation: Routes.splash,
        redirect: (context, state) {
          if (!isAuthenticated) {
            if (state.path != Routes.logIn &&
                state.path != Routes.signUp &&
                state.path != Routes.verification &&
                state.path != Routes.splash) {
              return Routes.logIn;
            }
          }
          return null;
        },
        routes: [
          GoRoute(
            path: Routes.splash,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SplashScreen(),
              transitionsBuilder: _transitionBuilder,
            ),
          ),
          GoRoute(
            path: Routes.logIn,
            builder: (context, state) => const LogInScreen(),
          ),
          GoRoute(
            path: Routes.signUp,
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            path: Routes.verification,
            builder: (context, state) => const VerificationScreen(),
          ),
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      );

  static Widget _transitionBuilder(
      context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    final offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}
