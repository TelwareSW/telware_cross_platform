import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/keys.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/palette.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/utils.dart';
import '../../../chat/view/widget/member_tile_widget.dart';
import '../../../chat/view_model/chats_view_model.dart';
import '../../../user/view/screens/blocked_users.dart';
import '../../../user/view/screens/invites_permissions_screen.dart';
import '../../../user/view/screens/last_seen_privacy_screen.dart';
import '../../../user/view/screens/phone_privacy_screen.dart';
import '../../../user/view/screens/profile_photo_privacy_screen.dart';
import '../../../user/view/screens/self_destruct_screen.dart';
import '../../../user/view/widget/settings_option_widget.dart';
import '../../../user/view/widget/settings_section.dart';
import '../../../user/view/widget/toolbar_widget.dart';
import '../widget/emoji_only_picker_widget.dart';

class EditGroup extends ConsumerStatefulWidget {
  static const String route = 'edit-chat';
  final ChatModel chatModel;
  const EditGroup({super.key, required this.chatModel});

  @override
  ConsumerState<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends ConsumerState<EditGroup> {
  late List<Map<String, dynamic>> profileSections;
  final GlobalKey _widgetKey = GlobalKey();
  late FocusNode _textFieldFocusNode;
  late FocusNode _descriptionTextFieldFocusNode;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
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

  Future<List<UserModel?>> getUsersInfo() async {
    final ChatModel chat = widget.chatModel;
    final List<UserModel?> users = [];
    for (final String userId in chat.userIds) {
      final UserModel? user =
          await ref.read(chatsViewModelProvider.notifier).getUser(userId);
      users.add(user);
    }
    return users;
  }

  @override
  void initState() {
    super.initState();
    searchController.text = widget.chatModel.title;
    _textFieldFocusNode = FocusNode();
    _descriptionTextFieldFocusNode = FocusNode();
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

  void _updateDependencies(UserModel? user) {
    profileSections = [
      {
        "title": "",
        "options": [
          {"icon": Icons.group, "text": 'Group Type', "trailing": "Private"},
          {
            "icon": Icons.chat_outlined,
            "text": 'Chat History',
            "trailing": "Hidden",
            "routes": SelfDestructScreen.route
          },
        ],
        "trailing": ""
      },
      {
        "title": "",
        "options": [
          {
            "icon": FontAwesomeIcons.heart,
            "text": 'Reactions',
            "trailing": "All",
            "routes": SelfDestructScreen.route
          },
          {
            "icon": FontAwesomeIcons.key,
            "text": 'Permissions',
            "trailing": "13/13",
            "routes": SelfDestructScreen.route
          },
          {
            "icon": FontAwesomeIcons.link,
            "text": 'Invite Links',
            "trailing": "1",
            "routes": SelfDestructScreen.route
          },
          {
            "icon": FontAwesomeIcons.shield,
            "text": 'Administrators',
            "trailing": "1",
            "routes": SelfDestructScreen.route
          },
          {
            "icon": Icons.group,
            "text": 'Members',
            "trailing": "3",
            "routes": SelfDestructScreen.route
          },
        ],
        "trailing": ""
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    _updateDependencies(user);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.secondary,
        title: const Text(
          'Edit',
          style: TextStyle(
            color: Palette.primaryText,
            fontSize: Sizes.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // make the logic
              context.pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Palette.secondary,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                      widget.chatModel.photoBytes != null ? MemoryImage(widget.chatModel.photoBytes!) : null,
                      backgroundColor:
                      widget.chatModel.photoBytes == null ? getRandomColor(widget.chatModel.title) : null,
                      child: widget.chatModel.photoBytes == null
                          ? Text(
                        getInitials(widget.chatModel.title),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Palette.primaryText,
                        ),
                      )
                          : null,
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
                              focusedBorder:
                                  InputBorder.none, // No border when focused
                              hintStyle: const TextStyle(color: Colors.white54),
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
            SettingsOptionWidget(
              key: ValueKey(
                  "set-profile-photo${WidgetKeys.settingsOptionSuffix.value}"),
              icon: Icons.camera_alt_outlined,
              iconColor: Palette.primary,
              text: "Set Profile Photo",
              color: Palette.primary,
              showDivider: true,
            ),
            Container(
              color: Palette.secondary,
              child:TextField(
                focusNode: _descriptionTextFieldFocusNode,
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  border: InputBorder.none, // No border
                  enabledBorder: InputBorder
                      .none, // No border when not focused
                  focusedBorder:
                  InputBorder.none, // No border when focused
                  hintStyle: const TextStyle(color: Palette.inactiveSwitch),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                ),
              ),
            ),
            SizedBox(height: Dimensions.sectionGaps),
            ...List.generate(profileSections.length, (index) {
              final section = profileSections[index];
              final title = section["title"] ?? "";
              final options = section["options"];
              final trailing = section["trailing"] ?? "";
              return Column(
                children: [
                  SettingsSection(
                    title: title,
                    settingsOptions: options,
                    trailing: trailing,
                  ),
                  const SizedBox(height: Dimensions.sectionGaps),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
