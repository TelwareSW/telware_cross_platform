import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  final int duration;
  final double borderRadius;

  const AudioPlayerWidget(
      {super.key,
      required this.filePath,
      this.borderRadius = 30,
      required this.duration});

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  bool isPlaying = false;
  late AnimationController controller;
  final progressStep = 0.15;
  late PlayerController playerController;
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
        setState(() {
          isPlaying = false;
          controller.animateTo(controller.value - progressStep,
              duration: const Duration(milliseconds: 300));
        });
      }
    });
    loadAudioFile();
  }

  @override
  void dispose() {
    controller.dispose();
    playerController.dispose();
    super.dispose();
  }

  Future<void> loadAudioFile() async {
    await playerController.preparePlayer(
      path: widget.filePath,
      shouldExtractWaveform: false,
      noOfSamples: 500,
      volume: 1.0,
    );
    setState(() {});
  }

  void loadDummyWaveform() {
    waveformData = generateDummyWaveform(500); // Example for 500 samples
    setState(() {});
  }

  void _startOrStopPlaying() async {
    try {
      if (isPlaying) {
        await playerController.pausePlayer();
        controller.animateTo(controller.value - progressStep,
            duration: const Duration(milliseconds: 300));
        isPlaying = false;
      } else {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60, // Set the width
          height: 40, // Set the height
          decoration: BoxDecoration(
            color: Palette.accent, // Set the background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                  widget.borderRadius), // Set the top-left radius
              bottomLeft: Radius.circular(
                  widget.borderRadius), // Set the bottom-left radius
            ), // Set border radius
          ),
          child: Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                _startOrStopPlaying();
              },
              child: Lottie.asset(
                "assets/json/play_pause.json",
                controller: controller,
                onLoaded: (composition) {
                  controller.duration = composition.duration;
                },
                width: 20,
                height: 20,
                decoder: LottieComposition.decodeGZip,
              ),
            ),
          ),
        ),
        AudioFileWaveforms(
          size: const Size(200.0, 40.0),
          playerController: playerController,
          enableSeekGesture: true,
          continuousWaveform: false,
          waveformType: WaveformType.fitWidth,
          backgroundColor: Palette.accent,
          playerWaveStyle: const PlayerWaveStyle(
            fixedWaveColor: Colors.white38,
            liveWaveColor: Colors.white,
            showSeekLine: false,
            spacing: 4,
            waveThickness: 2,
            scaleFactor: 10,
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: Palette.accent,
          ),
          waveformData: waveformData,
        ),
        Container(
          width: 60, // Set the width
          height: 40, // Set the height
          decoration: BoxDecoration(
            color: Palette.accent, // Set the background color
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(
                  widget.borderRadius), // Set the top-left radius
              bottomRight: Radius.circular(
                  widget.borderRadius), // Set the bottom-left radius
            ), // Set border radius
          ),
          child: Center(
            child: Text(
              formatTime(widget.duration),
              style: const TextStyle(
                color: Palette.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}