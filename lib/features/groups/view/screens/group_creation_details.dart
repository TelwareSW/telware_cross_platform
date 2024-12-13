import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/stories/view/screens/add_my_image_screen.dart';

import '../../../../core/theme/palette.dart';
import '../../../../core/theme/sizes.dart';
import '../../../chat/view/screens/chat_screen.dart';
import '../../../chat/view/widget/member_tile_widget.dart';
import '../../../chat/view_model/chatting_controller.dart';
import '../../../stories/view/widget/pick_from_gallery.dart';
import '../widget/emoji_only_picker_widget.dart';

class GroupCreationDetails extends ConsumerStatefulWidget {
  static const String route = 'group-creation-details';
  final List<UserModel> members;
  const GroupCreationDetails({super.key, required this.members});

  @override
  ConsumerState<GroupCreationDetails> createState() =>
      _GroupCreationDetailsState();
}

class _GroupCreationDetailsState extends ConsumerState<GroupCreationDetails> {
  final GlobalKey _widgetKey = GlobalKey();
  late FocusNode _textFieldFocusNode;
  final TextEditingController searchController = TextEditingController();
  bool _isEmojiKeyboardVisible = false;
  bool _quickDeleteVisible = false;
  File? groupImage;
  int autoDelete = -1;
  late RenderBox renderBox;
  late Offset offset;

  String _makeIntialName(List<UserModel> members) {
    String name = "";
    if (ref.read(userProvider)?.screenFirstName == null) {
      name += 'noName';
    } else {
      name += ref.read(userProvider)!.screenFirstName;
    }
    for (var user in members) {
      name += " and ";
      name += user.screenFirstName;
    }
    return name;
  }

  @override
  void initState() {
    super.initState();
    searchController.text = _makeIntialName(widget.members);
    _textFieldFocusNode = FocusNode();
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        setState(() {
          _isEmojiKeyboardVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: Palette.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Text(
                    'Auto-delete after ...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: ListWheelScrollView(
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        if (index >= 0 && index < 6) {
                          autoDelete = index + 1;
                        } else if (index >= 6 && index < 9) {
                          autoDelete = (index - 5) * 7;
                        } else if (index >= 9 && index < 15) {
                          autoDelete = (index - 8) * 30;
                        } else if (index == 15) {
                          autoDelete = 365;
                        } else if (index == 16) {
                          autoDelete = -1;
                        }
                      });
                    },
                    itemExtent: 50,
                    children: [
                      for (int i = 1; i <= 6; i++)
                        GestureDetector(
                          onTap: () {},
                          child: ListTile(
                            title: Center(
                                child: Text('$i day${i > 1 ? 's' : ''}')),
                          ),
                        ),
                      for (int i = 1; i <= 3; i++)
                        GestureDetector(
                          onTap: () {},
                          child: ListTile(
                            title: Center(
                                child: Text('$i week${i > 1 ? 's' : ''}')),
                          ),
                        ),
                      for (int i = 1; i <= 6; i++)
                        GestureDetector(
                          onTap: () {},
                          child: ListTile(
                            title: Center(
                                child: Text('$i month${i > 1 ? 's' : ''}')),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {},
                        child: ListTile(
                          title: Center(child: const Text('1 year')),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: ListTile(
                          title: Center(child: const Text('Disable')),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Palette.primary,
                          borderRadius: BorderRadius.circular(20)),
                      width: double.infinity,
                      height: 50,
                      child: Center(
                        child: Text(
                          'Set Auto-Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<File?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      return File(pickedImage.path);
    } else {
      debugPrint("No image selected.");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print(
              'group name ${searchController.text} \n image ${groupImage} \n members ${widget.members}');
          List<String> membersIds = widget.members
              .where((user) => user.id != null)
              .map((user) => user.id!)
              .toList();
          await ref.read(chattingControllerProvider).createGroup(
            type: 'group',
            name: searchController.text,
            members: membersIds,
            onEventComplete: (res) async {
            if (res['success'] == true) {
              debugPrint('Group created successfully');
              final members = res['data']['members'] as List;
              List<String> userIds = members.map((member) => member['user'] as String).toList();
              final ChatModel chat = ChatModel(title: res['data']['name'], userIds: userIds, type: res['data']['type'] == 'group' ? ChatType.group:ChatType.channel, messages: []);
              debugPrint('Opening Chat: $chat');
              context.push(ChatScreen.route, extra: chat);
            } else {
              debugPrint('Failed to create group');
              // Show a SnackBar if group creation failed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to create group'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          );
        },
        backgroundColor: Palette.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.check),
      ),
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.secondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'New Group',
          style: TextStyle(
            color: Palette.primaryText,
            fontSize: Sizes.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_quickDeleteVisible) {
            setState(() {
              _quickDeleteVisible = false;
              print(_quickDeleteVisible);
            });
          }
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    color: Palette.secondary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() async {
                                groupImage = await pickImageFromGallery();
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: Palette.primary,
                              radius: 35,
                              child: groupImage == null
                                  ? const Icon(
                                      Icons.add_a_photo,
                                      size: 30,
                                    )
                                  : ClipOval(
                                      child: Image.file(
                                        groupImage!,
                                        width:
                                            70, // Match the CircleAvatar diameter (2 * radius).
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  focusNode: _textFieldFocusNode,
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // No border
                                    enabledBorder: InputBorder
                                        .none, // No border when not focused
                                    focusedBorder: InputBorder
                                        .none, // No border when focused
                                    hintStyle:
                                        const TextStyle(color: Colors.white54),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 10.0),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isEmojiKeyboardVisible == true
                                            ? Icons.keyboard
                                            : Icons.emoji_emotions_outlined,
                                        color: Palette.accentText,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isEmojiKeyboardVisible =
                                              !_isEmojiKeyboardVisible;
                                          if (_isEmojiKeyboardVisible) {
                                            FocusScope.of(context).unfocus();
                                            if (_isEmojiKeyboardVisible) {
                                              FocusScope.of(context)
                                                  .unfocus(); // Hide system keyboard
                                            }
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 2,
                                  color: Palette.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    color: Palette.secondary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Palette.accentText,
                              ),
                              SizedBox(width: 15),
                              Text(
                                'Auto-Delete Messages',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                          GestureDetector(
                            key: _widgetKey,
                            onTap: () {
                              setState(() {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  RenderBox renderBox = _widgetKey
                                      .currentContext
                                      ?.findRenderObject() as RenderBox;
                                  offset = renderBox.localToGlobal(Offset.zero);
                                  print(
                                      "Absolute position on screen: ${offset.dx}, ${offset.dy}");
                                  print(_quickDeleteVisible);
                                  _quickDeleteVisible = !_quickDeleteVisible;
                                });
                              });
                            },
                            child: Text(
                              autoDelete == -1 ? 'off' : '${autoDelete}  day',
                              style: const TextStyle(
                                color: Palette.primary,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Text(
                        'Automatically delete messages in this group for everyone after period of time.',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            '${widget.members.length} members',
                            style: TextStyle(
                                color: Palette.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap:
                                true, // To allow proper layout within parent widgets
                            itemCount: widget.members.length,
                            itemBuilder: (context, index) {
                              UserModel user = widget.members[index];
                              return MemberTileWidget(
                                text:
                                    '${user.screenFirstName} ${user.screenLastName}',
                                subtext: user.status,
                                imagePath: user.photo,
                                onTap: () => () {},
                                showSelected: false,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isEmojiKeyboardVisible)
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                child: EmojiOnlyPickerWidget(
                  textEditingController: searchController,
                  emojiShowing: _isEmojiKeyboardVisible,
                ),
              ),
            if (_quickDeleteVisible)
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Material(
                  color: Colors.transparent,
                  child: Builder(
                    builder: (BuildContext context) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showMenu<int>(
                          context: context,
                          position:
                              RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
                          items: [
                            PopupMenuItem<int>(
                              value: 1,
                              child: const Text('1 day'),
                              onTap: () {
                                setState(() {
                                  _quickDeleteVisible = false;
                                  autoDelete = 1;
                                });
                              },
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: const Text('1 week'),
                              onTap: () {
                                setState(() {
                                  _quickDeleteVisible = false;
                                  autoDelete = 7;
                                });
                              },
                            ),
                            PopupMenuItem<int>(
                              value: 3,
                              child: const Text('1 month'),
                              onTap: () {
                                setState(() {
                                  _quickDeleteVisible = false;
                                  autoDelete = 30;
                                });
                              },
                            ),
                            PopupMenuItem<int>(
                              value: 4,
                              child: const Text('Set custom time'),
                              onTap: () {
                                setState(() {
                                  _quickDeleteVisible = false;
                                  showCustomBottomSheet(context);
                                });
                              },
                            ),
                            if (autoDelete != -1)
                              PopupMenuItem<int>(
                                value: 5,
                                child: const Text('Disable'),
                                onTap: () {
                                  setState(() {
                                    _quickDeleteVisible = false;
                                    autoDelete = -1;
                                  });
                                },
                              ),
                          ],
                          elevation: 8.0,
                        );
                      });
                      return Container();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
