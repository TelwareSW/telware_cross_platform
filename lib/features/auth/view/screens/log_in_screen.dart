import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';

import 'package:telware_cross_platform/core/providers/sign_up_provider.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/shake_my_auth_input.dart';
import 'package:telware_cross_platform/features/auth/view/widget/social_log_in.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';

class LogInScreen extends ConsumerStatefulWidget {
  static const String route = '/log-in';

  const LogInScreen({super.key});

  @override
  ConsumerState<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends ConsumerState<LogInScreen> {
  //------------------------------Keys------------------------------------------
  final logInFormKey = GlobalKey<FormState>(debugLabel: 'login_form');
  final logInEmailKey =
      GlobalKey<FormFieldState>(debugLabel: 'login_email_input');
  final logInPasswordKey =
      GlobalKey<FormFieldState>(debugLabel: 'login_password_input');
  final logInForgotPasswordKey =
      GlobalKey<State>(debugLabel: 'login_forgot_password_button');
  final logInSignUpKey = GlobalKey<State>(debugLabel: 'login_signup_button');
  final logInSubmitKey = GlobalKey<State>(debugLabel: 'login_submit_button');
  final logInemailShakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'login_email_shake');
  final logInpasswordShakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'login_password_shake');

  //----------------------------------------------------------------------------
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  bool isEmailFocused = false;
  bool isPasswordFocused = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

  void vibrate() {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator ?? false) {
        Vibration.vibrate(duration: 100);
      }
    });
  }

  void handelState(AuthState state) {
    if (state.type == AuthStateType.fail ||
        state.type == AuthStateType.success) {
      // the success state is in case of asking for reset password
      showToastMessage(state.message!);
    } else if (state.type == AuthStateType.authenticated) {
      context.go(Routes.home);
    } else if (state.type == AuthStateType.unverified) {
      ref.read(emailProvider.notifier).update((_) => emailController.text);
      context.push(
        Routes.verification,
        extra: {'sendVerificationCode': true}, // or false based on your logic
      );
    }
  }

  void login() {
    bool someNotFilled =
        emailController.text.isEmpty || passwordController.text.isEmpty;

    if (emailController.text.isEmpty) {
      logInemailShakeKey.currentState?.shake();
    } else if (passwordController.text.isEmpty) {
      logInpasswordShakeKey.currentState?.shake();
    }

    if (someNotFilled) {
      vibrate();
    } else {
      ref.read(authViewModelProvider.notifier).login(
          email: emailController.text, password: passwordController.text);
    }
  }

  void forgotPassword() {
    if (emailController.text.isEmpty) {
      showToastMessage('Enter an Email');
      logInemailShakeKey.currentState?.shake();
      return vibrate();
    }

    if (logInEmailKey.currentState != null &&
        (logInEmailKey.currentState?.validate() ?? false)) {
      debugPrint('forgot password called');
      ref
          .read(authViewModelProvider.notifier)
          .forgotPassword(emailController.text);
    } else {
      debugPrint('forgot password not called');
      debugPrint(
          'Keys.logInEmailKey.currentState: ${logInEmailKey.currentState}');
    }
  }

  String? customValidation(String? value) {
    return confirmPasswordValidation(passwordController.text, value);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (_, state) {
      if (state.type == AuthStateType.fail ||
          state.type == AuthStateType.success) {
        // the success state is in case of asking for reset password
        showToastMessage(state.message!);
      } else if (state.type == AuthStateType.authenticated) {
        context.go(Routes.home);
      } else if (state.type == AuthStateType.unverified) {
        ref.read(emailProvider.notifier).update((_) => emailController.text);
        context.push(
          Routes.verification,
          extra: {'sendVerificationCode': true}, // or false based on your logic
        );
      }
    });

    bool isLoading =
        ref.watch(authViewModelProvider).type == AuthStateType.loading;
    debugPrint('isLoading: $isLoading');

    return Scaffold(
      backgroundColor: Palette.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Center(
              child: SingleChildScrollView(
                child: Responsive(
                  child: Form(
                    key: logInFormKey,
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
                          formKey: logInEmailKey,
                          shakeKey: logInemailShakeKey,
                          isFocused: isEmailFocused,
                          focusNode: emailFocusNode,
                          controller: emailController,
                          validator: emailValidator,
                        ),
                        ShakeMyAuthInput(
                          name: 'Password',
                          formKey: logInPasswordKey,
                          shakeKey: logInpasswordShakeKey,
                          isFocused: isPasswordFocused,
                          focusNode: passwordFocusNode,
                          controller: passwordController,
                          padding: const EdgeInsets.only(
                            left: Dimensions.inputPaddingRight,
                            right: Dimensions.inputPaddingLeft,
                          ),
                          obscure: true,
                          visibilityKey: const Key('login-password-visibility'),
                        ),
                        _forgetPasswordButton(),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const TitleElement(
                              padding: EdgeInsets.only(right: 5),
                              name: 'Don\'t have an account?',
                              color: Palette.primaryText,
                              fontSize: Sizes.infoText,
                            ),
                            AuthSubTextButton(
                              buttonKey: logInSignUpKey,
                              onPressed: () {
                                context.push(Routes.signUp);
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
        formKey: logInFormKey,
        buttonKey: logInSubmitKey,
        onSubmit: login,
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
            buttonKey: logInForgotPasswordKey,
            onPressed: forgotPassword,
            label: 'Forgot Password?',
          ),
        )
      ],
    );
  }
}
