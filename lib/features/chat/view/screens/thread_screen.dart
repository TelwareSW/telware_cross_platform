// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/popup_menu_widget.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/providers/chat_provider.dart';
import 'package:telware_cross_platform/features/chat/services/audio_recording_service.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';
import 'package:telware_cross_platform/features/chat/view/widget/bottom_input_bar_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/call_overlay_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_messages_list.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/magic_recording_button.dart';
import 'package:telware_cross_platform/features/chat/view/widget/new_chat_screen_sticker.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart'
    as utils;

import '../../../../core/routes/routes.dart';
import '../widget/reply_widget.dart';
import 'create_chat_screen.dart';

class ThreadScreen extends ConsumerStatefulWidget {
  static const String route = '/thread-screen';
  final String chatId;
  final MessageModel announcement;
  final List<MessageModel> thread;
  final ChatModel? chatModel;

  const ThreadScreen({
    super.key,
    this.chatId = "",
    this.chatModel,
    required this.announcement,
    required this.thread,
  });

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreen();
}

class _ThreadScreen extends ConsumerState<ThreadScreen>
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
  bool isAllowedToSend = true;

  // ignore: prefer_final_fields
  int _currentMatch = 1;

  // ignore: unused_field
  int _currentMatchIndex = 0;
  Map<int, List<MapEntry<int, int>>> _messageMatches = {};
  List<int> _messageIndices = [];

  late Timer _draftTimer;

  // String _previousDraft = "";

  late ChatType type;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _chosenAnimation = utils.getRandomLottieAnimation();
    _audioRecorderService = AudioRecorderService(updateUI: setState);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorderService.dispose();
    _draftTimer.cancel();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
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

  //TODO: Implement the sendMsg method with another types of messages
  void _sendMessage({
    required WidgetRef ref,
    required String contentType,
    String? fileName,
    String? caption,
    String? filePath,
    bool? getRecordingPath,
    bool isMusic = false,
  }) async {
    MessageContentType messageContentType =
        MessageContentType.getType(contentType);
    MessageContent content;
    bool needUploadMedia = contentType != 'text';
    String? mediaUrl;
    String messageText = _messageController.text;
    // Upload the media file before sending the message
    if (needUploadMedia) {
      if (filePath != null) {
        if (UPLOAD_MEDIA) {
          mediaUrl = await ref
              .read(chattingControllerProvider)
              .uploadMedia(filePath, contentType);
          if (mediaUrl == null) {
            showToastMessage("Failed to upload media file");
            return;
          }
        }
      } else {
        showToastMessage("Media file is missing");
        return;
      }
    }

    if (mediaUrl != null || (!UPLOAD_MEDIA && needUploadMedia)) {
      messageText = caption ?? '';
      if (isMusic == false && contentType == 'audio') {
        UserModel me = ref.read(userProvider)!;
        String displayName =
            (me.screenFirstName.isEmpty) && (me.screenLastName.isEmpty)
                ? me.username
                : '${me.screenFirstName} ${me.screenLastName}'.trim();
        fileName = '$displayName ➜ ${widget.announcement.id}';
      }
    }

    content = createMessageContent(
      contentType: messageContentType,
      filePath: filePath,
      fileName: fileName,
      mediaUrl: mediaUrl,
      isMusic: isMusic,
      text: messageText,
    );
    // TODO : Handle media attribute in the request of sending a message
    print('##############3');
    print(widget.announcement);
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
    ref.read(chattingControllerProvider).sendMsg(
        content: newMessage.content!,
        msgType: newMessage.messageType,
        contentType: newMessage.messageContentType,
        chatType: ChatType.channel,
        chatModel: chatModel,
        parentMessgeId: widget.announcement.id,
        isReply: true,
        encryptionKey: chatModel.encryptionKey,
        initializationVector: chatModel.initializationVector);
  }

  void _editMessage() {
    if (editMessage == null || _messageController.text.isEmpty) return;
    // todo(ahmed): handle extreem cases like editing a message that is not yet sent
    ref.read(chattingControllerProvider).editMsg(
          (editMessage?.id)!,
          (chatModel.id)!,
          _messageController.text,
          chatType: ChatType.channel,
          encryptionKey: chatModel.encryptionKey,
          initializationVector: chatModel.initializationVector,
        );
    _messageController.text = '';
  }

  void _setChatMute(bool mute, DateTime? muteUntil) async {
    if (!mute) {
      ref.read(chattingControllerProvider).unmuteChat(chatModel).then((_) {
        debugPrint('Unmuted until: $muteUntil, chat: $chatModel');
        setState(() {
          _isMuted = false;
        });
      });
    } else {
      ref
          .read(chattingControllerProvider)
          .muteChat(chatModel, muteUntil)
          .then((_) {
        debugPrint('Muted until: $muteUntil, chat: $chatModel');
        setState(() {
          _isMuted = true;
        });
      });
    }
  }

  void _unreferenceMessages() {
    setState(() {
      replyMessage = null;
      editMessage = null;
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
    debugPrint('&*&**&**& rebuild thread screen');
    print('####################');
    print(widget.thread);
    final chats = ref.watch(chatsViewModelProvider);
    final index = chats.indexWhere((chat) => chat.id == widget.chatId);
    final ChatModel? chat =
        (index == -1) ? null : chats[index]; // Chat not found
    chatModel = widget.chatModel ?? chat!;
    const type = ChatType.channel;
    final String title = chatModel.title;
    final membersNumber = chatModel.userIds.length;
    final imageBytes = chatModel.photoBytes;
    final photo = chatModel.photo;
    final messages = [...widget.thread, widget.announcement];
    final chatID = chatModel.id;
    final String subtitle = chatModel.type == ChatType.private
        ? "last seen a long time ago"
        : chatModel.type == ChatType.group
            ? "$membersNumber Member${membersNumber > 1 ? "s" : ""}"
            : "$membersNumber subscribers${membersNumber > 1 ? "s" : ""}";

    _isMuted = chatModel.isMuted;
    if (chatModel.draft != null && chatModel.draft!.isNotEmpty) {
      _messageController.text = chatModel.draft ?? '';
    }
    chatContent = _generateChatContentWithDateLabels(widget.thread);
    pinnedMessages = [widget.announcement];

    if (chatModel.messagingPermission == false) {
      setState(() {
        isAllowedToSend =
            chatModel.admins!.contains(ref.read(userProvider)?.id);
      });
    }
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Scaffold(
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
                        context.pop();
                      }
                    },
                  ),
                  title: !isSearching
                      ? GestureDetector(
                          onTap: () {
                            context.push(Routes.chatInfoScreen,
                                extra: chatModel);
                          },
                          child: Text(
                              '${widget.announcement.threadMessages.length} Comments'),
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
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: _showMoreSettings,
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
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
          body: Column(
            children: [
              const CallOverlay(),
              Expanded(
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
                          child: isShowAsList
                              ? Container(
                                  color: Palette.background,
                                  child: Column(
                                    children: _messageIndices.map((index) {
                                      MessageModel msg = chatContent[index];
                                      return SettingsOptionWidget(
                                        imagePath: getRandomImagePath(),
                                        text: msg.senderId,
                                        subtext:
                                            msg.content?.getContent() ?? "",
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
                                      messages: widget.thread,
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
                                      onLongPress: _onLongPress,
                                      onReply: _onReply,
                                      onEdit: _onEdit,
                                      onPin: (MessageModel message) {},
                                      showExtention: false,
                                      chat: chat,
                            alwaysShow: true,
                                    ),
                        ),
                        if (replyMessage != null)
                          ReplyEditFieldHeader(
                            message: replyMessage!,
                            isReplyOrEdit: true,
                            onDiscard: () {
                              setState(() {
                                replyMessage = null;
                                editMessage = null;
                              });
                            },
                          ),
                        if (editMessage != null)
                          ReplyEditFieldHeader(
                            message: editMessage!,
                            isReplyOrEdit: false,
                            onDiscard: () {
                              setState(() {
                                replyMessage = null;
                                editMessage = null;
                                _messageController.text = '';
                              });
                            },
                          ),
                        if (selectedMessages.isNotEmpty)
                          Container(
                            color: Palette.secondary,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                style: TextStyle(
                                                    color: Colors.white),
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
                            isEditing: editMessage != null,
                            controller: _messageController,
                            audioRecorderService: _audioRecorderService,
                            chatID: chatID,
                            sendMessage: _sendMessage,
                            unreferenceMessages: _unreferenceMessages,
                            editMessage: _editMessage,
                            notAllowedToSend: false,
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
                                      minDateTime: DateTime.now().subtract(
                                          const Duration(days: 365 * 10)),
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
                                        isShowAsList
                                            ? 'Show as Chat'
                                            : 'Show as List',
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
                        sendMessage: (
                            {required String contentType, String? filePath}) {
                          _sendMessage(
                              ref: ref,
                              contentType: contentType,
                              filePath: filePath);
                        }),
                  ],
                ),
              )
            ],
          )),
    );
  }

  void _showMoreSettings() {
    var items = [];
    bool isAdmin = ref.read(userProvider)!.isAdmin;
    //TODO(marwan): check for filter status to update the icon status.
    if (isAdmin) {
      items = [
        {'icon': Icons.search, 'text': 'Search', 'value': 'search'},
        {
          'icon': Icons.filter_alt,
          'text': 'Filter Content',
          'value': 'filter-content'
        },
      ];
    } else {
      if (showMuteOptions) {
        items = [
          {'icon': Icons.arrow_back, 'text': 'Back', 'value': 'no-close'},
          {
            'icon': Icons.music_off_outlined,
            'text': 'Disable sound',
            'value': 'disable-sound'
          },
          {
            'icon': Icons.access_time_rounded,
            'text': 'Mute for 30m',
            'value': 'mute-30m'
          },
          {
            'icon': Icons.notifications_paused_outlined,
            'text': 'Mute for...',
            'value': 'mute-custom'
          },
          {
            'icon': Icons.tune_outlined,
            'text': 'Customize',
            'value': 'customize'
          },
          {
            'icon': Icons.volume_off_outlined,
            'text': 'Mute Forever',
            'value': 'mute-forever',
            'color': Palette.error
          },
        ];
      } else {
        if (_isMuted) {
          items = [
            {
              'icon': Icons.volume_off_outlined,
              'text': 'Unmute',
              'value': 'unmute-chat'
            },
          ];
        } else {
          items = [
            {
              'icon': Icons.volume_up_outlined,
              'text': 'Mute',
              'value': 'no-close',
              'trailing': const Icon(Icons.arrow_forward_ios_rounded,
                  color: Palette.inactiveSwitch, size: 16)
            },
          ];
        }
        items.addAll([
          {'icon': Icons.search, 'text': 'Search', 'value': 'search'},
        ]);
      }
    }
    final renderBox = context.findRenderObject() as RenderBox;
    final position = Offset(renderBox.size.width, -350);

    PopupMenuWidget.showPopupMenu(
        context: context,
        position: position,
        items: items,
        onSelected: _handlePopupMenuSelection);
  }

  void _handlePopupMenuSelection(String value) {
    final bool noChat = chatModel.id == null;
    switch (value) {
      case 'no-close':
        showMuteOptions = !showMuteOptions;
        break;
      case 'search':
        if (noChat) {
          showToastMessage("There is nothing to search");
          return;
        }
        _enableSearching();
        break;
      case 'mute-custom':
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
      case 'mute-30m':
        if (noChat) {
          showToastMessage("You can't mute nothing");
          return;
        }
        showMuteOptions = false;
        _setChatMute(true, DateTime.now().add(const Duration(minutes: 30)));
        break;
      case 'mute-forever':
        if (noChat) {
          showToastMessage("Seriously? Mute what?");
          return;
        }
        showMuteOptions = false;
        _setChatMute(true, null);
      case 'filter-content':
        // TODO(marwan): send request to backend to filter content for this group
        showToastMessage('Filter content');
        break;
      default:
        showToastMessage("No Bueno");
    }
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
      editMessage = null;
    });
  }

  void _onEdit(MessageModel message) {
    setState(() {
      debugPrint('edit');
      editMessage = message;
      replyMessage = null;
      debugPrint(message.content?.getContent());
      _messageController.text =
          message.content?.getContent() ?? 'what about this';
      debugPrint('${_messageController.text} look here');
    });
  }
}
