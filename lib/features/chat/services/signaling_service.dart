import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
import 'package:telware_cross_platform/features/chat/view_model/event_handler.dart';

typedef StreamStateCallback = void Function(MediaStream stream, String senderId);
typedef DescriptionCallback = void Function(RTCSessionDescription description, String senderId);
typedef CandidateCallback = void Function(RTCIceCandidate candidate, String senderId);
typedef ResponseCallback = void Function(dynamic response);

final TURN_SERVER_USERNAME = dotenv.env['TURN_SERVER_USERNAME'] ?? '';
final TURN_SERVER_PASSWORD = dotenv.env['TURN_SERVER_CREDENTIAL'] ?? '';

class Signaling {
  final EventHandler _eventHandler = EventHandler.instance;

  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      },
      {
        'urls': "turn:global.relay.metered.ca:80",
        'username': TURN_SERVER_USERNAME,
        'credential': TURN_SERVER_PASSWORD,
      },
      {
        'urls': "turn:global.relay.metered.ca:80?transport=tcp",
        'username': TURN_SERVER_USERNAME,
        'credential': TURN_SERVER_PASSWORD,
      },
      {
        'urls': "turn:global.relay.metered.ca:443",
        'username': TURN_SERVER_USERNAME,
        'credential': TURN_SERVER_PASSWORD,
      },
      {
        'urls': "turns:global.relay.metered.ca:443?transport=tcp",
        'username': TURN_SERVER_USERNAME,
        'credential': TURN_SERVER_PASSWORD,
      },
    ]
  };

  Map<String, RTCPeerConnection> peerConnections = {};
  MediaStream? localStream;
  Map<String, MediaStream> remoteStreams = {};
  StreamStateCallback? onAddRemoteStream;
  DescriptionCallback? onOffer;
  DescriptionCallback? onAnswer;
  CandidateCallback? onICECandidate;
  ResponseCallback? onCallStarted;
  ResponseCallback? onReceiveJoinedCall;
  ResponseCallback? onReceiveLeftCall;
  ResponseCallback? onReceiveEndCall;

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
      onICECandidate?.call(candidate, data['senderId']);
    }
  }

  Future<RTCSessionDescription> createOffer(clientId) async {
    await registerPeerConnection(clientId);

    localStream?.getTracks().forEach((track) {
      peerConnections[clientId]!.addTrack(track, localStream!);
    });

    var offer = await peerConnections[clientId]!.createOffer();
    await setLocalDescription(offer, clientId);

    return offer;
  }

  Future<RTCSessionDescription> createAnswer(String clientId) async {
    localStream?.getTracks().forEach((track) {
      peerConnections[clientId]!.addTrack(track, localStream!);
    });

    peerConnections[clientId]!.onTrack = (RTCTrackEvent event) async {
      debugPrint('Remote stream added');
      event.streams[0].getTracks().forEach((track) {
        remoteStreams[clientId]!.addTrack(track);
      });
    };

    var answer = await peerConnections[clientId]!.createAnswer();
    await setLocalDescription(answer, clientId);

    return answer;
  }

  Future<void> addCandidate(RTCIceCandidate candidate, String clientId) async {
    await peerConnections[clientId]!.addCandidate(candidate);
  }

  Future<void> registerPeerConnection(String clientId) async {
    peerConnections[clientId] ??= await createPeerConnection(configuration);
    registerPeerConnectionListeners(clientId);
  }

  Future<void> setRemoteDescription(RTCSessionDescription description, String clientId) async {
    debugPrint('Setting remote description to: ${description.sdp}');
    debugPrint('Remote SDP: ${description.sdp}');
    await peerConnections[clientId]!.setRemoteDescription(description);
  }

  Future<void> setLocalDescription(RTCSessionDescription description, String clientId) async {
    debugPrint('Local SDP: ${description.sdp}');
    await peerConnections[clientId]!.setLocalDescription(description);
  }

  Future<void> hangUp(RTCVideoRenderer localRenderer) async {
    closeUserMedia(localRenderer);

    remoteStreams.forEach((key, value) {
      value.getTracks().forEach((track) {
        track.stop();
      });
    });
    remoteStreams.clear();

    peerConnections.forEach((key, value) {
      value.close();
    });
    peerConnections.clear();

    _eventHandler.addEvent(
      LeaveCallEvent(
        {
          'voiceCallId': roomId,
        }
      )
    );

    localStream!.dispose();
  }

  Future<void> removeRemoteClient(String clientId) async {
    peerConnections[clientId]?.close();
    peerConnections.remove(clientId);

    remoteStreams[clientId]?.getTracks().forEach((track) {
      track.stop();
    });
    remoteStreams.remove(clientId);
  }

  void registerPeerConnectionListeners(String clientId) {
    peerConnections[clientId]!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null) {
        debugPrint('Generated ICE Candidate');
        _eventHandler.addEvent(
          SendSignalEvent(
            {
              'type': 'ICE',
              'data': {
                'candidate': candidate.candidate,
                'sdpMid': candidate.sdpMid,
                'sdpMLineIndex': candidate.sdpMLineIndex,
              },
              'targetId': clientId,
              'voiceCallId': roomId,
            },
          )
        );
      }
    };

    peerConnections[clientId]!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection state changed: $state');
    };

    peerConnections[clientId]!.onSignalingState = (RTCSignalingState state) {
      debugPrint('Signaling state changed: $state');
    };

    peerConnections[clientId]!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE connection state changed: $state');
    };

    peerConnections[clientId]!.onTrack = (RTCTrackEvent event) async {
      if (event.streams.isNotEmpty) {
        for (var track in event.streams[0].getTracks()) {
          remoteStreams[clientId]?.addTrack(track);
        }
        onAddRemoteStream?.call(event.streams[0], clientId);
      }
    };

    peerConnections[clientId]!.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE gathering state changed: $state');
    };

    peerConnections[clientId]!.onAddStream = (MediaStream stream) {
      debugPrint('Remote stream added');
      onAddRemoteStream?.call(stream, clientId);
      remoteStreams[clientId] = stream;
    };
  }

  void sendOffer(RTCSessionDescription offer, String targetId) {
    debugPrint('Sending offer to $targetId');
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
        // todo(mo): chack if the chat Id might be null or not
        chatId: chatId!,
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

  Future<void> openUserMedia(RTCVideoRenderer localRenderer) async {
    var stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = stream;
    localStream = stream;
  }

  Future<void> updateRemoteRenderer(RTCVideoRenderer remoteRenderer) async {
    remoteRenderer.srcObject = await createLocalMediaStream('remoteStream');
  }

  Future<void> closeUserMedia(RTCVideoRenderer localRenderer) async {
    localStream?.getTracks().forEach((track) {
      track.stop();
    });

    // Optionally clear the renderer
    localRenderer.srcObject = null;
  }

  void toggleVideoStream(bool isVideoEnabled) {
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoEnabled;
    });
  }

  void toggleAudioStream() {
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = !track.enabled;
    });
  }
}
