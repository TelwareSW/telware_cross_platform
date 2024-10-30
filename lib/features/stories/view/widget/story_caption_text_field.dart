import 'dart:ui';

import 'package:flutter/material.dart';

class StoryCaptionField extends StatelessWidget {
  final TextEditingController controller;

  const StoryCaptionField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter story caption",
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: Colors.white54),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
