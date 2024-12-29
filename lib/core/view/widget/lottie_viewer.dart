import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// TODO: you have to pass onTap function to the widget if you want to use a gesture detector with on tap function.
class LottieViewer extends StatefulWidget {
  final String path;
  final bool isIcon;
  final double width;
  final double height;
  final GlobalKey? lottieKey;

  final int? customDurationInMillis; // Optional custom duration in milliseconds
  final void Function()? onTap;
  final void Function()? onCompleted;
  final bool isLooping;

  const LottieViewer({
    super.key,
    this.lottieKey,
    required this.path,
    required this.width,
    required this.height,
    this.isIcon = false,
    this.customDurationInMillis,
    this.onTap,
    this.isLooping = false,
    this.onCompleted, // Accept custom duration
  });

  @override
  LottieViewerState createState() => LottieViewerState();
}

class LottieViewerState extends State<LottieViewer>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool isForward = true; // Flag to track animation direction

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.stop();
        if (widget.onCompleted != null) widget.onCompleted!();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Method to jump forward/backward by a specific fraction of duration
  void _restartAnimation() {
    const progressStep = 0.15; // Move forward by 5% each time

    if (widget.isIcon) {
      // If the widget is an icon, move forward or backward by a custom step
      if (widget.customDurationInMillis != null) {
        // If custom duration is provided, animate with it
        if (isForward) {
          // Move forward by the specified step
          controller.animateTo(controller.value + progressStep,
              duration: Duration(milliseconds: widget.customDurationInMillis!));
        } else {
          // Move backward by the specified step
          controller.animateTo(controller.value - progressStep,
              duration: Duration(milliseconds: widget.customDurationInMillis!));
        }
      } else {
        // Use the default duration
        controller.toggle();
      }
    } else {
      // For non-icon widgets, continue with normal behavior
      controller.reset();
      controller.forward();
    }

    // Toggle the direction for the next click
    setState(() {
      isForward = !isForward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.lottieKey,
      onTap: () {
        if (!widget.isLooping) _restartAnimation();
        if (widget.onTap != null) widget.onTap!();
      },
      child: Lottie.asset(
        widget.path,
        controller: widget.isLooping ? null : controller,
        onLoaded: widget.isLooping
            ? null
            : (composition) {
                controller.duration = composition.duration;
                if (!widget.isIcon) controller.forward();
              },
        width: widget.width,
        height: widget.height,
        decoder: LottieComposition.decodeGZip,
      ),
    );
  }
}
