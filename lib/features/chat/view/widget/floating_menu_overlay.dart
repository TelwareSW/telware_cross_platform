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
    required this.pinned,
  });

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
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
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
                        title: const Text('Reply'),
                        onTap: onReply,
                      ),
                      ListTile(
                        leading: const Icon(Icons.copy),
                        title: const Text('Copy'),
                        onTap: onCopy,
                      ),
                      ListTile(
                        leading: const Icon(FontAwesomeIcons.share),
                        title: const Text('Forward'),
                        onTap: onForward,
                      ),
                      ListTile(
                        leading: Icon(Icons.push_pin_outlined) ,
                        title: pinned ? const Text('Unpin') : const Text('Pin'),
                        onTap: onPin,
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit'),
                        onTap: onEdit,
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Delete'),
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
