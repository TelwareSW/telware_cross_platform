import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_input_widget.dart';

void main() {
  group('Settings Input Widget Tests', () {
    testWidgets('renders input and letters cap objects', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      const int lettersCap = 70;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsInputWidget(
              key: const ValueKey("input1-container"),
              controller: controller,
              lettersCap: lettersCap,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey("input1-container")), findsOneWidget,
          reason: "Expected settings input widget to render.");

      expect(find.byKey(const ValueKey("input1-container-input")), findsOneWidget,
          reason: "Expected input field to render.");
      final Finder lettersCapFind = find.byKey(const ValueKey("input1-container-letters-cap"));
      expect(lettersCapFind, findsOneWidget,
          reason: "Expected letters cap to render.");
      final Text lettersCapText = tester.firstWidget(lettersCapFind);
      expect(lettersCapText.data, lettersCap.toString(),
          reason: "Expected letters cap to be $lettersCap.");
    });

    testWidgets('renders placeholder', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      const String placeholder = "A Place Holder";
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsInputWidget(
              key: const ValueKey("input1-container"),
              controller: controller,
              placeholder: placeholder,
            ),
          ),
        ),
      );

      final Finder inputFind = find.byKey(const ValueKey("input1-container-input"));
      final TextField inputField = tester.firstWidget(inputFind);
      expect(inputField.decoration?.hintText, placeholder,
          reason: "Expected placeholder to be $placeholder.");
    });

    testWidgets('writes valid values', (WidgetTester tester) async {
      const String inputValue = "Value";
      final TextEditingController controller = TextEditingController(text: inputValue);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsInputWidget(
              key: const ValueKey("input1-container"),
              controller: controller,
            ),
          ),
        ),
      );

      final Finder textFind = find.byKey(const ValueKey("input1-container-input"));
      final TextField inputField = tester.firstWidget(textFind);
      expect(inputField.controller?.text, inputValue,
          reason: "Expected input value to be $inputValue");
      const String newInputValue = "new text";
      await tester.enterText(textFind, newInputValue);
      await tester.pump();
      expect(inputField.controller?.text, newInputValue,
          reason: "Expected updated input value to be $newInputValue");
    });

    testWidgets('monitors letters input', (WidgetTester tester) async {
      const String inputValue = "Value";
      const int lettersCap = 10;
      final TextEditingController controller = TextEditingController(text: inputValue);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsInputWidget(
              key: const ValueKey("input1-container"),
              controller: controller,
              lettersCap: lettersCap,
            ),
          ),
        ),
      );

      final Finder inputFind = find.byKey(const ValueKey("input1-container-input"));
      final Finder lettersCapFind = find.byKey(const ValueKey("input1-container-letters-cap"));
      expect(inputFind, findsOneWidget,
          reason: "Expected letters cap to render");
      final Text lettersCapText = tester.firstWidget(lettersCapFind);
      expect(lettersCapText.data, (lettersCap - inputValue.length).toString(),
          reason: "Expected letters cap to be ${lettersCap - inputValue.length}.");
      await tester.enterText(inputFind, "A"*(lettersCap+10));
      await tester.pump();
      final Text updatedLettersCapText = tester.firstWidget(lettersCapFind);
      expect(updatedLettersCapText.data, "0",
          reason: "Expected letters cap to be 0.");
      final TextField inputField = tester.firstWidget(inputFind);
      expect(inputField.controller?.text, "A"*lettersCap,
          reason: "Expected input value to not exceed the letters cap.");
    });

    testWidgets('doesn\'t render all components by default', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsInputWidget(
              key: const ValueKey("input1-container"),
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey("input1-container-letters-cap")), findsNothing,
          reason: "Expected letters cap to not render.");
      final Finder inputFind = find.byKey(const ValueKey("input1-container-input"));
      final TextField inputField = tester.firstWidget(inputFind);
      expect(inputField.decoration?.hintText, "",
          reason: "Expected placeholder value to be empty.");
    });
  });
}
