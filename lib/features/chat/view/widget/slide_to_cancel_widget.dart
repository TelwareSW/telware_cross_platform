import 'package:flutter/material.dart';

class SlideToCancelWidget extends StatefulWidget {
  final double dragPosition;

  const SlideToCancelWidget({super.key, required this.dragPosition});

  @override
  State<SlideToCancelWidget> createState() => _SlideToCancelWidgetState();
}

class _SlideToCancelWidgetState extends State<SlideToCancelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragPosition = 0.0;
  final double _threshold = 100.0; // Drag threshold for complete fade

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.1, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlideToCancelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dragPosition != widget.dragPosition) {
      _dragPosition = widget.dragPosition;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate opacity based on drag position
    double opacity = (_threshold - _dragPosition.abs()) / _threshold;
    opacity = opacity.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: SizedBox(
        height: 55,
        width: 300,
        child: Opacity(
          opacity: opacity, // Apply dynamic opacity
          child: Center(
            child: Transform.translate(
              offset: Offset(_dragPosition, 0),
              child: SlideTransition(
                position: _animation,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      size: 20,
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    Text(
                      "Slide to cancel",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
