import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/view/widget/responsive.dart';
import 'package:telware_cross_platform/features/auth/view/screens/verification_screen.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_phone_number.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';

class ChangeNumberFormScreen extends ConsumerStatefulWidget {
  static const String route = '/change-number-form';

  const ChangeNumberFormScreen({super.key});

  @override
  ConsumerState<ChangeNumberFormScreen> createState() =>
      _ChangeNumberFormScreen();
}

class _ChangeNumberFormScreen extends ConsumerState<ChangeNumberFormScreen> {
  final formKey = GlobalKey<FormState>();
  final FocusNode phoneFocusNode = FocusNode();
  bool isPhoneFocused = false;

  final PhoneController phoneController = PhoneController(
      initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ''));

  final phoneShakeKey = GlobalKey<ShakeWidgetState>();

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

  void _updatePhoneNumber() {
    // ref.read(authViewModelProvider.notifier).updatePhoneNumber(
    //   phone: phoneController.value.international,
    // );
    Navigator.of(context).pop(); // to close the dialog
    Navigator.pushReplacementNamed(context, VerificationScreen.route);
  }

  void _onEdit() {
    Navigator.of(context).pop();
  }

  void _handleSubmit() {
    bool notFilled = phoneController.value.nsn.isEmpty;
    if (phoneController.value.nsn.isEmpty) {
      phoneShakeKey.currentState?.shake();
    }

    String phoneNumber = "+${phoneController.value.countryCode} "
        "${phoneController.value.nsn}";

    if (notFilled) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
          Vibration.vibrate(duration: 100);
        }
      });
    } else {
      showConfirmationDialog(
          context: context,
          title: "Is this the correct number?",
          subtitle: phoneNumber,
          confirmText: "Yes",
          cancelText: "Edit",
          onConfirm: _updatePhoneNumber,
          onCancel: _onEdit);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              key: formKey,
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
                    shakeKey: phoneShakeKey,
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
        formKey: formKey,
        onSubmit: _handleSubmit,
      ),
    );
  }
}
