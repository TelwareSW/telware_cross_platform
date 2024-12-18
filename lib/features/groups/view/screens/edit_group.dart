import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telware_cross_platform/features/groups/view/screens/members_screen.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'dart:typed_data';
import '../../../../core/constants/keys.dart';
import '../../../../core/constants/server_constants.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/token_provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/palette.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/utils.dart';
import '../../../chat/view/widget/member_tile_widget.dart';
import '../../../chat/view_model/chats_view_model.dart';
import '../../../stories/utils/utils_functions.dart';
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
import 'add_members_screen.dart';
import 'package:http/http.dart' as http;


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
  Uint8List? imageBytes;
  bool isPublic = true;
  bool isOpen = true;
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
    imageBytes = widget.chatModel.photoBytes;
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
            "icon": Icons.group,
            "text": 'Members',
            "trailing": "3",
            "routes": MembersScreen.route,
            "extra": widget.chatModel,
          },
        ],
        "trailing": ""
      },
    ];
  }

  Future<void> updatePrivacy() async {
    final String url = '$API_URL/chats/privacy/${widget.chatModel.id!}';
    try {
      Map<String, dynamic> data = {
        "privacy": isPublic ==true ? "public":"private",
      };
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'X-Session-Token': ref.read(tokenProvider)??''
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        print('Privacy updated successfully: ${response.body}');
      } else {
        print('Privacy updated Failed: ${response.body}');
        print('Failed to update privacy: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors, such as no internet connection
      print('Error occurred: $e');
    }
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
              ref.read(chattingControllerProvider).setPermissions(
                  chatId: widget.chatModel.id!,
                  type: 'post',
                  who: isOpen == true ? "everyone" : "admin",
                  onEventComplete: (res) {
                    if (res['success'] == true) {
                      debugPrint('Group premissions set successfully');
                    } else {
                      debugPrint('Failed to Edit group settings');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to Edit group settings'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
              updatePrivacy();
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
                          imageBytes != null ? MemoryImage(imageBytes!) : null,
                      backgroundColor: imageBytes == null
                          ? getRandomColor(widget.chatModel.title)
                          : null,
                      child: imageBytes == null
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
              onTap: () async {
                File? file = await pickImageFromGallery();
                if (file != null) {
                  Uint8List localImageBytes = await file.readAsBytes();
                  await uploadChatImage(
                      file,
                      '$API_URL/chats/picture/${widget.chatModel.id}',
                      ref.read(tokenProvider) ?? '');
                  setState(() {
                    imageBytes = localImageBytes;
                    widget.chatModel.copyWith(photoBytes: imageBytes);
                    ref.read(chattingControllerProvider).getUserChats();
                  });
                }
              },
              key: ValueKey(
                  "set-profile-photo${WidgetKeys.settingsOptionSuffix.value}"),
              icon: Icons.camera_alt_outlined,
              iconColor: Palette.primary,
              text: "Set Profile Photo",
              color: Palette.primary,
              showDivider: true,
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
                            Icons.group,
                            color: Palette.accentText,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Group Type',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPublic = !isPublic;
                            print(isPublic ? 'Public' : 'Private');
                          });
                        },
                        child: Text(
                          isPublic == true ? 'Public' : 'Private',
                          style: const TextStyle(
                            color: Palette.primary,
                          ),
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
                            Icons.key,
                            color: Palette.accentText,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Who can Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isOpen = !isOpen;
                          });
                        },
                        child: Text(
                          isOpen == true ? 'Anyone' : 'Admins',
                          style: const TextStyle(
                            color: Palette.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
