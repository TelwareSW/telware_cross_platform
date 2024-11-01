import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif/gif.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/auth/view/screens/change_number_form_screen.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/screens/settings_screen.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';

class ChangeNumberScreen extends ConsumerStatefulWidget {
  static const String route = '/change-number';

  const ChangeNumberScreen({super.key});

  @override
  ConsumerState<ChangeNumberScreen> createState() => _ChangeNumberScreenState();
}

class _ChangeNumberScreenState extends ConsumerState<ChangeNumberScreen>
    with TickerProviderStateMixin {
  late final _user;
  late GifController _controller;

  @override
  void initState() {
    super.initState();
    _user = ref.read(userLocalRepositoryProvider).getUser()!;
    _controller = GifController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background, // Dark background
      appBar: const ToolbarWidget(
        title: "",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Centered GIF, Header, and Subtext
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Vertical centering
                children: [
                  Gif(
                    image: const AssetImage("assets/gifs/change-number.gif"),
                    controller: _controller,
                    autostart: Autostart.no,
                    placeholder: (context) => const Text('Loading...'),
                    onFetchCompleted: () {
                      _controller.reset();
                      _controller.forward();
                    },
                    height: 150, // Larger GIF size
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Change Number",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280), // Constrain width for tight layout
                    child: const Text(
                      "You can change your TelWare number here. Your account and all your "
                          "cloud data—messages, media, contacts, etc.—will be moved to the new number.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Palette.accentText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Buttons at the bottom
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Palette.background, // Slightly different color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0), // Internal padding
                      ),
                      onPressed: () {
                        context.pop(); // Go back on button press
                      },
                      child: Text(
                        "Keep ${_user.phone}", // Example number
                        style: const TextStyle(fontSize: 16, color: Palette.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding around the button
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0), // Add internal padding
                      ),
                      onPressed: () {
                        context.go(
                          ChangeNumberFormScreen.route,
                          extra: ModalRoute.withName(SettingsScreen.route),
                        );
                      },
                      child: const Text(
                        "Change Number",
                        style: TextStyle(fontSize: 16, color: Palette.primaryText),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32), // Space at the bottom
              ],
            ),
          ],
        ),
      ),
    );
  }
}
