import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import 'auth_sub_text_button.dart';

void showConfirmationDialog(
    BuildContext context,
    TextEditingController emailController,
    WebViewControllerPlus controllerPlus,
    VoidCallback onConfirm,
    VoidCallback onEdit) {
  showDialog(
    context: context,
    barrierDismissible: true,
    // Allow dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // Blur effect
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AlertDialog(
                  backgroundColor: Palette.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  contentPadding: const EdgeInsets.only(top: 16),
                  content: SizedBox(
                    width: 1000, // 90% of screen width
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TitleElement(
                          name: 'Is this the correct email address?',
                          color: Palette.accentText,
                          fontSize: Sizes.secondaryText,
                          padding: EdgeInsets.only(right: 70, bottom: 10),
                        ),
                        TitleElement(
                          name: emailController.text,
                          color: Palette.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AuthSubTextButton(
                          onPressed: onEdit,
                          fontSize: Sizes.secondaryText,
                          label: 'Edit',
                        ),
                        AuthSubTextButton(
                          onPressed: onConfirm,
                          fontSize: Sizes.secondaryText,
                          label: 'Yes',
                        ),
                      ],
                    )
                  ],
                ),
                Transform.scale(
                  scale: 1.5, // Adjust the scale factor as needed
                  child: Padding(
                    padding: const EdgeInsets.only(left: 70, top: 30),
                    child: SizedBox(
                      height: 200,
                      width: 300,
                      child: WebViewWidget(
                        controller: controllerPlus,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
    },
  );
}
