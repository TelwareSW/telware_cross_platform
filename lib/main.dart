import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user/view/screens/block_user.dart';
import 'package:telware_cross_platform/features/auth/view/screens/change_number_form_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/blocked_users.dart';
import 'package:telware_cross_platform/features/user/view/screens/change_number_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/privacy_and_security_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/profile_info_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/settings_screen.dart';
import 'package:telware_cross_platform/core/theme/app_theme.dart';
import 'package:telware_cross_platform/features/user/view/screens/user_profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:telware_cross_platform/features/stories/models/story_model.dart';
import 'package:telware_cross_platform/features/home/view/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:telware_cross_platform/core/view/screen/splash_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/log_in_screen.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'features/auth/view/screens/sign_up_screen.dart';
import 'features/auth/view/screens/verification_screen.dart';
import 'features/user/view/screens/devices_screen.dart';

Future<void> main() async {
  await init();
  runApp(const ProviderScope(child: TelWare()));
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ContactModelAdapter());
  Hive.registerAdapter(StoryModelAdapter());
  await Hive.initFlutter();
  await Hive.openBox<ContactModel>('contacts');
  await Hive.openBox<String>('auth-token');
  await Hive.openBox<UserModel>('auth-user');
  await dotenv.load(fileName: "lib/.env");
}

class TelWare extends ConsumerStatefulWidget {
  const TelWare({super.key});

  @override
  ConsumerState<TelWare> createState() => _TelWareState();
}

class _TelWareState extends ConsumerState<TelWare> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TelWare',
      theme: appTheme,
      routes: {
        SplashScreen.route: (context) => const SplashScreen(),
        LogInScreen.route: (context) => const LogInScreen(),
        SignUpScreen.route: (context) => const SignUpScreen(),
        VerificationScreen.route: (context) => const VerificationScreen(),
        HomeScreen.route: (context) => const HomeScreen(),
        SettingsScreen.route: (context) => const SettingsScreen(),
        ChangeNumberScreen.route : (context) => const ChangeNumberScreen(),
        ChangeNumberFormScreen.route: (context) => const ChangeNumberFormScreen(),
        ProfileInfoScreen.route: (context) => const ProfileInfoScreen(),
        BlockUserScreen.route: (context) => const BlockUserScreen(),
        BlockedUsersScreen.route: (context) => const BlockedUsersScreen(),
        UserProfileScreen.route: (context) => const UserProfileScreen(),
        PrivacySettingsScreen.route: (context) => const PrivacySettingsScreen(),
        DevicesScreen.route: (context) => const DevicesScreen(),
      },
      initialRoute: HomeScreen.route,
    );
  }
}
