import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';

class EmojiPickerWidget extends StatelessWidget {
  EmojiPickerWidget({
    super.key,
    required this.textEditingController,
    required this.emojiShowing,
    required this.onSelectedMedia,
    this.onEmojiSelected,
    this.onBackspacePressed,
  });

  final TextEditingController textEditingController;
  final bool emojiShowing;
  final void Function(Category? category, Emoji? emoji)? onEmojiSelected;
  final void Function(String filePath, String type) onSelectedMedia;
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
              Expanded(
                child: TabBarView(
                  children: [
                    // Emojis Tab
                    EmojiPicker(
                      key: GlobalKeyCategoryManager.addKey('emojiPicker'),
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
                    // GIFs Tab
                    GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Number of stickers per row
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: gifs.length,
                      itemBuilder: (context, index) {
                        final gifPath = gifs[index];
                        return GestureDetector(
                          key: GlobalKeyCategoryManager.addKey('gifPicker'),
                          onTap: () {
                            onSelectedMedia(gifPath, 'GIF');
                          },
                          child: Image.asset(
                            gifPath,
                            width: 20,
                            height: 20,
                          ),
                        );
                      },
                    ),
                    // Stickers Tab
                    GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6, // Number of stickers per row
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: lottieAnimations.length,
                      itemBuilder: (context, index) {
                        final stickerPath = lottieAnimations[index];
                        return LottieViewer(
                          path: stickerPath,
                          lottieKey:
                              GlobalKeyCategoryManager.addKey('stickerPicker'),
                          width: 10,
                          height: 10,
                          onTap: () {
                            onSelectedMedia(stickerPath, 'sticker');
                          },
                          isLooping: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
              TabBar(
                key: GlobalKeyCategoryManager.addKey('emojiPickerTabBar'),
                dividerHeight: 0,
                labelColor: Palette.accent,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Palette.primary,
                  height: 0.0,
                ),
                indicatorWeight: 0,
                indicatorPadding: const EdgeInsets.all(0),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: const Color.fromRGBO(34, 50, 66, 1),
                ),
                tabs: [
                  Tab(
                    child: tabBarName("Emojis"),
                  ),
                  Tab(
                    child: tabBarName("GIFs"),
                  ),
                  Tab(
                    child: tabBarName("Stickers"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<String> lottieAnimations = [
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
  final List<String> gifs = [
    'assets/gifs/angry-birds-parak.gif',
    'assets/gifs/cat-vibing-cat.gif',
    'assets/gifs/catpop.gif',
    'assets/gifs/change-number.gif',
    'assets/gifs/potato-fox-from-telegram-bouncing.gif',
    'assets/gifs/self-destruct-timer.gif',
    'assets/gifs/shut-up-i-want-you-to-shut-up.gif',
    'assets/gifs/team-nn.gif',
    'assets/gifs/telegram-russian-ban.gif',
    'assets/gifs/utya-utya-duck.gif',
  ];
}
