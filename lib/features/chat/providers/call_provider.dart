import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/chat/models/call_state.dart';

class CallStateNotifier extends StateNotifier<CallState> {
  CallStateNotifier()
      : super(CallState(
    isCallActive: false,
    isMinimized: false,
  ));

  void setCallee(UserModel? callee) {
    state.setCallee(callee);
  }

  void setCaller(bool isCaller) {
    state = state.copyWith(isCaller: isCaller);
  }

  void startCall() {
    state = state.copyWith(
        startTime: DateTime.now(),
        isCallActive: true,
        isMinimized: false
    );
  }

  void minimizeCall() {
    if (state.voiceCallId != null) {
      state = state.copyWith(isMinimized: true);
    }
  }

  void maximizeCall() {
    if (state.voiceCallId != null) {
      state = state.copyWith(isMinimized: false);
    }
  }

  void endCall() {
    state = CallState(
        callee: null,
        voiceCallId: null,
        startTime: null,
        isCaller: false,
        isCallInProgress: false,
        isCallActive: false,
        isMinimized: false,
        isVideoCall: false,
        isMuted: false,
        isSpeakerOn: false
    );
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void toggleSpeaker() {
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }

  void toggleVideoCall() {
    state = state.copyWith(isVideoCall: !state.isVideoCall);
  }

  void removeUser(String userId) {
    state = state.copyWith(callee: null);
  }

  void setVoiceCallId(String? voiceCallId) {
    state.setVoiceCallId(voiceCallId);
  }

  bool isInCall() {
    return state.voiceCallId != null || state.isCaller;
  }

  void acceptCall() {
    state = state.copyWith(isCallInProgress: true);
  }

  void receiveCall(String voiceCallId, UserModel? caller) {
    state = state.copyWith(
        voiceCallId: voiceCallId,
        callee: caller,
        isCaller: false
    );
  }

  void setCallInProgress(bool isCallInProgress) {
    state = state.copyWith(isCallInProgress: isCallInProgress);
  }
}

final callStateProvider =
StateNotifierProvider<CallStateNotifier, CallState>((ref) {
  return CallStateNotifier();
});
