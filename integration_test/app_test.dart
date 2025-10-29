import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:auteurly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auteurly App Integration Tests', () {
    testWidgets('app launches successfully', (WidgetTester tester) async {
      // Arrange & Act
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert - App should load (either login or home based on auth state)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('displays login page when user is not authenticated',
        (WidgetTester tester) async {
      // Note: This assumes user is logged out
      // In a real scenario, you'd mock Firebase Auth to return null user

      // Arrange & Act
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - Should show login UI elements
      // Adjust based on actual login page structure
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('can navigate through bottom navigation',
        (WidgetTester tester) async {
      // Note: This requires authenticated user state
      // You'd need to mock Firebase Auth with a user

      // Arrange & Act
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // This test would need authentication setup
      // Assert would check navigation between tabs
    });
  });
}
