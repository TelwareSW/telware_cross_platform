import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';


class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String? imagePath;
  final double factor;

  const ProfileHeader({super.key, required this.fullName, this.imagePath, this.factor = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(factor, 0, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundImage: imagePath != null
                ? AssetImage(imagePath!)
                : null,
            backgroundColor: imagePath == null ? Palette.primary : null,
            child: imagePath == null
                ? Text(
              getInitials(fullName),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Palette.primaryText,
              ),
            )
                : null,
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 14  + 6 * factor / 100,
                  fontWeight: FontWeight.bold,
                  color: Palette.primaryText,
                ),
              ),
              Text(
                "online",
                style: TextStyle(
                  fontSize: 10  + 6 * factor / 100,
                  color: Palette.accentText,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
