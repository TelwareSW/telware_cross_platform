import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/timer_display.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/providers/call_provider.dart';
import 'package:telware_cross_platform/features/chat/services/signaling_service.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';

class CallScreen extends ConsumerStatefulWidget {
  static const String route = '/call';
  final String? chatId;
  final UserModel? callee;
  final String? voiceCallId;

  const CallScreen({
    super.key,
    this.chatId,
    this.callee,
    this.voiceCallId,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final Signaling _signaling = Signaling.instance;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  UserModel? callee;
  String? voiceCallId;
  late bool isCaller;
  late bool isReceivingCall;

  @override
  void initState() {
    super.initState();
    isCaller = ref.read(callStateProvider).isCaller;
    callee = widget.callee ?? ref.read(callStateProvider).callee;
    voiceCallId = widget.voiceCallId ?? ref.read(callStateProvider).voiceCallId;
    String? chatId = widget.chatId;

    isReceivingCall = !isCaller && voiceCallId != null;

    _localRenderer.initialize();


    _signaling.onAddRemoteStream = (stream, clientId) {
      _remoteRenderers[clientId]!.srcObject = stream;
      setState(() {});
    };

    // Initialize media just one time
    if (_localRenderer.srcObject == null) {
      _signaling.openUserMedia(_localRenderer);
    }
    _signaling.toggleVideoStream(ref.read(callStateProvider).isVideoCall);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (callee != null && isCaller) {
        ref.read(callStateProvider.notifier).setCallee(callee!);
      }
      _initializeSignaling();
      if (voiceCallId == null && isCaller) {
        debugPrint("Call: Creating voice call");
        if (chatId == null) {
          ChatModel chat = ref.read(chatsViewModelProvider.notifier)
              .getChat(ref.read(userProvider)!, callee!, ChatType.private);
          chatId = chat.id;
        }
        _signaling.createVoiceCall(chatId, callee?.id);
      }
    });
  }

  void _initializeSignaling() {
    debugPrint("Call: Initializing signaling");
    _signaling.onAddRemoteStream = (stream, clientId) {
      _remoteRenderers[clientId]!.srcObject = stream;
      setState(() {});
    };

    _signaling.onOffer = (description, senderId) async {
      // If receiving a call, set remote description and create an answer
      await _signaling.registerPeerConnection(senderId);
      await _signaling.setRemoteDescription(description, senderId);
      final answer = await _signaling.createAnswer(senderId);
      _signaling.sendAnswer(answer, senderId);
      startCall();
    };

    _signaling.onAnswer = (description, senderId) async {
      await _signaling.setRemoteDescription(description, senderId);
      startCall();
    };

    _signaling.onICECandidate = (candidate, senderId) {
      _signaling.addCandidate(candidate, senderId);
    };

    _signaling.onCallStarted = (response) {
      if (voiceCallId == response['voiceCallId']) return;
      debugPrint("Call: Call started with voiceCallId: ${response['voiceCallId']}");
      _signaling.joinCall(response['voiceCallId']);
      updateVoiceCallId(response['voiceCallId']);
    };

    _signaling.onReceiveJoinedCall = (response) {
      final clientId = response['clientId'];
      print("# Call: Received joined call from $clientId");
      _remoteRenderers[clientId] = RTCVideoRenderer();
      _remoteRenderers[clientId]!.initialize();
      _signaling.updateRemoteRenderer(_remoteRenderers[clientId]!).then((_) {
        _signaling.createOffer(clientId).then((offer) {
          _signaling.sendOffer(offer, response['clientId']);
        });

        if (ref.read(callStateProvider).isCallInProgress) return;
        ref.read(callStateProvider.notifier).setCallInProgress(true);
      });
    };

    _signaling.onReceiveLeftCall = (response) {
      // Terminate connection with the specific user
      final clientId = response['clientId'];
      _signaling.removeRemoteClient(clientId);
    };

    _signaling.onReceiveEndCall = (response) {
      // Terminate connection with user
      endCall();
      context.pop();
    };
  }

  void startCall() {
    ref.read(callStateProvider.notifier).startCall();
  }

  void updateVoiceCallId(String voiceCallId) {
    ref.read(callStateProvider.notifier).setVoiceCallId(voiceCallId);
    this.voiceCallId = voiceCallId;
  }

  void endCall() {
    _signaling.hangUp(_localRenderer);
    ref.read(callStateProvider.notifier).endCall();
  }

  @override
  void dispose() {
    // _localRenderer.dispose();
    // _remoteRenderer.dispose();
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
          if (callState.isVideoCall)
            // Display all remote renderers as cubes beside each other
            Row(
              children: _remoteRenderers.values
                  .map((renderer) => SizedBox(
                width: 100,
                height: 150,
                child: RTCVideoView(renderer),
              ))
                  .toList(),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade300],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          if (callState.isVideoCall)
            Positioned(
              bottom: 120,
              right: 20,
              child: SizedBox(
                width: 100,
                height: 150,
                child: RTCVideoView(_localRenderer, mirror: true),
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
                      key: CallKeys.minimizeCallButton,
                      onPressed: () {
                        if (callState.voiceCallId == null) {
                          endCall();
                        } else {
                          callNotifier.minimizeCall();
                        }
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
                TimerDisplay(
                  key: CallKeys.callStatusText,
                  startDateTime: callState.startTime!
                )
              else if (callState.isCallInProgress)
                const Text(
                  key: CallKeys.callStatusText,
                  "Connecting...",
                  style: TextStyle(fontSize: 18, color: Palette.primaryText),
                )
              else if (isCaller)
                  const Text(
                    key: CallKeys.callStatusText,
                    "Requesting...",
                    style: TextStyle(fontSize: 18, color: Palette.primaryText),
                  )
                else if (isReceivingCall)
                  const Text(
                    key: CallKeys.callStatusText,
                    "Incoming call...",
                    style: TextStyle(fontSize: 18, color: Palette.primaryText),
                  ),

              const Spacer(),

              // Call control buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isReceivingCall && !callState.isCallInProgress) ...[
                      Column(
                        children: [
                          InkWell(
                            key: CallKeys.acceptCallButton,
                            onTap: () {
                              callNotifier.acceptCall();
                              _signaling.joinCall(voiceCallId!);
                            },
                            borderRadius: BorderRadius.circular(50),
                            splashColor: Colors.greenAccent,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.call,
                                  color: Colors.white,
                                  size: 30),
                            ),
                          ),
                          const Text('Accept', style: TextStyle(color: Palette.primaryText)),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            key: CallKeys.rejectCallButton,
                            onTap: () {
                              context.pop();
                              endCall();
                            },
                            borderRadius: BorderRadius.circular(50),
                            splashColor: Colors.redAccent,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.call_end,
                                  color: Colors.white,
                                  size: 30),
                            ),
                          ),
                          const Text('Decline', style: TextStyle(color: Palette.primaryText)),
                        ],
                      ),
                    ]
                    else ...[
                      _controlButton(
                        key: CallKeys.toggleSpeakerButton,
                        icon: callState.isSpeakerOn
                            ? Icons.volume_down
                            : Icons.volume_up,
                        isActive: callState.isSpeakerOn,
                        onTap: callNotifier.toggleSpeaker,
                      ),
                      _controlButton(
                        key: CallKeys.toggleVideoButton,
                        icon: callState.isVideoCall
                            ? Icons.videocam_off
                            : Icons.videocam,
                        isActive: callState.isVideoCall,
                        isVideoCall: true,
                        onTap: () {
                          _signaling.toggleVideoStream(!callState.isVideoCall);
                          callNotifier.toggleVideoCall();
                        },
                      ),
                      _controlButton(
                        key: CallKeys.toggleMuteButton,
                        icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                        isActive: callState.isMuted,
                        onTap: () {
                          callNotifier.toggleMute();
                          _signaling.toggleAudioStream();
                        },
                      ),
                      _controlButton(
                        key: CallKeys.endCallButton,
                        icon: Icons.call_end,
                        isActive: true,
                        isEndCall: true,
                        onTap: () {
                          context.pop();
                          endCall();
                        },
                      ),
                    ]
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
    Key? key,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isEndCall = false,
    bool isVideoCall = false,
  }) {
    return InkWell(
      key: key,
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
            color: isEndCall || !isActive ? Colors.white : Colors.blue.shade300,
            size: 30),
      ),
    );
  }
}
