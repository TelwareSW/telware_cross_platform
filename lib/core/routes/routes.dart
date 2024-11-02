import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:telware_cross_platform/core/view/screen/splash_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/change_number_form_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/log_in_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/sign_up_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/social_auth_loading_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/verification_screen.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/features/home/view/screens/home_screen.dart';
import 'package:telware_cross_platform/features/home/view/screens/inbox_screen.dart';
import 'package:telware_cross_platform/features/stories/view/screens/add_my_image_screen.dart';
import 'package:telware_cross_platform/features/stories/view/screens/show_taken_image_screen.dart';
import 'package:telware_cross_platform/features/stories/view/screens/story_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/block_user.dart';
import 'package:telware_cross_platform/features/user/view/screens/blocked_users.dart';
import 'package:telware_cross_platform/features/user/view/screens/change_number_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/change_username_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/privacy_and_security_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/profile_info_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/settings_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/user_profile_screen.dart';

import '../../features/user/view/screens/devices_screen.dart';

class Routes {
  static const String home = HomeScreen.route;
  static const String splash = SplashScreen.route;
  static const String logIn = LogInScreen.route;
  static const String signUp = SignUpScreen.route;
  static const String verification = VerificationScreen.route;
  static const String socialAuthLoading = SocialAuthLoadingScreen.route;
  static const String inboxScreen = InboxScreen.route;
  static const String addMyStory = AddMyImageScreen.route;
  static const String showTakenStory = ShowTakenImageScreen.route;
  static const String storyScreen = StoryScreen.route;
  static const String devicesScreen = DevicesScreen.route;
  static const String settings = SettingsScreen.route;
  static const String changeNumber = ChangeNumberScreen.route;
  static const String changeNumberForm = ChangeNumberFormScreen.route;
  static const String changeUsername = ChangeUsernameScreen.route;
  static const String profileInfo = ProfileInfoScreen.route;
  static const String blockUser = BlockUserScreen.route;
  static const String blockedUser = BlockedUsersScreen.route;
  static const String userProfile = UserProfileScreen.route;
  static const String privacySettings = PrivacySettingsScreen.route;

  static GoRouter appRouter(WidgetRef ref) => GoRouter(
        initialLocation: Routes.splash,
        redirect: (context, state) {
          final isAuthorized =
              ref.read(authViewModelProvider.notifier).isAuthorized();
          debugPrint('fullPath: ${state.fullPath}');
          if (!isAuthorized) {
            if ((state.fullPath?.startsWith(Routes.socialAuthLoading) ?? false)) return null;
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
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SignUpScreen(),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
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
              child: const AddMyImageScreen(),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
          GoRoute(
            path: Routes.showTakenStory,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: ShowTakenImageScreen(image: state.extra as File),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
          GoRoute(
            path: Routes.storyScreen,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: StoryScreen(
                userId:
                    (state.extra as Map<String, dynamic>)['userId'] as String,
                showSeens:
                    (state.extra as Map<String, dynamic>)['showSeens'] as bool,
              ),
              transitionsBuilder: _slideRightTransitionBuilder,
            ),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: Routes.changeNumber,
            builder: (context, state) => const ChangeNumberScreen(),
          ),
          GoRoute(
            path: Routes.changeNumberForm,
            builder: (context, state) => const ChangeNumberFormScreen(),
          ),
          GoRoute(
            path: Routes.profileInfo,
            builder: (context, state) => const ProfileInfoScreen(),
          ),
          GoRoute(
            path: Routes.blockUser,
            builder: (context, state) => const BlockUserScreen(),
          ),
          GoRoute(
            path: Routes.blockedUser,
            builder: (context, state) => const BlockedUsersScreen(),
          ),
          GoRoute(
            path: Routes.userProfile,
            builder: (context, state) => const UserProfileScreen(),
          ),
          GoRoute(
            path: Routes.privacySettings,
            builder: (context, state) => const PrivacySettingsScreen(),
          ),
          GoRoute(
            path: Routes.devicesScreen,
            builder: (context, state) => const DevicesScreen(),
          ),
          GoRoute(
            path: Routes.changeUsername,
            builder: (context, state) => const ChangeUsernameScreen(),
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
