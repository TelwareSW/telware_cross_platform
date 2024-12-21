import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/highlight_text_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:telware_cross_platform/features/user/view/widget/avatar_generator.dart';

class ChatTileWidget extends ConsumerStatefulWidget {
  const ChatTileWidget({
    super.key,
    required this.chatModel,
    required this.displayMessage,
    required this.sentByUser,
    required this.senderID,
    this.highlights = const [],
    this.titleHighlights = const [],
    this.showDivider = true,
    required this.onChatSelected,
    this.isMessageDisplayed = true,
    this.isForwarding = false,
  });

  final ChatModel chatModel;
  final MessageModel displayMessage;
  final String senderID;
  final bool showDivider;
  final bool sentByUser;
  final Function(ChatModel) onChatSelected;
  final bool isMessageDisplayed;
  final bool isForwarding;

  final List<MapEntry<int, int>> highlights;
  final List<MapEntry<int, int>> titleHighlights;

  @override
  ConsumerState<ChatTileWidget> createState() => _ChatTileWidget();
}

class _ChatTileWidget extends ConsumerState<ChatTileWidget> {
  // create getter
  late ChatModel chatModel;
  late MessageModel displayMessage;
  late String senderID;
  late bool sentByUser;
  late bool showDivider;

  @override
  void initState() {
    super.initState();
    chatModel = widget.chatModel;
    displayMessage = widget.displayMessage;
    senderID = widget.senderID;
    sentByUser = widget.sentByUser;
    showDivider = widget.showDivider;
  }

  String _getDisplayText(MessageContentType displayMessageContentType) {
    if (chatModel.draft?.isNotEmpty ?? false) {
      return chatModel.draft!;
    }
    String content = "";
    if (displayMessage.content?.getContent().isNotEmpty ?? false) {
      content = ": ${displayMessage.content?.getContent()}";
    }
    switch (displayMessageContentType) {
      case MessageContentType.text:
        return displayMessage.content?.getContent() ?? "";
      case MessageContentType.image:
        return "Photo$content";
      case MessageContentType.video:
        return "Video$content";
      case MessageContentType.audio:
        return "Voice message$content";
      case MessageContentType.file:
        return "File$content";
      case MessageContentType.sticker:
        return "Sticker$content";
      case MessageContentType.emoji:
        return "Emoji$content";
      case MessageContentType.GIF:
        return "GIF$content";
      case MessageContentType.link:
        return "Link$content";
      default:
        return "Unknown";
    }
  }

  Widget displayedMessage(
    String keyValue,
    bool hasDraft,
    bool isGroupChat,
    String senderName,
    int unreadCount,
    bool isMentioned,
    MessageContentType displayMessageContentType,
  ) {
    return Row(
      children: [
        // Displayed message content
        Expanded(
          child: RichText(
            key: ValueKey(
                "$keyValue${ChatKeys.chatTileDisplayTextPostfix.value}"),
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              children: [
                TextSpan(
                  text: hasDraft
                      ? "Draft: "
                      : !isGroupChat || ref.read(userProvider)?.isAdmin == true
                          ? ""
                          : sentByUser
                              ? "You: "
                              : "$senderName: ",
                  style: TextStyle(
                    color: hasDraft
                        ? Palette.banned
                        : isGroupChat
                            ? Palette.primaryText
                            : Palette.accentText,
                    fontWeight: hasDraft ? FontWeight.bold : null,
                  ),
                ),
                WidgetSpan(
                  child: HighlightTextWidget(
                    text: _getDisplayText(
                      displayMessageContentType,
                    ),
                    normalStyle: TextStyle(
                      color: hasDraft ||
                              displayMessageContentType ==
                                  MessageContentType.text ||
                              widget.highlights.isNotEmpty
                          ? Palette.accentText
                          : Palette.accent,
                      fontStyle: FontStyle.normal,
                    ),
                    highlightStyle: const TextStyle(
                      color: Palette.primary,
                      backgroundColor: Colors.transparent,
                    ),
                    highlights: widget.highlights,
                    overFlow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Add spacing between message content and unread count

        if (unreadCount > 0) ...[
          if (isMentioned)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                key: ValueKey(
                    "$keyValue${ChatKeys.chatTileMentionPostfix.value}"),
                Icons.alternate_email_rounded,
                size: 18,
                color: Palette.primary,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Palette.accent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                key: ValueKey(
                    "$keyValue${ChatKeys.chatTileDisplayUnreadCountPostfix.value}"),
                unreadCount.toString(),
                style: const TextStyle(
                  color: Palette.primaryText,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future:
          ref.watch(chatsViewModelProvider.notifier).getUser(widget.senderID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Skeletonizer(
            child: _tileBody(
                '',
                28.0,
                chatModel.photoBytes,
                false,
                false,
                false,
                "Skeletonizer",
                3,
                false,
                displayMessage.messageContentType,
                isSkeleton: true),
          ); // Or any placeholder widget
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final UserModel sender = snapshot.data!;
          final senderName = sender.screenFirstName.isEmpty
              ? sender.username
              : sender.screenFirstName;
          final keyValue = (widget.key as ValueKey).value;
          final imageBytes = chatModel.photoBytes;
          final hasDraft = chatModel.draft?.isNotEmpty ?? false;
          final isGroupChat = chatModel.type == ChatType.group;
          final unreadCount = _getUnreadMessageCount();
          final isMuted = chatModel.isMuted;
          final isMentioned = chatModel.isMentioned;
          final displayMessageContentType = displayMessage.messageContentType;
          const avatarWidth = 28.0;

          return widget.isForwarding
              ? _tileBody(
                  keyValue,
                  avatarWidth,
                  imageBytes,
                  isMuted,
                  hasDraft,
                  isGroupChat,
                  senderName,
                  unreadCount,
                  isMentioned,
                  displayMessageContentType,
                )
              : InkWell(
                  onTap: () {
                    // Get the width of the screen
                    double width = MediaQuery.of(context).size.width;

                    // Check if the width is greater than 600
                    if (width > 600) {
                      // Handle wider screens (e.g., tablets or large phones in landscape mode)
                      widget.onChatSelected(chatModel);
                    } else {
                      // Handle smaller screens (e.g., phones in portrait or smaller landscape)

                      if (ref.read(userProvider)?.isAdmin == true) {
                        filterConfirmationDialog(
                          chatModel.isFiltered ? 'UnFilter' : 'Filter',
                          chatModel.title,
                          chatId: chatModel.id,
                        );
                      } else {
                        context.push(Routes.chatScreen,
                            extra: chatModel.id ?? chatModel);
                      }
                    }
                  },
                  child: _tileBody(
                    keyValue,
                    avatarWidth,
                    imageBytes,
                    isMuted,
                    hasDraft,
                    isGroupChat,
                    senderName,
                    unreadCount,
                    isMentioned,
                    displayMessageContentType,
                  ),
                );
        } else {
          return const Text('No user data available'); // Handle no data state
        }
      },
    );
  }

  Container _tileBody(
      keyValue,
      double avatarWidth,
      Uint8List? imageBytes,
      bool isMuted,
      bool hasDraft,
      bool isGroupChat,
      String senderName,
      int unreadCount,
      bool isMentioned,
      MessageContentType displayMessageContentType,
      {bool isSkeleton = false}) {
    return Container(
      color: Palette.secondary,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: 12.0, left: 12.0, top: 8.0, bottom: 8.0),
                child: CircleAvatar(
                  key: ValueKey("$keyValue${ChatKeys.chatAvatarPostfix.value}"),
                  radius: avatarWidth,
                  backgroundImage:
                      imageBytes != null ? MemoryImage(imageBytes) : null,
                  backgroundColor: imageBytes == null ? Palette.primary : null,
                  child: imageBytes == null
                      ? AvatarGenerator(
                          name: isSkeleton ? '' : chatModel.title,
                          backgroundColor: getRandomColor(),
                          size: 100,
                        )
                      : null,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14.0, bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: HighlightTextWidget(
                                  key: ValueKey(
                                      "$keyValue${ChatKeys.chatNamePostfix.value}"),
                                  text: chatModel.title,
                                  overFlow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  normalStyle: const TextStyle(
                                    color: Palette.primaryText,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  highlightStyle: const TextStyle(
                                    color: Palette.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  highlights: widget.titleHighlights,
                                ),
                              ),
                              if (isMuted)
                                Padding(
                                  padding: const EdgeInsets.only(right: 2.0),
                                  child: Icon(
                                    key: ValueKey(
                                        "$keyValue${ChatKeys.chatTileMutePostfix.value}"),
                                    Icons.volume_off,
                                    size: 18,
                                    color: Palette.inactiveSwitch,
                                  ),
                                ),
                              if (sentByUser)
                                Padding(
                                  padding: const EdgeInsets.only(right: 2.0),
                                  child: Icon(
                                    key: ValueKey(
                                        "$keyValue${ChatKeys.chatTileMessageStatusPostfix.value}"),
                                    getMessageStateIcon(displayMessage),
                                    size: 16,
                                    color: Palette.accent,
                                  ),
                                ),
                              Text(
                                key: ValueKey(
                                    "$keyValue${ChatKeys.chatTileDisplayTimePostfix.value}"),
                                formatTimestamp(displayMessage.timestamp),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          if (widget.isMessageDisplayed) ...[
                            displayedMessage(
                              keyValue,
                              hasDraft,
                              isGroupChat,
                              senderName,
                              unreadCount,
                              isMentioned,
                              displayMessageContentType,
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showDivider) const Divider(),
        ],
      ),
    );
  }

  int _getUnreadMessageCount() {
    final random = Random();
    return random.nextInt(3); // Generate random number between 0 and 10
  }

  void filterConfirmationDialog(String action, String chatName,
      {String? chatId}) {
    showConfirmationDialog(
      context: context,
      title: 'Filter chat',
      titleFontWeight: FontWeight.normal,
      titleColor: Palette.primaryText,
      titleFontSize: 18.0,
      subtitle: 'Are you sure you want to $action $chatName?',
      subtitleFontWeight: FontWeight.bold,
      subtitleFontSize: 16.0,
      contentGap: 20.0,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      confirmText: action,
      confirmColor: const Color.fromRGBO(238, 104, 111, 1),
      confirmPadding: const EdgeInsets.only(left: 40.0),
      cancelText: 'Cancel',
      cancelColor: const Color.fromRGBO(100, 181, 239, 1),
      onConfirm: () async {
        if (chatId != null) {
          if (action == 'Filter') {
            await ref
                .read(chattingControllerProvider)
                .filterGroup(chatId: chatId);
          } else {
            await ref
                .read(chattingControllerProvider)
                .unFilterGroup(chatId: chatId);
          }
        }
        if (mounted) {
          context.pop();
        }
      },
      onCancel: () {
        context.pop();
      },
    );
  }
}
