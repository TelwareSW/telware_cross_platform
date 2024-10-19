import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/auth/view/screens/privacy_and_security_screen.dart';
import 'core/theme/auth_theme.dart';
import 'features/auth/view/screens/profile_info_screen.dart';
import 'features/auth/view/screens/user_profile_screen.dart';

void main() {
  runApp(const TelWare());
}

class TelWare extends StatelessWidget {
  const TelWare({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TelWare',
      theme: authTheme,
      routes: {
        UserProfileScreen.route: (context) => const UserProfileScreen(),
        "/bio": (context) => const ProfileInfoScreen(),
        "/privacy": (context) => const PrivacySettingsScreen(),
      },
      initialRoute: UserProfileScreen.route,
    );
  }
}
