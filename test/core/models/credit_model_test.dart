import 'package:auteurly/core/models/credit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreditModel', () {
    test('should create CreditModel with all required fields', () {
      // Arrange & Act
      final credit = CreditModel(
        id: 'credit123',
        userId: 'user123',
        projectId: 'project123',
        projectTitle: 'Test Movie',
        userFullName: 'Test User',
        role: 'Director',
        isVerified: true,
        year: 2024,
      );

      // Assert
      expect(credit.id, equals('credit123'));
      expect(credit.userId, equals('user123'));
      expect(credit.projectId, equals('project123'));
      expect(credit.projectTitle, equals('Test Movie'));
      expect(credit.userFullName, equals('Test User'));
      expect(credit.role, equals('Director'));
      expect(credit.isVerified, isTrue);
      expect(credit.year, equals(2024));
    });

    test('should create CreditModel with isVerified as false', () {
      // Arrange & Act
      final credit = CreditModel(
        id: 'credit123',
        userId: 'user123',
        projectId: 'project123',
        projectTitle: 'Test Movie',
        userFullName: 'Test User',
        role: 'Director',
        isVerified: false,
        year: 2024,
      );

      // Assert
      expect(credit.isVerified, isFalse);
    });

    test('fromFirestore should parse complete document', () {
      // Arrange
      final mockData = {
        'userId': 'user123',
        'projectId': 'project123',
        'projectTitle': 'Test Movie',
        'userFullName': 'Test User',
        'role': 'Director',
        'isVerified': true,
        'year': 2024,
      };

      final mockDoc = MockDocumentSnapshot(id: 'credit123', data: mockData);

      // Act
      final credit = CreditModel.fromFirestore(mockDoc);

      // Assert
      expect(credit.id, equals('credit123'));
      expect(credit.userId, equals('user123'));
      expect(credit.projectId, equals('project123'));
      expect(credit.projectTitle, equals('Test Movie'));
      expect(credit.userFullName, equals('Test User'));
      expect(credit.role, equals('Director'));
      expect(credit.isVerified, isTrue);
      expect(credit.year, equals(2024));
    });

    test('fromFirestore should handle missing fields with defaults', () {
      // Arrange
      final mockData = <String, dynamic>{};
      final mockDoc = MockDocumentSnapshot(id: 'credit123', data: mockData);

      // Act
      final credit = CreditModel.fromFirestore(mockDoc);

      // Assert
      expect(credit.id, equals('credit123'));
      expect(credit.userId, equals(''));
      expect(credit.projectId, equals(''));
      expect(credit.projectTitle, equals(''));
      expect(credit.userFullName, equals(''));
      expect(credit.role, equals(''));
      expect(credit.isVerified, isFalse);
      expect(credit.year, equals(0));
    });

    test('fromFirestore should handle boolean values correctly', () {
      // Arrange
      final mockDataFalse = {
        'userId': 'user123',
        'projectId': 'project123',
        'projectTitle': 'Test Movie',
        'userFullName': 'Test User',
        'role': 'Director',
        'isVerified': false,
        'year': 2024,
      };

      final mockDocFalse =
          MockDocumentSnapshot(id: 'credit123', data: mockDataFalse);

      // Act
      final creditFalse = CreditModel.fromFirestore(mockDocFalse);

      // Assert
      expect(creditFalse.isVerified, isFalse);
    });

    test('toJson should convert model to map', () {
      // Arrange
      final credit = CreditModel(
        id: 'credit123',
        userId: 'user123',
        projectId: 'project123',
        projectTitle: 'Test Movie',
        userFullName: 'Test User',
        role: 'Director',
        isVerified: true,
        year: 2024,
      );

      // Act
      final json = credit.toJson();

      // Assert
      expect(json['userId'], equals('user123'));
      expect(json['projectId'], equals('project123'));
      expect(json['projectTitle'], equals('Test Movie'));
      expect(json['userFullName'], equals('Test User'));
      expect(json['role'], equals('Director'));
      expect(json['isVerified'], isTrue);
      expect(json['year'], equals(2024));
      expect(json, isNot(contains('id'))); // id should not be in JSON
    });

    test('toJson should include false isVerified', () {
      // Arrange
      final credit = CreditModel(
        id: 'credit123',
        userId: 'user123',
        projectId: 'project123',
        projectTitle: 'Test Movie',
        userFullName: 'Test User',
        role: 'Director',
        isVerified: false,
        year: 2024,
      );

      // Act
      final json = credit.toJson();

      // Assert
      expect(json['isVerified'], isFalse);
    });
  });
}

// Mock DocumentSnapshot for testing
class MockDocumentSnapshot implements DocumentSnapshot {
  @override
  final String id;
  
  final Map<String, dynamic> _data;

  MockDocumentSnapshot({required this.id, required Map<String, dynamic> data})
      : _data = data;

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic get(Object field) => _data[field.toString()];

  @override
  dynamic operator [](Object field) => _data[field];

  @override
  bool get exists => true;

  @override
  DocumentReference get reference => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
}
