import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/stories/view/screens/add_my_image_screen.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_radio_button_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePhotoPrivacyScreen extends ConsumerStatefulWidget {
  static const String route = '/privacy/profile-picture';

  const ProfilePhotoPrivacyScreen({super.key});

  @override
  ConsumerState<ProfilePhotoPrivacyScreen> createState() => _ProfilePhotoPrivacyScreen();
}

class _ProfilePhotoPrivacyScreen extends ConsumerState<ProfilePhotoPrivacyScreen> {
  late final UserModel _user;
  late String _seeProfilePhotoSelectedOption;
  late final String _seeProfilePhotoInitValue;
  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    _user = ref.read(userLocalRepositoryProvider).getUser()!;
    _seeProfilePhotoSelectedOption = "Nobody";
    _seeProfilePhotoInitValue = _seeProfilePhotoSelectedOption;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _updatePrivacy() async {

  }

  void _handleSeeProfilePhotoPrivacy(String value) {
    setState(() {
      _seeProfilePhotoSelectedOption = value;
      _showSaveButton = value != _seeProfilePhotoInitValue;
    });
  }

  String _getExceptionsTrailing() {
    if (_seeProfilePhotoSelectedOption == "Everybody") {
      return "You can add users or entire groups that will not see your profile photo.";
    }
    if (_seeProfilePhotoSelectedOption == "My Contacts") {
      return "Add users or entire groups as exceptions that will override the settings above.";
    }
    return "Add users or entire groups that will still see your profile photo";
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.type == UserStateType.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? 'Phone privacy updated successfully')),
        );
        context.pop();
      } else if (next.type == UserStateType.fail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? 'Failed to update phone privacy')),
        );
      }
    });

    return Scaffold(
      appBar: ToolbarWidget(
        title: "Profile Photos",
        actions: [
          if (_showSaveButton)
            IconButton(
              onPressed: _updatePrivacy,
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              SettingsSection(
                containerKey: ValueKey("see-profile-photos${WidgetKeys.settingsRadioOptionSuffix.value}"),
                title: "Who can see my profile photos?",
                settingsOptions: const [],
                actions: [
                  SettingsRadioButtonWidget(
                    key: ValueKey("see-profile-photos-everybody${WidgetKeys.settingsRadioOptionSuffix.value}"),
                    text: "Everybody",
                    isSelected: _seeProfilePhotoSelectedOption == "Everybody",
                    onTap: () => _handleSeeProfilePhotoPrivacy("Everybody"),
                  ),
                  SettingsRadioButtonWidget(
                    key: ValueKey("see-profile-photos-contacts${WidgetKeys.settingsRadioOptionSuffix.value}"),
                    text: "My Contacts",
                    isSelected: _seeProfilePhotoSelectedOption == "My Contacts",
                    onTap: () => _handleSeeProfilePhotoPrivacy("My Contacts"),
                  ),
                  SettingsRadioButtonWidget(
                    key: ValueKey("see-profile-photos-nobody${WidgetKeys.settingsRadioOptionSuffix.value}"),
                    text: "Nobody",
                    isSelected: _seeProfilePhotoSelectedOption == "Nobody",
                    onTap: () => _handleSeeProfilePhotoPrivacy("Nobody"),
                    showDivider: false,
                  ),
                ],
                trailing: "You can restrict who can see yur profile photo with "
                    "granular precision.",
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              SettingsSection(
                title: "Add exceptions",
                settingsOptions: const [],
                actions: [
                  if (_seeProfilePhotoSelectedOption != "Everybody")
                    SettingsOptionWidget(
                      text: "Always Share With",
                      trailing: "Add Users",
                      onTap: () => showToastMessage("Coming Soon..."),
                      showDivider: _seeProfilePhotoSelectedOption != "Nobody",
                    ),
                  if (_seeProfilePhotoSelectedOption != "Nobody")
                    SettingsOptionWidget(
                      text: "Never Share With",
                      trailing: "Add Users",
                      onTap: () => showToastMessage("Coming Soon..."),
                      showDivider: false,
                    ),
                ],
                trailing: _getExceptionsTrailing(),
              ),
              if (_seeProfilePhotoSelectedOption != "Everybody") ...[
                const SizedBox(height: Dimensions.sectionGaps),
                SettingsSection(
                  settingsOptions: const [],
                  actions: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddMyImageScreen(
                                destination: 'profile'),
                          ),
                        );
                      },
                      child: SettingsOptionWidget(
                        key: ValueKey("set-profile-photo${WidgetKeys.settingsOptionSuffix.value}"),
                        icon: Icons.camera_alt_outlined,
                        iconColor: Palette.primary,
                        text: "Set Profile Photo",
                        color: Palette.primary,
                        showDivider: false,
                      ),
                    ),
                  ],
                  trailing: "You can upload a public photo for users who are "
                      "restricted from seeing your real profile photos.",
                ),
              ]
            ],
          )
      ),
    );
  }
}