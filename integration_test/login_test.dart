import 'package:telware_cross_platform/core/constants/keys.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:telware_cross_platform/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Tests', () {
    // setUpAll(() async {
    //   // Start the app
    //   app.main();
    //   await tester.pumpAndSettle();
    // });

    testWidgets('valid login credentials', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // Enter valid email
      //var emailInput = find.byType(TextFormField).at(0);
      var emailInput = find.byKey(Keys.logInEmailKey);
      await tester.enterText(emailInput, 'validuser@example.com');
      await tester.pumpAndSettle(const Duration(seconds: 1));
      //await tester.pumpAndSettle(const Duration(seconds: 1));
      // Enter valid password
      // await tester.enterText(
      //   find.byKey(const Key('login_password_input')),
      //   'validpassword',
      // );
      // await tester.pumpAndSettle(const Duration(seconds: 1));
      // // Tap on login button
      // await tester.tap(find.byKey(const Key('login_submit_button')));
      // await tester.pumpAndSettle();

      // // Verify navigation to home
      // expect(find.text('/'), findsOneWidget);
    });

    // testWidgets('invalid login credentials', (WidgetTester tester) async {
    //   // Assert error message is not visible at the beginning
    //   expect(find.text('Invalid email or password'), findsNothing);

    //   // Enter invalid email and password
    //   await tester.enterText(
    //     find.byKey(const Key('login-email-input')),
    //     'invaliduser@example.com',
    //   );
    //   await tester.enterText(
    //     find.byKey(const Key('login-password-input')),
    //     'wrongpassword',
    //   );
    //   // Tap on login button
    //   await tester.tap(find.byKey(const Key('login_submit_button')));
    //   await tester.pumpAndSettle();

    //   // Assert error message is shown
    //   expect(find.text('Invalid email or password'), findsOneWidget);

    //   // Assert that the email is still in the input field
    //   expect(find.text('invaliduser@example.com'), findsOneWidget);
    // });

    // testWidgets('blank login credentials', (WidgetTester tester) async {
    //   // Assert no validation message at the beginning
    //   expect(find.text('Email is required'), findsNothing);
    //   expect(find.text('Password is required'), findsNothing);

    //   // Tap on login button without filling form
    //   await tester.tap(find.byKey(const Key('login_submit_button')));
    //   await tester.pumpAndSettle();

    //   // Assert validation messages
    //   expect(find.text('Email is required'), findsOneWidget);
    //   expect(find.text('Password is required'), findsOneWidget);
    // });

    // testWidgets('forgot password, signup and long input tests',
    //     (WidgetTester tester) async {
    //   // Assert 'reset your password' message is not visible initially
    //   expect(find.text('Reset your password'), findsNothing);

    //   // Tap on forgot password
    //   await tester.tap(find.byKey(const Key('login_forgot_password_button')));
    //   await tester.pumpAndSettle();

    //   // Assert 'reset your password' message is visible
    //   expect(find.text('Reset your password'), findsOneWidget);

    //   // Close modal
    //   await tester.tap(find.byKey(const Key('modal-close-button')));
    //   await tester.pumpAndSettle();

    //   // Assert 'reset your password' message is no longer visible
    //   expect(find.text('Reset your password'), findsNothing);

    //   // Long input test
    //   await tester.enterText(
    //     find.byKey(const Key('login-email-input')),
    //     'averylongemailaddress@averylongdomainname.com',
    //   );
    //   await tester.enterText(
    //     find.byKey(const Key('login-password-input')),
    //     'averylongpasswordthatexceedslimits',
    //   );
    //   await tester.tap(find.byKey(const Key('login_submit_button')));
    //   await tester.pumpAndSettle();

    //   // Assert error message for long input
    //   expect(find.text('Very long email or password'), findsOneWidget);
    // });
  });
}
