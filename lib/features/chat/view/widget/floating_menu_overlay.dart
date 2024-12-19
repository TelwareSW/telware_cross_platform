import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class FloatingMenuOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback onForward;
  final VoidCallback onPin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSentByMe;
  final bool pinned;

  const FloatingMenuOverlay({
    super.key,
    required this.onDismiss,
    required this.onReply,
    required this.onCopy,
    required this.onForward,
    required this.onPin,
    required this.onEdit,
    required this.onDelete,
    required this.isSentByMe,
    required this.pinned,
  });

  final textStyle = const TextStyle(fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        // Floating menu
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.25,
          right: MediaQuery.of(context).size.width * 0.25,
          child: Material(
            // color: Colors.green,
            child: Center(
              child: Container(
                // width: 200,
                decoration: BoxDecoration(
                  color: Palette.secondary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.reply),
                        trailing: const Text('Reply'),
                        leadingAndTrailingTextStyle: textStyle,
                        onTap: onReply,
                      ),
                      ListTile(
                        leading: const Icon(Icons.copy),
                        trailing: const Text('Copy'),
                        leadingAndTrailingTextStyle: textStyle,
                        onTap: onCopy,
                      ),
                      ListTile(
                        leading: const Icon(FontAwesomeIcons.share),
                        trailing: const Text('Forward'),
                        leadingAndTrailingTextStyle: textStyle,
                        onTap: onForward,
                      ),
                      ListTile(
                        leading: const Icon(Icons.push_pin_outlined),
                        trailing:
                            pinned ? const Text('Unpin') : const Text('Pin'),
                        leadingAndTrailingTextStyle: textStyle,
                        onTap: onPin,
                      ),
                      if (isSentByMe)
                        ListTile(
                          leading: const Icon(Icons.edit),
                          trailing: const Text('Edit'),
                          leadingAndTrailingTextStyle: textStyle,
                          onTap: onEdit,
                        ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        trailing: const Text('Delete'),
                        leadingAndTrailingTextStyle: textStyle,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
