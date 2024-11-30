import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';

class MediaItemIconWidget extends StatefulWidget {
  final String title;
  final VoidCallback onClick;
  final String animationPath;
  final Color color;
  final bool isClicked;

  const MediaItemIconWidget({
    super.key,
    required this.title,
    required this.onClick,
    required this.animationPath,
    required this.color,
    required this.isClicked,
  });

  @override
  State<MediaItemIconWidget> createState() => _MediaItemIconWidgetState();
}

class _MediaItemIconWidgetState extends State<MediaItemIconWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClick,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 55.0,
            width: 55.0,
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isClicked ? Colors.transparent : widget.color,
              border: Border.all(
                color: widget.color,
                width:
                    widget.isClicked ? 4.0 : 0.0, // Creates the hollow effect
              ),
            ),
            child: Center(
              child: Container(
                // Inner filled circle when clicked
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
                child: Center(
                  child: LottieViewer(
                    path: widget.animationPath,
                    width: 30,
                    height: 30,
                    isIcon: true,
                    onTap: widget.onClick,
                  ),
                ),
              ),
            ),
          ),
          Text(
            widget.title,
            style: TextStyle(
              color: widget.isClicked ? widget.color : Palette.accentText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
