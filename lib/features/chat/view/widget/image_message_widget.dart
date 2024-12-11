import 'dart:io';

import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';
import 'package:telware_cross_platform/features/chat/view/widget/download_widget.dart';

class ImageMessageWidget extends StatelessWidget {
  final String? filePath;
  final String? url;
  final String? caption;
  final void Function(String?) onDownloadTap;

  const ImageMessageWidget({
    super.key,
    this.filePath,
    required this.onDownloadTap,
    this.url,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: filePath == null || !doesFileExistSync(filePath!)
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
        ),
        if (caption != null && caption!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8, top: 8),
            // Add horizontal padding
            child: Text(
              caption!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
