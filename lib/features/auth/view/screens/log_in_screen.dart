import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/screens/sign_up_screen.dart';
import 'package:telware_cross_platform/features/auth/view/screens/verification_screen.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/shake_my_auth_input.dart';
import 'package:telware_cross_platform/features/auth/view/widget/social_log_in.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';
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

  void login() {
    // todo handle logic for login
    Navigator.of(context).pop(); // to close the dialog
    Navigator.pushNamed(context, VerificationScreen.route);
  }

  void onEdit() {
    Navigator.of(context).pop(); // to close the dialog
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
    } else {
      // todo handle logic for successful submit
      showConfirmationDialog(context, emailController, login, onEdit);
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
                  const TitleElement(
                    name: 'Log In',
                    color: Palette.primaryText,
                    fontSize: Sizes.headingText,
                    fontWeight: FontWeight.bold,
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                  const TitleElement(
                    name: 'Enter your credentials',
                    color: Palette.accentText,
                    fontSize: Sizes.secondaryText,
                    padding: EdgeInsets.only(bottom: 30),
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
                    paddingBottom: 0,
                    obscure: true,
                    // todo: add validator for the password
                  ),
                  _forgetPasswordButton(),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const TitleElement(
                        name: 'Don\'t have an account?  ',
                        color: Palette.primaryText,
                        fontSize: Sizes.infoText,
                      ),
                      AuthSubTextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, SignUpScreen.route);
                        },
                        label: 'Sign Up',
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

  Widget _forgetPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: Dimensions.inputPaddingLeft, top: 5),
          child: AuthSubTextButton(
            onPressed: () {},
            label: 'Forgot Password?',
          ),
        )
      ],
    );
  }
}
