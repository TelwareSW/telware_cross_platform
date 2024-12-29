// Popup menu item widget
import 'package:flutter/cupertino.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class PopupMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;
  final Function? onTap;
  final Color? color;

  const PopupMenuItemWidget({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Palette.secondary,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 6.0, bottom: 6, right: 2.0),
          child: Row(
            children: [
              Icon(icon, color: color ?? Palette.accentText,),
              const SizedBox(width: 16),
              Text(text,
                style: TextStyle(
                  color: color ?? Palette.primaryText,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: trailing ?? const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        )
    );
  }
}