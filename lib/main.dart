import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/auth_theme.dart';
import 'features/auth/view/screens/sign_up_screen.dart';

void main() {
  runApp(const ProviderScope(
    child: TelWare(),
  ));
}

class TelWare extends StatelessWidget {
  const TelWare({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TalWare',
      theme: authTheme,
      routes: {
        SignUpScreen.route: (context) => const SignUpScreen(),
      },
      initialRoute: SignUpScreen.route,
    );
  }
}
