import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:telware_cross_platform/core/models/contact_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/app_theme.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'features/auth/view/screens/sign_up_screen.dart';
import 'features/auth/view/screens/verification_screen.dart';
import 'features/user/view/screens/devices_screen.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/models/story_model.dart';

Future<void> main() async {
  await init();
  runApp(const ProviderScope(child: TelWare()));
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ContactModelAdapter());
  Hive.registerAdapter(StoryModelAdapter());
  Hive.registerAdapter(ContactModelBlockAdapter());
  await Hive.initFlutter();
  dynamic box = await Hive.openBox<ContactModel>('contacts');
  await box.clear();
  box = await Hive.openBox<ContactModelBlock>('contacts-block');
  await box.clear();
  box = await Hive.openBox<String>('auth-token');
  await box.clear();
  box = await Hive.openBox<UserModel>('auth-user');
  await box.clear();
  await dotenv.load(fileName: "lib/.env");
}

class TelWare extends ConsumerStatefulWidget {
  const TelWare({super.key});

  @override
  ConsumerState<TelWare> createState() => _TelWareState();
}

class _TelWareState extends ConsumerState<TelWare> {
  late GoRouter router;

  @override
  void initState() {
    super.initState();
    router = Routes.appRouter(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TelWare',
      theme: appTheme,
      routerConfig: router,
    );
  }
}
