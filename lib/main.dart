import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/inbox_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/auth_theme.dart';
import 'features/user_profile/models/story_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter()); // Make sure to register your adapter
  Hive.registerAdapter(StoryModelAdapter()); // Register the StoryModel adapter
  await Hive.openBox<UserModel>('contacts'); // Open the box// Replace 'stories' with your actual box name

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
