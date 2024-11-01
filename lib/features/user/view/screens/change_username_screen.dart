import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeUsernameScreen extends ConsumerStatefulWidget {
  static const String route = '/change-username';

  const ChangeUsernameScreen({super.key});

  @override
  ConsumerState<ChangeUsernameScreen> createState() => _ChangeUsernameScreen();
}

class _ChangeUsernameScreen extends ConsumerState<ChangeUsernameScreen> with SingleTickerProviderStateMixin {
  late final _user;
  final TextEditingController _usernameController = TextEditingController();
  final _shakeKey = GlobalKey<ShakeWidgetState>();

  bool _showSaveButton = false;
  bool _isValid = false;
  String _validationMessage = "";
  Color _validationMessageColor = Palette.accentText;

  @override
  void initState() {
    super.initState();
    _user = ref.read(userLocalRepositoryProvider).getUser()!;
    _usernameController.text = _user.username;
    _usernameController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }


  /// Checks for changes and validates the username in real-time.
  Future<void> _checkForChanges() async {
    String newUsername = _usernameController.text;

    bool hasChanged = newUsername != _user.username;

    setState(() {
      _showSaveButton = hasChanged;
      _validationMessageColor = Palette.error;
      _isValid = false;

      if (newUsername.isEmpty) {
        _validationMessage = "";
        _isValid = true;
      } else if (RegExp(r'^[0-9]').hasMatch(newUsername[0])) {
        _validationMessage = "Username can't start with a number.";
      } else if (newUsername.length < 5) {
        _validationMessage = "Username must have at least 5 characters.";
      } else if (!_isUsernameValid(newUsername)) {
        _validationMessage = "Username is invalid.";
      } else {
        _validationMessage = "Checking username...";
        _validationMessageColor = Palette.accentText;

        // Check if the username is unique (remote call).
        _checkUsernameUniqueness(newUsername);
      }
    });
  }

  /// Validates if the username follows allowed patterns.
  bool _isUsernameValid(String username) {
    final RegExp usernameRegExp = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
    return usernameRegExp.hasMatch(username);
  }

  /// Asynchronously checks if the username is unique via remote repository.
  Future<void> _checkUsernameUniqueness(String username) async {
    bool isUnique = await ref.read(userViewModelProvider.notifier).checkUsernameUniqueness(username);

    setState(() {
      if (isUnique) {
        _validationMessage = "Username is available.";
        _validationMessageColor = Colors.green.shade500;
        _isValid = true;
      } else {
        _validationMessage = "This username is already taken.";
        _validationMessageColor = Colors.red.shade700;
      }
    });
  }

  /// Updates the username both locally and remotely.
  Future<void> _updateUsername() async {
    String newUsername = _usernameController.text;
    if (_isValid) {
      await ref.read(userViewModelProvider.notifier).changeUsername(newUsername);
    } else {
      _shakeAndVibrate();
    }
  }

  /// Shakes the widget and triggers vibration feedback on error.
  void _shakeAndVibrate() {
    _shakeKey.currentState?.shake();
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator ?? false) {
        Vibration.vibrate(duration: 100);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.type == UserStateType.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? 'Username updated successfully')),
        );
        context.pop();
      } else if (next.type == UserStateType.fail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? 'Failed to update username')),
        );
      }
    });

    return Scaffold(
      appBar: ToolbarWidget(
        title: "Username",
        actions: [
          if (_showSaveButton)
            IconButton(
              onPressed: _updateUsername,
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: ShakeMe(
          key: _shakeKey,
          shakeCount: 1,
          shakeOffset: 8,
          child: Column(
            children: [
              SettingsSection(
                title: "Set username",
                settingsOptions: const [],
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              prefix: Text(
                                "t.me/",
                                style: TextStyle(
                                  color: Palette.primaryText,
                                  fontSize: 16,
                                ),
                              ),
                              hintText: "username",
                              hintStyle: TextStyle(color: Palette.accentText),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_validationMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 16, 11, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _validationMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: _validationMessageColor,
                      ),
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(11, 7, 11, 7),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "You can choose a username on TelWare. If you do, people will be able to "
                        "find you by this username and contact you without needing your phone number.\n\n"
                        "You can use a-z, 0-9 and underscores.\nMinimum length is 5 characters.",
                    style: TextStyle(fontSize: 14, color: Palette.accentText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}