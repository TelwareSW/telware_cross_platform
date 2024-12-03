import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';

class DownloadWidget extends StatefulWidget {
  final void Function(String?) onTap;
  final String? url;
  final Color? color;

  const DownloadWidget({
    super.key,
    required this.onTap,
    required this.url,
    this.color = Colors.transparent,
  });

  @override
  DownloadWidgetState createState() => DownloadWidgetState();
}

class DownloadWidgetState extends State<DownloadWidget> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _handelTap() async {
    if (widget.url == null) {
      debugPrint('DownloadWidgetState._handelTap: URL is null');
      showToastMessage('File has been deleted ask the sender to resend it');
      return;
    }
    if (USE_MOCK_DATA) {
      debugPrint('DownloadWidgetState._handelTap: ${widget.url}');
      widget.onTap(widget.url);
      return;
    }
    String? filePath = await downloadAndSaveFile(widget.url);
    widget.onTap(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handelTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: widget.color,
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: LottieViewer(
              path: 'assets/json/download.json',
              width: 50,
              height: 50,
              onTap: _handelTap,
              isLooping: true,
            ),
          ),
        ),
      ),
    );
  }
}
