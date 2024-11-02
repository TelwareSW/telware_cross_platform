import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

import 'animated_snack_bar_widget.dart';

class CopyableLinkTextWidget extends StatefulWidget {
  final String linkText;

  const CopyableLinkTextWidget({super.key, required this.linkText});

  @override
  State<CopyableLinkTextWidget> createState() => _CopyableLinkTextWidget();
}

class _CopyableLinkTextWidget extends State<CopyableLinkTextWidget> {

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.linkText));

    // Show the SnackBar with the animated icon and message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: AnimatedSnackBarWidget(
          icon: Icon(Icons.copy, color: Colors.white),
          text: "Link copied to clipboard.",
        ),
        duration: Duration(seconds: 1, milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copyToClipboard,
      child: Text(
        widget.linkText,
        style: const TextStyle(
          color: Palette.primary,
          fontSize: Dimensions.fontSizeSmall,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
