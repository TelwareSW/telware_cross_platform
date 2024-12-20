import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_phone_number.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:telware_cross_platform/features/user/view/screens/settings_screen.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeNumberFormScreen extends ConsumerStatefulWidget {
  static const String route = '/change-number-form';

  const ChangeNumberFormScreen({super.key});

  @override
  ConsumerState<ChangeNumberFormScreen> createState() =>
      _ChangeNumberFormScreen();
}

class _ChangeNumberFormScreen extends ConsumerState<ChangeNumberFormScreen> {
  final FocusNode phoneFocusNode = FocusNode();
  bool isPhoneFocused = false;

  final PhoneController phoneController = PhoneController(
      initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ''));

  @override
  void initState() {
    super.initState();
    phoneFocusNode.addListener(() {
      setState(() {
        isPhoneFocused = phoneFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    phoneFocusNode.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool isKeyboardOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  Future<void> _updatePhoneNumber() async {
    final newPhoneNumber = phoneController.value.international;

    // Trigger the update process in UserViewModel
    await ref
        .read(userViewModelProvider.notifier)
        .updatePhoneNumber(newPhoneNumber);
  }

  void _onEdit() {
    context.pop();
  }

  void _handleSubmit() {
    bool notFilled = phoneController.value.nsn.isEmpty;
    if (phoneController.value.nsn.isEmpty) {
      Keys.changeNumberPhoneShakeKey.currentState?.shake();
    }

    if (notFilled) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.vibrate(duration: 100);
        }
      });
    } else {
      // todo (Ahmed): make it like the sign up if it needs captcha.
      // showConfirmationDialog(context,
      //     "Is this the correct number?", phoneNumber,
      //     "Yes", "Edit", _updatePhoneNumber, _onEdit);
      _updatePhoneNumber();
      if (kDebugMode) {
        debugPrint("Success");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.type == UserStateType.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(next.message ?? 'Phone number updated successfully')),
        );
        // context.pop();
        // context.pushReplacement(Routes.verification);
        context.go(SettingsScreen.route);
      } else if (next.type == UserStateType.fail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.message ?? 'Failed to update phone number')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
      ),
      backgroundColor: Palette.background,
      body: Responsive(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Form(
              key: Keys.changeNumberFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const TitleElement(
                    name: 'New Number',
                    color: Palette.primaryText,
                    fontSize: Sizes.primaryText,
                    fontWeight: FontWeight.bold,
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                  const TitleElement(
                      name:
                          'Your new number will receive a confirmation code via SMS.',
                      color: Palette.accentText,
                      fontSize: Sizes.secondaryText,
                      padding: EdgeInsets.only(bottom: 30),
                      width: 250.0),
                  AuthPhoneNumber(
                    name: 'Phone Number',
                    shakeKey: Keys.changeNumberPhoneShakeKey,
                    isFocused: isPhoneFocused,
                    focusNode: phoneFocusNode,
                    controller: phoneController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AuthFloatingActionButton(
        formKey: Keys.changeNumberFormKey,
        onSubmit: _handleSubmit,
      ),
    );
  }
}
