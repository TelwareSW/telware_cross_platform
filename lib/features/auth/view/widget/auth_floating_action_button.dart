import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view/widget/circular_button.dart';

class AuthFloatingActionButton extends StatelessWidget {
  const AuthFloatingActionButton({
    super.key,
    required this.onSubmit,
    this.formKey,
    this.buttonKey,
  });

  final VoidCallback onSubmit;
  final GlobalKey<FormState>? formKey;
  final GlobalKey<State>? buttonKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CircularButton(
        buttonKey: buttonKey,
        icon: Icons.arrow_forward,
        iconSize: Sizes.iconSize,
        radius: Sizes.circleButtonRadius,
        formKey: formKey,
        handelClick: onSubmit,
      ),
    );
  }
}
