import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/animated_snack_bar_widget.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_radio_button_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvitesPermissionScreen extends ConsumerStatefulWidget {
  static const String route = '/privacy/invites-permission';

  const InvitesPermissionScreen({super.key});

  @override
  ConsumerState<InvitesPermissionScreen> createState() => _InvitesPermissionScreen();
}

class _InvitesPermissionScreen extends ConsumerState<InvitesPermissionScreen> {
  late String _invitePermissionsSelectedOption;
  late final String _invitePermissionsInitValue;
  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    final UserModel user = ref.read(userLocalRepositoryProvider).getUser()!;
    _invitePermissionsSelectedOption = user.invitePermissionsPrivacy;
    _invitePermissionsInitValue = _invitePermissionsSelectedOption;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _updatePrivacy() async {
    await ref.read(userViewModelProvider.notifier).changeInvitePermissions(_invitePermissionsSelectedOption);
  }

  void _handleInvitePermissionsPrivacy(String value) {
    setState(() {
      if ((value != _invitePermissionsInitValue) != _showSaveButton) {
        _showSaveButton = !_showSaveButton;
      }
      _invitePermissionsSelectedOption = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.type == UserStateType.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AnimatedSnackBarWidget(
              icon: const Icon(Icons.upgrade_rounded),
              text: next.message ?? 'Invite permissions updated successfully'
            )
          ),
        );
        context.pop();
      } else if (next.type == UserStateType.fail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AnimatedSnackBarWidget(
              icon: const Icon(Icons.error_outline_rounded),
              text: next.message ?? 'Failed to update invite permissions'
            ),
            backgroundColor: Palette.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: ToolbarWidget(
        title: "Invites",
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
              containerKey: ValueKey("invite-permissions${WidgetKeys.settingsSectionSuffix.value}"),
              title: "Who can add me to group chats?",
              settingsOptions: const [],
              actions: [
                SettingsRadioButtonWidget(
                  key: ValueKey("invite-permissions-everybody${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "Everybody",
                  isSelected: _invitePermissionsSelectedOption == "everyone",
                  onTap: () => _handleInvitePermissionsPrivacy("everyone"),
                ),
                SettingsRadioButtonWidget(
                  key: ValueKey("invite-permissions-admins${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "Admins",
                  isSelected: _invitePermissionsSelectedOption == "admins",
                  onTap: () => _handleInvitePermissionsPrivacy("admins"),
                  showDivider: false,
                ),
              ],
              trailing: "You can restrict who can add you to groups and "
                  "channels with granular precision.",
            ),
            const SizedBox(height: Dimensions.sectionGaps),
            SettingsSection(
                title: "Add exceptions",
                settingsOptions: const [],
                actions: [
                  if (_invitePermissionsSelectedOption != "everyone")
                     SettingsOptionWidget(
                       text: "Always Allow",
                       trailing: "Add Users",
                       onTap: () => showToastMessage("Coming Soon..."),
                    ),
                    SettingsOptionWidget(
                      text: "Never Allow",
                      trailing: "Add Users",
                      onTap: () => showToastMessage("Coming Soon..."),
                      showDivider: false,
                    ),
                ],
              trailing: "These users will or will not be able to add you to "
                  "groups and channels regardless of settings above.",
            ),
          ],
        )
      ),
    );
  }
}