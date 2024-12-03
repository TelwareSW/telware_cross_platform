import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telware_cross_platform/core/constants/constant.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
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
  final String? chatID;
  final void Function(BuildContext) startRecording;
  final Future<String?> Function() stopRecording;
  final void Function() deleteRecording;
  final String? Function() resetRecording;
  final void Function() cancelRecording;
  final void Function() lockRecording;
  final void Function(
      {required String contentType,
      String? filePath,
      required WidgetRef ref,
      bool? getRecordingPath}) sendMessage;
  final void Function() removeReply;
  final void Function(double) lockRecordingDrag;
  final String? audioFilePath;
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
    required this.startRecording,
    required this.stopRecording,
    required this.cancelRecording,
    required this.isRecording,
    required this.isRecordingCompleted,
    required this.deleteRecording,
    required this.resetRecording,
    required this.lockRecording,
    required this.removeReply,
    required this.isRecordingLocked,
    required this.lockRecordingDrag,
    required this.isRecordingPaused,
    this.audioFilePath,
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
        oldWidget.isRecordingPaused != widget.isRecordingPaused ||
        oldWidget.audioFilePath != widget.audioFilePath) {
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

  List<String> mediaFiles = [];

  Future<void> _loadMediaFiles() async {
    mediaFiles.clear(); // Clear previous files
    const int maxFiles = MAX_SELECTED_FILES; // Maximum file count
    const int maxSizeInBytes = MAX_FILE_SIZE;

    final List<XFile> media =
        await ImagePicker().pickMultipleMedia(limit: maxFiles);
    if (media.length >= maxFiles) {
      showToastMessage('You can only select up to $maxFiles files');
      return;
    }
    final Directory appDir =
        await getApplicationDocumentsDirectory(); // Local storage directory

    for (var mediaFile in media) {
      final File file = File(mediaFile.path);
      if (await file.length() > maxSizeInBytes) {
        showToastMessage(
            'File size exceeds the limit of ${maxSizeInBytes / 1024 / 1024} MB');
        continue;
      }
      if (await file.length() <= maxSizeInBytes &&
          mediaFiles.length < maxFiles) {
        // Get the filename and create a new file path in local storage
        final String fileName = mediaFile.name; // Extract file name
        final String localPath = '${appDir.path}/$fileName'; // Destination path
        String? mimeType = lookupMimeType(file.path);
        debugPrint('Local path: $localPath');
        debugPrint('MIME type: $mimeType');
        // Save the file locally
        await file.copy(localPath);
        // Determine the content type based on the MIME type
        String contentType = 'unknown';
        if (mimeType != null) {
          if (mimeType.startsWith('image/')) {
            contentType = 'image';
          } else if (mimeType.startsWith('video/')) {
            contentType = 'video';
          } else if (mimeType.startsWith('audio/')) {
            contentType = 'audio';
          } else if (mimeType.startsWith('application/')) {
            contentType = 'file';
          }
        }

        widget.sendMessage(
            ref: ref, contentType: contentType, filePath: localPath);

        // Add to the mediaFiles list with the updated local path
        mediaFiles.add(localPath);
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
                    filePath: widget.audioFilePath!,
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
                onLongPressUp: () async {
                  if (widget.isRecordingLocked) {
                    return;
                  }
                  String? recordingPath = await widget.stopRecording();
                  widget.sendMessage(
                    ref: ref,
                    contentType: 'audio',
                    filePath: recordingPath,
                  );
                  widget.resetRecording();
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
                if (widget.isRecordingCompleted) {
                  String? filePath = widget.resetRecording();
                  widget.sendMessage(
                      ref: ref, contentType: 'audio', filePath: filePath);
                } else {
                  widget.sendMessage(ref: ref, contentType: 'text');
                }
                widget.removeReply();
              },
            ),
          ],
        ],
      ),
    );
  }
}
