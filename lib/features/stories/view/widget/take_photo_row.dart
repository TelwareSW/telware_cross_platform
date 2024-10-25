import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/stories/view/widget/pick_from_gallery.dart';

class TakePhotoRow extends StatelessWidget {
  const TakePhotoRow({
    super.key,
    required String selectedMode,
    required this.onCapture,
    required this.onToggle,
  }) : _selectedMode = selectedMode;
  final String _selectedMode;
  final VoidCallback onCapture;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    debugPrint('Building TakePhotoRow...');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: ClipOval(
            child: Container(
              color: Colors.grey.shade900.withOpacity(0.5),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: PickFromGallery(),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onCapture();
          },
          child: Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.0),
            ),
            child: Center(
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: _selectedMode == 'Photo' ? Colors.white : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0),
          child: GestureDetector(
            onTap: onToggle,
            child: ClipOval(
                child: Container(
                    color: Colors.grey.shade900.withOpacity(0.5),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.cached,
                        size: 35,
                      ),
                    ))),
          ),
        ),
      ],
    );
  }
}

