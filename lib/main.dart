import 'package:flutter/material.dart';
import 'core/theme/auth_theme.dart';
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
      },
      initialRoute: UserProfileScreen.route,
    );
  }
}
