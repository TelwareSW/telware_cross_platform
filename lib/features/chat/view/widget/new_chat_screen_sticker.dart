import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';

class NewChatScreenSticker extends StatelessWidget {
  const NewChatScreenSticker({
    super.key,
    required String chosenAnimation,
  }) : _chosenAnimation = chosenAnimation;

  final String _chosenAnimation;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          width: 210,
          margin: const EdgeInsets.symmetric(
              horizontal: 24.0),
          padding: const EdgeInsets.all(22.0),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(4, 86, 57, 0.30),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'No messages here yet...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Palette.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Send a message or tap the greeting below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.primaryText,
                ),
              ),
              const SizedBox(height: 20),
              LottieViewer(
                path: _chosenAnimation,
                width: 100,
                height: 100,
                isLooping: true,
              ),
            ],
          ),
        ),
      );
  }
}
