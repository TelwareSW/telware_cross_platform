import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/features/chat/view/widget/download_widget.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/palette.dart';
import '../../utils/chat_utils.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? filePath;
  final String? fileName;
  final String? url;
  final void Function(String?) onDownloadTap;

  const VideoPlayerWidget({
    super.key,
    this.filePath,
    this.fileName,
    this.url,
    required this.onDownloadTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  int durationCounter = 0; // Tracks current position
  bool showTotalDuration = true; // Controls which duration to display
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.filePath ?? ''))
      ..initialize().then((_) {
        setState(() {
          // Initialize durationCounter with total duration
          durationCounter = _controller.value.duration.inSeconds;
        });
      });

    _controller.addListener(() {
      // Check if video has completed playing
      if (_controller.value.position >= _controller.value.duration) {
        _timer?.cancel();
        setState(() {
          showTotalDuration = true; // Show total duration after completion
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          durationCounter = _controller.value.position.inSeconds;
          showTotalDuration = false; // Show current time during playback
        });
      } else {
        timer.cancel();
      }
    });
  }

  String formatDuration(int seconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final duration = Duration(seconds: seconds);
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secondsPart = twoDigits(duration.inSeconds.remainder(60));

    return hours != "00"
        ? "$hours:$minutes:$secondsPart"
        : "$minutes:$secondsPart";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: _controller.value.isInitialized
          ? GestureDetector(
              key: GlobalKeyCategoryManager.addKey('toggleVideoMessageButton'),
              onTap: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                    _timer?.cancel(); // Stop timer when paused
                  } else {
                    _controller.play();
                    startTimer(); // Start timer when playing
                  }
                });
              },
              child: widget.filePath == null ||
                      !doesFileExistSync(widget.filePath!)
                  ? SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: DownloadWidget(
                          onTap: widget.onDownloadTap,
                          url: widget.url,
                          fileName: widget.fileName,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        SizedBox.expand(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              // Display total duration initially and after playback, current position during playback
                              formatDuration(showTotalDuration
                                  ? _controller.value.duration.inSeconds
                                  : durationCounter),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Palette.accent,
              ),
            ),
    );
  }
}
