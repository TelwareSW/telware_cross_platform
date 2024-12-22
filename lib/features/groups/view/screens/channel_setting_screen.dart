import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/features/groups/view/screens/members_screen.dart';

import '../../../../core/theme/palette.dart';

class ChannelSettingScreen extends StatefulWidget {
  static const String route = '/channel-setting-screen';
  final String channelName;
  final String channelDescription;
  final File? channelImage;
  const ChannelSettingScreen({
    super.key,
    required this.channelDescription,
    required this.channelName,
    required this.channelImage,
  });

  @override
  State<ChannelSettingScreen> createState() => _ChannelSettingScreenState();
}

class _ChannelSettingScreenState extends State<ChannelSettingScreen> {
  String _channelType = 'Public';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = 't.me/';
    _controller.addListener(() {
      if (!_controller.text.startsWith('t.me/')) {
        _controller.text = 't.me/';
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel Settings'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Palette.primaryText,
            ),
            onPressed: () {
              context.push(Routes.selectChannelMembers, extra: {
                'name': widget.channelName,
                'privacy': _channelType,
                'channelDiscription': widget.channelDescription,
                'channelImage': null,
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Channel type',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Palette.primary),
            ),
            const SizedBox(height: 8),
            RadioListTile(
              activeColor: Palette.primary,
              title: const Text('Public Channel'),
              subtitle: const Text(
                'Public channels can be found in search, anyone can join them.',
                style: TextStyle(
                  color: Palette.accentText,
                  fontSize: 11.5,
                ),
              ),
              value: 'Public',
              groupValue: _channelType,
              onChanged: (value) {
                setState(() {
                  _channelType = value.toString();
                });
              },
            ),
            RadioListTile(
              activeColor: Palette.primary,
              title: const Text('Private Channel'),
              subtitle: const Text(
                'Private channels can only be joined via an invite link.',
                style: TextStyle(
                  color: Palette.accentText,
                  fontSize: 11.5,
                ),
              ),
              value: 'Private',
              groupValue: _channelType,
              onChanged: (value) {
                setState(() {
                  _channelType = value.toString();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Permanent link',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Palette.primary),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'If you set a permanent link, other people will be able to find and join your channel.\n\n'
              'You can use a-z, 0-9 and underscores.\nMinimum length is 5 characters.',
              style: TextStyle(
                color: Palette.accentText,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
