import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/palette.dart';
class EmojiOnlyPickerWidget extends StatelessWidget {
  EmojiOnlyPickerWidget({
    super.key,
    required this.textEditingController,
    required this.emojiShowing,
    this.onEmojiSelected,
    this.onBackspacePressed,
  });

  final TextEditingController textEditingController;
  final bool emojiShowing;
  final void Function(Category? category, Emoji? emoji)? onEmojiSelected;
  final void Function()? onBackspacePressed;
  final _scrollController = ScrollController();

  Widget tabBarName(String name) {
    return Container(
      width: 80,
      height: 30,
      padding:
      const EdgeInsets.only(top: 0.0, bottom: 0.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        // color: const Color.fromRGBO(34, 50, 66, 1),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !emojiShowing,
      child: SizedBox(
        height: 300, // Adjust height as needed
        child: DefaultTabController(
          length: 3, // Number of tabs
          child: Column(
            children: [
              // Tab View
              EmojiPicker(
                textEditingController: textEditingController,
                scrollController: _scrollController,
                config: const Config(
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28,
                    backgroundColor: Palette.trinary,
                  ),
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: Palette.trinary,
                    dividerColor: Palette.trinary,
                    iconColor: Palette.accentText,
                    extraTab: CategoryExtraTab.SEARCH,
                  ),
                  bottomActionBarConfig: BottomActionBarConfig(
                    backgroundColor: Palette.trinary,
                    buttonColor: Palette.trinary,
                    buttonIconColor: Palette.accentText,
                    showSearchViewButton: false,
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: Palette.trinary,
                    buttonIconColor: Palette.accentText,
                  ),
                ),
                onEmojiSelected: onEmojiSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}