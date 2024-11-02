import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedSnackBarWidget extends StatefulWidget {
  final Icon icon;
  final String text;
  final Duration duration;

  const AnimatedSnackBarWidget({
    super.key,
    required this.icon,
    required this.text,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedSnackBarWidget> createState() => _AnimatedSnackBarWidget();
}

class _AnimatedSnackBarWidget extends State<AnimatedSnackBarWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ScaleTransition(
          scale: _animation,
          child: widget.icon,
        ),
        const SizedBox(width: 10),
        Text(widget.text),
      ],
    );
  }
}