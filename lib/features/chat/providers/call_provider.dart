import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/chat/models/call_state.dart';

class CallStateNotifier extends StateNotifier<CallState> {
  CallStateNotifier()
      : super(CallState(
    isCallActive: false,
    isMinimized: false,
  ));

  void setCallee(UserModel callee) {
    state = state.copyWith(callee: callee);
  }

  void startCall() {
    state = state.copyWith(
        startTime: DateTime.now(),
        isCallActive: true,
        isMinimized: false
    );
  }

  void minimizeCall() {
    if (state.isCallActive) {
      state = state.copyWith(isMinimized: true);
    }
  }

  void maximizeCall() {
    if (state.isCallActive) {
      state = state.copyWith(isMinimized: false);
    }
  }

  void endCall() {
    state = state.copyWith(
        callee: null,
        startTime: null,
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
}

final callStateProvider =
StateNotifierProvider<CallStateNotifier, CallState>((ref) {
  return CallStateNotifier();
});
