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

  Keys._();
}