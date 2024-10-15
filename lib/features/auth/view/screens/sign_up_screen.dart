import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_input_field.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';

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
    emailFocusNode.dispose(); // Dispose the FocusNode to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const TitleElement(
                  name: 'Your email address',
                  color: Palette.primaryText,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  paddingBottom: 10.0),
              const TitleElement(
                  name:
                      'Please confirm your email address and enter your password.',
                  color: Palette.accentText,
                  fontSize: 15.0,
                  paddingBottom: 30.0,
                  width: 250.0),
              AuthInputField(
                  name: 'Email',
                  paddingBottom: 25,
                  paddingLeft: 40,
                  paddingRight: 40,
                  isFocused: isEmailFocused,
                  focusNode: emailFocusNode),
              AuthInputField(
                  name: 'Password',
                  paddingBottom: 25,
                  paddingLeft: 40,
                  paddingRight: 40,
                  isFocused: isPasswordFocused,
                  focusNode: passwordFocusNode),
              AuthInputField(
                  name: 'Confirm Password',
                  paddingBottom: 60,
                  paddingLeft: 40,
                  paddingRight: 40,
                  isFocused: isConfirmPasswordFocused,
                  focusNode: confirmPasswordFocusNode),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleElement(
                      name: 'Already have an account?  ',
                      paddingBottom: 0,
                      color: Palette.primaryText,
                      fontSize: 12),
                  TitleElement(
                    name: 'Log in',
                    paddingBottom: 0,
                    color: Palette.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15, top: 30),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(
                    onPressed: () {
                      // Button action
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Palette.primary, // Button color
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Palette.icons,
                      size: 22, // Icon size
                    ),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
