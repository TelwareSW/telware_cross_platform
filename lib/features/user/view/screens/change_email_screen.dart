import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:telware_cross_platform/core/models/signup_result.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:vibration/vibration.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import 'package:telware_cross_platform/core/providers/sign_up_provider.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_phone_number.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/shake_my_auth_input.dart';
import 'package:telware_cross_platform/features/auth/view/widget/social_log_in.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  static const String route = '/change-email';

  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen>
    with TickerProviderStateMixin {
  //-------------------------------------- Keys -------------------------
  final formKey = GlobalKey<FormState>(debugLabel: 'change_email_form');
  final emailKey = GlobalKey<FormFieldState>(debugLabel: 'change_email_input');
  final submitKey = GlobalKey<State>(debugLabel: 'change_email_submit_button');
  final emailShakeKey = GlobalKey<ShakeWidgetState>();

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
      emailShakeKey.currentState?.shake();
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
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const LottieViewer(
                    path: 'assets/json/mailBox.json', width: 200, height: 200),
                const TitleElement(
                  name: 'Enter New Email',
                  color: Palette.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  padding: EdgeInsets.only(bottom: 10),
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
                  formKey: emailKey,
                  shakeKey: emailShakeKey,
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
        formKey: formKey,
        buttonKey: submitKey,
        onSubmit: handelSubmit,
      ),
    );
  }
}
