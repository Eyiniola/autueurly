# Auteurly Test Suite

This directory contains unit tests, widget tests, and integration tests for the Auteurly application.

## Test Structure

```
test/
├── core/
│   ├── models/          # Unit tests for data models
│   │   ├── user_model_test.dart
│   │   ├── project_model_test.dart
│   │   └── credit_model_test.dart
│   └── widgets/         # Widget tests for core widgets
│       └── gallery_thumbnail_widget_test.dart
└── features/
    └── components/       # Widget tests for reusable components
        ├── textfield_test.dart
        └── button_test.dart

integration_test/
├── app_test.dart           # Basic app launch tests
├── auth_flow_test.dart     # Authentication flow tests
└── project_flow_test.dart  # Project creation/management tests
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/core/models/user_model_test.dart
```

### Run widget tests only
```bash
flutter test test/widgets/
```

### Run integration tests
```bash
flutter test integration_test/
```

Or for device:
```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
```

## Test Coverage

To generate test coverage report:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Notes

1. **Firebase Dependencies**: Some tests may require Firebase emulator setup or mocking. Consider using:
   - `firebase_messaging_mocks` for push notifications
   - Firebase emulators for Firestore/Auth testing
   - `mockito` for service mocking

2. **Integration Tests**: Integration tests require a device or emulator. They test the full app flow and may need:
   - Test Firebase project configuration
   - Authentication setup
   - Cleanup of test data

3. **Mocking**: For unit tests with Firebase dependencies, use:
   - `mockito` package (already added to dev_dependencies)
   - Generate mocks with: `flutter pub run build_runner build`

## Adding New Tests

1. **Unit Tests**: Test business logic, models, and pure functions
2. **Widget Tests**: Test UI components in isolation
3. **Integration Tests**: Test complete user flows across multiple screens

Follow the existing test patterns and structure your tests using:
- `group()` for organizing related tests
- `test()` for unit tests
- `testWidgets()` for widget tests
- Descriptive test names that explain what is being tested
