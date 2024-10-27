import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';

void main() {
  group('Settings Option Widget Tests', () {
    testWidgets('renders widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsOptionWidget(
              key: ValueKey("option1-option"),
              text: "Option 1",
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey("option1-option")), findsOneWidget,
          reason: "Expected settings option widget to render.");
    });

    testWidgets('renders icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsOptionWidget(
              key: ValueKey("option1-option"),
              text: "Option 1",
              icon: Icons.security,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey("option1-option-icon")), findsOneWidget,
          reason: "Expected icon to render.");
    });

    testWidgets('renders trailing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsOptionWidget(
              key: ValueKey("option1-option"),
              text: "Option 1",
              trailing: "Everybody",
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey("option1-option-trailing")), findsOneWidget,
          reason: "Expected trailing text to render.");
    });
  });
}
