import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';

class AudioMessageWidget extends StatefulWidget {
  final String filePath;
  final int? duration;
  final double borderRadius;

  const AudioMessageWidget(
      {super.key,
      this.borderRadius = 30,
      this.duration,
      required this.filePath});

  @override
  AudioMessageWidgetState createState() => AudioMessageWidgetState();
}

class AudioMessageWidgetState extends State<AudioMessageWidget>
    with TickerProviderStateMixin {
  late PlayerController playerController;
  bool isPlaying = false;
  late AnimationController controller;
  final progressStep = 0.15;
  int durationCounter = -1;
  int currentDuration = 0;
  Timer? _timer;
  List<double> waveformData = [];

  @override
  void initState() {
    super.initState();
    playerController = PlayerController();
    loadDummyWaveform();
    controller = AnimationController(vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.stop();
      }
    });
    playerController.onCompletion.listen((_) async {
      await playerController.seekTo(0);
      if (mounted) {
        durationCounter = -1;
        setState(() {
          isPlaying = false;
          controller.animateTo(controller.value - progressStep,
              duration: const Duration(milliseconds: 300));
        });
      }
    });
    loadAudioFile();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPlaying) {
        if (durationCounter < currentDuration) {
          durationCounter++;
          setState(() {});
        } else {
          timer.cancel();
        }
      }
    });
  }

  Future<void> loadAudioFile() async {
    await playerController.preparePlayer(
      path: widget.filePath,
      shouldExtractWaveform: false,
      noOfSamples: 500,
      volume: 1.0,
    );
    currentDuration = widget.duration ??
        await playerController.getDuration(DurationType.max) ~/ 1000;

    if (currentDuration < 0) {
      currentDuration = 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    playerController.dispose();
    super.dispose();
    _timer?.cancel();
  }

  void _startOrStopPlaying() async {
    try {
      if (isPlaying) {
        await playerController.pausePlayer();
        controller.animateTo(controller.value - progressStep,
            duration: const Duration(milliseconds: 300));
        isPlaying = false;
      } else {
        if (durationCounter == -1) {
          durationCounter = 0;
          startTimer();
        }
        await playerController.startPlayer(finishMode: FinishMode.pause);
        controller.animateTo(controller.value + progressStep,
            duration: const Duration(milliseconds: 300));
        isPlaying = true;
      }
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loadDummyWaveform() {
    waveformData = generateDummyWaveform(500); // Example for 500 samples
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white, // Set the background color
            borderRadius:
                BorderRadius.circular(widget.borderRadius), // Set border radius
          ),
          child: Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                _startOrStopPlaying();
              },
              child: Lottie.asset(
                "assets/json/play_pause_message.json",
                controller: controller,
                onLoaded: (composition) {
                  controller.duration = composition.duration;
                },
                width: 30,
                height: 30,
                decoder: LottieComposition.decodeGZip,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AudioFileWaveforms(
              size: const Size(200.0, 40.0),
              playerController: playerController,
              enableSeekGesture: true,
              continuousWaveform: false,
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: const PlayerWaveStyle(
                fixedWaveColor: Colors.white38,
                liveWaveColor: Colors.white,
                showSeekLine: false,
                scaleFactor: 50,
                spacing: 5,
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: Colors.transparent,
              ),
              waveformData: waveformData,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // Set the background color
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(
                      widget.borderRadius), // Set the top-left radius
                  bottomRight: Radius.circular(
                      widget.borderRadius), // Set the bottom-left radius
                ), // Set border radius
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formatTime(durationCounter != -1
                          ? durationCounter
                          : currentDuration),
                      style: const TextStyle(
                        color: Palette.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                        padding: const EdgeInsets.only(top: 2),
                        child: const Icon(
                          Icons.circle,
                          color: Palette.primaryText,
                          size: 9,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
