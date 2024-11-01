import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:telware_cross_platform/features/stories/view/widget/stacked_overlapped_images.dart';

import '../../../../core/theme/palette.dart';
import '../../models/contact_model.dart';
class BottomActionsStoryScreen extends StatelessWidget {
  const BottomActionsStoryScreen({
    super.key,
    required this.showSeens,
    required this.focusNode,
    required this.seenIds,
    required this.seensUsers,
  });

  final bool showSeens;
  final FocusNode focusNode;
  final List<String> seenIds;
  final List<ContactModel> seensUsers;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: showSeens == false
                  ? TextField(
                onTap: () {
                  focusNode.requestFocus();
                  // Assuming you have an animation controller
                  // indicatorAnimationController.value = IndicatorAnimationCommand.pause;
                },
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Palette.accentText),
                  hintText: 'Reply privately...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
                ),
              )
                  : Row(
                children: [
                  seenIds.isEmpty
                      ? const Text(
                    'No views yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  )
                      : Row(
                    children: [
                      StackedOverlappedImages(
                        users: seensUsers,
                        showBorder: false,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${seenIds.length} views',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.share),
              onPressed: () {},
            ),
            showSeens == false
                ? IconButton(
              icon: const FaIcon(FontAwesomeIcons.heart),
              onPressed: () {},
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}