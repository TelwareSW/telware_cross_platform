import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/contact_view_model.dart';
class BottomActionButtonsEditTakenImage extends StatelessWidget {
  final VoidCallback cropImage;
  final VoidCallback discardChanges;
  final Future<File> Function() saveAndPostStory;
  final TextEditingController captionController;
  final WidgetRef ref;
  final String destination;

  const BottomActionButtonsEditTakenImage({
    Key? key,
    required this.cropImage,
    required this.discardChanges,
    required this.saveAndPostStory,
    required this.captionController,
    required this.ref,
    this.destination = 'story'
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: cropImage,
          icon: const Icon(Icons.crop),
          label: const Text("Crop"),
        ),
        ElevatedButton.icon(
          onPressed: discardChanges,
          icon: const Icon(Icons.clear),
          label: const Text("Discard"),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            File combinedImageFile = await saveAndPostStory();
            String storyCaption = captionController.text;
            bool uploadResult = false;
            if(destination == 'story') {
              final contactViewModel = ref.read(
                  usersViewModelProvider.notifier);
              uploadResult = await contactViewModel.postStory(
                  combinedImageFile, storyCaption);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(uploadResult
                      ? 'Story Posted Successfully'
                      : 'Failed to post Story'),
                ),
              );
            }
            else{
              final contactViewModel = ref.read(
                  usersViewModelProvider.notifier);
              uploadResult = await contactViewModel.updateProfilePicture(
                  combinedImageFile);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(uploadResult
                      ? 'Profile Picture updated'
                      : 'Failed to post update profile picture'),
                ),
              );
            }
            if (uploadResult) {
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.of(context).pop();
              });
            }
          },
          icon: const Icon(Icons.send),
          label: const Text("Post"),
        ),
      ],
    );
  }
}
