import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:go_router/go_router.dart';

import 'package:telware_cross_platform/core/constants/keys.dart';

import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_input_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileInfoScreen extends ConsumerStatefulWidget {
  static const String route = '/bio';

  const ProfileInfoScreen({super.key});

  @override
  ConsumerState<ProfileInfoScreen> createState() => _ProfileInfoScreen();
}

class _ProfileInfoScreen extends ConsumerState<ProfileInfoScreen> with SingleTickerProviderStateMixin {
  late final UserModel _user;

  final firstNameShakeKey = GlobalKey<ShakeWidgetState>();
  final lastNameShakeKey = GlobalKey<ShakeWidgetState>();


  late final TextEditingController _firstNameController;
  late final TextEditingController _secondNameController;
  late final TextEditingController _bioController;

  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers based on userViewModelProvider data
    _user = ref.read(userLocalRepositoryProvider).getUser()!;
    final nameParts = [_user.screenFirstName, _user.screenLastName];
    _firstNameController = TextEditingController(text: nameParts.isNotEmpty ? nameParts[0] : '');
    _secondNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    _bioController = TextEditingController(text: _user.bio);

    _firstNameController.addListener(_checkForChanges);
    _secondNameController.addListener(_checkForChanges);
    _bioController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final screenName = '${_firstNameController.text} ${_secondNameController.text}'.trim();
    final hasChanged = (screenName != '${_user.screenFirstName} ${_user.screenFirstName}' || _bioController.text != _user.bio);

    if (hasChanged != _showSaveButton) {
      setState(() {
        _showSaveButton = hasChanged;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.type == UserStateType.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? 'Profile updated successfully')),
        );
      } else if (next.type == UserStateType.fail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? 'Failed to update profile')),
        );
      }
    });

    return Scaffold(
      appBar: ToolbarWidget(
        title: "Profile Info",
        actions: [
          if (_showSaveButton)
            IconButton(
              onPressed: _updateUserData,
              icon: const Icon(Icons.check),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingsSection(
              title: "Your Name",
              settingsOptions: const [],
              actions: [
                SettingsInputWidget(
                  key: Keys.profileInfoFirstNameInput,
                  controller: _firstNameController,
                  placeholder: "First Name",
                  shakeKey: Keys.profileInfoFirstNameShakeKey,
                ),
                SettingsInputWidget(
                  key: Keys.profileInfoLastNameInput,
                  controller: _secondNameController,
                  placeholder: "Last Name",
                  shakeKey: Keys.profileInfoLastNameShakeKey,
                ),
              ],
            ),
            const SizedBox(height: Dimensions.sectionGaps),
            const SettingsSection(
              title: "Your channel",
              settingsOptions: [
                {"text": "Personal channel", "trailing": "Add"}
              ],
            ),
            const SizedBox(height: Dimensions.sectionGaps),
            SettingsSection(
              title: "Your bio",
              settingsOptions: const [],
              actions: [
                SettingsInputWidget(
                  key: Keys.profileInfoBioInput,
                  controller: _bioController,
                  placeholder: "Write about yourself...",
                  lettersCap: 70,
                )
              ],
              trailing: "You can add a few lines about yourself. Choose who can "
                  "see your bio in Settings",
            ),
            const SizedBox(height: Dimensions.sectionGaps),
            const SettingsSection(
              title: "Your birthday",
              settingsOptions: [
                {"text": "Date of birth", "trailing": "Add"}
              ],
              trailing: "Only your contacts can see your birthday. Change>",
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserData() async {
    if (_firstNameController.text.isEmpty) {
      return _shakeAndVibrate(Keys.profileInfoFirstNameShakeKey);
    }
    if (_secondNameController.text.isEmpty) {
      return _shakeAndVibrate(Keys.profileInfoLastNameShakeKey);
    }

    final userViewModel = ref.read(userViewModelProvider.notifier);
    await userViewModel.updateUserInfo(_firstNameController.text, _secondNameController.text, _bioController.text);

    context.pop();
  }

  void _shakeAndVibrate(GlobalKey<ShakeWidgetState> shakeKey) {
    shakeKey.currentState?.shake();
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator ?? false) {
        Vibration.vibrate(duration: 100);
      }
    });
  }
}
