import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class SettingsOptionWidget extends StatelessWidget {
  final IconData? icon;
  final String text;
  final String subtext;
  final String trailing;
  final double fontSize;
  final Color iconColor;
  final Color color;
  final Color trailingColor;
  final bool showDivider;
  final VoidCallback? onTap;

  const SettingsOptionWidget({
    super.key,
    required this.icon,
    required this.text,
    this.subtext = "",
    this.fontSize = 14,
    this.iconColor = Palette.accentText,
    this.color = Palette.primaryText,
    this.trailing = "",
    this.trailingColor = Palette.primary,
    this.showDivider = true,
    this.onTap,
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
                  title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: TextStyle(color: color, fontSize: fontSize),),
                      if (subtext != "") ...[
                        const SizedBox(height: 5,),
                        Text(subtext, style: TextStyle(color: Palette.accentText, fontSize: fontSize*0.8))
                      ]
                    ]
                  ),
                  trailing: trailing != ""
                      ? Text(trailing, style: TextStyle(fontSize: fontSize*0.9, color: trailingColor))
                      : null,
                  onTap: onTap,
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