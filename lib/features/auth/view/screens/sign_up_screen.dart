import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/repository/sign_up_email_provider.dart';
import 'package:telware_cross_platform/features/auth/view/screens/log_in_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/verification_screen.dart';
import 'package:telware_cross_platform/features/auth/view/widget/shake_my_auth_input.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_phone_number.dart';
import 'package:telware_cross_platform/features/auth/view/widget/social_log_in.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static const String route = '/sign-up';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  bool isEmailFocused = false;
  bool isPhoneFocused = false;
  bool isPasswordFocused = false;
  bool isConfirmPasswordFocused = false;

  final TextEditingController emailController = TextEditingController();
  final PhoneController phoneController = PhoneController(
      initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ''));
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final emailShakeKey = GlobalKey<ShakeWidgetState>();
  final phoneShakeKey = GlobalKey<ShakeWidgetState>();
  final passwordShakeKey = GlobalKey<ShakeWidgetState>();
  final confirmPasswordShakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(() {
      setState(() {
        isEmailFocused = emailFocusNode.hasFocus;
      });
    });
    phoneFocusNode.addListener(() {
      setState(() {
        isPhoneFocused = phoneFocusNode.hasFocus;
      });
    });
    passwordFocusNode.addListener(() {
      setState(() {
        isPasswordFocused = passwordFocusNode.hasFocus;
      });
    });
    confirmPasswordFocusNode.addListener(() {
      setState(() {
        isConfirmPasswordFocused = confirmPasswordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool isKeyboardOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  void signUp() {
    // todo add logic if email is not valid to return to sign up screen again.
    // phoneController.value.international gives the phone number in international format eg. +20123456789
    ref.read(authViewModelProvider.notifier).signUp(
          email: emailController.text,
          phone: phoneController.value.international,
          password: passwordController.text,
        );
    ref.read(signUpEmailProvider.notifier).update((_) => emailController.text);
    Navigator.of(context).pop(); // to close the dialog
    Navigator.pushNamed(context, VerificationScreen.route);
  }

  void onEdit() {
    Navigator.of(context).pop();
  }

  void handelSubmit() {
    bool someNotFilled = emailController.text.isEmpty ||
        phoneController.value.nsn.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty;

    if (emailController.text.isEmpty) {
      emailShakeKey.currentState?.shake();
    } else if (phoneController.value.nsn.isEmpty) {
      phoneShakeKey.currentState?.shake();
    } else if (passwordController.text.isEmpty) {
      passwordShakeKey.currentState?.shake();
    } else if (confirmPasswordController.text.isEmpty) {
      confirmPasswordShakeKey.currentState?.shake();
    }

    if (someNotFilled) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.vibrate(duration: 100);
        }
      });
    } else {
      showConfirmationDialog(context,
          'Is this the correct email address?',
          emailController.text,
          "Yes", "Edit", signUp, onEdit);
    }
  }

  String? customValidation(String? value) {
    return confirmPasswordValidation(passwordController.text, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      backgroundColor: Palette.background,
      body: Responsive(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const TitleElement(
                    name: 'Your email address',
                    color: Palette.primaryText,
                    fontSize: Sizes.primaryText,
                    fontWeight: FontWeight.bold,
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                  const TitleElement(
                      name:
                          'Please confirm your email address and enter your password.',
                      color: Palette.accentText,
                      fontSize: Sizes.secondaryText,
                      padding: EdgeInsets.only(bottom: 30),
                      width: 250.0),
                  ShakeMyAuthInput(
                    name: 'Email',
                    shakeKey: emailShakeKey,
                    isFocused: isEmailFocused,
                    focusNode: emailFocusNode,
                    controller: emailController,
                    validator: emailValidator,
                  ),
                  AuthPhoneNumber(
                    name: 'Phone Number',
                    shakeKey: phoneShakeKey,
                    isFocused: isPhoneFocused,
                    focusNode: phoneFocusNode,
                    controller: phoneController,
                  ),
                  ShakeMyAuthInput(
                    name: 'Password',
                    shakeKey: passwordShakeKey,
                    isFocused: isPasswordFocused,
                    focusNode: passwordFocusNode,
                    controller: passwordController,
                    obscure: true,
                    validator: passwordValidator,
                  ),
                  ShakeMyAuthInput(
                    name: 'Confirm Password',
                    shakeKey: confirmPasswordShakeKey,
                    isFocused: isConfirmPasswordFocused,
                    focusNode: confirmPasswordFocusNode,
                    controller: confirmPasswordController,
                    obscure: true,
                    validator: customValidation,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TitleElement(
                          name: 'Already have an account?  ',
                          color: Palette.primaryText,
                          fontSize: Sizes.infoText),
                      AuthSubTextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: 'Log in',
                      ),
                    ],
                  ),
                  const SocialLogIn(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AuthFloatingActionButton(
        formKey: formKey,
        onSubmit: handelSubmit,
      ),
    );
  }
}
