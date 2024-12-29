import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../model/model.dart';
import '../view/screens/devices_screen.dart';

class DevicesViewModel extends StateNotifier<AsyncValue<List<Session>>> {
  DevicesViewModel() : super(const AsyncValue.loading());

  Future<void> fetchSessions(BuildContext context) async {
    try {
      await Future.delayed(
          const Duration(seconds: 2)); // Simulate network delay
      final sessions = [
        Session(
          title: "Current session",
          options: [
            SessionOption(
              icon: FontAwesomeIcons.android,
              phoneName: 'Redmi Redmi Note 8 Pro',
              telegramVersion: "Telegram Android 11.2.3",
              location: "Cairo, Egypt",
              state: "online",
            ),
          ],
          trailing: "Logs out all devices except this one",
        ),
        Session(
          title: "Active sessions",
          options: [
            SessionOption(
              icon: FontAwesomeIcons.android,
              phoneName: 'Redmi Redmi Note 8 Pro',
              telegramVersion: "Telegram Android 11.2.3",
              location: "Cairo, Egypt",
              state: "online",
            ),
            SessionOption(
              icon: FontAwesomeIcons.edge,
              phoneName: 'Microsoft Edge 130',
              telegramVersion: "Telegram Web 11.2.3",
              location: "Texas, USA",
              state: "8:33 PM",
            ),
            SessionOption(
              icon: FontAwesomeIcons.apple,
              phoneName: 'iPhone 15 Pro',
              telegramVersion: "Telegram iOS 11.2.3",
              location: "Texas, USA",
              state: "online",
            ),
          ],
          trailing:
              "The official Telegram app is available for Android, iPhone, iPad, Windows, macOS and Linux.",
        ),
      ];
      final currentSessionSection = sessions.firstWhere(
        (section) => section.title == "Current session",
        orElse: () => Session(
            title: 'title',
            options: [
              SessionOption(
                  icon: FontAwesomeIcons.apple,
                  phoneName: 'phoneName',
                  telegramVersion: 'telegramVersion',
                  location: 'location',
                  state: 'state')
            ],
            trailing: 'trailing'),
      );
      currentSessionSection.options.add(SessionOption(
        icon: FontAwesomeIcons.hand,
        phoneName: 'Terminate All Other Sessions',
        color: Colors.red,
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertTerminateSessionConformation(
                body: "Are you sure you want to terminate all other sessions?",
                title: "Terminate other sessions",
                conformationText: "Terminate",
                functionOnConfirmed: () {},
              );
            },
          );
        },
        telegramVersion: '',
        location: '',
        state: '',
      ));
      currentSessionSection.options.add(SessionOption(
        icon: FontAwesomeIcons.xmark,
        phoneName: 'Terminate All Sessions',
        color: Colors.red,
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertTerminateSessionConformation(
                body: "Are you sure you want to terminate all sessions?",
                title: "Terminate all sessions",
                conformationText: "Terminate",
                functionOnConfirmed: () {},
              );
            },
          );
        },
        telegramVersion: '',
        location: '',
        state: '',
      ));
      state = AsyncValue.data(sessions);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

final devicesViewModelProvider =
    StateNotifierProvider<DevicesViewModel, AsyncValue<List<Session>>>((ref) {
  return DevicesViewModel();
});
