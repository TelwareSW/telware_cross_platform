import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:telware_cross_platform/features/user/view/screens/devices_screen.dart';

class MockDevicesScreen extends DevicesScreen {
  @override
  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    // Return mock data similar to your actual _fetchSessions data
    return [
      {
        "title": "Current session",
        "options": [
          {
            "icon": FontAwesomeIcons.android,
            "phoneName": 'Redmi Redmi Note 8 Pro',
            "telegramVersion": "Telegram Android 11.2.3",
            "location": "Cairo, Egypt",
            "state": "online"
          },
          {
            "icon": FontAwesomeIcons.hand,
            "phoneName": 'Terminate All Other Sessions',
            "color": Colors.red
          },
        ],
        "trailing": "Logs out all devices except this one",
      },
    ];
  }
}

void main() {
  testWidgets('DevicesScreen displays loading indicator while waiting', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DevicesScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('DevicesScreen displays error message on Future error', (WidgetTester tester) async {
    final screen = MockDevicesScreen();

    // Simulate an error in _fetchSessions
    when(screen._fetchSessions()).thenThrow(Exception('Failed to load sessions'));

    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pump(); // Trigger FutureBuilder rebuild

    expect(find.text('Error: Failed to load sessions'), findsOneWidget);
  });

  testWidgets('DevicesScreen displays session tiles', (WidgetTester tester) async {
    final screen = MockDevicesScreen();

    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle(); // Wait for FutureBuilder to complete

    // Verify title and trailing text
    expect(find.text('Current session'), findsOneWidget);
    expect(find.text('Logs out all devices except this one'), findsOneWidget);

    // Verify session tiles data
    expect(find.text('Redmi Redmi Note 8 Pro'), findsOneWidget);
    expect(find.text('Telegram Android 11.2.3'), findsOneWidget);
    expect(find.text('Cairo, Egypt'), findsOneWidget);
  });

  testWidgets('SessionTile displays the correct information', (WidgetTester tester) async {
    var sessionTile = SessionTile(
      icon: Icons.android,
      text: 'Redmi Redmi Note 8 Pro',
      telegramPlatform: 'Telegram Android 11.2.3',
      location: 'Cairo, Egypt', onTap: () {  },
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: sessionTile)));

    expect(find.text('Redmi Redmi Note 8 Pro'), findsOneWidget);
    expect(find.text('Telegram Android 11.2.3'), findsOneWidget);
    expect(find.text('Cairo, Egypt'), findsOneWidget);
  });

  testWidgets('LeadingIcon displays icon with container', (WidgetTester tester) async {
    const leadingIcon = LeadingIcon(icon: Icons.android, showContainer: true);

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: leadingIcon)));

    expect(find.byType(Container), findsOneWidget);
    expect(find.byIcon(Icons.android), findsOneWidget);
  });

  testWidgets('DevicesScreen scrolls when there are many sessions', (WidgetTester tester) async {
    final screen = MockDevicesScreen();

    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();

    final listFinder = find.byType(SingleChildScrollView);
    await tester.drag(listFinder, const Offset(0, -300)); // Scroll up
    await tester.pump();

    // Ensure more widgets are in view after scrolling
    expect(find.text('Microsoft Edge 130'), findsOneWidget);
  });
}




