import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';

import 'package:telware_cross_platform/features/chat/view/widget/audio_player_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/slide_to_cancel_widget.dart';

class BottomInputBarWidget extends ConsumerStatefulWidget {
  final TextEditingController controller; // Accept controller as a parameter
  final RecorderController recorderController;
  final PlayerController playerController;
  final String? chatID;
  final void Function(BuildContext) startRecording;
  final void Function() stopRecording;
  final void Function() deleteRecording;
  final void Function() cancelRecording;
  final void Function() lockRecording;
  final void Function() removeReply;
  final void Function(WidgetRef) sendMessage;
  final void Function(double) lockRecordingDrag;
  final bool isRecordingLocked;
  final bool isRecording;
  final bool isRecordingCompleted;
  final bool isRecordingPaused;

  const BottomInputBarWidget({
    super.key,
    this.chatID,
    required this.sendMessage,
    required this.controller,
    required this.recorderController,
    required this.playerController,
    required this.startRecording,
    required this.stopRecording,
    required this.isRecording,
    required this.isRecordingCompleted,
    required this.deleteRecording,
    required this.cancelRecording,
    required this.lockRecording,
    required this.removeReply,
    required this.isRecordingLocked,
    required this.lockRecordingDrag,
    required this.isRecordingPaused,
  });

  @override
  ConsumerState<BottomInputBarWidget> createState() =>
      BottomInputBarWidgetState();
}

class BottomInputBarWidgetState extends ConsumerState<BottomInputBarWidget> {
  bool isTextEmpty = true;

  int elapsedTime = 0; // Track the elapsed time in seconds
  double _dragPosition = 0;
  final double _cancelThreshold = 100.0; // Drag threshold for complete fade
  final double _lockThreshold = 100.0; // Drag threshold for lock recording
  bool isCanceled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    isTextEmpty = widget.controller.text.isEmpty;
  }

  @override
  void didUpdateWidget(BottomInputBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording ||
        oldWidget.isRecordingCompleted != widget.isRecordingCompleted ||
        oldWidget.isRecordingLocked != widget.isRecordingLocked ||
        oldWidget.isRecordingPaused != widget.isRecordingPaused) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.isRecordingPaused) {
        return;
      }
      if (!widget.isRecording) {
        elapsedTime = 0;
        return;
      }
      setState(() {
        elapsedTime++;
      });
    });
  }

  List<XFile> mediaFiles = [];

  Future<void> _loadMediaFiles() async {
    mediaFiles.clear(); // Clear previous files
    const int maxFiles = 10;
    const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    final List<XFile> media = await ImagePicker().pickMultipleMedia();
    for (var mediaFile in media) {
      final file = File(mediaFile.path);
      if (await file.length() <= maxSizeInBytes &&
          mediaFiles.length < maxFiles) {
        mediaFiles.add(mediaFile);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: widget.isRecordingCompleted ? 0 : 10, vertical: 0),
      color: Palette.trinary,
      child: Row(
        children: [
          widget.isRecording || widget.isRecordingCompleted
              ? const SizedBox.shrink()
              : Expanded(
                  child: Row(
                    children: [
                      isCanceled
                          ? LottieViewer(
                              path:
                                  "assets/json/chat_audio_record_delete_3.json",
                              width: 20,
                              height: 20,
                              onCompleted: () {
                                isCanceled = false;
                                setState(() {});
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.insert_emoticon),
                              color: Palette.accentText,
                              onPressed: () {},
                            ),
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Palette.accentText,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                          cursorColor: Palette.accent,
                          onChanged: (text) {
                            setState(() {
                              isTextEmpty = text.isEmpty;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          if (widget.controller.text.isEmpty && isTextEmpty) ...[
            if (widget.isRecording || widget.isRecordingLocked) ...[
              if (!widget.isRecordingCompleted) ...[
                const LottieViewer(
                  path: "assets/json/recording_led.json",
                  width: 20,
                  height: 20,
                  isLooping: true,
                ),
                Text(
                  formatTime(elapsedTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer()
              ],
              if (widget.isRecordingLocked) ...[
                if (widget.isRecordingCompleted) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: LottieViewer(
                      path: "assets/json/group_pip_delete_icon.json",
                      width: 40,
                      height: 40,
                      isLooping: true,
                      onTap: () {
                        widget.deleteRecording();
                      },
                    ),
                  ),
                  AudioPlayerWidget(
                    playerController: widget.playerController,
                    duration: elapsedTime,
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: () {
                      widget.cancelRecording();
                      setState(() {});
                    },
                    child: const SizedBox(
                      width: 100,
                      height: 50,
                      child: Padding(
                        padding: EdgeInsets.only(right: 30.0),
                        child: Center(
                          child: Text(
                            "CANCEL",
                            style: TextStyle(
                                color: Palette.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ] else
                SlideToCancelWidget(dragPosition: _dragPosition),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.attach_file_rounded),
                color: Palette.accentText,
                onPressed: () => {
                  _loadMediaFiles(),
                },
              ),
            ],
            if (!widget.isRecordingCompleted) ...[
              GestureDetector(
                onLongPress: () => widget.startRecording(context),
                onLongPressUp: () {
                  if (widget.isRecordingLocked) {
                    return;
                  }
                  widget.cancelRecording();
                },
                onLongPressMoveUpdate: (details) {
                  if (details.localPosition.dx.abs() > _cancelThreshold) {
                    isCanceled = true;
                    widget.cancelRecording();
                    setState(() {});
                    return;
                  }
                  widget.lockRecordingDrag(details.localPosition.dy);
                  if (details.localPosition.dy.abs() > _lockThreshold) {
                    widget.lockRecording();
                    return;
                  }
                  setState(() {
                    _dragPosition = details.localPosition.dx;
                  });
                },
                child: const LottieViewer(
                  path: "assets/json/voice_to_video.json",
                  width: 29,
                  height: 29,
                  isIcon: true,
                ),
              ),
            ],
          ],
          if (widget.isRecordingCompleted ||
              (widget.controller.text.isNotEmpty || !isTextEmpty)) ...[
            IconButton(
              padding: const EdgeInsets.only(left: 10),
              iconSize: 28,
              icon: const Icon(Icons.send),
              color: Palette.accent,
              onPressed: () {
                widget.sendMessage(ref);
                widget.removeReply();
                if (widget.isRecordingCompleted) {
                  //TODO: Send the recorded audio
                  widget.deleteRecording();
                }
              },
            ),
          ],
        ],
      ),
    );
  }

}
