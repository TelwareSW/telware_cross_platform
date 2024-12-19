import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
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
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';

class PinnedMessagesScreen extends ConsumerStatefulWidget {
  static const String route = '/pinned_messages_screen';
  final String chatId;
  final ChatModel? chatModel;
  final List<MessageModel>? forwardedMessages;

  const PinnedMessagesScreen(
      {super.key, this.chatId = "", this.chatModel, this.forwardedMessages});

  @override
  ConsumerState<PinnedMessagesScreen> createState() => _PinnedMessagesScreen();
}

class _PinnedMessagesScreen extends ConsumerState<PinnedMessagesScreen>
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

  // ignore: prefer_final_fields

  // ignore: unused_field
  final int _currentMatchIndex = 0;
  final Map<int, List<MapEntry<int, int>>> _messageMatches = {};
  final List<int> _messageIndices = [];

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
  final lockPath = "assets/json/passcode_lock.json";
  String? path;
  late Directory appDirectory;

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
      if (widget.forwardedMessages != null) {
        _sendForwardedMessages();
      }
    });
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final chatModel =
        widget.chatModel ?? ref.watch(chatProvider(widget.chatId))!;
    final type = chatModel.type;
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
        title: Text('${chatModel.messages.length.toString()} Pinned Messages'),
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
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
                                children: chatContent.mapIndexed((index, item) {
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
                                              backgroundColor: selectedMessages
                                                          .contains(item) ==
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
                                          chatId: chatModel.id ?? '',
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
                                          onEdit: (_) {},
                                          onPin: (message) {
                                            setState(() {
                                              pinnedMessages.contains(message)
                                                  ? pinnedMessages
                                                      .remove(message)
                                                  : pinnedMessages.add(message);
                                            });
                                          },
                                          onPress: selectedMessages.isEmpty
                                              ? null
                                              : () {},
                                          onLongPress: (message) {
                                            setState(() {
                                              replyMessage = null;
                                              selectedMessages.contains(message)
                                                  ? selectedMessages
                                                      .remove(message)
                                                  : selectedMessages
                                                      .add(message);
                                            });
                                          },
                                          onDownloadTap: (String? filePath) {},
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
              GestureDetector(
                child: Container(
                    width: double.infinity,
                    color: Palette.secondary,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'UNPIN ALL MESSAGES',
                          style: TextStyle(color: Palette.primary),
                        ),
                      ),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}