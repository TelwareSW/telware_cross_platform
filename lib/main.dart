import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/contact_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/app_theme.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
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
  Hive.registerAdapter(ChatModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(MessageEventAdapter());
  Hive.registerAdapter(SendMessageEventAdapter());
  Hive.registerAdapter(DeleteMessageEventAdapter());
  Hive.registerAdapter(EditMessageEventAdapter());
  Hive.registerAdapter(ChatTypeAdapter());
  Hive.registerAdapter(MessageStateAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  Hive.registerAdapter(DeleteMessageTypeAdapter());
  Hive.registerAdapter(MessageContentTypeAdapter());
  Hive.registerAdapter(TextContentAdapter());
  Hive.registerAdapter(AudioContentAdapter());
  Hive.registerAdapter(ImageContentAdapter());
  Hive.registerAdapter(VideoContentAdapter());
  Hive.registerAdapter(DocumentContentAdapter());

  await Hive.initFlutter();
  await Hive.openBox<ContactModel>('contacts');
  await Hive.openBox<ContactModelBlock>('contacts-block');
  await Hive.openBox<String>('auth-token');
  await Hive.openBox<UserModel>('auth-user');
  await Hive.openBox<List>('chats-box'); // List<ChatModel>
  await Hive.openBox<List>('chatting-events-box'); // List<MessageEvent>
  await Hive.openBox<Map>('other-users-box'); // Map<String, UserModel>
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
