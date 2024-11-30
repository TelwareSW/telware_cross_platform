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

  WidgetKeys._();
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

  SignUpKeys._();
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

  ValidationKeys._();
}

class ChangeEmailKeys {
  static final formKey = GlobalKey<FormState>(debugLabel: 'change_email_form');
  static final emailKey =
      GlobalKey<FormFieldState>(debugLabel: 'change_email_input');
  static final submitKey =
      GlobalKey<State>(debugLabel: 'change_email_submit_button');
  static final emailShakeKey =
      GlobalKey<ShakeWidgetState>(debugLabel: 'change_email_shake');

  ChangeEmailKeys._();
}

class ChatKeys {
  static const ValueKey<String> chatSearchButton = ValueKey('chat-search-button');
  static const ValueKey<String> chatSearchInput = ValueKey('chat-search-input');
  static const ValueKey<String> chatSearchShowMode = ValueKey('chat-search-show-mode');
  static const ValueKey<String> chatSearchDatePicker = ValueKey('chat-search-date-picker');
  static const ValueKey<String> chatTilePrefix = ValueKey('chat-tile-');
  static const ValueKey<String> chatMessagePrefix = ValueKey('chat-message-');
  static const ValueKey<String> chatNamePostfix = ValueKey('-name');
  static const ValueKey<String> chatTileDisplayTextPostfix =
      ValueKey('-display-text');
  static const ValueKey<String> chatTileDisplayTimePostfix =
      ValueKey('-display-time');
  static const ValueKey<String> chatTileDisplayUnreadCountPostfix =
      ValueKey('-display-unread-count');
  static const ValueKey<String> chatTileMentionPostfix = ValueKey('-mention');
  static const ValueKey<String> chatTileMutePostfix = ValueKey('-mute');
  static const ValueKey<String> chatTileMessageStatusPostfix =
      ValueKey('-message');
  static const ValueKey<String> chatAvatarPostfix = ValueKey('-avatar');

  ChatKeys._();
}

class MessageKeys {
  static const ValueKey<String> messagePrefix = ValueKey('message-');
  static const ValueKey<String> messageSenderPostfix = ValueKey('-sender');
  static const ValueKey<String> messageContentPostfix = ValueKey('-content');
  static const ValueKey<String> messageTimePostfix = ValueKey('-time');
  static const ValueKey<String> messageStatusPostfix = ValueKey('-status');
  static const ValueKey<String> messageReplyPostfix = ValueKey('-reply');
  static const ValueKey<String> messageForwardPostfix = ValueKey('-forward');
  static const ValueKey<String> messageCopyPostfix = ValueKey('-copy');
  static const ValueKey<String> messageDeletePostfix = ValueKey('-delete');

  MessageKeys._();
}


class Keys {
  // LogInScreen
  static final logInFormKey = GlobalKey<FormState>(debugLabel:'login_form');
  static final logInEmailKey = GlobalKey<FormFieldState>(debugLabel:'login_email_input');
  static final logInPasswordKey = GlobalKey<FormFieldState>(debugLabel:'login_password_input');
  static final logInForgotPasswordKey = GlobalKey<State>(debugLabel:'login_forgot_password_button');
  static final logInSignUpKey = GlobalKey<State>(debugLabel:'login_signup_button');
  static final logInSubmitKey = GlobalKey<State>(debugLabel:'login_submit_button');
  static final logInemailShakeKey = GlobalKey<ShakeWidgetState>(debugLabel: 'login_email_shake');
  static final logInpasswordShakeKey = GlobalKey<ShakeWidgetState>(debugLabel: 'login_password_shake');

  // ChangeNumberFormScreen
  static final changeNumberFormKey = GlobalKey<FormState>(debugLabel: 'change_number_form');
  static final changeNumberPhoneShakeKey = GlobalKey<ShakeWidgetState>(debugLabel: 'change_number_phone_shake');

  // SocialLogIn
  static const googleLogIn = Key('google_log_in');
  static const githubLogIn = Key('github_log_in');

  // ShowTakenStoryScreen
  static final signatureBoundaryKey  = GlobalKey(debugLabel: 'signature_boundary');

  // ProfileInfoScreen
  static final profileInfoFirstNameShakeKey = GlobalKey<ShakeWidgetState>();
  static final profileInfoLastNameShakeKey = GlobalKey<ShakeWidgetState>();
  static const profileInfoFirstNameInput = ValueKey("first-name-input");
  static const profileInfoLastNameInput = ValueKey("last-name-input");
  static const profileInfoBioInput = ValueKey("bio-input");

  // SettingsScreen
  static const settingsSetProfilePhotoOptions = ValueKey("set-profile-photo-option");

  Keys._();
}