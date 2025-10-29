import 'package:auteurly/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    late Timestamp testTimestamp;

    setUp(() {
      testTimestamp = Timestamp.now();
    });

    test('should create UserModel with all required fields', () {
      // Arrange & Act
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        fullName: 'Test User',
        headline: 'Filmmaker',
        availabilityStatus: 'Available',
        bio: 'Test bio',
        profilePictureUrl: 'https://example.com/pic.jpg',
        showreelUrl: 'https://example.com/video.mp4',
        location: 'Kigali',
        keyRoles: ['Director', 'Producer'],
        skills: ['Cinematography', 'Editing'],
        genres: ['Drama', 'Comedy'],
        equipment: ['Camera', 'Lights'],
        languages: ['English', 'Kinyarwanda'],
        status: 'online',
        projectGallery: [],
        lastSeen: testTimestamp,
      );

      // Assert
      expect(user.uid, equals('user123'));
      expect(user.email, equals('test@example.com'));
      expect(user.fullName, equals('Test User'));
      expect(user.headline, equals('Filmmaker'));
      expect(user.availabilityStatus, equals('Available'));
      expect(user.bio, equals('Test bio'));
      expect(user.profilePictureUrl, equals('https://example.com/pic.jpg'));
      expect(user.showreelUrl, equals('https://example.com/video.mp4'));
      expect(user.location, equals('Kigali'));
      expect(user.keyRoles, equals(['Director', 'Producer']));
      expect(user.skills, equals(['Cinematography', 'Editing']));
      expect(user.genres, equals(['Drama', 'Comedy']));
      expect(user.equipment, equals(['Camera', 'Lights']));
      expect(user.languages, equals(['English', 'Kinyarwanda']));
      expect(user.status, equals('online'));
      expect(user.projectGallery, isEmpty);
      expect(user.lastSeen, equals(testTimestamp));
    });

    test('should create UserModel with nullable fields as null', () {
      // Arrange & Act
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        fullName: 'Test User',
        headline: 'Filmmaker',
        availabilityStatus: 'Available',
        bio: 'Test bio',
        profilePictureUrl: null,
        showreelUrl: null,
        location: '',
        keyRoles: [],
        skills: [],
        genres: [],
        equipment: [],
        languages: [],
        status: 'offline',
        projectGallery: [],
        lastSeen: testTimestamp,
      );

      // Assert
      expect(user.profilePictureUrl, isNull);
      expect(user.showreelUrl, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      // Arrange
      final originalUser = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        fullName: 'Test User',
        headline: 'Filmmaker',
        availabilityStatus: 'Available',
        bio: 'Test bio',
        profilePictureUrl: null,
        showreelUrl: null,
        location: 'Kigali',
        keyRoles: ['Director'],
        skills: ['Cinematography'],
        genres: ['Drama'],
        equipment: [],
        languages: [],
        status: 'online',
        projectGallery: [],
        lastSeen: testTimestamp,
      );

      // Act
      final updatedUser = originalUser.copyWith(
        fullName: 'Updated Name',
        availabilityStatus: 'Unavailable',
        status: 'offline',
      );

      // Assert
      expect(updatedUser.uid, equals(originalUser.uid));
      expect(updatedUser.email, equals(originalUser.email));
      expect(updatedUser.fullName, equals('Updated Name'));
      expect(updatedUser.availabilityStatus, equals('Unavailable'));
      expect(updatedUser.status, equals('offline'));
      expect(originalUser.fullName, equals('Test User')); // Original unchanged
    });

    test('fromFirestore should parse complete document', () {
      // Arrange
      final mockData = {
        'email': 'test@example.com',
        'fullName': 'Test User',
        'headline': 'Filmmaker',
        'availabilityStatus': 'Available',
        'bio': 'Test bio',
        'profilePictureUrl': 'https://example.com/pic.jpg',
        'showreelUrl': 'https://example.com/video.mp4',
        'location': 'Kigali',
        'keyRoles': ['Director'],
        'skills': ['Cinematography'],
        'genres': ['Drama'],
        'equipment': ['Camera'],
        'languages': ['English'],
        'status': 'online',
        'projectGallery': [],
        'lastSeen': testTimestamp,
      };

      final mockDoc = MockDocumentSnapshot(id: 'user123', data: mockData);

      // Act
      final user = UserModel.fromFirestore(mockDoc);

      // Assert
      expect(user.uid, equals('user123'));
      expect(user.email, equals('test@example.com'));
      expect(user.fullName, equals('Test User'));
      expect(user.status, equals('online'));
    });

    test('fromFirestore should handle missing fields with defaults', () {
      // Arrange
      final mockData = <String, dynamic>{};
      final mockDoc = MockDocumentSnapshot(id: 'user123', data: mockData);

      // Act
      final user = UserModel.fromFirestore(mockDoc);

      // Assert
      expect(user.uid, equals('user123'));
      expect(user.email, equals(''));
      expect(user.fullName, equals(''));
      expect(user.availabilityStatus, equals('available'));
      expect(user.status, equals('offline'));
      expect(user.keyRoles, isEmpty);
      expect(user.skills, isEmpty);
      expect(user.projectGallery, isEmpty);
    });

    test('fromFirestore should handle missing status field', () {
      // Arrange
      final mockData = {
        'email': 'test@example.com',
        'fullName': 'Test User',
        'headline': '',
        'availabilityStatus': 'Available',
        'bio': '',
      };
      final mockDoc = MockDocumentSnapshot(id: 'user123', data: mockData);

      // Act
      final user = UserModel.fromFirestore(mockDoc);

      // Assert
      expect(user.status, equals('offline')); // Default
    });

    test('toJson should convert model to map', () {
      // Arrange
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        fullName: 'Test User',
        headline: 'Filmmaker',
        availabilityStatus: 'Available',
        bio: 'Test bio',
        profilePictureUrl: 'https://example.com/pic.jpg',
        showreelUrl: null,
        location: 'Kigali',
        keyRoles: ['Director'],
        skills: ['Cinematography'],
        genres: ['Drama'],
        equipment: ['Camera'],
        languages: ['English'],
        status: 'online',
        projectGallery: [],
        lastSeen: testTimestamp,
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['uid'], equals('user123'));
      expect(json['email'], equals('test@example.com'));
      expect(json['fullName'], equals('Test User'));
      expect(json['profilePictureUrl'], equals('https://example.com/pic.jpg'));
      expect(json['showreelUrl'], isNull);
      expect(json['keyRoles'], equals(['Director']));
      expect(json['lastSeen'], equals(testTimestamp));
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
