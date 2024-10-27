import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';

void main() {
  group('Settings Section Widget Tests', () {
    testWidgets('renders title and settings options', (WidgetTester tester) async {
      final settingsOptions = [
        {
          "key": "option1-option",
          "text": "Option 1",
          "route": "/option1",
          "icon": Icons.settings,
          "type": "normal",
        },
        {
          "key": "option2-option",
          "text": "Option 2",
          "route": "locked",
          "icon": Icons.lock,
          "type": "locked",
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSection(
              title: "Settings",
              settingsOptions: settingsOptions,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey("settings-section")), findsOneWidget,
          reason: "Expected settings section to render");

      expect(find.byKey(const ValueKey("settings-section-title")), findsOneWidget,
          reason: "Expected section title to render");

      expect(find.byKey(const ValueKey("option1-option")), findsOneWidget,
          reason: "Expected first option to render");
      expect(find.byKey(const ValueKey("option2-option")), findsOneWidget,
          reason: "Expected second option to render");
    });

    testWidgets('navigates to the correct path on option tap', (WidgetTester tester) async {
      final settingsOptions = [
        {
          "key": "option1-option",
          "text": "Option 1",
          "route": "/option1",
          "icon": Icons.settings,
        },
      ];

      // Create a MaterialApp with a route defined
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSection(
              title: "Settings",
              settingsOptions: settingsOptions,
            ),
          ),
          routes: {
            '/option1': (context) => const Scaffold(body: Center(child: Text('Option 1 Screen'))),
          },
        ),
      );

      expect(find.byKey(const ValueKey("option1-option")), findsOneWidget,
          reason: "The first option didn't render");

      await tester.tap(find.byKey(const ValueKey("option1-option")));
      await tester.pumpAndSettle(); // Wait for navigation to complete

      final BuildContext currentContext = tester.element(find.byType(SettingsSection));
      final currentRoute = Navigator.of(currentContext).context.findAncestorWidgetOfExactType<MaterialApp>()?.routes?.entries
          .firstWhere((entry) => entry.value.call(currentContext) is Scaffold)
          .key;
      expect(currentRoute, '/option1', reason: "Expected to navigate to '/option1'");
    });
  });
}

