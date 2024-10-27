import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class SettingsInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final double fontSize;
  final Color color;
  final bool showDivider;
  final int lettersCap;
  final shakeKey;

  const SettingsInputWidget({
    super.key,
    required this.controller,
    this.placeholder = "",
    this.fontSize = 14,
    this.color = Palette.primaryText,
    this.lettersCap = -1,
    this.showDivider = true,
    this.shakeKey,
  });

  @override
  _SettingsInputWidgetState createState() => _SettingsInputWidgetState();
}

class _SettingsInputWidgetState extends State<SettingsInputWidget> {
  @override
  void initState() {
    super.initState();
    // Listen to changes in the TextEditingController
    widget.controller.addListener(() {
      setState(() {}); // Update the UI when the text changes
    });
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int remainingChars = widget.lettersCap >= 0
        ? widget.lettersCap - widget.controller.text.length
        : -1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
        children: [
          // Row to hold the TextField and remaining character count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space evenly
            children: [
              Expanded( // Allows TextField to take remaining space
                child: ShakeMe(
                  key: widget.shakeKey,
                  shakeCount: 1,
                  shakeOffset: 8,
                  shakeDuration: const Duration(milliseconds: 300),
                  child: TextField(
                    key: widget.key,
                    controller: widget.controller,
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(color: Palette.accentText, fontSize: widget.fontSize), // Placeholder color
                      border: InputBorder.none, // Makes the border invisible
                      focusedBorder: InputBorder.none, // Also remove border when focused
                      enabledBorder: InputBorder.none, // Remove border when enabled
                    ),
                    inputFormatters: [
                      // Limit the number of characters if lettersCap is greater than 0
                      if (widget.lettersCap > 0)
                        LengthLimitingTextInputFormatter(widget.lettersCap),
                    ],
                  ),
                ),
              ),
              if (widget.lettersCap > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // Add some spacing
                  child: Text(
                    remainingChars >= 0 ? '$remainingChars' : '',
                    style: TextStyle(color: Palette.accentText, fontSize: widget.fontSize * 0.8),
                  ),
                ),
            ],
          ),
          // Optional Divider
          if (widget.showDivider) const Divider(),
        ],
      ),
    );
  }
}
