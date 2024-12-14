import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/chat/providers/call_provider.dart';

class CallOverlay extends StatelessWidget {
  final bool showDetails;

  const CallOverlay({super.key, this.showDetails = true});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final callState = ref.watch(callStateProvider);
        final callNotifier = ref.read(callStateProvider.notifier);
        final UserModel? callee = callState.callee;
        final String displayName = '${callee?.screenFirstName} ${callee?.screenLastName}';
        debugPrint("CallOverlay: voiceCallId: ${callState.voiceCallId}, isMinimized: ${callState.isMinimized}");
        if (callState.voiceCallId == null || !callState.isMinimized) {
          return const SizedBox.shrink(); // Do not show overlay if not minimized
        }

        return GestureDetector(
          onTap: () {
            callNotifier.maximizeCall();
            context.push(Routes.callScreen, extra: {'user': callee, 'voiceCallId': callState.voiceCallId});
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  Color.fromRGBO(8, 200, 156, 1.0),
                  Color.fromRGBO(8, 204, 133, 1.0),
                  Color.fromRGBO(8, 194, 103, 1.0),
                  Color.fromRGBO(8, 184, 103, 1.0),
                  Color.fromRGBO(12, 204, 71, 1.0),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: callee != null ? CircleAvatar(
                    radius: 15,
                    backgroundImage: callee.photoBytes != null ? MemoryImage(callee.photoBytes!) : null,
                    backgroundColor: callee.photoBytes == null ? Palette.primary : null,
                    child: callee.photoBytes == null
                        ? Text(
                            getInitials(displayName),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Palette.primaryText,
                            ),
                          )
                        : null,
                  ) : const SizedBox.shrink(),
                  title: Text(
                      showDetails ? displayName : "RETURN TO CALL",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Palette.primaryText,
                      ),
                      textAlign: TextAlign.center
                  ),
                  trailing: Icon(Icons.mic, color: Palette.primaryText),
                ),
              ),
            ),
          )
        );
      },
    );
  }
}