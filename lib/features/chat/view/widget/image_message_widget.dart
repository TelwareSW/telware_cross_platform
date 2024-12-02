import 'dart:io';

import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/chat/view/widget/download_widget.dart';

class ImageMessageWidget extends StatelessWidget {
  final String? filePath;
  final String? url;
  final void Function(String?) onDownloadTap;

  const ImageMessageWidget({
    super.key,
    this.filePath,
    required this.onDownloadTap,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: filePath == null
          ? SizedBox(
              width: 200,
              height: 200,
              child: Center(
                child: DownloadWidget(
                  onTap: onDownloadTap,
                  url: url,
                  color: Colors.white,
                ),
              ),
            )
          : Image.file(
              File(filePath!),
              fit: BoxFit.cover,
            ),
    );
  }
}