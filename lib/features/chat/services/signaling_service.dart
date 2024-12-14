import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
import 'package:telware_cross_platform/features/chat/view_model/event_handler.dart';

typedef StreamStateCallback = void Function(MediaStream stream);
typedef DescriptionCallback = void Function(RTCSessionDescription description, String senderId);
typedef CandidateCallback = void Function(RTCIceCandidate candidate);
typedef ResponseCallback = void Function(dynamic response);

class Signaling {
  final EventHandler _eventHandler = EventHandler.instance;
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;
  DescriptionCallback? onOffer;
  DescriptionCallback? onAnswer;
  CandidateCallback? onICECandidate;
  ResponseCallback? onCallStarted;
  ResponseCallback? onReceiveJoinedCall;
  ResponseCallback? onReceiveLeftCall;

  String? roomId;

  void handleSignal(dynamic data) async {
    debugPrint('Received message: $data');


    if (data['type'] == 'OFFER') {
      final description = RTCSessionDescription(data['data'], "offer");
      onOffer?.call(description, data['senderId']);
    } else if (data['type'] == 'ANSWER') {
      final description = RTCSessionDescription(data['data'], "answer");
      onAnswer?.call(description, data['senderId']);
    } else if (data['type'] == 'ICE') {
      final candidate = RTCIceCandidate(
        data['data']['candidate'],
        data['data']['sdpMid'],
        data['data']['sdpMLineIndex'],
      );
      onICECandidate?.call(candidate);
    }
  }

  Future<RTCSessionDescription> createOffer(calleeId) async {
    await registerPeerConnection(calleeId);

    localStream?.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });

    var offer = await peerConnection!.createOffer();
    await setLocalDescription(offer);

    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    localStream?.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });

    peerConnection!.onTrack = (RTCTrackEvent event) async {
      debugPrint('Remote stream added');
      event.streams[0].getTracks().forEach((track) {
        remoteStream!.addTrack(track);
      });
    };

    var answer = await peerConnection!.createAnswer();
    await setLocalDescription(answer);

    return answer;
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await peerConnection!.addCandidate(candidate);
  }

  Future<void> registerPeerConnection(String callerId) async {
    peerConnection ??= await createPeerConnection(configuration);
    registerPeerConnectionListeners(callerId);
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    debugPrint('Setting remote description to: ${description.sdp}');
    debugPrint('Remote SDP: ${description.sdp}');
    await peerConnection!.setRemoteDescription(description);
  }

  Future<void> setLocalDescription(RTCSessionDescription description) async {
    debugPrint('Local SDP: ${description.sdp}');
    await peerConnection!.setLocalDescription(description);
  }

  Future<void> hangUp(RTCVideoRenderer localRenderer) async {
    closeUserMedia(localRenderer);

    remoteStream?.getTracks().forEach((track) {
      track.stop();
    });

    if (peerConnection != null) peerConnection!.close();
    _eventHandler.addEvent(
      LeaveCallEvent(
        {
          'voiceCallId': roomId,
        }
      )
    );

    localStream!.dispose();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners(String calleeId) {
    peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null) {
        debugPrint('Generated ICE Candidate: ${candidate.candidate}');
        debugPrint('Sending to peer...');
        _eventHandler.addEvent(
          SendSignalEvent(
            {
              'type': 'ICE',
              'data': {
                'candidate': candidate.candidate,
                'sdpMid': candidate.sdpMid,
                'sdpMLineIndex': candidate.sdpMLineIndex,
              },
              'targetId': calleeId,
              'voiceCallId': roomId,
            },
          )
        );
      }
    };

    peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection state changed: $state');
    };

    peerConnection!.onSignalingState = (RTCSignalingState state) {
      debugPrint('Signaling state changed: $state');
    };

    peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE connection state changed: $state');
    };

    peerConnection!.onTrack = (RTCTrackEvent event) async {
      if (event.streams.isNotEmpty) {
        for (var track in event.streams[0].getTracks()) {
          remoteStream?.addTrack(track);
        }
        onAddRemoteStream?.call(event.streams[0]);
      }
    };

    peerConnection!.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE gathering state changed: $state');
    };

    peerConnection!.onAddStream = (MediaStream stream) {
      debugPrint('Remote stream added');
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }

  void sendOffer(RTCSessionDescription offer, String targetId) {
    debugPrint('Sending offer to $targetId');
    debugPrint('Offer: ${offer.sdp}');
    _eventHandler.addEvent(
      SendSignalEvent(
        {
          'type': 'OFFER',
          'data': offer.sdp,
          'targetId': targetId,
          'voiceCallId': roomId,
        },
      )
    );
  }

  void sendAnswer(RTCSessionDescription answer, String targetId) {
    debugPrint('Sending answer to $targetId');
    _eventHandler.addEvent(
      SendSignalEvent(
        {
          'type': 'ANSWER',
          'data': answer.sdp,
          'targetId': targetId,
          'voiceCallId': roomId,
        },
      )
    );
  }

  void createVoiceCall(String? chatId, String? targetId) {
    _eventHandler.addEvent(
      CreateCallEvent(
        {
          'chatId': chatId,
          'targetId': targetId,
        },
        chatId: chatId,
      )
    );
  }

  // Create a new instance of Signaling
  Signaling._internal();

  // Singleton instance
  static final Signaling instance = Signaling._internal();

  void joinCall(String voiceCallId) {
    debugPrint('Chat: Joining call with id: $voiceCallId');
    roomId = voiceCallId;
    _eventHandler.addEvent(
      JoinCallEvent(
        {
          'voiceCallId': voiceCallId,
        }
      )
    );
  }

  Future<void> openUserMedia(RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer) async {
    var stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = stream;
    localStream = stream;

    remoteRenderer.srcObject = await createLocalMediaStream('remoteStream');
  }

  Future<void> closeUserMedia(RTCVideoRenderer localRenderer) async {
    localStream?.getTracks().forEach((track) {
      track.stop();
    });

    // Optionally clear the renderer
    localRenderer.srcObject = null;
  }
}
