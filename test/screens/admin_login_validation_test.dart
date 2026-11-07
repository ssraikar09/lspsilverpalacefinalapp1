import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_silver_app/screens/admin_login_screen.dart';

void main() {
  group('AdminLoginScreen Validation & UI Interaction Tests', () {
    testWidgets('shows validation error messages when fields are submitted empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminLoginScreen(),
        ),
      );

      // Verify initial UI elements
      expect(find.text('Admin Portal'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);

      // Tap SIGN IN without typing anything
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      // Expect field validation error messages
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows invalid email format validation when email does not contain @', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminLoginScreen(),
        ),
      );

      final emailFields = find.byType(TextFormField);
      final emailField = emailFields.at(0);
      final passwordField = emailFields.at(1);

      await tester.enterText(emailField, 'not-an-email');
      await tester.enterText(passwordField, 'secret123');

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('toggles password obscure text visibility when suffix icon is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminLoginScreen(),
        ),
      );

      final passwordFormFieldFinder = find.byType(TextFormField).at(1);
      final passwordTextFieldFinder = find.descendant(
        of: passwordFormFieldFinder,
        matching: find.byType(TextField),
      );

      TextField passwordTextField = tester.widget<TextField>(passwordTextFieldFinder);
      expect(passwordTextField.obscureText, isTrue);

      // Tap the eye icon to show password
      final toggleButton = find.byIcon(Icons.visibility);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // Icon changes to visibility_off and text is no longer obscured
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      passwordTextField = tester.widget<TextField>(passwordTextFieldFinder);
      expect(passwordTextField.obscureText, isFalse);
    });
  });
}
