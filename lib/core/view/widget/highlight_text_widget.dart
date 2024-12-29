import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:url_launcher/url_launcher.dart';

bool isHighlight(
  int index,
  int lowerBoundIndex,
  List<MapEntry<int, int>> list,
) {
  if (lowerBoundIndex < list.length) {
    int highlightStart = list[lowerBoundIndex].key;
    int highlightEnd = highlightStart + list[lowerBoundIndex].value;
    return index >= highlightStart && index < highlightEnd;
  }
  return false;
}

class HighlightTextWidget extends StatelessWidget {
  final String text;
  final List<MapEntry<int, int>>
      highlights; // Each entry holds start index and length of highlight
  final TextStyle normalStyle;
  final TextStyle highlightStyle;
  final TextStyle linkStyle;
  final TextStyle mentionStyle;
  final TextOverflow overFlow;
  final int? maxLines;

  final RegExp _linkRegExp = RegExp(
    r'((https?|ftp)://[^\s/$.?#].[^\s]*)',
    caseSensitive: false,
  );

  final RegExp _mentionRegExp = RegExp(
    r'@\[(.*?)\]\((.*?)\)',
    caseSensitive: false,
  );

  HighlightTextWidget({
    super.key,
    required this.text,
    required this.highlights,
    this.normalStyle = const TextStyle(color: Palette.primaryText),
    this.highlightStyle = const TextStyle(color: Palette.error),
    this.linkStyle = const TextStyle(
      color: Palette.accent,
      decoration: TextDecoration.underline,
    ),
    this.mentionStyle = const TextStyle(
      color: Color.fromARGB(255, 43, 121, 255),
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    ),
    this.overFlow = TextOverflow.clip,
    this.maxLines,
  });

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showToastMessage('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (highlights.length == 1 && highlights[0].key != 0) {
      debugPrint(highlights.toString());
    }

    // Find all links in the text
    final List<RegExpMatch> linkMatches = _linkRegExp.allMatches(text).toList();
    final List<RegExpMatch> mantionMatches =
        _mentionRegExp.allMatches(text).toList();
    final List<MapEntry<int, int>> linkRanges = linkMatches
        .map((match) => MapEntry(match.start, match.end - match.start))
        .toList();
    final List<MapEntry<int, int>> mentionRanges = mantionMatches
        .map((match) => MapEntry(match.start, match.end - match.start))
        .toList();

    final List<MapEntry<int, String>> highlightRanges =
        List.generate(text.length, (index) => MapEntry(index, 'normal'));

    for (var i = 0; i < highlightRanges.length; i++) {
      int lowerBoundIndex = lowerBound<MapEntry<int, int>>(
        highlights,
        MapEntry(i, 0), // Create a temporary MapEntry with the target value
        compare: (a, b) => a.key.compareTo(b.key), // Compare by the key
      );
      if (lowerBoundIndex != 0) {
        lowerBoundIndex = (lowerBoundIndex < highlights.length &&
                highlights[lowerBoundIndex].key == i)
            ? lowerBoundIndex
            : lowerBoundIndex - 1;
      }
      if (isHighlight(i, lowerBoundIndex, highlights)) {
        highlightRanges[i] = MapEntry(i, 'highlight');
        continue;
      }

      lowerBoundIndex = lowerBound<MapEntry<int, int>>(
        mentionRanges,
        MapEntry(i, 0), // Create a temporary MapEntry with the target value
        compare: (a, b) => a.key.compareTo(b.key), // Compare by the key
      );
      if (lowerBoundIndex != 0) {
        lowerBoundIndex = (lowerBoundIndex < mentionRanges.length &&
                mentionRanges[lowerBoundIndex].key == i)
            ? lowerBoundIndex
            : lowerBoundIndex - 1;
      }
      if (isHighlight(i, lowerBoundIndex, mentionRanges)) {
        highlightRanges[i] = MapEntry(i, 'mention');
        continue;
      }

      lowerBoundIndex = lowerBound<MapEntry<int, int>>(
        linkRanges,
        MapEntry(i, 0), // Create a temporary MapEntry with the target value
        compare: (a, b) => a.key.compareTo(b.key), // Compare by the key
      );
      if (lowerBoundIndex != 0) {
        lowerBoundIndex = (lowerBoundIndex < linkRanges.length &&
                linkRanges[lowerBoundIndex].key == i)
            ? lowerBoundIndex
            : lowerBoundIndex - 1;
      }
      if (isHighlight(i, lowerBoundIndex, linkRanges)) {
        highlightRanges[i] = MapEntry(i, 'link');
        continue;
      }
    }

    final List<MapEntry<String, MapEntry<int, int>>> groupedHighlights = [];

    // group the same type of highlights together
    if (highlightRanges.isNotEmpty) {
      String currentType = highlightRanges[0].value;
      int start = highlightRanges[0].key;
      int length = 1;

      for (int i = 1; i < highlightRanges.length; i++) {
        if (highlightRanges[i].value == currentType) {
          length++;
        } else {
          groupedHighlights.add(MapEntry(currentType, MapEntry(start, length)));

          currentType = highlightRanges[i].value;
          start = highlightRanges[i].key;
          length = 1;
        }
      }

      groupedHighlights.add(MapEntry(currentType, MapEntry(start, length)));
    }

    List<TextSpan> textSpans = [];

    for (var highlight in groupedHighlights) {
      int index = highlight.value.key;
      int length = highlight.value.value;
      String type = highlight.key;
      switch (type) {
        case 'normal':
          textSpans.add(TextSpan(
            text: text.substring(index, index + length),
            style: normalStyle,
          ));
          break;
        case 'highlight':
          textSpans.add(TextSpan(
            text: text.substring(index, index + length),
            style: highlightStyle,
          ));
          break;
        case 'link':
          textSpans.add(
            TextSpan(
              text: text.substring(index, index + length),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap =
                    () => _launchURL(text.substring(index, index + length)),
            ),
          );
          break;
        case 'mention':
          textSpans.add(
            TextSpan(
              text: '@${(text.substring(index, index + length)).splitMapJoin(
                _mentionRegExp,
                onMatch: (m) => m.group(1)!,
                onNonMatch: (m) => m,
              )}',
              style: mentionStyle,
            ),
          );
          break;
      }
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
      overflow: overFlow,
      maxLines: maxLines,
    );
  }
}
