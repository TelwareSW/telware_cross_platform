import 'dart:async';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:telware_cross_platform/core/constants/constant.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  static const String route = '/verify';

  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreen();
}

class _VerificationScreen extends ConsumerState<VerificationScreen> {
  String _code = '';
  bool _onEditing = true;
  int remainingTime = 60; // Total seconds for countdown
  Timer? _timer;
  final shakeKey = GlobalKey<ShakeWidgetState>();

  final TextStyle digitStyle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Palette.primary,
  );

  @override
  void initState() {
    super.initState();
    startTimer(); // Start the countdown timer
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  void resendCode() {
    setState(() {
      remainingTime = 60;
    });
    startTimer();
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
      _onEditing = value;
    });
    if (!_onEditing) FocusScope.of(context).unfocus();
  }

  void onSubmit() {
    if (_code.length == VERIFICATION_LENGTH) {
      // todo handle logic for successful submit
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
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
                const TitleElement(
                  name: 'marwan2232004@gmail.com',
                  color: Colors.white,
                  fontSize: Sizes.secondaryText,
                  fontWeight: FontWeight.bold,
                  padding: EdgeInsets.only(bottom: 30),
                  width: 250.0,
                ),
                ShakeMe(
                  key: shakeKey,
                  shakeCount: 3,
                  shakeOffset: 10,
                  shakeDuration: const Duration(milliseconds: 500),
                  child: VerificationCode(
                    textStyle: digitStyle,
                    keyboardType: TextInputType.number,
                    underlineColor: Palette.accentText,
                    underlineUnfocusedColor: Palette.primary,
                    fullBorder: true,
                    digitsOnly: true,
                    underlineWidth: 2.0,
                    length: VERIFICATION_LENGTH,
                    // Assume verification length is 6
                    cursorColor: Palette.accentText,
                    onCompleted: onCompleted,
                    onEditing: onEditing,
                  ),
                ),
                remainingTime == 0
                    ? AuthSubTextButton(
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
        onSubmit: onSubmit,
      ),
    );
  }
}
