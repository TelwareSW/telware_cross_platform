import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/stories/models/story_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'core/models/user_model.dart';
import 'core/theme/app_theme.dart';

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
    final isAuthenticated = ref.watch(authViewModelProvider.notifier).isAuthenticated();
    final router = Routes.appRouter(isAuthenticated);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TelWare',
      theme: appTheme,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
    );
  }
}
