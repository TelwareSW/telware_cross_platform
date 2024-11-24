import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:telware_cross_platform/core/models/signup_result.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';
import 'package:vibration/vibration.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';

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

class SignUpScreen extends ConsumerStatefulWidget {
  static const String route = '/sign-up';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  //-------------------------------------- Focus nodes -------------------------
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  bool isEmailFocused = false;
  bool isPhoneFocused = false;
  bool isPasswordFocused = false;
  bool isConfirmPasswordFocused = false;

  //-------------------------------------- Controllers -------------------------

  final TextEditingController emailController = TextEditingController();
  final PhoneController phoneController = PhoneController(
      initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ''));
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  late WebViewControllerPlus _controllerPlus;

  //-------------------------------------- Errors -------------------------
  String? emailError;
  String? phoneError;

  String? passwordError;

  String? confirmPasswordError;

  final String siteKey = dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';

  final bool byPassCaptcha =
      (dotenv.env['BYPASS_CAPTCHA'] ?? 'false') == 'true';

  String? captchaToken;

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
    _controllerPlus = WebViewControllerPlus()
      ..addJavaScriptChannel('onCaptchaCompleted',
          onMessageReceived: (JavaScriptMessage message) {
        captchaToken = message.message;
        debugPrint('Captcha token: $captchaToken');
      })
      ..loadFlutterAssetServer('assets/webpages/captcha.html')
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));
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
    _controllerPlus.server.close();
    super.dispose();
  }

  void vibrate() {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator ?? false) {
        Vibration.vibrate(duration: 100);
      }
    });
  }

  Widget reCaptcha() {
    return Transform.scale(
      scale: 1.1,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 70,
        ),
        child: SizedBox(
          height: 200,
          width: 300,
          child: WebViewWidget(
            controller: _controllerPlus,
          ),
        ),
      ),
    );
  }

  void signUp() async {
    if ((captchaToken == null || captchaToken!.isEmpty) && !byPassCaptcha) {
      vibrate();
      return;
    }
    // phoneController.value.international gives the phone number in international format eg. +20123456789
    SignupResult signUpResult =
        await ref.read(authViewModelProvider.notifier).signUp(
              email: emailController.text,
              phone: phoneController.value.international,
              password: passwordController.text,
              confirmPassword: confirmPasswordController.text,
              reCaptchaResponse: byPassCaptcha ? 'dummy' : captchaToken!,
            );

    if (mounted) {
      context.pop();
    }
    // if the error message is not "Please provide all required fields" then
    // the captcha token is invalid, so if the byPassCaptcha is true then we will
    // ignore the captcha token and proceed to the verification screen
    if (signUpResult.state.type == AuthStateType.unverified ||
        (byPassCaptcha &&
            signUpResult.error?.error == "reCaptcha verification failed")) {
      ref.read(emailProvider.notifier).update((_) => emailController.text);
      if (mounted) {
        context.push(Routes.verification);
      }
    } else {
      setState(() {
        emailError = signUpResult.error?.emailError;
        phoneError = signUpResult.error?.phoneNumberError;
        passwordError = signUpResult.error?.passwordError;
        confirmPasswordError = signUpResult.error?.confirmPasswordError;
        debugPrint('emailError: $emailError');
        debugPrint('phoneError: $phoneError');
        debugPrint('passwordError: $passwordError');
        debugPrint('confirmPasswordError: $confirmPasswordError');
      });
    }
  }

  void onEdit() {
    context.pop();
  }

  void handelSubmit() {
    bool someNotFilled = emailController.text.isEmpty ||
        phoneController.value.nsn.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty;

    if (emailController.text.isEmpty) {
      SignUpKeys.emailShakeKey.currentState?.shake();
    } else if (phoneController.value.nsn.isEmpty) {
      SignUpKeys.phoneShakeKey.currentState?.shake();
    } else if (passwordController.text.isEmpty) {
      SignUpKeys.passwordShakeKey.currentState?.shake();
    } else if (confirmPasswordController.text.isEmpty) {
      SignUpKeys.confirmPasswordShakeKey.currentState?.shake();
    }

    if (someNotFilled) {
      vibrate();
    } else {
      showConfirmationDialog(
        context: context,
        title: 'is this the correct email?',
        subtitle: emailController.text,
        confirmText: 'Yes',
        cancelText: 'Edit',
        actionsAlignment: MainAxisAlignment.spaceBetween,
        onConfirm: signUp,
        onCancel: onEdit,
        trailing: reCaptcha(),
        onCancelButtonKey: SignUpKeys.onCancellationKey,
        onConfirmButtonKey: SignUpKeys.onConfirmationKey,
      );
    }
  }

  String? customValidation(String? value) {
    return confirmPasswordValidation(passwordController.text, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Palette.background,
      body: Center(
        child: SingleChildScrollView(
          child: Responsive(
            child: Form(
              key: SignUpKeys.formKey,
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
                    errorText: emailError,
                    formKey: SignUpKeys.emailKey,
                    shakeKey: SignUpKeys.emailShakeKey,
                    isFocused: isEmailFocused,
                    focusNode: emailFocusNode,
                    controller: emailController,
                    validator: emailValidator,
                  ),
                  AuthPhoneNumber(
                    name: 'Phone Number',
                    errorText: phoneError,
                    formKey: SignUpKeys.phoneKey,
                    shakeKey: SignUpKeys.phoneShakeKey,
                    isFocused: isPhoneFocused,
                    focusNode: phoneFocusNode,
                    controller: phoneController,
                  ),
                  ShakeMyAuthInput(
                    name: 'Password',
                    errorText: passwordError,
                    formKey: SignUpKeys.passwordKey,
                    shakeKey: SignUpKeys.passwordShakeKey,
                    isFocused: isPasswordFocused,
                    focusNode: passwordFocusNode,
                    controller: passwordController,
                    obscure: true,
                    validator: passwordValidator,
                  ),
                  ShakeMyAuthInput(
                    name: 'Confirm Password',
                    errorText: confirmPasswordError,
                    formKey: SignUpKeys.confirmPasswordKey,
                    shakeKey: SignUpKeys.confirmPasswordShakeKey,
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
                          padding: EdgeInsets.only(right: 5),
                          name: 'Already have an account?',
                          color: Palette.primaryText,
                          fontSize: Sizes.infoText),
                      AuthSubTextButton(
                        buttonKey: SignUpKeys.alreadyHaveAccountKey,
                        onPressed: () {
                          context.pop();
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
        formKey: SignUpKeys.formKey,
        buttonKey: SignUpKeys.signUpSubmitKey,
        onSubmit: handelSubmit,
      ),
    );
  }
}
