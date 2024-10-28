import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import '../../../../core/theme/palette.dart';
import '../../models/story_model.dart';

class StoryAvatar extends StatelessWidget {
  final ContactModel user;
  final String screenType;
  final VoidCallback onTap;
  final bool showBorder;

  const StoryAvatar({
    super.key,
    required this.user,
    required this.screenType,
    required this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('Building StoryAvatar...');

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: SizedBox(
          width: 45,
          height: 45,
          child: CustomPaint(
            painter: showBorder
                ? StoryBorderPainter(user.stories)
                : null, // Conditionally apply painter
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Palette.secondary,
              ),
              child: ClipOval(
                child: user.userImage != null
                    ? Image.memory(
                        user.userImage!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoryBorderPainter extends CustomPainter {
  final List<StoryModel> stories;

  StoryBorderPainter(this.stories);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    double startAngle = -90.0;
    double sweepAngle = 360 / stories.length;
    double gapAngle = 5;

    for (var story in stories) {
      paint.color = story.isSeen ? Colors.grey : Colors.greenAccent;

      canvas.drawArc(
        Rect.fromCircle(
            center: size.center(Offset.zero), radius: size.width / 2),
        radians(startAngle),
        radians(sweepAngle - gapAngle),
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double radians(double degrees) {
    return degrees * (3.1415926535897932 / 180);
  }
}
