import 'dart:async';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/core/providers/sign_up_email_provider.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:telware_cross_platform/core/constants/constant.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  static const String route = '/verify';

  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreen();
}

class _VerificationScreen extends ConsumerState<VerificationScreen> {
  final verificationCodeKey =
      GlobalKey<State>(debugLabel: 'verificationCode_input');
  final resendCodeKey =
      GlobalKey<State>(debugLabel: 'verification_resendCode_button');
  final submitKey = GlobalKey<State>(debugLabel: 'verification_submit_button');
  final shakeKey = GlobalKey<ShakeWidgetState>();

  String _code = '';
  bool codeNotMatched = false;
  int remainingTime =
      VERIFICATION_CODE_EXPIRATION_TIME; // Total seconds for countdown
  Timer? _timer;
  late String email;

  final TextStyle digitStyle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Palette.primary,
  );

  @override
  void initState() {
    super.initState();
    email = ref.read(signUpEmailProvider);
    startTimer(); // Start the countdown timer
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  void resendCode() async {
    AuthState sendCodeState = await ref
        .read(authViewModelProvider.notifier)
        .sendConfirmationCode(email: email);
    if (sendCodeState.type == AuthStateType.success) {
      setState(() {
        remainingTime = VERIFICATION_CODE_EXPIRATION_TIME;
      });
      startTimer();
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime == 0) {
        timer.cancel();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void onCompleted(String value) {
    setState(() {
      _code = value;
    });
  }

  void onEditing(bool value) {
    setState(() {
      codeNotMatched =
          false; // waiting for the user to enter the code to show an error message if the code is not correct
    });
    if (value) {
      setState(() {
        // if the user completed the code then edited it
        // again but did not complete it, then submit the code will contains the old one,
        // so we have to set it to empty to avoid this issue
        _code = '';
      });
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void onSubmit() async {
    if (_code.length == VERIFICATION_LENGTH) {
      AuthState state =
          await ref.read(authViewModelProvider.notifier).verifyEmail(
                email: email,
                code: _code,
              );
      if (state.type == AuthStateType.verified) {
        // todo: Navigate to the home screen
        if (mounted) {
          context.push(Routes.logIn);
        }
      } else {
        setState(() {
          codeNotMatched = true;
        });
      }
    } else {
      shakeKey.currentState?.shake();
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.vibrate(duration: 100);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      body: Responsive(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const TitleElement(
                  name: 'Verification',
                  color: Palette.primaryText,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  padding: EdgeInsets.only(bottom: 30),
                ),
                const TitleElement(
                  name: 'Please enter the verification code sent to',
                  color: Palette.accentText,
                  fontSize: Sizes.secondaryText + 1,
                  padding: EdgeInsets.only(bottom: 5),
                ),
                TitleElement(
                  name: email,
                  color: Colors.white,
                  fontSize: Sizes.secondaryText,
                  fontWeight: FontWeight.bold,
                  padding: const EdgeInsets.only(bottom: 30),
                  width: 250.0,
                ),
                codeNotMatched
                    ? const TitleElement(
                        name:
                            'Verification failed. Try again or request a new one.',
                        color: Colors.white,
                        fontSize: Sizes.secondaryText,
                        padding: EdgeInsets.only(bottom: 30),
                        width: 350.0,
                      )
                    : const SizedBox(),
                ShakeMe(
                  key: shakeKey,
                  shakeCount: 3,
                  shakeOffset: 10,
                  shakeDuration: const Duration(milliseconds: 500),
                  child: VerificationCode(
                    key: verificationCodeKey,
                    textStyle: digitStyle,
                    keyboardType: TextInputType.number,
                    underlineColor: Palette.accentText,
                    underlineUnfocusedColor: Palette.primary,
                    fullBorder: true,
                    digitsOnly: true,
                    underlineWidth: 2.0,
                    length: VERIFICATION_LENGTH,
                    cursorColor: Palette.accentText,
                    onCompleted: onCompleted,
                    onEditing: onEditing,
                  ),
                ),
                remainingTime == 0
                    ? AuthSubTextButton(
                        buttonKey: resendCodeKey,
                        onPressed: resendCode,
                        label: 'Resend code',
                        padding: const EdgeInsets.only(top: 20, right: 5),
                        fontSize: Sizes.secondaryText,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const TitleElement(
                            name: 'Resend code in',
                            color: Palette.accentText,
                            fontSize: Sizes.secondaryText,
                            padding: EdgeInsets.only(top: 20, right: 5),
                          ),
                          TitleElement(
                            name: formatTime(remainingTime),
                            color: Colors.white,
                            fontSize: Sizes.secondaryText,
                            fontWeight: FontWeight.bold,
                            padding: const EdgeInsets.only(top: 20),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AuthFloatingActionButton(
        buttonKey: submitKey,
        onSubmit: onSubmit,
      ),
    );
  }
}
