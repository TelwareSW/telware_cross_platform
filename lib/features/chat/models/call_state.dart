import 'package:flutter/cupertino.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';

class CallState extends ChangeNotifier {
  UserModel? callee;
  // Add start time
  DateTime? startTime;
  bool isCallActive = false;
  bool isMinimized = false;
  bool isVideoCall = false;
  bool isMuted = false;
  bool isSpeakerOn = false;

  CallState({
    this.callee,
    this.startTime,
    required this.isCallActive,
    required this.isMinimized,
    this.isVideoCall = false,
    this.isMuted = false,
    this.isSpeakerOn = false,
  });


  CallState copyWith({
    UserModel? callee,
    DateTime? startTime,
    bool? isCallActive,
    bool? isMinimized,
    bool? isVideoCall,
    bool? isMuted,
    bool? isSpeakerOn,
  }) {
    return CallState(
      callee: callee ?? this.callee,
      startTime: startTime ?? this.startTime,
      isCallActive: isCallActive ?? this.isCallActive,
      isMinimized: isMinimized ?? this.isMinimized,
      isVideoCall: isVideoCall ?? this.isVideoCall,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }
}
