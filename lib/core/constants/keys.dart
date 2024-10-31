import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';

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

  // SignUpScreen
  static final signUpformKey = GlobalKey<FormState>(debugLabel: 'signup_form');
  static final signUpemailShakeKey = GlobalKey<ShakeWidgetState>(debugLabel: 'signup_email_shake');
  static final signUpphoneShakeKey = GlobalKey<ShakeWidgetState>(debugLabel: 'signup_phone_shake');
  static final signUppasswordShakeKey = GlobalKey<ShakeWidgetState>(debugLabel: 'signup_password_shake');
  static final signUpconfirmPasswordShakeKey = GlobalKey<ShakeWidgetState>(debugLabel: 'signup_confirm_password_shake');

  // VerificationScreen
  static final verificationShakeKey = GlobalKey<ShakeWidgetState>(debugLabel: 'verification_shake');

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