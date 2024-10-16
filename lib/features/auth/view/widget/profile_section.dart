import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'info_text_widget.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});
  static const String phoneNumber = '+20 11* *****88';
  static const String username = 'None';
  static const String bio = 'Bio';

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Palette.primary,
        ),
        InfoTextWidget(
          text: phoneNumber,
          subText: 'Tap to change phone number',
        ),
        InfoTextWidget(
          text: username,
          subText: 'Username',
        ),
        InfoTextWidget(
          text: bio,
          subText: 'Add a few words about yourself',
        ),
      ],
    );
  }
}