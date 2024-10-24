import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/auth_theme.dart';
import 'features/user_profile/models/story_model.dart';
import 'features/user_profile/view/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(StoryModelAdapter());
  await Hive.openBox<UserModel>('contacts');

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
        HomeScreen.route: (context) => const HomeScreen(),
      },
      initialRoute: HomeScreen.route,
    );
  }
}
