import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/widget/shake_my_auth_input.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/auth/view/widget/circular_button.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:vibration/vibration.dart';

class LogInScreen extends StatefulWidget {
  static const String route = '/log-in';

  const LogInScreen({super.key});

  @override
  LogInScreenState createState() => LogInScreenState();
}

class LogInScreenState extends State<LogInScreen> {
  final formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  bool isEmailFocused = false;
  bool isPasswordFocused = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final emailShakeKey = GlobalKey<ShakeWidgetState>();
  final passwordShakeKey = GlobalKey<ShakeWidgetState>();

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
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handelSubmit() {
    bool someNotFilled =
        emailController.text.isEmpty || passwordController.text.isEmpty;

    if (emailController.text.isEmpty) {
      emailShakeKey.currentState?.shake();
    } else if (passwordController.text.isEmpty) {
      passwordShakeKey.currentState?.shake();
    }

    if (someNotFilled) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.vibrate(duration: 100);
        }
      });
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
            padding: const EdgeInsets.only(top: 0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // const SizedBox(
                  //   height: 150,
                  // ),
                  const TitleElement(
                    name: 'Log In',
                    color: Palette.primaryText,
                    fontSize: Sizes.headingText,
                    fontWeight: FontWeight.bold,
                    paddingBottom: 10.0,
                  ),
                  const TitleElement(
                    name: 'Enter your credentials',
                    color: Palette.accentText,
                    fontSize: Sizes.secondaryText,
                    paddingBottom: 30.0,
                    width: 250.0,
                  ),
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
                    // todo: add validator for the password
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TitleElement(
                        name: 'Don\'t have an account?  ',
                        color: Palette.primaryText,
                        fontSize: Sizes.infoText,
                      ),
                      TextButton(
                        onPressed: () => {},
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const TitleElement(
                          name: 'Sign Up',
                          color: Palette.accent,
                          fontSize: Sizes.infoText,
                          fontWeight: FontWeight.bold,
                        ),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: CircularButton(
          icon: Icons.arrow_forward,
          iconSize: Sizes.iconSize,
          radius: Sizes.circleButtonRadius,
          formKey: formKey,
          handelSubmit: handelSubmit,
        ),
      ),
    );
  }
}

class SocialLogIn extends StatelessWidget {
  const SocialLogIn({
    super.key,
  });

  static const double _size = 35;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
              height: 1,
              width: 250,
              decoration: const BoxDecoration(color: Palette.primaryText)),
        ),
        const Text('or Continue with'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _socialButton(img: 'google-g-white.png', onTap: () {}),
            _socialButton(img: 'facebook-f-white.png', onTap: () {}),
            _socialButton(img: 'github-icon-white.png', onTap: () {}),
          ],
        )
      ],
    );
  }

  Widget _socialButton({required VoidCallback onTap, required String img}) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        width: _size,
        height: _size,
        child: InkWell(
          onTap: onTap,
          child: Image.asset('assets/imgs/$img'),
        ),
      );
}
