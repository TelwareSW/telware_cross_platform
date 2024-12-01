import 'dart:math';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/providers/chat_provider.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/popup_menu_item_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/bottom_input_bar_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:vibration/vibration.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';

import '../widget/reply_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static const String route = '/chat';
  final String chatId;
  final ChatModel? chatModel;

  const ChatScreen({super.key, this.chatId = "", this.chatModel});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  List<dynamic> chatContent = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _chosenAnimation;
  MessageModel? replyMessage;

  late ChatModel? chatModel;
  bool isSearching = false;
  bool isShowAsList = false;
  int _numberOfMatches = 0;

  // ignore: prefer_final_fields
  int _currentMatch = 1;

  // ignore: unused_field
  int _currentMatchIndex = 0;
  Map<int, List<MapEntry<int, int>>> _messageMatches = {};
  List<int> _messageIndices = [];

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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatModel = widget.chatModel ?? ref.watch(chatProvider(widget.chatId));
      _messageController.text = chatModel!.draft ?? "";
      final messages = chatModel?.messages ?? [];
      _updateChatMessages(messages);
      _scrollToBottom();
    });
    _chosenAnimation = getRandomLottieAnimation();
    _getDir();
    _scrollToBottom();
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.aac_adts
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..bitRate = 128000
      ..sampleRate = 44100;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose of the ScrollController
    _recorderController.dispose();
    _playerController.dispose();
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  void _updateChatMessages(List<MessageModel> messages) async {
    _generateChatContentWithDateLabels(messages).then((content) {
      setState(() {
        chatContent = content;
      });
    });
  }

  Future<List<dynamic>> _generateChatContentWithDateLabels(
      List<MessageModel> messages) async {
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

  void _scrollToTimeStamp(DateTime date) {
    final DateTime timestamp = DateTime(date.year, date.month, date.day);
    final int index = chatContent.indexWhere((element) {
      if (element is MessageModel) {
        return element.timestamp.isAfter(timestamp);
      }
      return false;
    });
    if (index != -1) {
      _scrollController.jumpTo(index * 20.0);
    }
  }

  // Scroll the chat view to the bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  //TODO: Implement the sendMsg method with another types of messages
  void _sendMessage(WidgetRef ref) {
    ref.read(chattingControllerProvider).sendMsg(
          content: TextContent(_messageController.text),
          msgType: MessageType.normal,
          contentType: MessageContentType.text,
          chatType: ChatType.private,
          chatID: widget.chatId,
        );
    _messageController.clear();
    List<MessageModel> messages =
        ref.watch(chatProvider(widget.chatId))?.messages ?? [];
    _updateChatMessages(messages);
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
      if (!isRecording) {
        setState(() {
          isRecording = true;
        });
      }
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

    if (isRecordingCompleted) {
      setState(() {
        isRecordingCompleted = false;
      });
    }
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

  void _searchForText(searchText) async {
    Map<int, List<MapEntry<int, int>>> messageMatches = {};
    int numberOfMatches = 0;
    int currentMatchIndex = 0;
    List<int> messageIndices = [];
    for (int i = 0; i < chatContent.length; i++) {
      var msg = chatContent[i];
      if (msg is! MessageModel ||
          msg.messageContentType != MessageContentType.text) {
        continue;
      }
      String messageText = msg.content?.toJson()['text'] ?? "";
      List<MapEntry<int, int>> matches = kmp(messageText, searchText);
      if (matches.isNotEmpty && matches[0].value != 0) {
        numberOfMatches += 1;
        messageMatches[i] = matches;
        currentMatchIndex = i;
        messageIndices.add(i);
      }
    }

    setState(() {
      _messageIndices = messageIndices;
      _currentMatchIndex = currentMatchIndex;
      _numberOfMatches = numberOfMatches;
      _messageMatches = messageMatches;
    });
  }

  void _enableSearching() {
    // Implement search functionality here
    setState(() {
      isSearching = true;
    });
  }

  void _toggleSearchDisplay() {
    setState(() {
      isShowAsList = !isShowAsList;
    });
  }

  void _scrollToPrevMatch() {
    if (_currentMatch == _numberOfMatches) {
      return;
    }
    _scrollController.jumpTo((_currentMatchIndex - 1) * 20.0);

    setState(() {
      _currentMatchIndex = _currentMatchIndex - 1;
      _currentMatch = _currentMatch + 1;
    });
  }

  void _scrollToNextMatch() {
    if (_currentMatch == 0) {
      return;
    }
    _scrollController.jumpTo((_currentMatchIndex + 1) * 20.0);

    setState(() {
      _currentMatchIndex = _currentMatchIndex + 1;
      _currentMatch = _currentMatch - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatModel =
        widget.chatModel ?? ref.watch(chatProvider(widget.chatId))!;
    final type = chatModel.type;
    final String title = chatModel.title;
    final membersNumber = chatModel.userIds.length;
    final String subtitle = chatModel.type == ChatType.private
        ? "last seen a long time ago"
        : "$membersNumber Member${membersNumber > 1 ? "s" : ""}";
    final imageBytes = chatModel.photoBytes;
    final photo = chatModel.photo;
    final chatID = chatModel.id;
    const menuItemsHeight = 45.0;
    var messagesIndex = 0;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (isShowAsList) {
                setState(() {
                  isShowAsList = false;
                });
              } else if (isSearching) {
                setState(() {
                  isSearching = false;
                  _messageMatches.clear();
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: !isSearching
              ? ChatHeaderWidget(
                  title: title,
                  subtitle: subtitle,
                  photo: photo,
                  imageBytes: imageBytes,
                )
              : TextField(
                  key: ChatKeys.chatSearchInput,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                        color: Palette.accentText, fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onSubmitted: _searchForText,
                  onChanged: (value) => {
                    if (isShowAsList)
                      {
                        setState(() {
                          isShowAsList = false;
                        })
                      }
                  },
                ),
          actions: [
            if (!isSearching)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) {
                  if (value == 'search') {
                    _enableSearching();
                  } else {
                    showToastMessage("No Bueno");
                  }
                },
                color: Palette.secondary,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'mute-options',
                      padding: EdgeInsets.zero,
                      height: menuItemsHeight,
                      child: PopupMenuItemWidget(
                          icon: Icons.volume_up_rounded,
                          text: 'Mute',
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Palette.inactiveSwitch,
                            size: 16,
                          )),
                    ),
                    const PopupMenuDivider(
                      height: 10,
                    ),
                    const PopupMenuItem<String>(
                      value: 'video-call',
                      padding: EdgeInsets.zero,
                      height: menuItemsHeight,
                      child: PopupMenuItemWidget(
                        icon: Icons.videocam_outlined,
                        text: 'Video Call',
                      ),
                    ),
                    const PopupMenuItem<String>(
                      key: ChatKeys.chatSearchButton,
                      value: 'search',
                      padding: EdgeInsets.zero,
                      height: menuItemsHeight,
                      child: PopupMenuItemWidget(
                        icon: Icons.search,
                        text: 'Search',
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'change-wallpaper',
                      padding: EdgeInsets.zero,
                      height: menuItemsHeight,
                      child: PopupMenuItemWidget(
                        icon: Icons.wallpaper_rounded,
                        text: 'Change Wallpaper',
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'clear-history',
                      padding: EdgeInsets.zero,
                      height: menuItemsHeight,
                      child: PopupMenuItemWidget(
                        icon: Icons.cleaning_services,
                        text: 'Clear History',
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete-chat',
                      padding: EdgeInsets.zero,
                      height: menuItemsHeight,
                      child: PopupMenuItemWidget(
                        icon: Icons.delete_outline,
                        text: 'Delete Chat',
                      ),
                    ),
                  ];
                },
              ),
          ],
        ),
        body: Stack(
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
                  child: isShowAsList
                      ? Container(
                          color: Palette.background,
                          child: Column(
                            children: _messageIndices.map((index) {
                              MessageModel msg = chatContent[index];
                              return SettingsOptionWidget(
                                imagePath: getRandomImagePath(),
                                text: msg.senderId,
                                subtext: msg.content?.toJson()['text'] ?? "",
                                onTap: () => {
                                  // TODO (Mo): Create scroll to msg
                                },
                              );
                            }).toList(),
                          ),
                        )
                      : chatContent.isEmpty
                          ? Center(
                              child: Container(
                                width: 210,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                padding: const EdgeInsets.all(22.0),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(4, 86, 57, 0.30),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'No messages here yet...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Palette.primaryText,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Send a message or tap the greeting below.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Palette.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    LottieViewer(
                                      path: _chosenAnimation,
                                      width: 100,
                                      height: 100,
                                      isLooping: true,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              controller:
                                  _scrollController, // Use the ScrollController
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Column(
                                  children:
                                      chatContent.mapIndexed((index, item) {
                                    if (item is DateLabelWidget) {
                                      return item;
                                    } else if (item is MessageModel) {
                                      return MessageTileWidget(
                                        key: ValueKey(
                                            '${MessageKeys.messagePrefix}${messagesIndex++}'),
                                        messageModel: item,
                                        isSentByMe: item.senderId ==
                                            ref.read(userProvider)!.id,
                                        showInfo: type == ChatType.group,
                                        highlights: _messageMatches[index] ??
                                            const [MapEntry(0, 0)],
                                        onReply: (message) {
                                          setState(() {
                                            replyMessage = message;
                                          });
                                        },
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }).toList(),
                                ),
                              ),
                            ),
                ),
                if (replyMessage != null)
                  ReplyWidget(
                    message: replyMessage!,
                    onDiscard: (){
                      setState(() {
                        replyMessage = null;
                      });
                    },
                  )
                else
                  const SizedBox(),
                if (!isSearching)
                  BottomInputBarWidget(
                    controller: _messageController,
                    recorderController: _recorderController,
                    playerController: _playerController,
                    chatID: chatID,
                    sendMessage: _sendMessage,
                    startRecording: _startRecording,
                    stopRecording: _stopRecording,
                    deleteRecording: _deleteRecording,
                    cancelRecording: _cancelRecording,
                    lockRecording: _lockRecording,
                    isRecording: isRecording,
                    isRecordingCompleted: isRecordingCompleted,
                    isRecordingLocked: isRecordingLocked,
                    isRecordingPaused: isRecordingPaused,
                    lockRecordingDrag: _lockRecordingDrag,
                  )
                else
                  Container(
                    color: Palette.trinary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          key: ChatKeys.chatSearchDatePicker,
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () {
                            // Show the Cupertino Date Picker when the icon is pressed
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: const DateTimePickerTheme(
                                backgroundColor: Palette.secondary,
                                itemTextStyle: TextStyle(
                                  color: Palette.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                confirm: Text(
                                  'Jump to date',
                                  style: TextStyle(
                                    color: Palette.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                cancel: null,
                              ),
                              minDateTime: DateTime.now()
                                  .subtract(const Duration(days: 365 * 10)),
                              maxDateTime: DateTime.now(),
                              initialDateTime: DateTime.now(),
                              dateFormat: 'dd-MMMM-yyyy',
                              locale: DateTimePickerLocale.en_us,
                              onConfirm: (date, time) {
                                _scrollToTimeStamp(date);
                              },
                            );
                          },
                        ),
                        if (_numberOfMatches != 0)
                          Text(
                            _numberOfMatches == 0
                                ? 'No results'
                                : isShowAsList
                                    ? '$_numberOfMatches result${_numberOfMatches != 1 ? 's' : ''}'
                                    : '$_currentMatch of $_numberOfMatches',
                            style: const TextStyle(
                                color: Palette.primaryText,
                                fontWeight: FontWeight.w500),
                          ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                _toggleSearchDisplay();
                              },
                              child: Text(
                                key: ChatKeys.chatSearchShowMode,
                                isShowAsList ? 'Show as Chat' : 'Show as List',
                                style: const TextStyle(
                                  color: Palette.accent,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
            if (isSearching && _numberOfMatches != 0) ...[
              Positioned(
                bottom: 150,
                right: 10,
                child: GestureDetector(
                  onTap: _scrollToPrevMatch,
                  child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Palette.quaternary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Icon(Icons.keyboard_arrow_up_sharp),
                      )),
                ),
              ),
              Positioned(
                bottom: 90,
                right: 10,
                child: GestureDetector(
                  onTap: _scrollToNextMatch,
                  child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Palette.quaternary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Icon(Icons.keyboard_arrow_down_sharp),
                      )),
                ),
              ),
            ],
            AnimatedPositioned(
              bottom: -20,
              right: -20,
              duration: const Duration(milliseconds: 300),
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
          ],
        ));
  }

  String getRandomLottieAnimation() {
    // List of Lottie animation paths
    List<String> lottieAnimations = [
      'assets/tgs/curious_pigeon.tgs',
      'assets/tgs/fruity_king.tgs',
      'assets/tgs/graceful_elmo.tgs',
      'assets/tgs/hello_anteater.tgs',
      'assets/tgs/hello_astronaut.tgs',
      'assets/tgs/hello_badger.tgs',
      'assets/tgs/hello_bee.tgs',
      'assets/tgs/hello_cat.tgs',
      'assets/tgs/hello_clouds.tgs',
      'assets/tgs/hello_duck.tgs',
      'assets/tgs/hello_elmo.tgs',
      'assets/tgs/hello_fish.tgs',
      'assets/tgs/hello_flower.tgs',
      'assets/tgs/hello_food.tgs',
      'assets/tgs/hello_fridge.tgs',
      'assets/tgs/hello_ghoul.tgs',
      'assets/tgs/hello_king.tgs',
      'assets/tgs/hello_lama.tgs',
      'assets/tgs/hello_monkey.tgs',
      'assets/tgs/hello_pigeon.tgs',
      'assets/tgs/hello_possum.tgs',
      'assets/tgs/hello_rat.tgs',
      'assets/tgs/hello_seal.tgs',
      'assets/tgs/hello_shawn_sheep.tgs',
      'assets/tgs/hello_snail_rabbit.tgs',
      'assets/tgs/hello_virus.tgs',
      'assets/tgs/hello_water_animal.tgs',
      'assets/tgs/hello_whales.tgs',
      'assets/tgs/muscles_wizard.tgs',
      'assets/tgs/plague_doctor.tgs',
      'assets/tgs/screaming_elmo.tgs',
      'assets/tgs/shy_elmo.tgs',
      'assets/tgs/sick_wizard.tgs',
      'assets/tgs/snowman.tgs',
      'assets/tgs/spinny_jelly.tgs',
      'assets/tgs/sus_moon.tgs',
      'assets/tgs/toiletpaper.tgs',
    ];

    // Generate a random index
    Random random = Random();
    int randomIndex =
        random.nextInt(lottieAnimations.length); // Gets a random index

    // Return the randomly chosen Lottie animation path
    return lottieAnimations[randomIndex];
  }
}
