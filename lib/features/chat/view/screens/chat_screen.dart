import 'dart:math';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
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
import 'package:telware_cross_platform/features/chat/view/screens/pinned_messages_screen.dart';
import 'package:telware_cross_platform/features/chat/view/widget/bottom_input_bar_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:vibration/vibration.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';

import '../../../../core/routes/routes.dart';
import '../widget/reply_widget.dart';
import 'create_chat_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static const String route = '/chat';
  final String chatId;
  final ChatModel? chatModel;
  final List<MessageModel>? forwardedMessages;

  const ChatScreen(
      {super.key, this.chatId = "", this.chatModel, this.forwardedMessages});

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
  List<MessageModel> selectedMessages = [];
  List<MessageModel> pinnedMessages = [];
  int indexInPinnedMessage = 0;

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
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isRecordingLocked = false;
  bool isRecordingPaused = false;
  bool isLoading = true;
  bool isTextEmpty = true;
  bool showMuteOptions = false;
  double _lockRecordingDragPosition = 0;
  final lockPath = "assets/json/passcode_lock.json";
  String? recordingPath;
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
    // _scrollToBottom();
      if (widget.forwardedMessages != null) {
        _sendForwardedMessages();
      }
    });
    _chosenAnimation = getRandomLottieAnimation();
    _getDir();
    // _scrollToBottom();
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
      // _scrollToBottom();
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

  // Send the Forwarded Messages
  void _sendForwardedMessages() {
    for (MessageModel message in widget.forwardedMessages!) {
      ref.read(chattingControllerProvider).sendMsg(
            content: TextContent(message.content as String),
            msgType: MessageType.normal,
            contentType: MessageContentType.text,
            chatType: ChatType.private,
            chatModel: widget.chatModel,
          );
      _messageController.clear();
      List<MessageModel> messages =
          ref.watch(chatProvider(widget.chatId))?.messages ?? [];
      _updateChatMessages(messages);
    }
  }

  //TODO: Implement the sendMsg method with another types of messages
  void _sendMessage(
      {required WidgetRef ref,
      required String contentType,
      String? filePath,
      bool? getRecordingPath}) async {
    MessageContentType messageContentType =
        MessageContentType.getType(contentType);
    MessageContent content;
    bool needUploadMedia = contentType != 'text';
    String? mediaUrl;
    // Upload the media file before sending the message
    if (needUploadMedia) {
      if (filePath == null) {
        debugPrint("Try to send a media without a file path");
        return;
      } else {
        mediaUrl =
            await ref.read(chattingControllerProvider).uploadMedia(filePath);
        if (mediaUrl == null) {
          showToastMessage(
              "Failed to upload the media check your connection or try again later");
          return;
        }
        debugPrint("Media uploaded successfully with url: $mediaUrl");
      }
    }
    switch (contentType) {
      case 'text':
        content = TextContent(_messageController.text);
        break;
      case 'image':
        content = ImageContent(filePath: filePath, imageUrl: mediaUrl);
        break;
      case 'video':
        content = VideoContent(filePath: filePath, videoUrl: mediaUrl);
        break;
      case 'audio':
        if (getRecordingPath == true && filePath == null) {
          if (recordingPath == null) {
            showToastMessage("Recording has no path");
            return;
          }
          content = AudioContent(filePath: recordingPath!, audioUrl: mediaUrl);
        } else {
          content = AudioContent(filePath: filePath, audioUrl: mediaUrl);
        }
        break;
      case 'file':
        content = DocumentContent(
            filePath: filePath,
            fileName: filePath!.split('/').last,
            fileUrl: mediaUrl);
      default:
        content = TextContent(_messageController.text);
    }
    // TODO : Handle media attribute in the request of sending a message

    MessageModel newMessage = MessageModel(
      senderId: ref.read(userProvider)!.id!,
      messageContentType: messageContentType,
      content: content,
      timestamp: DateTime.now(),
      messageType: MessageType.normal,
      userStates: {},
    );
    _messageController.clear();
    _updateChatMessages([...?chatModel?.messages, newMessage]);
    ref
        .read(chattingControllerProvider)
        .sendMsg(
          content: newMessage.content!,
          msgType: newMessage.messageType,
          contentType: newMessage.messageContentType,
          chatType: ChatType.private,
          chatModel: chatModel,
        )
        .then((_) {
      List<MessageModel> messages =
          ref.watch(chatProvider(chatModel!.id!))?.messages ?? [];
      _updateChatMessages(messages);
      // _scrollToBottom();
    });
  }

  void _setChatMute(DateTime? muteUntil) {
    if (muteUntil == null) {
      ref.read(chattingControllerProvider).unmuteChat(chatModel!.id!).then((_) {
        setState(() {
          chatModel = chatModel!.copyWith(isMuted: false, muteUntil: null);
        });
      });
    } else {
      ref
          .read(chattingControllerProvider)
          .muteChat(chatModel!.id!, muteUntil)
          .then((_) {
        setState(() {
          chatModel = chatModel!.copyWith(isMuted: true, muteUntil: muteUntil);
        });
      });
    }
  }

  //--------------------------------Recording--------------------------------
  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    recordingPath = "${appDirectory.path}/recording.m4a";
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
      _recorderController.record(path: recordingPath);
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

  void _resetRecording() {
    isRecording = false;
    isRecordingLocked = false;
    isRecordingPaused = false;
    isRecordingCompleted = false;
    recordingPath = null;
    setState(() {});
  }

  void _deleteRecording() {
    if (recordingPath == null) {
      debugPrint("No recording to delete");
      return;
    }
    if (File(recordingPath!).existsSync()) {
      File(recordingPath!).deleteSync();
      debugPrint("Recording deleted at $recordingPath");
      _resetRecording();
    }
  }

  void _cancelRecording() async {
    if (isRecording) {
      String? path = await _recorderController.stop(true);
      if (path != null) {
        if (File(path).existsSync()) {
          File(path).deleteSync();
          debugPrint("Recording deleted at $path");
        }
        debugPrint("Recording canceled");
      }
      _resetRecording();
    }
  }

  void _record() async {
    try {
      await _recorderController.record(); // Path is optional
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

  //wait for sending will not set the isRecording to false and you will have to set it manually
  // or call cancel recording to reset every thing
  Future<String?> _stopRecording() async {
    try {
      recordingPath = await _recorderController.stop(false);
      _recorderController.reset();

      if (recordingPath != null) {
        isRecordingCompleted = true;
        isRecording = false;
        isRecordingPaused = false;
        setState(() {});
        debugPrint(recordingPath);
        debugPrint("Recorded file size: ${File(recordingPath!).lengthSync()}");
        return recordingPath!;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return null;
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

  void onMediaDownloaded(String? filePath, String? messageId, String? chatId) {
    if (filePath == null) {
      showToastMessage('File has been deleted ask the sender to resend it');
      return;
    }
    if (messageId == null || chatId == null) {
      showToastMessage('Message ID or Chat ID is missing');
      return;
    }
    debugPrint("Downloaded file path: $filePath");
    debugPrint("Message ID: $messageId");
    debugPrint("Chat ID: $chatId");
    ref
        .read(chattingControllerProvider)
        .editMessageFilePath(chatId, messageId, filePath);
  }

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
    final popupMenu = buildPopupMenu();
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
        appBar: selectedMessages.isEmpty
            ? AppBar(
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
                onSelected: _handlePopupMenuSelection,
                color: Palette.secondary,
                padding: EdgeInsets.zero,
                itemBuilder: popupMenu,
              ),
          ],
        ): AppBar(
                backgroundColor: Palette.secondary,
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMessages = [];
                    });
                  },
                  child: Icon(Icons.close),
                ),
                title: Row(
                  children: [
                    // Number
                    Text(
                      selectedMessages.length.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Spacer(),
                    // Copy icon
                    IconButton(
                      icon: Icon(Icons.copy, color: Colors.white),
                      onPressed: () {},
                    ),
                    // Share icon
                    IconButton(
                      icon: Icon(FontAwesomeIcons.share, color: Colors.white),
                      onPressed: () {
                        context.push(CreateChatScreen.route);
                      },
                    ),
                    // Delete icon
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        // TODO call delete function
                      },
                    ),
                  ],
                ),
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
                            reverse: true,
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
                                      return Row(
                                        mainAxisAlignment: item.senderId ==
                                                ref.read(userProvider)!.id
                                            ? selectedMessages.isNotEmpty
                                                ? MainAxisAlignment.spaceBetween
                                                : MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          if (selectedMessages
                                              .isNotEmpty) // Show check icon only if selected
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 1), // White border
                                              ),
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    selectedMessages.contains(
                                                                item) ==
                                                            true
                                                        ? Colors.green
                                                        : Colors.transparent,
                                                child: selectedMessages
                                                            .contains(item) ==
                                                        true
                                                    ? const Icon(Icons.check,
                                                        color: Colors.white,
                                                        size: 16)
                                                    : const SizedBox(),
                                              ),
                                            ),
                                          if (selectedMessages.contains(item))
                                            const SizedBox(width: 10),
                                          MessageTileWidget(
                                        key: ValueKey(
                                            '${MessageKeys.messagePrefix}${messagesIndex++}'),
                                        messageModel: item,
                                        isSentByMe: item.senderId ==
                                            ref.read(userProvider)!.id,
                                        showInfo: type == ChatType.group,
                                        highlights: _messageMatches[index] ??
                                            const [MapEntry(0, 0)],

                                        onDownloadTap: (String? filePath) {
                                          onMediaDownloaded(
                                              filePath, item.id, chatID);
                                        },

                                            onReply: (message) {
                                              setState(() {
                                                replyMessage = message;
                                              });
                                            },
                                            onPin: (message) {
                                              setState(() {
                                                pinnedMessages.contains(message)
                                                    ? pinnedMessages
                                                        .remove(message)
                                                    : pinnedMessages
                                                        .add(message);
                                              });
                                            },
                                            onPress: selectedMessages.isEmpty
                                                ? null
                                                : () {},
                                            onLongPress: (message) {
                                              setState(() {
                                                replyMessage = null;
                                                selectedMessages
                                                        .contains(message)
                                                    ? selectedMessages
                                                        .remove(message)
                                                    : selectedMessages
                                                        .add(message);
                                              });
                                            },
                                          ),
                                        ],

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
                    onDiscard: () {
                      setState(() {
                        replyMessage = null;
                      });
                    },
                  )
                else
                  const SizedBox(),
                if (selectedMessages.isNotEmpty)
                  Container(
                    color: Palette.secondary,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                replyMessage = selectedMessages[0];
                                selectedMessages = [];
                              });
                            },
                            child: Row(
                              children: [
                                selectedMessages.length == 1
                                    ? const Icon(
                                        Icons.reply,
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  width: 5,
                                ),
                                selectedMessages.length == 1
                                    ? const Text(
                                        'Reply',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push(CreateChatScreen.route);
                            },
                            child: const Row(
                              children: [
                                Icon(FontAwesomeIcons.share),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Forward',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                else if (!isSearching)
                  BottomInputBarWidget(
                    controller: _messageController,
                    recorderController: _recorderController,
                    chatID: chatID,
                    sendMessage: _sendMessage,
                    startRecording: _startRecording,
                    stopRecording: _stopRecording,
                    deleteRecording: _deleteRecording,
                    resetRecording: _resetRecording,
                    cancelRecording: _cancelRecording,
                    lockRecording: _lockRecording,
                    isRecording: isRecording,
                    isRecordingCompleted: isRecordingCompleted,
                    isRecordingLocked: isRecordingLocked,
                    isRecordingPaused: isRecordingPaused,
                    lockRecordingDrag: _lockRecordingDrag,
                    audioFilePath: recordingPath,
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
            pinnedMessages.isNotEmpty
                ? Positioned(
                    top:
                        0, // Adjust this to position the widget from the top of the screen
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Palette
                          .secondary, // Example background color for the widget
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                children: List.generate(pinnedMessages.length,
                                    (index) {
                                  return Container(
                                    height: 40 / pinnedMessages.length,
                                    padding: const EdgeInsets.all(1.0),
                                    margin: const EdgeInsets.all(1.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pinned Message',
                                    style: TextStyle(
                                        color: Palette.primary, fontSize: 12),
                                  ),
                                  Text(
                                    // pinnedMessages[indexInPinnedMessage].content as String,
                                    'Content placeholder',
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              List<String> senderIds = [];
                              for (var message in pinnedMessages) {
                                senderIds.add(message.senderId);
                              }
                              ChatModel newChat = ChatModel(
                                  title: 'pinnedMessages',
                                  userIds: senderIds,
                                  type: ChatType.group,
                                  messages: pinnedMessages);
                              context.push(Routes.pinnedMessagesScreen,
                                  extra: newChat);
                            },
                            child: const Icon(
                              Icons.menu_open_outlined,
                              color: Palette.accentText,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
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
                          onPressed: () async {
                            if (isRecording) {
                              String? filePath = await _stopRecording();
                              _sendMessage(
                                  ref: ref,
                                  contentType: 'audio',
                                  filePath: filePath);
                              _cancelRecording();
                            }
                          },
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ));
  }

  void _handlePopupMenuSelection(String value) {
    switch (value) {
      // case 'no-close':
      //   break;
      case 'search':
        _enableSearching();
        break;
      case 'mute-chat':
        showMuteOptions = false;
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
              'Confirm',
              style: TextStyle(
                color: Palette.primary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          pickerMode: DateTimePickerMode.time,
          minDateTime: DateTime.now(),
          maxDateTime: DateTime.now().add(const Duration(days: 365)),
          initialDateTime: DateTime.now(),
          dateFormat: 'dd-MMMM-yyyy',
          locale: DateTimePickerLocale.en_us,
          onConfirm: (date, time) {
            _setChatMute(date);
          },
        );
        break;
      case 'unmute-chat':
        _setChatMute(null);
        break;
      case 'mute-chat-forever':
        showMuteOptions = false;
        _setChatMute(DateTime.now().add(const Duration(days: 365 * 10)));
      default:
        showToastMessage("No Bueno");
    }
  }

  PopupMenuItemBuilder<String> buildPopupMenu() {
    const double menuItemsHeight = 45.0;

    return (BuildContext context) {
      if (showMuteOptions) {
        return [
          PopupMenuItem<String>(
              value: 'no-close',
              padding: EdgeInsets.zero,
              height: menuItemsHeight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showMuteOptions = false;
                  });
                },
                child: const PopupMenuItemWidget(
                  icon: Icons.arrow_back,
                  text: 'Back',
                ),
              )),
          const PopupMenuItem<String>(
            value: 'disable-sound',
            padding: EdgeInsets.zero,
            height: menuItemsHeight,
            child: PopupMenuItemWidget(
              icon: Icons.music_off_outlined,
              text: 'Disable sound',
            ),
          ),
          const PopupMenuItem<String>(
            key: ChatKeys.chatSearchButton,
            value: 'mute-chat',
            padding: EdgeInsets.zero,
            height: menuItemsHeight,
            child: PopupMenuItemWidget(
              icon: Icons.notifications_paused_outlined,
              text: 'Mute for...',
            ),
          ),
          const PopupMenuItem<String>(
            value: 'customize-chat',
            padding: EdgeInsets.zero,
            height: menuItemsHeight,
            child: PopupMenuItemWidget(
              icon: Icons.tune_outlined,
              text: 'Customize',
            ),
          ),
          const PopupMenuItem<String>(
            value: 'mute-chat-forever',
            padding: EdgeInsets.zero,
            height: menuItemsHeight,
            child: PopupMenuItemWidget(
              icon: Icons.volume_off_outlined,
              text: 'Mute Forever',
            ),
          ),
        ];
      }
      return [
        if (chatModel!.isMuted)
          const PopupMenuItem<String>(
              value: 'unmute-chat',
              padding: EdgeInsets.zero,
              height: menuItemsHeight,
              child: PopupMenuItemWidget(
                icon: Icons.volume_off_outlined,
                text: 'Unmute',
              ))
        else
          PopupMenuItem<String>(
            value: 'no-close',
            padding: EdgeInsets.zero,
            height: menuItemsHeight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showMuteOptions = true;
                });
              },
              child: const PopupMenuItemWidget(
                  icon: Icons.volume_up_rounded,
                  text: 'Mute',
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Palette.inactiveSwitch,
                    size: 16,
                  )),
            ),
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
    };
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

