import 'dart:async';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/core/providers/sign_up_provider.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_sub_text_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/constants/constant.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/utils.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  static const String route = '/verify';
  final bool sendVerificationCode;

  const VerificationScreen({super.key, required this.sendVerificationCode});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreen();
}

class _VerificationScreen extends ConsumerState<VerificationScreen> {
  //-------------------------------------- Keys --------------------------------
  final verificationCodeKey =
      GlobalKey<State>(debugLabel: 'verificationCode_input');
  final resendCodeKey =
      GlobalKey<State>(debugLabel: 'verification_resendCode_button');
  final submitKey = GlobalKey<State>(debugLabel: 'verification_submit_button');
  final shakeKey = GlobalKey<ShakeWidgetState>();

  //------------------------------ Controllers ---------------------------------
  late StreamController<ErrorAnimationType> errorController;

  String _code = '';
  int remainingTime =
      VERIFICATION_CODE_EXPIRATION_TIME; // Total seconds for countdown
  Timer? _timer;
  late String email;

  final TextStyle digitStyle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  sendVerificationCode() async {
    await ref.read(authViewModelProvider.notifier).sendConfirmationCode(
          email: email,
        );
  }

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    email = ref.read(emailProvider);
    if (widget.sendVerificationCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sendVerificationCode();
      });
    }
    startTimer(); // Start the countdown timer
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    errorController.close();
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

  void onCompleted(String value) {
    setState(() {
      _code = value;
    });
  }

  void onEditing(String? value) {
    setState(() {
      _code = '';
    });
  }

  void onSubmit() async {
    if (_code.length == VERIFICATION_LENGTH) {
      AuthState state =
          await ref.read(authViewModelProvider.notifier).verifyEmail(
                email: email,
                code: _code,
              );
      if (state.type == AuthStateType.verified) {
        if (mounted) {
          context.push(Routes.logIn);
        }
      } else {
        showToastMessage(state.message!);
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
      backgroundColor: Palette.secondary,
      appBar: AppBar(
        backgroundColor: Palette.secondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Responsive(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LottieViewer(
                path: 'assets/json/mail.json',
                width: 200,
                height: 200,
              ),
              const TitleElement(
                name: 'Check Your Email',
                color: Palette.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                padding: EdgeInsets.only(bottom: 10),
              ),
              TitleElement(
                name:
                    'Please enter the code we have sent to your email\n $email',
                color: Palette.accentText,
                fontSize: 14,
                padding: const EdgeInsets.only(bottom: 40),
              ),
              ShakeMe(
                key: shakeKey,
                shakeCount: 3,
                shakeOffset: 10,
                shakeDuration: const Duration(milliseconds: 500),
                child: PinCodeTextField(
                  keyboardType: TextInputType.number,
                  length: VERIFICATION_LENGTH,
                  mainAxisAlignment: MainAxisAlignment.center,
                  obscureText: false,
                  animationType: AnimationType.slide,
                  autoFocus: true,
                  useHapticFeedback: true,
                  textStyle: digitStyle,
                  pinTheme: PinTheme(
                    fieldOuterPadding: const EdgeInsets.all(5),
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 42,
                    fieldWidth: 33,
                    activeFillColor: Palette.secondary,
                    inactiveFillColor: Palette.secondary,
                    selectedFillColor: Palette.secondary,
                    inactiveColor: const Color.fromRGBO(77, 91, 104, 1),
                    activeColor: const Color.fromRGBO(77, 91, 104, 1),
                    selectedColor: Palette.primary,
                  ),
                  showCursor: false,
                  animationDuration: const Duration(milliseconds: 200),
                  backgroundColor: Palette.secondary,
                  enableActiveFill: true,
                  errorAnimationController: errorController,
                  onCompleted: onCompleted,
                  onChanged: onEditing,
                  beforeTextPaste: (text) {
                    return false;
                  },
                  appContext: context,
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
      floatingActionButton: AuthFloatingActionButton(
        buttonKey: submitKey,
        onSubmit: onSubmit,
      ),
    );
  }
}
