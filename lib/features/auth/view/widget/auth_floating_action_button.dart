import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view/widget/circular_button.dart';

class AuthFloatingActionButton extends StatelessWidget {
  const AuthFloatingActionButton({
    super.key,
    required this.onSubmit,
    required this.formKey,
  });

  final VoidCallback onSubmit;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CircularButton(
        icon: Icons.arrow_forward,
        iconSize: Sizes.iconSize,
        radius: Sizes.circleButtonRadius,
        formKey: formKey,
        handelSubmit: onSubmit,
      ),
    );
  }
}
