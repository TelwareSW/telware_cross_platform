import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class HighlightTextWidget extends StatelessWidget {
  final String text;
  final List<MapEntry<int, int>> highlights;  // Each entry holds start index and length of highlight
  final TextStyle normalStyle;
  final TextStyle highlightStyle;

  const HighlightTextWidget({
    super.key,
    required this.text,
    required this.highlights,
    this.normalStyle = const TextStyle(color: Palette.primaryText),
    this.highlightStyle = const TextStyle(color: Palette.error),
  });

  @override
  Widget build(BuildContext context) {
    if (highlights.length == 1 && highlights[0].key != 0) {
      print(highlights);
    }
    List<TextSpan> textSpans = [];
    int start = 0;

    for (var highlight in highlights) {
      int index = highlight.key;
      int length = highlight.value;

      if (index > start) {
        textSpans.add(TextSpan(text: text.substring(start, index), style: normalStyle));
      }

      String highlightedText = text.substring(index, index + length);
      textSpans.add(TextSpan(text: highlightedText, style: highlightStyle));

      start = index + length;
    }

    if (start < text.length) {
      textSpans.add(TextSpan(text: text.substring(start), style: normalStyle));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
}