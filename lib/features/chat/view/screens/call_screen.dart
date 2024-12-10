import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
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
  final Signaling _signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  UserModel? callee;

  @override
  void initState() {
    super.initState();

    callee = widget.callee ?? ref.read(callStateProvider).callee;
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (callee != null) {
        ref.read(callStateProvider.notifier).setCallee(callee!);
        ref.read(callStateProvider.notifier).startCall();
        _initializeSignaling();
      }
    });
  }

  void _initializeSignaling() {
    _signaling.onAddRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    };

    _signaling.onOffer = (description) async {
      await _signaling.setRemoteDescription(description);
      final answer = await _signaling.createAnswer();
      _signaling.setLocalDescription(answer);
      _signaling.sendAnswer(answer);
    };

    _signaling.onAnswer = (description) async {
      await _signaling.setRemoteDescription(description);
    };

    _signaling.onICECandidate = (candidate) {
      _signaling.addCandidate(candidate);
    };

    if (ref.read(callStateProvider).callee?.id != ref.read(userProvider)!.id) {
      _signaling.createOffer().then((offer) {
        _signaling.setLocalDescription(offer);
        _signaling.sendOffer(offer);
      });
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callStateProvider);
    final callNotifier = ref.read(callStateProvider.notifier);
    final displayName = callee != null
        ? '${callee?.screenFirstName} ${callee?.screenLastName}'
        : 'Group Call';
    final Uint8List? imageBytes = callee?.photoBytes;

    return Scaffold(
      body: Stack(
        children: [
          // Remote video
          if (callState.isVideoCall) ...[
            Positioned.fill(child: RTCVideoView(_remoteRenderer)),
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 100,
                height: 150,
                child: RTCVideoView(_localRenderer),
              ),
            ),
          ],

          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // UI Elements
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        callNotifier.minimizeCall();
                        context.pop();
                      },
                      icon: const Icon(Icons.zoom_in_map, color: Palette.primaryText),
                    ),
                    const Icon(Icons.lock, color: Palette.primaryText),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile avatar
              CircleAvatar(
                radius: 40,
                backgroundImage:
                imageBytes != null ? MemoryImage(imageBytes) : null,
                backgroundColor: imageBytes == null ? Palette.primary : null,
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

              // Display name
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Palette.primaryText,
                ),
              ),

              const SizedBox(height: 10),

              // Call status or timer
              if (callState.isCallActive)
                TimerDisplay(startDateTime: callState.startTime!)
              else
                const Text(
                  "Connecting...",
                  style: TextStyle(fontSize: 18, color: Palette.primaryText),
                ),

              const Spacer(),

              // Call control buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _controlButton(
                      icon: callState.isSpeakerOn
                          ? Icons.volume_down
                          : Icons.volume_up,
                      isActive: callState.isSpeakerOn,
                      onTap: callNotifier.toggleSpeaker,
                    ),
                    _controlButton(
                      icon: callState.isVideoCall
                          ? Icons.videocam_off
                          : Icons.videocam,
                      isActive: callState.isVideoCall,
                      onTap: callNotifier.toggleVideoCall,
                    ),
                    _controlButton(
                      icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                      isActive: callState.isMuted,
                      onTap: callNotifier.toggleMute,
                    ),
                    _controlButton(
                      icon: Icons.call_end,
                      isActive: true,
                      isEndCall: true,
                      onTap: () {
                        callNotifier.endCall();
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isEndCall = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      splashColor: isEndCall ? Colors.redAccent : Colors.greenAccent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isEndCall
              ? Colors.red
              : Color.fromRGBO(255, 255, 255, isActive ? 1 : 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: isEndCall || isActive ? Colors.white : Colors.blue.shade300,
            size: 30),
      ),
    );
  }
}
