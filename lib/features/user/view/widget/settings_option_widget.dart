import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

import 'package:telware_cross_platform/core/utils.dart';
import '../../../user/view/widget/avatar_generator.dart';

class SettingsOptionWidget extends StatelessWidget {
  final IconData? icon;
  final GlobalKey? trailingIconKey;
  final String? imagePath;
  final Uint8List? imageMemory;
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
  final bool? avatar;
  final VoidCallback? onTap;

  static final Map<String, Color> _colorCache = {};

  const SettingsOptionWidget({
    super.key,
    this.trailingIconKey,
    this.icon,
    required this.text,
    this.imagePath,
    this.imageMemory,
    this.avatar,
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
    Color avatarBackgroundColor = _colorCache.putIfAbsent(text, () => getRandomColor());

    return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.optionsHorizontalPad,
            vertical: Dimensions.optionsVerticalPad),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  key: key != null
                      ? ValueKey("${(key as ValueKey).value}-icon")
                      : null,
                  color: iconColor),
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
            ] else if (imageMemory != null) ...[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageRadius),
                  child: Image.memory(
                    imageMemory!,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ] else if (avatar != null) ...[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AvatarGenerator(
                  name: text,
                  backgroundColor: avatarBackgroundColor,
                  size: imageWidth,
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
                    trailing: trailing.isNotEmpty
                        ? Padding(
                            padding: trailingPadding ?? const EdgeInsets.all(0),
                            child: Text(
                              trailing,
                              key: key != null
                                  ? ValueKey(
                                      "${(key as ValueKey).value}-trailing")
                                  : null,
                              style: TextStyle(
                                fontSize: trailingFontSize ?? fontSize * 0.9,
                                color: trailingColor ?? Palette.primary,
                              ),
                            ),
                          )
                        : trailingIcon != null
                            ? IconButton(
                                key: trailingIconKey,
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
