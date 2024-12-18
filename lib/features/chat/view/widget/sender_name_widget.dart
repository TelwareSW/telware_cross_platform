import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';

class SenderNameWidget extends ConsumerStatefulWidget {
  final bool showInfo, isSentByMe;
  final String userId;
  final dynamic keyValue;
  final Color nameColor;

  const SenderNameWidget(
    this.keyValue,
    this.nameColor, {
    super.key,
    required this.showInfo,
    required this.isSentByMe,
    required this.userId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SenderNameWidgetState();
}

class _SenderNameWidgetState extends ConsumerState<SenderNameWidget> {
  bool showName = false;
  String otherUserName = '';

  @override
  void initState() {
    super.initState();
    _getName();
  }

  Future<void> _getName() async {
    if (widget.showInfo && !widget.isSentByMe) {
      final user = (await ref
          .read(chatsViewModelProvider.notifier)
          .getUser(widget.userId));
      setState(() {
        otherUserName = '${user!.screenFirstName} ${user.screenLastName}';
        showName = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget senderNameWidget = (widget.isSentByMe  || !widget.showInfo)
        ? const SizedBox.shrink()
        : Text(
            key: ValueKey(
                '${widget.keyValue}${MessageKeys.messageSenderPostfix.value}'),
            otherUserName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.nameColor,
              fontSize: 12,
            ),
          );
    return senderNameWidget;
  }
}