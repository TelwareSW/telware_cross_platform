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
import 'package:telware_cross_platform/features/chat/view/widget/download_widget.dart';

import '../../utils/chat_utils.dart';

class AudioMessageWidget extends StatefulWidget {
  final String? filePath;
  final String? url;
  final int? duration;
  final bool isMessage;
  final double borderRadius;
  final void Function(String?) onDownloadTap;

  const AudioMessageWidget({
    super.key,
    this.borderRadius = 30,
    this.duration,
    this.filePath,
    required this.onDownloadTap,
    this.url,
    this.isMessage = true,
  });

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
    if (widget.filePath == null) {
      return;
    }
    await playerController.preparePlayer(
      path: widget.filePath!,
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

  BorderRadiusGeometry getBorderRadius(
      {topLeft, bottomLeft, topRight, bottomRight}) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ? widget.borderRadius : 0),
      bottomLeft: Radius.circular(bottomLeft ? widget.borderRadius : 0),
      topRight: Radius.circular(topRight ? widget.borderRadius : 0),
      bottomRight: Radius.circular(bottomRight ? widget.borderRadius : 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget audioWaveform = AudioFileWaveforms(
      size: const Size(200.0, 40.0),
      playerController: playerController,
      enableSeekGesture: true,
      continuousWaveform: false,
      waveformType: WaveformType.fitWidth,
      playerWaveStyle: PlayerWaveStyle(
        fixedWaveColor: Colors.white38,
        liveWaveColor: Colors.white,
        showSeekLine: false,
        spacing: 4,
        waveThickness: 2,
        scaleFactor: widget.isMessage ? 50 : 10,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color: widget.isMessage ? Colors.transparent : Palette.accent,
      ),
      waveformData: waveformData,
    );

    Widget audioDuration = Container(
      width: widget.isMessage ? null : 60, // Set the width
      height: widget.isMessage ? null : 40, // Set the height
      decoration: BoxDecoration(
        color: widget.isMessage ? Colors.transparent : Palette.accent,
        borderRadius: getBorderRadius(
          topRight: true,
          topLeft: widget.isMessage,
          bottomLeft: widget.isMessage,
          bottomRight: true,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formatTime(durationCounter != -1 && widget.isMessage
                  ? durationCounter
                  : currentDuration),
              style: TextStyle(
                color: Palette.primaryText,
                fontSize: widget.isMessage ? 15 : 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (widget.isMessage) ...[
              const SizedBox(width: 2),
              Container(
                padding: const EdgeInsets.only(top: 2),
                child: const Icon(
                  Icons.circle,
                  color: Palette.primaryText,
                  size: 9,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Row(
      children: [
        Container(
          width: 60,
          height: widget.isMessage ? 60 : 40,
          margin: EdgeInsets.only(right: widget.isMessage ? 10 : 0),
          decoration: BoxDecoration(
            color: widget.isMessage ? Colors.white : Palette.accent,
            // Set the background color
            borderRadius: getBorderRadius(
              topLeft: true,
              bottomLeft: true,
              topRight: widget.isMessage,
              bottomRight: widget.isMessage,
            ), // Set border radius
          ),
          child: widget.filePath == null || !doesFileExistSync(widget.filePath!)
              ? DownloadWidget(onTap: widget.onDownloadTap, url: widget.url)
              : Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      _startOrStopPlaying();
                    },
                    child: Lottie.asset(
                      "assets/json/play_pause${widget.isMessage ? '_message' : ''}.json",
                      controller: controller,
                      onLoaded: (composition) {
                        controller.duration = composition.duration;
                      },
                      width: widget.isMessage ? 30 : 20,
                      height: widget.isMessage ? 30 : 20,
                      decoder: LottieComposition.decodeGZip,
                    ),
                  ),
                ),
        ),
        if (!widget.isMessage) ...[
          audioWaveform,
          audioDuration,
        ] else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              audioWaveform,
              audioDuration,
            ],
          ),
      ],
    );
  }
}
