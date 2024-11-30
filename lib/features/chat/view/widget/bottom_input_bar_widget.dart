import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class BottomInputBarWidget extends StatelessWidget {
  final TextEditingController controller; // Accept controller as a parameter

  const BottomInputBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Palette.trinary,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.insert_emoticon),
            color: Palette.accentText,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: controller, // Use the passed controller
              decoration: const InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(
                    color: Palette.accentText,
                    fontWeight: FontWeight.w400
                ),
                border: InputBorder.none, // No border
                focusedBorder: InputBorder.none, // No border when focused
                enabledBorder: InputBorder.none, // No border when enabled
              ),
              cursorColor: Palette.accent, // Set the cursor color
              onChanged: (text) {
                // Add setState or any other callback to update UI if needed
              },
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, text, _) {
              return Row(
                children: [
                  if (text.text.isEmpty) ...[
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      color: Palette.accentText,
                      onPressed: () {
                        // Handle file attachment
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic),
                      color: Palette.accentText,
                      onPressed: () {
                        // Handle mic
                      },
                    ),
                  ] else
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Palette.accent,
                      onPressed: () {
                        // Handle send action
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
