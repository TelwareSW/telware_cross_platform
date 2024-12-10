import 'package:flutter/material.dart';
import 'dart:async';

import 'package:telware_cross_platform/core/theme/palette.dart';

class TimerDisplay extends StatefulWidget {
  final DateTime startDateTime;

  const TimerDisplay({super.key, required this.startDateTime});

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Timer _timer;
  late Duration _elapsedTime;

  @override
  void initState() {
    super.initState();
    _elapsedTime = DateTime.now().difference(widget.startDateTime);
    _startTimer();
  }

  // Start the timer to update every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(widget.startDateTime);
      });
    });
  }

  // Format elapsed time as mm:ss
  String _formatTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _formatTime(_elapsedTime),
        style: const TextStyle(
          fontSize: 18,
          color: Palette.primaryText,
        ),
      ),
    );
  }
}