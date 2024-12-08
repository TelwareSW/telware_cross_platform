import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/timer_display.dart';
import 'package:telware_cross_platform/features/chat/providers/call_provider.dart';
import 'package:telware_cross_platform/features/chat/services/signaling_service.dart';

class CallScreen extends ConsumerStatefulWidget {
  static const String route = '/call';
  final UserModel? callee;

  const CallScreen({
    super.key,
    this.callee,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreen();
}

class _CallScreen extends ConsumerState<CallScreen> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController();
  UserModel? callee;

  @override
  void initState() {
    // Add the callee data to the call state
    callee = widget.callee ?? ref.read(callStateProvider).callee;
    debugPrint("callee: $callee");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.callee != null) {
        ref.read(callStateProvider.notifier).setCallee(callee!);
        ref.read(callStateProvider.notifier).startCall();
      }
    });
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    signaling.onAddRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    };

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("CallScreen");
    // Get the call state
    final callState = ref.watch(callStateProvider);
    // Get the call notifier
    final callNotifier = ref.read(callStateProvider.notifier);
    final displayName = callee != null ?
    '${callee?.screenFirstName} ${callee?.screenLastName}' : 'Group Call';
    final String? photo = callee?.photo;
    final Uint8List? imageBytes = callee?.photoBytes;

    return Scaffold(
      body: Stack(
        // Create gradient background
        children: [
          if (callState.isVideoCall) ...[
            Positioned.fill(
              child: RTCVideoView(_remoteRenderer),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 100,
                height: 150,
                child: RTCVideoView(_localRenderer),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minimize and encryption emojis
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Minimize button
                    IconButton(
                      onPressed: () {
                        callNotifier.minimizeCall();
                        context.pop();
                      },
                      icon: const Icon(
                        Icons.zoom_in_map,
                        color: Palette.primaryText,
                      ),
                    ),
                    // Encryption icon
                    const Icon(
                      Icons.lock,
                      color: Palette.primaryText,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Contact initials
              CircleAvatar(
                radius: 40,
                backgroundImage:
                imageBytes != null ? MemoryImage(imageBytes) : null,
                backgroundColor:
                imageBytes == null ? Palette.primary : null,
                child: imageBytes == null
                    ? Text(
                  getInitials(displayName),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Palette.primaryText,
                  ),
                )
                    : null,
              ),
              const SizedBox(height: 20),
              // Contact name
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Palette.primaryText,
                ),
              ),
              const SizedBox(height: 10),
              // Call duration
              if (callState.isCallActive)
                TimerDisplay(startDateTime: callState.startTime!)
              else
                const Text(
                  "Requesting...",
                  style: TextStyle(
                    fontSize: 18,
                    color: Palette.primaryText,
                  ),
                ),
              const Spacer(),
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Speaker button
                    InkWell(
                      onTap: () {
                        callNotifier.toggleSpeaker();
                      },
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.greenAccent,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, callState.isSpeakerOn ? 1 : 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          callState.isSpeakerOn ? Icons.volume_down : Icons.volume_up,
                          color: !callState.isSpeakerOn ? Colors.white : Colors.blue.shade300,
                          size: 30,
                        ),
                      ),
                    ),
                    // Video toggle button
                    InkWell(
                      onTap: () {
                        // signaling.toggleVideo(_localRenderer, !callState.isVideoCall);
                        callNotifier.toggleVideoCall();
                      },
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.greenAccent,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, callState.isVideoCall ? 1 : 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          callState.isVideoCall ? Icons.videocam_off : Icons.videocam,
                          color: !callState.isVideoCall ? Colors.white : Colors.blue.shade300,
                          size: 30,
                        ),
                      ),
                    ),
                    // Mute button
                    InkWell(
                      onTap: () {
                        // Mute action
                        // signaling.mute(_localRenderer, !callState.isMuted);
                        callNotifier.toggleMute();
                      },
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.greenAccent,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, callState.isMuted ? 1 : 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          callState.isMuted ? Icons.mic_off : Icons.mic,
                          color: !callState.isMuted ? Colors.white : Colors.blue.shade300,
                          size: 30,
                        ),
                      ),
                    ),
                    // End call button
                    InkWell(
                      onTap: () async {
                        // End call action
                        // await signaling.hangUp(_localRenderer);
                        callNotifier.endCall();
                        print("Call ended");
                        context.pop();
                      },
                      borderRadius: BorderRadius.circular(50),
                      splashColor: Colors.redAccent,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.red, // Red background
                          shape: BoxShape.circle, // Circular shape
                        ),
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white, // White icon
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]

      )
    );
  }
}