import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:telware_cross_platform/core/view/screen/splash_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/log_in_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/sign_up_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/social_auth_loading_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/verification_screen.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/features/home/view/screen/home_screen.dart';
import 'package:telware_cross_platform/features/home/view/screen/inbox_screen.dart';
import 'package:telware_cross_platform/features/stories/view/screens/add_my_story_screen.dart';
import 'package:telware_cross_platform/features/stories/view/screens/show_taken_story_screen.dart';
import 'package:telware_cross_platform/features/stories/view/screens/story_screen.dart';

class Routes {
  static const String home = HomeScreen.route;
  static const String splash = SplashScreen.route;
  static const String logIn = LogInScreen.route;
  static const String signUp = SignUpScreen.route;
  static const String verification = VerificationScreen.route;
  static const String socialAuthLoading = SocialAuthLoadingScreen.route;
  static const String inboxScreen = InboxScreen.route;
  static const String addMyStory = AddMyStoryScreen.route;
  static const String showTakenStory = ShowTakenStoryScreen.route;
  static const storyScreen = StoryScreen.route;

  static GoRouter appRouter(WidgetRef ref) => GoRouter(
        initialLocation: Routes.splash,
        redirect: (context, state) {
          final isAuthenticated = ref.read(authViewModelProvider.notifier).isAuthenticated();
          if (!isAuthenticated) {
            if (state.fullPath != Routes.logIn &&
                state.fullPath != Routes.signUp &&
                state.fullPath != Routes.verification &&
                state.fullPath != Routes.splash) {
              return Routes.logIn;
            }
          }
          return null;
        },
        routes: [
          GoRoute(
            path: Routes.splash,
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: Routes.logIn,
            builder: (context, state) => const LogInScreen(),
          ),
          GoRoute(
            path: Routes.signUp,
            builder: (context, state) => const SignUpScreen(),
          ),
          // GoRoute(
          //   path: Routes.signUp,
          //   pageBuilder: (context, state) => CustomTransitionPage(
          //     key: state.pageKey,
          //     child: const SignUpScreen(),
          //     transitionsBuilder: _slideRightTransitionBuilder,
          //   ),
          // ),
          GoRoute(
            path: Routes.verification,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const VerificationScreen(),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
          GoRoute(
            path: '${Routes.socialAuthLoading}/:secretSessionId',
            builder: (context, state) {
              final secretSessionId = state.pathParameters['secretSessionId']!;
              return SocialAuthLoadingScreen(secretSessionId: secretSessionId);
            },
          ),
          GoRoute(
            path: home,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
          GoRoute(
            path: Routes.inboxScreen,
            builder: (context, state) => const InboxScreen(),
          ),
          GoRoute(
            path: Routes.addMyStory,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AddMyStoryScreen(),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
          GoRoute(
            path: Routes.showTakenStory,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: ShowTakenStoryScreen(image: state.extra as File),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
          GoRoute(
            path: Routes.storyScreen,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: StoryScreen(
                userId: (state.extra as Map<String, dynamic>)['userId'] as String,
                showSeens: (state.extra as Map<String, dynamic>)['showSeens'] as bool,
              ),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
        ],
      );

  static Widget _slideRightTransitionBuilder(
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
