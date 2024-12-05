import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/chat/services/audio_recording_service.dart';

class MagicRecordingButton extends StatelessWidget {
  final AudioRecorderService audioRecorderService;
  final void Function({
    required String contentType,
    String? filePath,
  }) sendMessage;

  const MagicRecordingButton({
    super.key,
    required this.audioRecorderService,
    required this.sendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      audioRecorderService.isRecording || audioRecorderService.isRecordingLocked
          ? AnimatedPositioned(
              bottom: 90,
              right: 10,
              width: 30,
              height: 30,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () => audioRecorderService.startOrStopRecording(context),
                child: Transform.translate(
                  offset:
                      Offset(0, audioRecorderService.lockRecordingDragPosition),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Palette.quaternary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: audioRecorderService.isRecordingLocked
                          ? IconButton(
                              onPressed: () => audioRecorderService
                                  .startOrStopRecording(context),
                              padding: const EdgeInsets.all(5),
                              icon: Icon(
                                audioRecorderService.isRecordingCompleted
                                    ? Icons.mic
                                    : Icons.pause,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          : LottieViewer(
                              path: audioRecorderService.lockPath,
                              width: 20,
                              height: 20,
                              isLooping: true,
                            ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
      if (audioRecorderService.isRecording) ...[
        const Positioned(
          bottom: -50,
          right: -50,
          child: LottieViewer(
            path: "assets/json/wave_animation_2.json",
            width: 150,
            height: 150,
            isLooping: true,
          ),
        ),
        const Positioned(
          bottom: -50,
          right: -50,
          child: LottieViewer(
            path: "assets/json/wave_animation_1.json",
            width: 150,
            height: 150,
            isLooping: true,
          ),
        )
      ],
      AnimatedPositioned(
        bottom: -20,
        right: -20,
        duration: const Duration(milliseconds: 300),
        child: audioRecorderService.isRecording
            ? Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Palette.accent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      size: 28,
                      audioRecorderService.isRecordingLocked
                          ? Icons.send
                          : Icons.mic,
                    ),
                    color: Colors.white,
                    onPressed: () async {
                      if (audioRecorderService.isRecording) {
                        String? filePath = await audioRecorderService
                            .stopRecording(waitForSending: true);
                        sendMessage(contentType: 'audio', filePath: filePath);
                        audioRecorderService.cancelRecording();
                      }
                    },
                  ),
                ),
              )
            : const SizedBox.shrink(),
      )
    ]);
  }
}
