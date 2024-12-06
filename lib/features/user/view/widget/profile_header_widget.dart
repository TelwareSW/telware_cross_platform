
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';

class ProfileHeader extends ConsumerWidget {
  final BoxConstraints constraints;
  final Uint8List? photoBytes;
  final String displayName;
  final String? substring;

  const ProfileHeader({
    super.key,
    this.constraints = const BoxConstraints(),
    required this.photoBytes,
    required this.displayName,
    this.substring,
  });

  double _calculateFactor(BoxConstraints constraints) {
    double maxExtent = 130.0;
    double scrollOffset = constraints.maxHeight - kToolbarHeight;
    double factor =
    scrollOffset > 0 ? (maxExtent - scrollOffset) / maxExtent * 90.0 : 60.0;
    return factor.clamp(0, 90.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double factor = _calculateFactor(constraints);

    return Padding(
      padding: EdgeInsets.fromLTRB(factor, 0, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundImage:
            photoBytes != null ? MemoryImage(photoBytes!) : null,
            backgroundColor:
            photoBytes == null ? getRandomColor(displayName) : null,
            child: photoBytes == null
                ? Text(
              getInitials(displayName),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Palette.primaryText,
              ),
            )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 14  + 6 * factor / 100,
                  fontWeight: FontWeight.bold,
                  color: Palette.primaryText,
                ),
              ),
              if (substring != null)
                Text(
                  substring!,
                  style: TextStyle(
                    fontSize: 10  + 6 * factor / 100,
                    color: Palette.accentText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ))
        ],
      ),
    );
  }
}
