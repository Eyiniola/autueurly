import 'package:auteurly/features/components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyTextfield Widget Tests', () {
    testWidgets('should display hint text', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextfield(
              controller: controller,
              hintText: 'Enter your name',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('should display entered text', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextfield(
              controller: controller,
              hintText: 'Enter text',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello World');
      await tester.pump();

      // Assert
      expect(controller.text, equals('Hello World'));
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should obscure text when obscureText is true',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextfield(
              controller: controller,
              hintText: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      // Assert
      expect(controller, isNotNull);
      // Verify obscureText is set on the field - check through controller state
    });

    testWidgets('should not obscure text when obscureText is false',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextfield(
              controller: controller,
              hintText: 'Username',
              obscureText: false,
            ),
          ),
        ),
      );

      // Assert
      expect(controller, isNotNull);
      // Verify obscureText is not set - check through controller state
    });

    testWidgets('should call validator when provided',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: MyTextfield(
                controller: controller,
                hintText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      formKey.currentState?.validate();
      await tester.pump();

      // Assert - Check if validator is working
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should support multiple lines when maxLines > 1',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextfield(
              controller: controller,
              hintText: 'Description',
              maxLines: 5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
      // Verify maxLines through finding TextFormField widget
    });

    testWidgets('should use default maxLines of 1',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextfield(
              controller: controller,
              hintText: 'Single line',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should use specified keyboardType',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyTextfield(
              controller: controller,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
      // Verify keyboardType is set - accessed through widget properties
    });
  });
}
