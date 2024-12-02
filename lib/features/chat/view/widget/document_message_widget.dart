import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/chat/view/widget/download_widget.dart';

import '../../utils/chat_utils.dart';

class DocumentMessageWidget extends StatefulWidget {
  final String? filePath;
  final void Function(String?) onDownloadTap;
  final String? url;
  final void Function() openOptions;

  const DocumentMessageWidget({
    super.key,
    this.filePath,
    required this.openOptions,
    required this.onDownloadTap,
    this.url,
  });

  @override
  DocumentMessageWidgetState createState() => DocumentMessageWidgetState();
}

class DocumentMessageWidgetState extends State<DocumentMessageWidget> {
  late String fileName;
  late String fileSize;

  @override
  void initState() {
    super.initState();
    _initializeFileDetails();
  }

  void _initializeFileDetails() {
    if (widget.filePath == null) {
      fileName = 'Document';
      fileSize = '0 MB';
      return;
    }
    final file = File(widget.filePath!);
    fileName = file.uri.pathSegments.last;
    fileSize = '${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  Future<void> openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      debugPrint('Error opening file: ${result.message}');
    }
  }

  // Simulate document opening logic
  Future<void> _handleDocumentTap() async {
    if (widget.filePath == null) {
      showToastMessage('Please Download the file first');
      return;
    }
    debugPrint("Opening document: $fileName");
    await openFile(widget.filePath!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleDocumentTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.filePath == null || !doesFileExistSync(widget.filePath!)
              ? DownloadWidget(
                  onTap: widget.onDownloadTap,
                  url: widget.url,
                  color: Colors.white,
                )
              : LottieViewer(
                  path: 'assets/json/attach_file.json',
                  width: 50,
                  height: 50,
                  onTap: _handleDocumentTap,
                ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                      onPressed: widget.openOptions,
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  fileSize,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
