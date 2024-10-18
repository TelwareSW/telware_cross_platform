import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/screens/log_in_screen.dart';
import 'package:telware_cross_platform/features/auth/view/widget/shake_my_auth_input.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static const String route = '/sign-up';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  bool isEmailFocused = false;
  bool isPasswordFocused = false;
  bool isConfirmPasswordFocused = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final emailShakeKey = GlobalKey<ShakeWidgetState>();
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
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool isKeyboardOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  void signUp() {
    bool someNotFilled = emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty;

    if (emailController.text.isEmpty) {
      emailShakeKey.currentState?.shake();
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
      ref.read(authViewModelProvider.notifier).signUp(
            email: emailController.text,
            phone: '',
            password: passwordController.text,
          );
    }
  }

  String? customValidation(String? value) {
    return confirmPasswordValidation(passwordController.text, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: Responsive(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Form(
              key: formKey,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: isKeyboardOpen(context) ? 150 : 0,
                      ),
                      const TitleElement(
                        name: 'Your email address',
                        color: Palette.primaryText,
                        fontSize: Sizes.primaryText,
                        fontWeight: FontWeight.bold,
                        paddingBottom: 10.0,
                      ),
                      const TitleElement(
                          name:
                              'Please confirm your email address and enter your password.',
                          color: Palette.accentText,
                          fontSize: Sizes.secondaryText,
                          paddingBottom: 30.0,
                          width: 250.0),
                      ShakeMyAuthInput(
                        name: 'Email',
                        shakeKey: emailShakeKey,
                        isFocused: isEmailFocused,
                        focusNode: emailFocusNode,
                        controller: emailController,
                        validator: emailValidator,
                      ),
                      ShakeMyAuthInput(
                        name: 'Password',
                        shakeKey: passwordShakeKey,
                        isFocused: isPasswordFocused,
                        focusNode: passwordFocusNode,
                        controller: passwordController,
                        obscure: true,
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
                              Navigator.pushReplacementNamed(
                                  context, LogInScreen.route);
                            },
                            label: 'Log in',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AuthFloatingActionButton(
        formKey: formKey,
        onSubmit: signUp,
      ),
    );
  }
}
