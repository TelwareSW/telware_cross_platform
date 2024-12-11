import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/view/widget/popup_menu_item_widget.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class PopupMenuWidget extends StatelessWidget {
  final List<PopupMenuEntry> items;
  final Function onSelected;

  const PopupMenuWidget({
    super.key,
    required this.items,
    required this.onSelected,
  });

  static void showPopupMenu({
    required BuildContext context,
    Offset? position,
    required List<dynamic> items,
    required Function onSelected,
  }) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    position ??= renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      color: Palette.secondary,
      position: RelativeRect.fromLTRB(position.dx, position.dy + renderBox.size.height / 2, position.dx + 100, position.dy),
      items: <PopupMenuEntry<dynamic>>[
        ...items.map((item) {
          print("Item $item");
          return PopupMenuItem<dynamic>(
            value: item['value'],
            child: PopupMenuItemWidget(
              icon: item['icon'],
              text: item['text'],
              trailing: item['trailing'],
              color: item['color']
            ),
          );
        }),
      ],
    ).then((value) {
      if (value != null) {
        onSelected(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showPopupMenu(
          context: context,
          items: items,
          onSelected: onSelected,
        );
      },
      child: Container(
        key: key,
        padding: const EdgeInsets.all(20),
        color: Colors.blue,
        child: const Text('Show Popup Menu'),
      ),
    );
  }
}