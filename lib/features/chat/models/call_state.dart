import 'package:flutter/cupertino.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

class CallState extends ChangeNotifier {
  UserModel? callee;
  String? voiceCallId;
  // Add start time
  DateTime? startTime;
  bool isCaller = false;
  bool isCallInProgress = false;
  bool isCallActive = false;
  bool isMinimized = false;
  bool isVideoCall = false;
  bool isMuted = false;
  bool isSpeakerOn = false;

  CallState({
    this.callee,
    this.voiceCallId,
    this.startTime,
    this.isCaller = false,
    this.isCallInProgress = false,
    required this.isCallActive,
    required this.isMinimized,
    this.isVideoCall = false,
    this.isMuted = false,
    this.isSpeakerOn = false,
  });

  void setCallee(UserModel? callee) {
    this.callee = callee;
    notifyListeners();
  }

  void setVoiceCallId(String? voiceCallId) {
    this.voiceCallId = voiceCallId;
    notifyListeners();
  }

  CallState copyWith({
    UserModel? callee,
    String? voiceCallId,
    DateTime? startTime,
    bool? isCaller,
    bool? isCallInProgress,
    bool? isCallActive,
    bool? isMinimized,
    bool? isVideoCall,
    bool? isMuted,
    bool? isSpeakerOn,
  }) {
    return CallState(
      callee: callee ?? this.callee,
      voiceCallId: voiceCallId ?? this.voiceCallId,
      startTime: startTime ?? this.startTime,
      isCaller: isCaller ?? this.isCaller,
      isCallInProgress: isCallInProgress ?? this.isCallInProgress,
      isCallActive: isCallActive ?? this.isCallActive,
      isMinimized: isMinimized ?? this.isMinimized,
      isVideoCall: isVideoCall ?? this.isVideoCall,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }
}
