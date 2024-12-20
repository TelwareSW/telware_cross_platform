import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool notAllowedToSend;

  const LinkTextField({
    Key? key,
    required this.controller,
    this.notAllowedToSend = false,
  }) : super(key: key);

  @override
  _LinkTextFieldState createState() => _LinkTextFieldState();
}

class _LinkTextFieldState extends State<LinkTextField> {
  final FocusNode _textFieldFocusNode = FocusNode();
  bool isTextEmpty = true;
  bool _emojiShowing = false;
  final RegExp _linkRegExp = RegExp(
    r'((https?|ftp)://[^\s/$.?#].[^\s]*)',
    caseSensitive: false,
  );

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<TextSpan> _buildTextSpans(String text) {
    List<TextSpan> spans = [];
    int start = 0;

    _linkRegExp.allMatches(text).forEach((match) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      final String url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
        ),
      );
      start = match.end;
    });

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          focusNode: _textFieldFocusNode,
          controller: widget.controller,
          enabled: !widget.notAllowedToSend,
          decoration: InputDecoration(
            hintText: widget.notAllowedToSend ? 'Text not Allowed' : 'Message',
            hintStyle: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            prefixIcon: widget.notAllowedToSend
                ? const Icon(
                    Icons.lock,
                    color: Colors.grey,
                  )
                : null,
          ),
          cursorColor: Colors.blue,
          onTap: () {
            if (widget.notAllowedToSend) return;
            setState(() {
              _emojiShowing = false;
            });
          },
          onChanged: (text) {
            if (isTextEmpty ^ text.isEmpty) {
              setState(() {
                isTextEmpty = text.isEmpty;
              });
            }
          },
        ),
        if (widget.controller.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.topLeft,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.black),
                children: _buildTextSpans(widget.controller.text),
              ),
            ),
          ),
      ],
    );
  }
}
