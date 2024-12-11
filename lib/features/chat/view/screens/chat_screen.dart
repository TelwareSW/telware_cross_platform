// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/providers/chat_provider.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/popup_menu_item_widget.dart';
import 'package:telware_cross_platform/features/chat/services/audio_recording_service.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';
import 'package:telware_cross_platform/features/chat/view/widget/bottom_input_bar_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/magic_recording_button.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/new_chat_screen_sticker.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
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
  late AudioRecorderService _audioRecorderService;

  List<dynamic> chatContent = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _chosenAnimation;
  MessageModel? replyMessage;
  MessageModel? editMessage;
  List<MessageModel> selectedMessages = [];
  List<MessageModel> pinnedMessages = [];
  int indexInPinnedMessage = 0;

  late ChatModel chatModel;
  bool isSearching = false;
  bool isShowAsList = false;
  int _numberOfMatches = 0;
  bool _isMuted = false;
  bool isLoading = true;
  bool isTextEmpty = true;
  bool showMuteOptions = false;

  // ignore: prefer_final_fields
  int _currentMatch = 1;

  // ignore: unused_field
  int _currentMatchIndex = 0;
  Map<int, List<MapEntry<int, int>>> _messageMatches = {};
  List<int> _messageIndices = [];

  late Timer _draftTimer;
  String _previousDraft = "";

  late ChatType type;

  @override
  void initState() {
    super.initState();
    _messageController.text = widget.chatModel?.draft ?? "";
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.forwardedMessages != null) {
        _sendForwardedMessages();
      }
    });
    _chosenAnimation = getRandomLottieAnimation();
    // Initialize the AudioRecorderService
    _audioRecorderService = AudioRecorderService(updateUI: setState);

    _draftTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateDraft();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose of the ScrollController
    _audioRecorderService.dispose();
    _draftTimer.cancel();
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  void _updateDraft() async {
    // TODO : server return 500 status code every time try to fix it ASAP
    return;
    if (!mounted) return;
    final currentDraft = _messageController.text;
    if (currentDraft != _previousDraft) {
      ref
          .read(chattingControllerProvider)
          .updateDraft(chatModel!, currentDraft);
      _previousDraft = currentDraft;
    } else if (chatModel?.id != null) {
      // ref
      //     .read(chattingControllerProvider)
      //     .getDraft(chatModel!.id!)
      //     .then((draft) {
      //   if (draft != null && draft != _previousDraft) {
      //     setState(() {
      //       _messageController.text = draft;
      //       _previousDraft = draft;
      //     });
      //   }
      // });
    }
  }

  void _updateChatMessages(List<MessageModel> messages) async {
    setState(() {
      chatContent = _generateChatContentWithDateLabels(messages);
    });
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
            content: message.content!,
            msgType: MessageType.forward,
            contentType: message.messageContentType,
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
  void _sendMessage({
    required WidgetRef ref,
    required String contentType,
    String? filePath,
    bool? getRecordingPath,
  }) async {
    MessageContentType messageContentType =
        MessageContentType.getType(contentType);
    MessageContent content;
    bool needUploadMedia = contentType != 'text';
    String? mediaUrl;
    // Upload the media file before sending the message
    if (needUploadMedia && UPLOAD_MEDIA) {
      if (filePath != null) {
        mediaUrl = await ref
            .read(chattingControllerProvider)
            .uploadMedia(filePath, contentType);
        if (mediaUrl == null) {
          showToastMessage("Failed to upload media file");
          return;
        }
      } else {
        showToastMessage("Media file is missing");
        return;
      }
    }
    content = createMessageContent(
        contentType: messageContentType,
        filePath: filePath,
        mediaUrl: mediaUrl,
        text: _messageController.text);
    // TODO : Handle media attribute in the request of sending a message

    MessageModel newMessage = MessageModel(
      senderId: ref.read(userProvider)!.id!,
      messageContentType: messageContentType,
      content: content,
      timestamp: DateTime.now(),
      messageType: MessageType.normal,
      userStates: {},
      parentMessage: replyMessage?.id,
    );
    _messageController.clear();
    _updateChatMessages([...chatModel.messages, newMessage]);
    ref.read(chattingControllerProvider).sendMsg(
        content: newMessage.content!,
        msgType: newMessage.messageType,
        contentType: newMessage.messageContentType,
        chatType: ChatType.private,
        chatModel: chatModel,
        parentMessgeId: replyMessage?.id);
  }

  void _setChatMute(bool mute, DateTime? muteUntil) async {
    if (!mute) {
      ref.read(chattingControllerProvider).unmuteChat(chatModel!).then((_) {
        debugPrint('Unmuted until: $muteUntil, chat: $chatModel');
        setState(() {
          _isMuted = false;
        });
      });
    } else {
      ref
          .read(chattingControllerProvider)
          .muteChat(chatModel!, muteUntil)
          .then((_) {
        debugPrint('Muted until: $muteUntil, chat: $chatModel');
        setState(() {
          _isMuted = true;
        });
      });
    }
  }

  void _removeReply() {
    setState(() {
      replyMessage = null;
    });
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
    debugPrint('&*&**&**& rebuild chat screen');
    // ref.watch(chatsViewModelProvider);
    final popupMenu = buildPopupMenu();

    final chats = ref.watch(chatsViewModelProvider);
    final index = chats.indexWhere((chat) => chat.id == widget.chatId);
    final ChatModel? chat =
        (index == -1) ? null : chats[index]; // Chat not found
    chatModel = widget.chatModel ?? chat!;
    _updateDraft();
    final type = chatModel.type;
    final String title = chatModel.title;
    final membersNumber = chatModel.userIds.length;
    final imageBytes = chatModel.photoBytes;
    final photo = chatModel.photo;
    final messages = chatModel.messages;
    final chatID = chatModel.id;
    final String subtitle = chatModel.type == ChatType.private
        ? "last seen a long time ago"
        : "$membersNumber Member${membersNumber > 1 ? "s" : ""}";

    debugPrint('(^) number of messages: ${messages.length}');

    _isMuted = chatModel.isMuted;
    _messageController.text = chatModel.draft ?? "";
    chatContent = _generateChatContentWithDateLabels(messages);
    pinnedMessages = messages.where((message) => message.isPinned).toList();
    debugPrint('pinned Messages count after is : ${pinnedMessages.length}');

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
                      _updateDraft();
                      Navigator.pop(context);
                    }
                  },
                ),
                title: !isSearching
                    ? GestureDetector(
                        onTap: () {
                          context.push(Routes.chatInfoScreen,
                              extra: chatModel!);
                        },
                        child: ChatHeaderWidget(
                          title: title,
                          subtitle: subtitle,
                          photo: photo,
                          imageBytes: imageBytes,
                        ),
                      )
                    : TextField(
                        key: ChatKeys.chatSearchInput,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              color: Palette.accentText,
                              fontWeight: FontWeight.w400),
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
              )
            : AppBar(
                backgroundColor: Palette.secondary,
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMessages = [];
                    });
                  },
                  child: const Icon(Icons.close),
                ),
                title: Row(
                  children: [
                    // Number
                    Text(
                      selectedMessages.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Spacer(),
                    // Copy icon
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      onPressed: () {},
                    ),
                    // Share icon
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.share,
                          color: Colors.white),
                      onPressed: () {
                        context.push(CreateChatScreen.route);
                      },
                    ),
                    // Delete icon
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
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
                          ? NewChatScreenSticker(
                              chosenAnimation: _chosenAnimation)
                          : ChatMessagesList(
                            messages: messages,
                              scrollController: _scrollController,
                              chatContent: chatContent,
                              selectedMessages: selectedMessages,
                              type: type,
                              messageMatches: _messageMatches,
                              replyMessage: replyMessage,
                              chatId: chatID,
                              pinnedMessages: pinnedMessages,
                              updateChatMessages:
                                  _generateChatContentWithDateLabels,
                              onPin: _onPin,
                              onLongPress: _onLongPress,
                              onReply: _onReply),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
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
                    audioRecorderService: _audioRecorderService,
                    chatID: chatID,
                    sendMessage: _sendMessage,
                    removeReply: _removeReply,
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
                    top: 0,
                    // Adjust this to position the widget from the top of the screen
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Palette
                          .secondary, // Example background color for the widget
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
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
                : const SizedBox(),
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
            MagicRecordingButton(
                audioRecorderService: _audioRecorderService,
                sendMessage: ({required String contentType, String? filePath}) {
                  _sendMessage(
                      ref: ref, contentType: contentType, filePath: filePath);
                })
          ],
        ));
  }

  void _handlePopupMenuSelection(String value) {
    final bool noChat = chatModel?.id == null;
    switch (value) {
      // case 'no-close':
      //   break;
      case 'search':
        if (noChat) {
          showToastMessage("There is nothing to search");
          return;
        }
        _enableSearching();
        break;
      case 'mute-chat':
        showMuteOptions = false;
        if (noChat) {
          showToastMessage("Maybe say something first...");
          return;
        }
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
            _setChatMute(true, date);
          },
        );
        break;
      case 'unmute-chat':
        _setChatMute(false, null);
        break;
      case 'mute-chat-forever':
        if (noChat) {
          showToastMessage("Seriously? Mute what?");
          return;
        }
        showMuteOptions = false;
        _setChatMute(true, null);
      default:
        showToastMessage("No Bueno");
    }
  }

  void _onPin(MessageModel message) {
    setState(() {
      pinnedMessages.contains(message)
          ? pinnedMessages.remove(message)
          : pinnedMessages.add(message);
      ref.read(chattingControllerProvider).pinMessageClient(
            message.id ?? '',
            chatModel.id ?? '',
          );
    });
  }

  void _onLongPress(MessageModel message) {
    setState(() {
      replyMessage = null;
      selectedMessages.contains(message)
          ? selectedMessages.remove(message)
          : selectedMessages.add(message);
    });
  }

  void _onReply(MessageModel message) {
    setState(() {
      debugPrint('reply');
      replyMessage = message;
    });
  }

  PopupMenuItemBuilder<String> buildPopupMenu() {
    const double menuItemsHeight = 45.0;
    if (!mounted) return (BuildContext context) => [];
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
        if (_isMuted)
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
}

class ChatMessagesList extends ConsumerStatefulWidget {
  ChatMessagesList({
    super.key,
    required this.scrollController,
    required this.chatContent,
    required this.selectedMessages,
    required this.type,
    required this.messageMatches,
    required this.replyMessage,
    required this.chatId,
    required this.pinnedMessages,
    required this.messages,
    required this.updateChatMessages,
    required this.onPin,
    required this.onLongPress,
    required this.onReply,
  });

  final ScrollController scrollController;
  final ChatType type;
  final String? chatId;
  List chatContent;
  List<MessageModel> messages;
  List<MessageModel> selectedMessages;
  List<MessageModel> pinnedMessages;
  Map<int, List<MapEntry<int, int>>> messageMatches;
  MessageModel? replyMessage;
  final Function(List<MessageModel> messages) updateChatMessages;
  final Function(MessageModel message) onPin;
  final Function(MessageModel message) onLongPress;
  final Function(MessageModel message) onReply;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatMessagesListState();
}

class _ChatMessagesListState extends ConsumerState<ChatMessagesList> {
  var messagesIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      controller: widget.scrollController, // Use the ScrollController
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: widget.chatContent.mapIndexed((index, item) {
            if (item is DateLabelWidget) {
              return item;
            } else if (item is MessageModel) {
              int parentIndex = -1;
                if (item.content?.getContent() == 'god') {
                  print('#############################');
                  print(item);
                  print('#############################');
                }
              MessageModel? parentMessage;
              if (item.parentMessage != null && item.parentMessage!.isNotEmpty) {
                parentIndex = widget.messages.indexWhere((msg)=> msg.id == item.parentMessage);
              }
              if (parentIndex >=0) {
                parentMessage = widget.messages[parentIndex];
              }
              return Row(
                mainAxisAlignment: item.senderId == ref.read(userProvider)!.id
                    ? widget.selectedMessages.isNotEmpty
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (widget.selectedMessages
                      .isNotEmpty) // Show check icon only if selected
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 1), // White border
                      ),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            widget.selectedMessages.contains(item) == true
                                ? Colors.green
                                : Colors.transparent,
                        child: widget.selectedMessages.contains(item) == true
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : const SizedBox(),
                      ),
                    ),
                  if (widget.selectedMessages.contains(item))
                    const SizedBox(width: 10),
                  MessageTileWidget(
                    key: ValueKey(
                        '${MessageKeys.messagePrefix}${messagesIndex++}'),
                    messageModel: item,
                    chatId: widget.chatId ?? '',
                    isSentByMe: item.senderId == ref.read(userProvider)!.id,
                    showInfo: widget.type == ChatType.group,
                    highlights:
                        widget.messageMatches[index] ?? const [MapEntry(0, 0)],
                    onDownloadTap: (String? filePath) {
                      onMediaDownloaded(filePath, item.localId, widget.chatId);
                    },
                    onReply: widget.onReply,
                    onPin: widget.onPin,
                    onPress: widget.selectedMessages.isEmpty ? null : () {},
                    onLongPress: widget.onLongPress,
                    parentMessage: parentMessage,
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          }).toList(),
        ),
      ),
    );
  }

  //----------------------------------------------------------------------------
  //-------------------------------Media----------------------------------------

  void onMediaDownloaded(
      String? filePath, String? messageLocalId, String? chatId) {
    if (filePath == null) {
      showToastMessage('File has been deleted ask the sender to resend it');
      return;
    }
    if (messageLocalId == null) {
      showToastMessage('File does not exist please upload it again');
      return;
    }
    if (chatId == null) {
      showToastMessage('Chat ID is missing');
      return;
    }
    debugPrint("Downloaded file path: $filePath");
    debugPrint("Message local ID: $messageLocalId");
    debugPrint("Chat ID: $chatId");
    ref
        .read(chattingControllerProvider)
        .editMessageFilePath(chatId, messageLocalId, filePath);
    List<MessageModel> messages =
        ref.watch(chatProvider(chatId))?.messages ?? [];
    widget.updateChatMessages(messages);
  }
}
