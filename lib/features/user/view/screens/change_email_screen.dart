import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:vibration/vibration.dart';

import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/shake_my_auth_input.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  static const String route = '/change-email';

  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen>
    with TickerProviderStateMixin {
  //-------------------------------------- Focus nodes -------------------------
  final FocusNode emailFocusNode = FocusNode();
  bool isEmailFocused = false;

  //-------------------------------------- Controllers ------------------------
  final TextEditingController emailController = TextEditingController();

  //-------------------------------------- Errors -------------------------
  String? emailError;

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {
        isEmailFocused = emailFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    emailController.dispose();
    super.dispose();
  }

  void vibrate() {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator ?? false) {
        Vibration.vibrate(duration: 100);
      }
    });
  }

  void changeEmail() async {
    await ref.read(userViewModelProvider.notifier).updateEmail(
          newEmail: emailController.text,
        );
  }

  void handelSubmit() {
    if (emailController.text.isEmpty) {
      ChangeEmailKeys.emailShakeKey.currentState?.shake();
      vibrate();
    } else {
      changeEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.type == UserStateType.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? 'Email updated successfully')),
        );
      } else if (next.type == UserStateType.fail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? 'Failed to update email')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Palette.secondary,
      body: SingleChildScrollView(
        child: Responsive(
          child: Form(
            key: ChangeEmailKeys.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const LottieViewer(
                    path: 'assets/tgs/mailBox.tgs', width: 120, height: 120),
                const TitleElement(
                  name: 'Enter New Email',
                  color: Palette.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  padding: EdgeInsets.only(bottom: 10, top: 15),
                ),
                const TitleElement(
                  name:
                      'You will receive Telegram login codes via email and\nnot SMS. Please enter an email address to which you\nhave access.',
                  color: Palette.accentText,
                  fontSize: Sizes.secondaryText - 1,
                  padding: EdgeInsets.only(bottom: 30),
                ),
                ShakeMyAuthInput(
                  name: 'Your new email',
                  errorText: emailError,
                  formKey: ChangeEmailKeys.emailKey,
                  shakeKey: ChangeEmailKeys.emailShakeKey,
                  isFocused: isEmailFocused,
                  focusNode: emailFocusNode,
                  controller: emailController,
                  validator: emailValidator,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AuthFloatingActionButton(
        formKey: ChangeEmailKeys.formKey,
        buttonKey: ChangeEmailKeys.submitKey,
        onSubmit: handelSubmit,
      ),
    );
  }
}
