import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:vibration/vibration.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import 'package:telware_cross_platform/core/providers/sign_up_email_provider.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_phone_number.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';
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
  final formKey = GlobalKey<FormState>(debugLabel: 'signup_form');
  final emailKey = GlobalKey<FormFieldState>(debugLabel: 'signup_email_input');
  final phoneKey = GlobalKey<FormFieldState>(debugLabel: 'signup_phone_input');
  final passwordKey =
      GlobalKey<FormFieldState>(debugLabel: 'signup_password_input');
  final confirmPasswordKey =
      GlobalKey<FormFieldState>(debugLabel: 'signup_confirm_password_input');
  final alreadyHaveAccountKey =
      GlobalKey<State>(debugLabel: 'signup_already_have_account_button');
  final signUpSubmitKey = GlobalKey<State>(debugLabel: 'signup_submit_button');
  final onConfirmationKey =
      GlobalKey<State>(debugLabel: 'signup_on_confirmation_button');
  final onCancellationKey =
      GlobalKey<State>(debugLabel: 'signup_on_cancellation_button');

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

  final String siteKey = dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';

  String? captchaToken;

  late WebViewControllerPlus _controllerPlus;

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
    // todo check which field make the error if found to tell the user.
    if (captchaToken == null || captchaToken!.isEmpty) {
      vibrate();
      return;
    }
    // phoneController.value.international gives the phone number in international format eg. +20123456789
    AuthState signUpState =
        await ref.read(authViewModelProvider.notifier).signUp(
              email: emailController.text,
              phone: phoneController.value.international,
              password: passwordController.text,
              confirmPassword: confirmPasswordController.text,
              reCaptchaResponse: captchaToken!,
            );

    if (mounted) {
      context.pop(); // to close the dialog
    }
    if (signUpState.type == AuthStateType.unauthenticated) {
      ref
          .read(signUpEmailProvider.notifier)
          .update((_) => emailController.text);
      if (mounted) {
        context.push(Routes.verification);
      }
    } else {
      //todo show error message to the user eg. email already exists / email not valid
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
      emailShakeKey.currentState?.shake();
    } else if (phoneController.value.nsn.isEmpty) {
      phoneShakeKey.currentState?.shake();
    } else if (passwordController.text.isEmpty) {
      passwordShakeKey.currentState?.shake();
    } else if (confirmPasswordController.text.isEmpty) {
      confirmPasswordShakeKey.currentState?.shake();
    }

    if (someNotFilled) {
      vibrate();
    } else {
      // todo make recaptcha better
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
        onCancelButtonKey: onCancellationKey,
        onConfirmButtonKey: onConfirmationKey,
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
                    formKey: emailKey,
                    shakeKey: emailShakeKey,
                    isFocused: isEmailFocused,
                    focusNode: emailFocusNode,
                    controller: emailController,
                    validator: emailValidator,
                  ),
                  AuthPhoneNumber(
                    name: 'Phone Number',
                    formKey: phoneKey,
                    shakeKey: phoneShakeKey,
                    isFocused: isPhoneFocused,
                    focusNode: phoneFocusNode,
                    controller: phoneController,
                  ),
                  ShakeMyAuthInput(
                    name: 'Password',
                    formKey: passwordKey,
                    shakeKey: passwordShakeKey,
                    isFocused: isPasswordFocused,
                    focusNode: passwordFocusNode,
                    controller: passwordController,
                    obscure: true,
                    validator: passwordValidator,
                  ),
                  ShakeMyAuthInput(
                    name: 'Confirm Password',
                    formKey: confirmPasswordKey,
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
                        buttonKey: alreadyHaveAccountKey,
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
        formKey: formKey,
        onSubmit: handelSubmit,
      ),
    );
  }
}
