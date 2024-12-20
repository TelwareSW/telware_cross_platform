import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';

import 'auth_sub_text_button.dart';

void showConfirmationDialog({
  required BuildContext context,
  required String title,
  FontWeight? titleFontWeight,
  Color? titleColor,
  double? titleFontSize,
  required String subtitle,
  FontWeight? subtitleFontWeight,
  Color? subtitleColor,
  double? subtitleFontSize,
  double? contentGap,
  required String confirmText,
  EdgeInsetsGeometry? confirmPadding,
  Color? confirmColor,
  required String cancelText,
  EdgeInsetsGeometry? cancelPadding,
  Color? cancelColor,
  required VoidCallback onConfirm,
  required VoidCallback onCancel,
  GlobalKey<State>? onConfirmButtonKey,
  GlobalKey<State>? onCancelButtonKey,
  MainAxisAlignment? actionsAlignment,
  Widget? trailing,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    // Allow dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 17.0, sigmaY: 17.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AlertDialog(
                  backgroundColor: Palette.trinary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  contentPadding: const EdgeInsets.only(top: 16),
                  content: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleElement(
                          name: title,
                          color: titleColor ?? Palette.accentText,
                          fontSize: titleFontSize ?? Sizes.secondaryText,
                          fontWeight: titleFontWeight,
                          textAlign: TextAlign.left,
                        ),
                        TitleElement(
                          name: subtitle,
                          color: subtitleColor ?? Palette.primaryText,
                          fontSize: subtitleFontSize ?? 16,
                          fontWeight: subtitleFontWeight ?? FontWeight.bold,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: contentGap ?? 10),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment:
                          actionsAlignment ?? MainAxisAlignment.spaceBetween,
                      children: [
                        AuthSubTextButton(
                          buttonKey: onCancelButtonKey,
                          onPressed: onCancel,
                          fontSize: Sizes.secondaryText,
                          label: cancelText,
                          color: cancelColor,
                          padding: cancelPadding ?? const EdgeInsets.all(0),
                        ),
                        AuthSubTextButton(
                          buttonKey: onConfirmButtonKey,
                          onPressed: onConfirm,
                          fontSize: Sizes.secondaryText,
                          label: confirmText,
                          color: confirmColor,
                          padding: confirmPadding ?? const EdgeInsets.all(0),
                        ),
                      ],
                    )
                  ],
                ),
                trailing ?? Container(),
              ],
            ),
          ),
        ),
      );
    },
  );
}
