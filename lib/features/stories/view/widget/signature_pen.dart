import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePen extends StatelessWidget {
  final GlobalKey signatureBoundaryKey;
  final File? imageFile;
  final SignatureController controller;

  const SignaturePen({
    super.key,
    required this.signatureBoundaryKey,
    required this.imageFile,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: signatureBoundaryKey,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(imageFile!),
            fit: BoxFit.cover,
          ),
        ),
        child: Signature(
          controller: controller,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
