import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';

class WidgetKeys {
  static const ValueKey<String> settingsOptionSuffix = ValueKey('-option');
  static const ValueKey<String> iconSuffix = ValueKey('-icon');
  static const ValueKey<String> settingsSectionSuffix = ValueKey('-section');
  static const ValueKey<String> titleSuffix = ValueKey('-title');
  static const ValueKey<String> trailingSuffix = ValueKey('-trailing');
  static const ValueKey<String> radioButtonSuffix = ValueKey('-radio-button');
  static const ValueKey<String> settingsRadioOptionSuffix =
      ValueKey('-radio-button-option');
  static const ValueKey<String> settingsToggleSwitchOptionSuffix =
      ValueKey('-switch-option');
  static const ValueKey<String> toggleSwitchButtonSuffix =
      ValueKey('-switch-button');
  static const ValueKey<String> userChatCopyableLink =
      ValueKey("user-chat-copyable-link");
}

class SignUpKeys {
  static final formKey = GlobalKey<FormState>(debugLabel: 'signup_form');
  static final emailKey =
      GlobalKey<FormFieldState>(debugLabel: 'signup_email_input');
  static final phoneKey =
      GlobalKey<FormFieldState>(debugLabel: 'signup_phone_input');
  static final passwordKey =
      GlobalKey<FormFieldState>(debugLabel: 'signup_password_input');
  static final confirmPasswordKey =
      GlobalKey<FormFieldState>(debugLabel: 'signup_confirm_password_input');
  static final alreadyHaveAccountKey =
      GlobalKey<State>(debugLabel: 'signup_already_have_account_button');
  static final signUpSubmitKey =
      GlobalKey<State>(debugLabel: 'signup_submit_button');
  static final onConfirmationKey =
      GlobalKey<State>(debugLabel: 'signup_on_confirmation_button');
  static final onCancellationKey =
      GlobalKey<State>(debugLabel: 'signup_on_cancellation_button');

  static final emailShakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'signup_email_shake');
  static final phoneShakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'signup_phone_shake');
  static final passwordShakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'signup_password_shake');
  static final confirmPasswordShakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'signup_confirm_password_shake');
}

class ValidationKeys {
  static final verificationCodeKey =
      GlobalKey<State>(debugLabel: 'verificationCode_input');
  static final resendCodeKey =
      GlobalKey<State>(debugLabel: 'verification_resendCode_button');
  static final submitKey =
      GlobalKey<State>(debugLabel: 'verification_submit_button');
  static final shakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'verification_shake');
}

class ChangeEmailKeys {
  static final formKey = GlobalKey<FormState>(debugLabel: 'change_email_form');
  static final emailKey =
      GlobalKey<FormFieldState>(debugLabel: 'change_email_input');
  static final submitKey =
      GlobalKey<State>(debugLabel: 'change_email_submit_button');
  static final emailShakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'change_email_shake');
}
