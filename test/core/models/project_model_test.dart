import 'package:auteurly/core/models/project_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectModel', () {
    test('should create ProjectModel with all required fields', () {
      // Arrange & Act
      final project = ProjectModel(
        id: 'project123',
        title: 'Test Movie',
        projectType: 'Feature Film',
        description: 'A test movie',
        year: 2024,
        posterUrl: 'https://example.com/poster.jpg',
        createdBy: 'user123',
        status: 'In Production',
      );

      // Assert
      expect(project.id, equals('project123'));
      expect(project.title, equals('Test Movie'));
      expect(project.projectType, equals('Feature Film'));
      expect(project.description, equals('A test movie'));
      expect(project.year, equals(2024));
      expect(project.posterUrl, equals('https://example.com/poster.jpg'));
      expect(project.createdBy, equals('user123'));
      expect(project.status, equals('In Production'));
    });

    test('should create ProjectModel with nullable posterUrl as null', () {
      // Arrange & Act
      final project = ProjectModel(
        id: 'project123',
        title: 'Test Movie',
        projectType: 'Feature Film',
        description: 'A test movie',
        year: 2024,
        posterUrl: null,
        createdBy: 'user123',
        status: 'Development',
      );

      // Assert
      expect(project.posterUrl, isNull);
    });

    test('fromFirestore should parse complete document', () {
      // Arrange
      final mockData = {
        'title': 'Test Movie',
        'projectType': 'Feature Film',
        'description': 'A test movie',
        'year': 2024,
        'posterUrl': 'https://example.com/poster.jpg',
        'createdBy': 'user123',
        'status': 'In Production',
      };

      final mockDoc = MockDocumentSnapshot(id: 'project123', data: mockData);

      // Act
      final project = ProjectModel.fromFirestore(mockDoc);

      // Assert
      expect(project.id, equals('project123'));
      expect(project.title, equals('Test Movie'));
      expect(project.projectType, equals('Feature Film'));
      expect(project.description, equals('A test movie'));
      expect(project.year, equals(2024));
      expect(project.posterUrl, equals('https://example.com/poster.jpg'));
      expect(project.createdBy, equals('user123'));
      expect(project.status, equals('In Production'));
    });

    test('fromFirestore should handle missing fields with defaults', () {
      // Arrange
      final mockData = <String, dynamic>{};
      final mockDoc = MockDocumentSnapshot(id: 'project123', data: mockData);

      // Act
      final project = ProjectModel.fromFirestore(mockDoc);

      // Assert
      expect(project.id, equals('project123'));
      expect(project.title, equals(''));
      expect(project.projectType, equals(''));
      expect(project.description, equals(''));
      expect(project.year, equals(0));
      expect(project.posterUrl, isNull);
      expect(project.createdBy, equals(''));
      expect(project.status, equals('Development'));
    });

    test('fromFirestore should handle null posterUrl', () {
      // Arrange
      final mockData = {
        'title': 'Test Movie',
        'projectType': 'Feature Film',
        'description': 'A test movie',
        'year': 2024,
        'posterUrl': null,
        'createdBy': 'user123',
        'status': 'In Production',
      };

      final mockDoc = MockDocumentSnapshot(id: 'project123', data: mockData);

      // Act
      final project = ProjectModel.fromFirestore(mockDoc);

      // Assert
      expect(project.posterUrl, isNull);
    });

    test('toJson should convert model to map', () {
      // Arrange
      final project = ProjectModel(
        id: 'project123',
        title: 'Test Movie',
        projectType: 'Feature Film',
        description: 'A test movie',
        year: 2024,
        posterUrl: 'https://example.com/poster.jpg',
        createdBy: 'user123',
        status: 'In Production',
      );

      // Act
      final json = project.toJson();

      // Assert
      expect(json['title'], equals('Test Movie'));
      expect(json['projectType'], equals('Feature Film'));
      expect(json['description'], equals('A test movie'));
      expect(json['year'], equals(2024));
      expect(json['posterUrl'], equals('https://example.com/poster.jpg'));
      expect(json['createdBy'], equals('user123'));
      expect(json['status'], equals('In Production'));
      expect(json, isNot(contains('id'))); // id should not be in JSON
    });

    test('toJson should include null posterUrl', () {
      // Arrange
      final project = ProjectModel(
        id: 'project123',
        title: 'Test Movie',
        projectType: 'Feature Film',
        description: 'A test movie',
        year: 2024,
        posterUrl: null,
        createdBy: 'user123',
        status: 'In Production',
      );

      // Act
      final json = project.toJson();

      // Assert
      expect(json['posterUrl'], isNull);
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
