import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/inbox_screen.dart';

import 'core/theme/auth_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TelWare(),
    ),
  );
}

class TelWare extends StatelessWidget {
  const TelWare({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TelWare',
      theme: authTheme,
      routes: {
        InboxScreen.route: (context) => const InboxScreen(),
      },
      initialRoute: InboxScreen.route,
    );
  }
}
