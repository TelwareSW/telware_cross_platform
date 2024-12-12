import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telware_cross_platform/core/constants/constant.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/chat/services/audio_recording_service.dart';
import 'package:telware_cross_platform/features/chat/view/widget/audio_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/emoji_picker_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/slide_to_cancel_widget.dart';

class BottomInputBarWidget extends ConsumerStatefulWidget {
  final TextEditingController controller; // Accept controller as a parameter
  final bool isEditing;
  final String? chatID;
  final void Function(
      {required String contentType,
      String? filePath,
      required WidgetRef ref,
      bool? getRecordingPath}) sendMessage;
  final void Function() unreferenceMessages;
  final void Function() editMessage;
  final AudioRecorderService audioRecorderService;

  const BottomInputBarWidget({
    super.key,
    this.chatID,
    required this.sendMessage,
    required this.controller,
    required this.unreferenceMessages,
    required this.editMessage,
    required this.audioRecorderService,
    required this.isEditing,
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
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _emojiShowing = false;

  @override
  void initState() {
    super.initState();
    startTimer();
    isTextEmpty = widget.controller.text.isEmpty;
  }

  @override
  void didUpdateWidget(BottomInputBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioRecorderService.isRecording !=
            widget.audioRecorderService.isRecording ||
        oldWidget.audioRecorderService.isRecordingCompleted !=
            widget.audioRecorderService.isRecordingCompleted ||
        oldWidget.audioRecorderService.isRecordingLocked !=
            widget.audioRecorderService.isRecordingLocked ||
        oldWidget.audioRecorderService.isRecordingPaused !=
            widget.audioRecorderService.isRecordingPaused ||
        oldWidget.audioRecorderService.recordingPath !=
            widget.audioRecorderService.recordingPath) {
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
      if (widget.audioRecorderService.isRecordingPaused) {
        return;
      }
      if (!widget.audioRecorderService.isRecording) {
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

  void sendGifsStickers(String mediaPath, String mediaType) async {
    try {
      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = mediaPath.split('/').last; // Extract the file name
      final newFilePath = '${directory.path}/$fileName';

      // Copy the sticker asset to the new location
      final byteData = await rootBundle.load(mediaPath); // Load the asset
      final file = File(newFilePath);
      await file.writeAsBytes(byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));

      // Call the sendMessage function with the new file path
      widget.sendMessage(
        filePath: newFilePath,
        ref: ref,
        contentType: mediaType,
      );

      debugPrint("$mediaType saved and sent: $newFilePath");
    } catch (e) {
      debugPrint("Error saving or sending sticker: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('this is in the input field widget: ${widget.controller.text}');
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: widget.audioRecorderService.isRecordingCompleted ? 0 : 10,
          vertical: 0),
      color: Palette.trinary,
      child: Column(
        children: [
          Row(
            children: [
              widget.audioRecorderService.isRecording ||
                      widget.audioRecorderService.isRecordingCompleted
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
                              : LottieViewer(
                                  path: "assets/json/sticker_to_keyboard.json",
                                  width: 30,
                                  height: 30,
                                  isIcon: true,
                                  onTap: () {
                                    _emojiShowing = !_emojiShowing;
                                    if (_emojiShowing) {
                                      FocusScope.of(context).unfocus();
                                    } else {
                                      FocusScope.of(context)
                                          .requestFocus(_textFieldFocusNode);
                                    }
                                    setState(() {});
                                  },
                                  onCompleted: () {
                                    // isCanceled = false;
                                    // setState(() {});
                                  },
                                ),
                          Expanded(
                            child: TextField(
                              focusNode: _textFieldFocusNode,
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
                              onTap: () {
                                setState(() {
                                  _emojiShowing = false;
                                });
                              },
                              onChanged: (text) {
                                if (isTextEmpty ^ text.isEmpty) {
                                  setState(() {
                                    isTextEmpty = text.isEmpty;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
              if (widget.controller.text.isEmpty && isTextEmpty) ...[
                if (widget.audioRecorderService.isRecording ||
                    widget.audioRecorderService.isRecordingLocked) ...[
                  if (!widget.audioRecorderService.isRecordingCompleted) ...[
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
                  if (widget.audioRecorderService.isRecordingLocked) ...[
                    if (widget.audioRecorderService.isRecordingCompleted) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: LottieViewer(
                          path: "assets/json/group_pip_delete_icon.json",
                          width: 40,
                          height: 40,
                          isLooping: true,
                          onTap: () {
                            widget.audioRecorderService.deleteRecording();
                          },
                        ),
                      ),
                      AudioMessageWidget(
                        filePath: widget.audioRecorderService.recordingPath!,
                        onDownloadTap: (String? _) {},
                        isMessage: false,
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: () {
                          widget.audioRecorderService.cancelRecording();
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
                if (!widget.audioRecorderService.isRecordingCompleted) ...[
                  GestureDetector(
                    onLongPress: () =>
                        widget.audioRecorderService.startRecording(context),
                    onLongPressUp: () async {
                      if (widget.audioRecorderService.isRecordingLocked ||
                          isCanceled) {
                        return;
                      }
                      String? recordingPath =
                          await widget.audioRecorderService.stopRecording();
                      widget.sendMessage(
                        ref: ref,
                        contentType: 'audio',
                        filePath: recordingPath,
                      );
                      widget.audioRecorderService.resetRecording();
                    },
                    onLongPressMoveUpdate: (details) {
                      if (details.localPosition.dx.abs() > _cancelThreshold) {
                        isCanceled = true;
                        widget.audioRecorderService.cancelRecording();
                        setState(() {});
                        return;
                      }
                      widget.audioRecorderService
                          .lockRecordingDragPositionUpdate(
                              details.localPosition.dy);
                      if (details.localPosition.dy.abs() > _lockThreshold) {
                        widget.audioRecorderService.lockRecording();
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
              if (widget.audioRecorderService.isRecordingCompleted ||
                  (widget.controller.text.isNotEmpty || !isTextEmpty)) ...[
                IconButton(
                  padding: const EdgeInsets.only(left: 10),
                  iconSize: 28,
                  icon: widget.isEditing ? const Icon(Icons.check_circle) : const Icon(Icons.send),
                  color: Palette.accent,
                  onPressed: () {
                    if (widget.audioRecorderService.isRecordingCompleted) {
                      String? filePath =
                          widget.audioRecorderService.resetRecording();
                      widget.sendMessage(
                          ref: ref, contentType: 'audio', filePath: filePath);
                    } else {
                      widget.isEditing ? widget.editMessage() : widget.sendMessage(ref: ref, contentType: 'text');
                    }
                    widget.unreferenceMessages();
                  },
                ),
              ],
            ],
          ),
          EmojiPickerWidget(
            textEditingController: widget.controller,
            emojiShowing: _emojiShowing,
            onSelectedMedia: sendGifsStickers,
          )
        ],
      ),
    );
  }
}
