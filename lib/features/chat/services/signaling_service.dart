import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef StreamStateCallback = void Function(MediaStream stream);
typedef DescriptionCallback = void Function(RTCSessionDescription description);
typedef CandidateCallback = void Function(RTCIceCandidate candidate);

class Signaling {
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

  late IO.Socket socket;

  String? roomId;

  Signaling() {
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to signaling server');
    });

    socket.on('signal', (data) {
      handleSignal(data);
    });

    socket.onDisconnect((_) {
      print('Disconnected from signaling server');
    });
  }

  void handleSignal(dynamic data) async {
    Map<String, dynamic> message = jsonDecode(data);

    if (message['type'] == 'offer') {
      final description = RTCSessionDescription(message['sdp'], message['type']);
      onOffer?.call(description);
    } else if (message['type'] == 'answer') {
      final description = RTCSessionDescription(message['sdp'], message['type']);
      onAnswer?.call(description);
    } else if (message['type'] == 'candidate') {
      final candidate = RTCIceCandidate(
        message['candidate'],
        message['sdpMid'],
        message['sdpMLineIndex'],
      );
      onICECandidate?.call(candidate);
    }
  }

  Future<RTCSessionDescription> createOffer() async {
    peerConnection = await createPeerConnection(configuration);
    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    var offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    socket.emit('signal', jsonEncode({
      'type': 'offer',
      'sdp': offer.sdp,
      'room': roomId,
    }));

    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    var answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    socket.emit('signal', jsonEncode({
      'type': 'answer',
      'sdp': answer.sdp,
      'room': roomId,
    }));

    return answer;
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await peerConnection?.addCandidate(candidate);
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await peerConnection?.setRemoteDescription(description);
  }

  void setLocalDescription(RTCSessionDescription description) {
    peerConnection?.setLocalDescription(description);
  }

  Future<void> openUserMedia() async {
    localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': false,
    });
  }

  Future<void> hangUp() async {
    localStream?.getTracks().forEach((track) {
      track.stop();
    });

    if (peerConnection != null) peerConnection!.close();
    socket.disconnect();
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null) {
        socket.emit('signal', jsonEncode({
          'type': 'candidate',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'room': roomId,
        }));
      }
    };

    peerConnection?.onTrack = (RTCTrackEvent event) {
      event.streams[0].getTracks().forEach((track) {
        remoteStream?.addTrack(track);
      });
      onAddRemoteStream?.call(event.streams[0]);
    };
  }

  void sendOffer(RTCSessionDescription offer) {
    socket.emit('signal', jsonEncode({
      'type': 'offer',
      'sdp': offer.sdp,
      'room': roomId,
    }));
  }

  void sendAnswer(RTCSessionDescription answer) {
    socket.emit('signal', jsonEncode({
      'type': 'answer',
      'sdp': answer.sdp,
      'room': roomId,
    }));
  }

  void dispose() {
    hangUp();
  }

}
