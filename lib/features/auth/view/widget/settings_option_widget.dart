import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class SettingsOptionWidget extends StatelessWidget {
  final IconData? icon;
  final String text;
  final String trailing;
  final double fontSize;
  final Color iconColor;
  final Color color;
  final Color trailingColor;
  final bool showDivider;

  const SettingsOptionWidget({
    super.key,
    required this.icon,
    required this.text,
    this.fontSize = 16,
    this.iconColor = Palette.accentText,
    this.color = Palette.primaryText,
    this.trailing = "",
    this.trailingColor = Palette.primary,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding (
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    text,
                    style: TextStyle(color: color),
                  ),
                  trailing: trailing != ""
                      ? Text(trailing, style: TextStyle(fontSize: 12, color: trailingColor))
                      : null,
                  onTap: () {},
                ),
                if (showDivider)
                  const Divider(
                  ),
              ],
            ),
          )
        ],
      )
    );
  }
}