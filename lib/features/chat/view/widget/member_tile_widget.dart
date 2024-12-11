import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/profile_avatar_widget.dart';

class MemberTileWidget extends StatelessWidget {
  final String? imagePath;
  final String text;
  final String subtext;
  final String? moreInfo;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showSelected;

  const MemberTileWidget({
    super.key,
    this.imagePath,
    required this.text,
    required this.subtext,
    this.moreInfo,
    this.onTap,
    this.showDivider = true,
    this.showSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.optionsHorizontalPad,
            vertical: 6.0
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ProfileAvatarWidget(
                  text: text,
                  imagePath: imagePath,
                ),
                if (showSelected)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Palette.valid,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Palette.secondary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Palette.primaryText,
                        size: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Palette.primaryText,
                        ),
                      ),
                      const Spacer(),
                      if (moreInfo != null)
                        Text(moreInfo!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Palette.accent,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    subtext,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Palette.accentText,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  if (showDivider) const Divider(color: Palette.secondary),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}