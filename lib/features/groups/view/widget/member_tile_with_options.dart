import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/profile_avatar_widget.dart';
import 'dart:typed_data';

import '../../../../core/models/chat_model.dart';
import '../../../chat/view_model/chatting_controller.dart';

class MemberTileWithOptions extends ConsumerStatefulWidget {
  final String? imagePath;
  final String text;
  final String subtext;
  final String? moreInfo;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showSelected;
  final bool showMenu;
  final String userId;
  final String chatId;
  final BuildContext context;

  const MemberTileWithOptions({
    super.key,
    this.imagePath,
    required this.text,
    required this.subtext,
    this.moreInfo,
    this.onTap,
    this.showDivider = true,
    this.showSelected = false,
    this.showMenu = true,
    required this.userId,
    required this.chatId,
    required this.context,
  });

  @override
  ConsumerState<MemberTileWithOptions> createState() =>
      _MemberTileWithOptionsState();
}

class _MemberTileWithOptionsState extends ConsumerState<MemberTileWithOptions> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.optionsHorizontalPad, vertical: 6.0),
        child: Row(
          children: [
            Stack(
              children: [
                ProfileAvatarWidget(
                  text: widget.text,
                  imagePath: widget.imagePath,
                ),
                if (widget.showSelected)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Palette.valid,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Palette.secondary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Palette.primaryText,
                        size: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Palette.primaryText,
                        ),
                      ),
                      const Spacer(),
                      if (widget.moreInfo != null)
                        Text(
                          widget.moreInfo!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Palette.accent,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    widget.subtext,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Palette.accentText,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  if (widget.showDivider)
                    const Divider(color: Palette.secondary),
                ],
              ),
            ),
            widget.showMenu
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'option1') {
                        onOption1Selected();
                      } else if (value == 'option2') {
                        onOption2Selected();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'option1',
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text('Promote to admin'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'option2',
                          child: Row(
                            children: [
                              Icon(
                                Icons.highlight_off_outlined,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Remove from group',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                    icon: const Icon(
                      Icons.more_vert,
                      color: Palette.accent,
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> onOption1Selected() async {
    await ref.read(chattingControllerProvider).addAdmin(
      chatId: widget.chatId,
      members: [widget.userId],
      onEventComplete: (res) async {
        if (res['success'] == true) {
          debugPrint('Group admin successfully');
        } else {
          debugPrint('Failed to make admin');
          ScaffoldMessenger.of(widget.context).showSnackBar(
            const SnackBar(
              content: Text('Failed to make admin'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Future<void> onOption2Selected() async {
    await ref.read(chattingControllerProvider).removeMember(
      chatId: widget.chatId,
      members: [widget.userId],
      onEventComplete: (res) async {
        if (res['success'] == true) {
          debugPrint('removed successfully');
        } else {
          debugPrint('Failed to make admin');
          ScaffoldMessenger.of(widget.context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove member'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
