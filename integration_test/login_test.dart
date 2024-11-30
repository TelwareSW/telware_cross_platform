import 'package:telware_cross_platform/core/constants/keys.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:telware_cross_platform/features/home/view/screens/home_screen.dart';
import 'package:telware_cross_platform/main.dart' as app;

import 'utils/test_users.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  //DONE
  // group("Login Tests", () {
  //   testWidgets("valid login credentials", (WidgetTester tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 2));
  //
  //     var emailInput = find.byKey(Keys.logInEmailKey);
  //     var passwordInput = find.byKey(Keys.logInPasswordKey);
  //     var submitButton = find.byKey(Keys.logInSubmitKey);
  //
  //     await tester.enterText(emailInput, validUsers[0][0]);
  //     await tester.pumpAndSettle(const Duration(seconds: 1));
  //     await tester.enterText(passwordInput, validUsers[0][1]);
  //     await tester.pumpAndSettle(const Duration(seconds: 1));
  //     await tester.tap(submitButton);
  //     await tester.pumpAndSettle(const Duration(seconds: 2));
  //
  //     // Verify that the user is redirected to the home page
  //     expect(find.text('TelWare'), findsOneWidget);
  //   });

    //ToddO: till toasts are solved
    // testWidgets("invalid login credentials", (WidgetTester tester) async {
    //   var emailInput = find.byKey(Keys.logInEmailKey);
    //   var passwordInput = find.byKey(Keys.logInPasswordKey);
    //   var submitButton = find.byKey(Keys.logInSubmitKey);
    //
    //   expect(find.text('Invalid email or password'), findsNothing);
    //   await tester.enterText(emailInput, invalidUsers[0].email);
    //   await tester.enterText(passwordInput, invalidUsers[0].password);
    //   await tester.tap(submitButton);
    //   await tester.pumpAndSettle();
    //
    //   expect(find.text('Invalid email or password'), findsOneWidget);
    //   expect(find.text(invalidUsers[0].email), findsOneWidget);
    // });

  //DONE
    // testWidgets("invalid email or short password", (WidgetTester tester) async {
    //   app.main();
    //   await tester.pumpAndSettle(const Duration(seconds: 2));
    //
    //   var emailInput = find.byKey(Keys.logInEmailKey);
    //   var passwordInput = find.byKey(Keys.logInPasswordKey);
    //   var submitButton = find.byKey(Keys.logInSubmitKey);
    //
    //   expect(find.text('Enter a valid email address'), findsNothing);
    //   expect(find.text('Password must be at least 8 characters long'), findsNothing);
    //   await tester.enterText(emailInput, validUsers[0][0]);
    //   await tester.pumpAndSettle(const Duration(seconds: 1));
    //
    //   await tester.enterText(passwordInput, validUsers[0][1]);
    //   await tester.pumpAndSettle(const Duration(seconds: 1));
    //
    //   await tester.tap(submitButton);
    //   await tester.pumpAndSettle(const Duration(seconds: 2));
    //
    //   expect(find.text('Enter a valid email address'), findsNothing);
    //   expect(find.text('Password must be at least 8 characters long'), findsNothing);
    //
    // });

    // ASK ahmed about shaking
    testWidgets("blank login credentials", (WidgetTester tester) async {
      var submitButton = find.byKey(Keys.logInSubmitKey);

      expect(find.text('Email is required'), findsNothing);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    // DONE
    // testWidgets("forget password & signup click", (WidgetTester tester) async {
    //   app.main();
    //   await tester.pumpAndSettle(const Duration(seconds: 2));
    //
    //   var signupLink = find.byKey(Keys.logInSignUpKey);
    //   await tester.tap(signupLink);
    //   await tester.pumpAndSettle(const Duration(seconds: 1));
    //
    //   expect(find.text('Your email address'), findsOneWidget);
    //   // navigate back to test the forget password
    //   await tester.tap(find.byTooltip('Back'));
    //   await tester.pumpAndSettle(const Duration(seconds: 1));
    //
    //   expect(find.text('Enter your credentials'), findsOneWidget);
    // });

  //DONE
  //   testWidgets("long inputs tests", (WidgetTester tester) async {
  //       app.main();
  //       await tester.pumpAndSettle(const Duration(seconds: 2));
  //
  //     var emailInput = find.byKey(Keys.logInEmailKey);
  //     var passwordInput = find.byKey(Keys.logInPasswordKey);
  //     var submitButton = find.byKey(Keys.logInSubmitKey);
  //
  //     await tester.enterText(emailInput, invalidUsers[2][0]);
  //     await tester.pumpAndSettle(const Duration(seconds: 1));
  //
  //     await tester.enterText(passwordInput, invalidUsers[2][1]);
  //     await tester.pumpAndSettle(const Duration(seconds: 1));
  //
  //     await tester.tap(submitButton);
  //     await tester.pumpAndSettle();
  //
  //     expect(find.text('Very long email or password'), findsOneWidget);
  //   });
  //});
}
