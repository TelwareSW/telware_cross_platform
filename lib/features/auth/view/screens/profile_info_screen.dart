import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_input_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/auth/view/widget/toolbar_widget.dart';

class ProfileInfoScreen extends StatefulWidget {
  static const String route = '/bio';

  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreen();
}

class _ProfileInfoScreen extends State<ProfileInfoScreen> {
  static const user = {
    "firstName": "Moamen",
    "lastName": "Hefny"
  };
  final TextEditingController _firstNameController = TextEditingController(text: user["firstName"]);
  final TextEditingController _secondNameController = TextEditingController(text: user["lastName"]);
  final TextEditingController _bioController = TextEditingController();


  static List<Map<String, dynamic>> profileSections = [
    const {"title": "Your channel", "options": [
      {"text": 'Personal channel', "trailing": "Add"},
    ]},
    const {"title": "Your bio", "options": [
      {"placeholder": 'Write about yourself...', "lettersCap": 70, "type": "input"},
    ], "trailing": "You can add a few lines about yourself. "
        "Choose who can see your bio in Settings."},
    const {"title": "Your birthday", "options": [
      {"text": 'Date of Birth', "trailing": "Add"},
    ], "trailing": "Only your contacts can see your birthday.\nChange>"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolbarWidget(
        title: "Profile Info",
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              SettingsSection(title: "Your Name",
                settingsOptions: const [],
                actions: [
                  SettingsInputWidget(controller:_firstNameController),
                  SettingsInputWidget(controller:_secondNameController),
                ],),
              const SizedBox(height: Dimensions.sectionGaps),
              const SettingsSection(title: "Your channel",
                settingsOptions: [{"text": "Personal channel", "trailing": "Add"}],
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              SettingsSection(title: "Your bio",
                settingsOptions: const [],
                actions: [
                  SettingsInputWidget(controller:_bioController,
                      placeholder: "Write about yourself...", lettersCap: 70,)
                ],
                trailing: "You can add a few lines about yourself. Choose who can "
                    "see your bio in Settings",),
              const SizedBox(height: Dimensions.sectionGaps),
              const SettingsSection(title: "Your birthday",
                settingsOptions: [{"text": "Date of birth", "trailing": "Add"}],
                trailing: "Only your contacts can see your birthday. Change>",),
            ],
          )
      ),
    );
  }
}