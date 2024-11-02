import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/copyable_link_text_widget.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_radio_button_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section_trailing.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhonePrivacyScreen extends ConsumerStatefulWidget {
  static const String route = '/privacy/phone';

  const PhonePrivacyScreen({super.key});

  @override
  ConsumerState<PhonePrivacyScreen> createState() => _PhonePrivacyScreen();
}

class _PhonePrivacyScreen extends ConsumerState<PhonePrivacyScreen> {
  late final UserModel _user;
  late String _seePhoneSelectedOption;
  late String _findByPhoneSelectedOption;
  late final String _seePhoneInitValue;
  late final String _findByPhoneInitValue;
  bool _showSaveButton = false;
  late final String _userChatLink;

  @override
  void initState() {
    super.initState();
    _user = ref.read(userLocalRepositoryProvider).getUser()!;
    _seePhoneSelectedOption = "Nobody";
    _findByPhoneSelectedOption = "Everybody";
    _seePhoneInitValue = _seePhoneSelectedOption;
    _findByPhoneInitValue = _findByPhoneSelectedOption;
    _userChatLink = "https://t.me/${_user.phone}";
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _updatePrivacy() async {

  }

  void _handleSeePhonePrivacy(String value) {
    setState(() {
      if ((value != _seePhoneInitValue) != _showSaveButton) {
        _showSaveButton = !_showSaveButton;
        if (value == "Nobody" && !_showSaveButton) {
          if ((_findByPhoneSelectedOption != _findByPhoneInitValue)) {
            _showSaveButton = true;
          }
        }
      }
      _seePhoneSelectedOption = value;
    });
  }

  void _handleFindByPhonePrivacy(String value) {
    setState(() {
      if ((value != _findByPhoneInitValue) != _showSaveButton) {
        _showSaveButton = !_showSaveButton;
      }
      _findByPhoneSelectedOption = value;
    });
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
        title: "Phone Number",
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
              containerKey: ValueKey("see-phone-privacy${WidgetKeys.settingsSectionSuffix.value}"),
              title: "Who can see my phone number?",
              settingsOptions: const [],
              actions: [
                SettingsRadioButtonWidget(
                  key: ValueKey("see-phone-privacy-everybody${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "Everybody",
                  isSelected: _seePhoneSelectedOption == "Everybody",
                  onTap: () => _handleSeePhonePrivacy("Everybody"),
                ),
                SettingsRadioButtonWidget(
                  key: ValueKey("see-phone-privacy-contacts${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "My Contacts",
                  isSelected: _seePhoneSelectedOption == "My Contacts",
                  onTap: () => _handleSeePhonePrivacy("My Contacts"),
                ),
                SettingsRadioButtonWidget(
                  key: ValueKey("see-phone-privacy-nobody${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "Nobody",
                  isSelected: _seePhoneSelectedOption == "Nobody",
                  onTap: () => _handleSeePhonePrivacy("Nobody"),
                  showDivider: false,
                ),
              ],
            ),
            if (_seePhoneSelectedOption == "Nobody") ...[
              const SizedBox(height: Dimensions.sectionGaps),
              SettingsSection(
                containerKey: ValueKey("find-by-phone-privacy${WidgetKeys.settingsSectionSuffix.value}"),
                title: "Who can find me by my number?",
                settingsOptions: const [],
                actions: [
                  SettingsRadioButtonWidget(
                    key: ValueKey("find-by-phone-privacy-everybody${WidgetKeys.settingsRadioOptionSuffix.value}"),
                    text: "Everybody",
                    isSelected: _findByPhoneSelectedOption == "Everybody",
                    onTap: () => _handleFindByPhonePrivacy("Everybody"),
                  ),
                  SettingsRadioButtonWidget(
                    key: ValueKey("find-by-phone-privacy-contacts${WidgetKeys.settingsRadioOptionSuffix.value}"),
                    text: "My Contacts",
                    isSelected: _findByPhoneSelectedOption == "My Contacts",
                    onTap: () => _handleFindByPhonePrivacy("My Contacts"),
                    showDivider: false,
                  ),
                ],
              ),
            ],
            const SettingsSectionTrailingWidget(
              actions: [
                Text(
                    "Users who have your number saved in their contacts will"
                        " also see it on TelWare.",
                    style: TextStyle(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Palette.accentText)
                ),
              ],
            ),
            SettingsSectionTrailingWidget(
                padding: const EdgeInsets.fromLTRB(Dimensions.optionsHorizontalPad, 10, Dimensions.optionsHorizontalPad, 16),
                actions: [
                  const Text(
                      "This public link opens a chat with you:",
                      style: TextStyle(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Palette.accentText)
                  ),
                  CopyableLinkTextWidget(
                    key: WidgetKeys.userChatCopyableLink,
                    linkText: _userChatLink,
                  ),
                ],
            ),
            SettingsSection(
                title: "Add exceptions",
                settingsOptions: const [],
                actions: [
                  if (_seePhoneSelectedOption != "Everybody")
                     SettingsOptionWidget(
                       text: "Always Allow",
                       trailing: "Add Users",
                       onTap: () => showToastMessage("Coming Soon..."),
                       showDivider: _seePhoneSelectedOption != "Nobody",
                    ),
                  if (_seePhoneSelectedOption != "Nobody")
                    SettingsOptionWidget(
                      text: "Never Allow",
                      trailing: "Add Users",
                      onTap: () => showToastMessage("Coming Soon..."),
                      showDivider: false,
                    ),
                ],
              trailing: "You can add users or entire groups as exceptions that "
                  "will override the settings above.",
            ),
          ],
        )
      ),
    );
  }
}