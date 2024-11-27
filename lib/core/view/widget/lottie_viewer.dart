import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieViewer extends StatefulWidget {
  final String path;
  final double width;
  final double height;
  final bool isLooping;

  const LottieViewer({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    this.isLooping = false,
  });

  @override
  LottieViewerState createState() => LottieViewerState();
}

class LottieViewerState extends State<LottieViewer>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !widget.isLooping) {
        controller.stop();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _restartAnimation() {
    controller.reset();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _restartAnimation,
      child: Lottie.asset(
        widget.path,
        controller: controller,
        onLoaded: (composition) {
          controller.duration = composition.duration;
          if (widget.isLooping) {
            controller.repeat();
          } else {
            controller.forward();
          }
        },
        width: widget.width,
        height: widget.height,
        decoder: LottieComposition.decodeGZip,
      ),
    );
  }
}
