import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';
import 'package:telware_cross_platform/features/chat/view/widget/download_widget.dart';

class StickerMessageWidget extends StatelessWidget {
  final String? filePath;
  final String? url;
  final void Function(String?) onDownloadTap;

  const StickerMessageWidget({
    super.key,
    this.filePath,
    required this.onDownloadTap,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
          : Lottie.file(
              File(filePath!),
              width: 200,
              height: 200,
              decoder: LottieComposition.decodeGZip,
            ),
    );
  }
}
