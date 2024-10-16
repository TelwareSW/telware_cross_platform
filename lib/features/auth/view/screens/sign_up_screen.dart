import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_input_field.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/auth/view/widget/circular_button.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';

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

  bool isKeyboardOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: Padding(
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
                      height: isKeyboardOpen(context) ? 160 : 0,
                    ),
                    const TitleElement(
                        name: 'Your email address',
                        color: Palette.primaryText,
                        fontSize: Sizes.primaryText,
                        fontWeight: FontWeight.bold,
                        paddingBottom: 10.0),
                    const TitleElement(
                        name:
                            'Please confirm your email address and enter your password.',
                        color: Palette.accentText,
                        fontSize: Sizes.secondaryText,
                        paddingBottom: 30.0,
                        width: 250.0),
                    AuthInputField(
                        name: 'Email',
                        paddingBottom: 25,
                        paddingLeft: Dimensions.inputPaddingLeft,
                        paddingRight: Dimensions.inputPaddingRight,
                        isFocused: isEmailFocused,
                        focusNode: emailFocusNode),
                    AuthInputField(
                      name: 'Password',
                      paddingBottom: 25,
                      paddingLeft: Dimensions.inputPaddingLeft,
                      paddingRight: Dimensions.inputPaddingRight,
                      isFocused: isPasswordFocused,
                      focusNode: passwordFocusNode,
                      obscure: true,
                    ),
                    AuthInputField(
                      name: 'Confirm Password',
                      paddingBottom: 60,
                      paddingLeft: Dimensions.inputPaddingLeft,
                      paddingRight: Dimensions.inputPaddingRight,
                      isFocused: isConfirmPasswordFocused,
                      focusNode: confirmPasswordFocusNode,
                      obscure: true,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TitleElement(
                            name: 'Already have an account?  ',
                            color: Palette.primaryText,
                            fontSize: Sizes.infoText),
                        TitleElement(
                          name: 'Log in',
                          color: Palette.accent,
                          fontSize: Sizes.infoText,
                          fontWeight: FontWeight.bold,
                        )
                      ],
                    ),
                  ],
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  right: 20,
                  bottom: isKeyboardOpen(context) ? 10 : 150,
                  child: const CircularButton(
                    icon: Icons.arrow_forward,
                    iconSize: Sizes.iconSize,
                    radius: Sizes.circleButtonRadius,
                  ),
                )
              ],
            )),
      ),
    );
  }
}
