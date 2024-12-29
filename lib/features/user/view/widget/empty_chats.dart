import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class EmptyChats extends StatelessWidget {
  const EmptyChats({
    super.key,
    this.height,
    this.padding,
  });

  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: SizedBox(
          height: height ?? MediaQuery.of(context).size.height,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LottieViewer(
                  path: 'assets/tgs/EasterDuck.tgs',
                  width: 100,
                  height: 100,
                ),
                TitleElement(
                  name: 'Welcome to Telegram',
                  color: Palette.primaryText,
                  fontSize: Sizes.primaryText - 2,
                  fontWeight: FontWeight.bold,
                  padding: EdgeInsets.only(bottom: 0, top: 10),
                ),
                TitleElement(
                    name:
                        'Start messaging by tapping the pencil button in the bottom right corner.',
                    color: Palette.accentText,
                    fontSize: Sizes.secondaryText - 2,
                    padding: EdgeInsets.only(bottom: 0, top: 5),
                    width: 350.0),
              ],
            ),
          ),
        ));
  }
}
