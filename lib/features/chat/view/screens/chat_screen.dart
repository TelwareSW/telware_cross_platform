import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telware_cross_platform/core/mock/messages_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/chat/view/widget/bottom_input_bar_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';
import 'package:vibration/vibration.dart';

class ChatScreen extends StatefulWidget {
  static const String route = '/chat';
  final ChatModel chatModel;

  const ChatScreen({super.key, required this.chatModel});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> with WidgetsBindingObserver {
  List<dynamic> chatContent = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  //---------------------------------Recording--------------------------------
  // TODO: This works only on mobile if you tried to run it on web it will throw an error

  late final RecorderController _recorderController;
  final PlayerController _playerController = PlayerController();
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isRecordingLocked = false;
  bool isRecordingPaused = false;
  bool isLoading = true;
  bool isTextEmpty = true;
  double _lockRecordingDragPosition = 0;
  final lockPath = "assets/json/passcode_lock.json";
  String? path;
  late Directory appDirectory;

  //----------------------------------------------------------------------------
  //-------------------------------Media----------------------------------------

  late ChatType type;

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.aac_adts
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..bitRate = 128000
      ..sampleRate = 44100;

    _getDir();
    _controller.text = widget.chatModel.draft ?? "";
    type = widget.chatModel.type;
    WidgetsBinding.instance.addObserver(this);
    loadChatContent();
  }

  loadChatContent() async {
    final messages = await generateFakeMessages();
    chatContent = _generateChatContentWithDateLabels(messages);
    _scrollToBottom();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // Dispose of the ScrollController
    _recorderController.dispose();
    _playerController.dispose();
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  List<dynamic> _generateChatContentWithDateLabels(
      List<MessageModel> messages) {
    List<dynamic> chatContent = [];
    for (int i = 0; i < messages.length; i++) {
      if (i == 0 ||
          !isSameDay(messages[i - 1].timestamp, messages[i].timestamp)) {
        chatContent.add(DateLabelWidget(
            label: DateFormat('MMMM d').format(messages[i].timestamp)));
      }
      chatContent.add(messages[i]);
    }
    return chatContent;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Called when the keyboard visibility changes
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_scrollController.hasClients && _isAtBottom()) {
      // When the keyboard is shown and the user is at the bottom, scroll to the bottom
      _scrollToBottom();
    }
  }

  // Check if the user is already at the bottom of the scroll view
  bool _isAtBottom() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      return true;
    }
    return false;
  }

  // Scroll the chat view to the bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  //--------------------------------Recording--------------------------------
  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    isLoading = false;
    setState(() {});
  }

  void _lockRecordingDrag(double dragPosition) {
    if (isRecordingLocked) {
      _lockRecordingDragPosition = 0;
      return;
    }
    if (dragPosition < 0) {
      _lockRecordingDragPosition = dragPosition;
    }
    setState(() {});
  }

  void _pauseRecording() async {
    if (isRecordingPaused) {
      _recorderController.record(path: path);
    } else {
      _recorderController.pause();
    }
    debugPrint("Recording paused");
    isRecordingPaused = !isRecordingPaused;
    setState(() {});
  }

  void _lockRecording() {
    if (!isRecordingLocked) vibrate();
    isRecordingLocked = true;
    setState(() {});
  }

  void _deleteRecording() {
    if (path == null) {
      debugPrint("No recording to delete");
      return;
    }
    if (File(path!).existsSync()) {
      File(path!).deleteSync();
      path = null;
      isRecording = false;
      isRecordingLocked = false;
      isRecordingPaused = false;
      isRecordingCompleted = false;
      setState(() {});
    }
  }

  void _cancelRecording() {
    //TODO : check for memory leaks
    _recorderController.stop(true);
    isRecording = false;
    isRecordingLocked = false;
    isRecordingPaused = false;
    isRecordingCompleted = false;
    setState(() {});
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      musicFile = result.files.single.path;
      setState(() {});
    } else {
      debugPrint("File not picked");
    }
  }

  void _record() async {
    try {
      await _recorderController.record(path: path); // Path is optional
      debugPrint("Recording started");
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = true;
      });
    }
  }

  void _stopRecording() async {
    try {
      path = await _recorderController.stop(false);
      _recorderController.reset();

      if (path != null) {
        isRecordingCompleted = true;
        isRecording = false;
        isRecordingPaused = false;
        setState(() {});
        await _playerController.preparePlayer(
          path: path!,
          shouldExtractWaveform: true,
          noOfSamples: 500,
          volume: 1.0,
        );
        debugPrint(path);
        debugPrint("Recorded file size: ${File(path!).lengthSync()}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _startRecording(context) async {
    if (isRecording) return;

    setState(() {
      isRecordingCompleted = false;
    });
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      _record();
      vibrate();
    } else if (status.isDenied || status.isRestricted) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        _record();
        vibrate();
      } else {
        // Handle denied permission scenario gracefully
        showSnackBarMessage(
            context, 'Microphone permission is required to record audio.');
      }
    } else if (status.isPermanentlyDenied) {
      // If permanently denied, open app settings
      SnackBarAction action = SnackBarAction(
        label: 'Open Settings',
        onPressed: () => openAppSettings(),
      );
      showSnackBarMessage(context,
          'Microphone permission is permanently denied. Please enable it in settings.',
          action: action);
    }
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        _stopRecording();
      } else {
        _startRecording(context);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void vibrate() {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator ?? false) {
        Vibration.vibrate(duration: 50);
      }
    });
  }

  //----------------------------------------------------------------------------
  //-------------------------------Media----------------------------------------

  @override
  Widget build(BuildContext context) {
    final String title = widget.chatModel.title;
    final membersNumber = widget.chatModel.userIds.length;
    final String subtitle = widget.chatModel.type == ChatType.oneToOne
        ? "last seen a long time ago"
        : "$membersNumber Member${membersNumber > 1 ? "s" : ""}";
    final imageBytes = widget.chatModel.photoBytes;
    final photo = widget.chatModel.photo;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
        title: ChatHeaderWidget(
          title: title,
          subtitle: subtitle,
          photo: photo,
          imageBytes: imageBytes,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Hide the keyboard when tapping outside of text field
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Chat content area (with background SVG)
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/svg/default_pattern.svg',
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Palette.trinary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController, // Use the ScrollController
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        children: chatContent.map((item) {
                          if (item is DateLabelWidget) {
                            return item;
                          } else if (item is MessageModel) {
                            return MessageTileWidget(
                              messageModel: item,
                              isSentByMe: item.senderName == "John Doe",
                              showInfo: type == ChatType.group,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                BottomInputBarWidget(
                  controller: _controller,
                  recorderController: _recorderController,
                  playerController: _playerController,
                  startRecording: _startRecording,
                  stopRecording: _stopRecording,
                  isRecording: isRecording,
                  isRecordingCompleted: isRecordingCompleted,
                  deleteRecording: _deleteRecording,
                  cancelRecording: _cancelRecording,
                  lockRecording: _lockRecording,
                  isRecordingLocked: isRecordingLocked,
                  isRecordingPaused: isRecordingPaused,
                  lockRecordingDrag: _lockRecordingDrag,
                ),
              ],
            ),

            isRecording || isRecordingLocked
                ? AnimatedPositioned(
                    bottom: 90,
                    right: 10,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      child: Transform.translate(
                        offset: Offset(0, _lockRecordingDragPosition),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Palette.quaternary,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: isRecordingLocked
                                ? IconButton(
                                    onPressed: _startOrStopRecording,
                                    padding: const EdgeInsets.all(5),
                                    icon: Icon(
                                      isRecordingCompleted
                                          ? Icons.mic
                                          : Icons.pause,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                : LottieViewer(
                                    path: lockPath,
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
            if (isRecording) ...[
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
              child: GestureDetector(
                onLongPressUp: () {
                  _cancelRecording();
                },
                child: isRecording
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
                              isRecordingLocked ? Icons.send : Icons.mic,
                            ),
                            color: Colors.white,
                            onPressed: () {
                              _cancelRecording();
                            },
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
