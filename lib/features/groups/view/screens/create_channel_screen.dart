import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';

import '../../../../core/theme/palette.dart';
import '../../../../core/theme/sizes.dart';

class CreateChannelScreen extends StatefulWidget {
  static const String route = '/create-channel-screen';

  CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? groupImage;
  String channelName = "";
  String channelDescription = "";

  late FocusNode nameFocusNode;
  late FocusNode descriptionFocusNode;

  bool _isEmojiKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();

    nameFocusNode.addListener(() {
      if (nameFocusNode.hasFocus) {
        setState(() {
          _isEmojiKeyboardVisible = false;
        });
      }
    });

    descriptionFocusNode.addListener(() {
      if (descriptionFocusNode.hasFocus) {
        setState(() {
          _isEmojiKeyboardVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<File?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      return File(pickedImage.path);
    } else {
      debugPrint("No image selected.");
      return null;
    }
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'New Channel',
          style: TextStyle(
            color: Palette.primaryText,
            fontSize: Sizes.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Palette.primaryText,
            ),
            onPressed: () {
              if (channelName.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Channel name cannot be empty!',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                context.push(
                  Routes.channelSettingsScreen,
                  extra: {
                    'channelName': channelName,
                    'channelDescription': channelDescription,
                    'channelImage': null,
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Container(
              color: Palette.background,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final image = await pickImageFromGallery();
                        setState(() {
                          groupImage = image;
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
                            width: 70,
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
                            onChanged: (value) {
                              setState(() {
                                channelName = value;
                              });
                            },
                            focusNode: nameFocusNode,
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Channel name',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintStyle: const TextStyle(color: Colors.white54),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 10.0,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isEmojiKeyboardVisible
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
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      channelDescription = value;
                    });
                  },
                  focusNode: descriptionFocusNode,
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white54),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 10.0,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 2,
                  color: Palette.secondary,
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'You can provide an optional description for your channel',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
