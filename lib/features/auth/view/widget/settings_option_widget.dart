import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class SettingsOptionWidget extends StatelessWidget {
  final IconData? icon;
  final GlobalKey? iconKey;
  final String? imagePath;
  final double imageWidth;
  final double imageHeight;
  final double imageRadius;
  final String text;
  final String subtext;
  final String trailing;
  final IconData? trailingIcon;
  final VoidCallback? trailingIconAction;
  final double fontSize;
  final FontWeight? fontWeight;
  final double? subtextFontSize;
  final double? trailingFontSize;
  final EdgeInsets? trailingPadding;
  final Color iconColor;
  final Color color;
  final Color? trailingColor;
  final bool showDivider;
  final VoidCallback? onTap;

  const SettingsOptionWidget({
    super.key,
    this.iconKey,
    this.icon,
    required this.text,
    this.imagePath,
    this.imageWidth = 45,
    this.imageHeight = 45,
    this.imageRadius = 50,
    this.subtext = "",
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.subtextFontSize,
    this.trailingFontSize,
    this.iconColor = Palette.accentText,
    this.color = Palette.primaryText,
    this.trailing = "",
    this.trailingIcon,
    this.trailingIconAction,
    this.trailingPadding,
    this.trailingColor = Palette.primary,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor),
              const SizedBox(width: 16),
            ] else if (imagePath != null) ...[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageRadius),
                  child: Image.asset(
                    imagePath!,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            color: color,
                            fontSize: fontSize,
                            fontWeight: fontWeight ?? FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (subtext != "") ...[
                          Text(
                            subtext,
                            style: TextStyle(
                              color: Palette.accentText,
                              fontSize: subtextFontSize ?? fontSize * 0.8,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ]
                      ],
                    ),
                    trailing: trailing != ""
                        ? Padding(
                            padding: trailingPadding ?? const EdgeInsets.all(0),
                            child: Text(
                              trailing,
                              style: TextStyle(
                                fontSize: trailingFontSize ?? fontSize * 0.9,
                                color: trailingColor ?? Palette.primary,
                              ),
                            ),
                          )
                        : trailingIcon != null
                            ? IconButton(
                                key: iconKey,
                                icon: Icon(
                                  trailingIcon,
                                  color: trailingColor ?? Palette.primary,
                                ),
                                onPressed: trailingIconAction,
                              )
                            : null,
                    onTap: onTap,
                  ),
                  if (showDivider) const Divider(),
                ],
              ),
            )
          ],
        ));
  }
}
