import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String headline;
  final String availabilityStatus;
  final String bio;
  final String? profilePictureUrl;
  final String? showreelUrl;
  final List<String> keyRoles;
  final List<String> skills;
  final List<String> genres;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.headline,
    required this.availabilityStatus,
    required this.bio,
    this.profilePictureUrl,
    this.showreelUrl,
    required this.keyRoles,
    required this.skills,
    required this.genres,
  });

  // Factory constructor to create a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullname'] ?? '',
      headline: data['headline'] ?? '',
      availabilityStatus: data['availabilityStatus'] ?? 'available',
      bio: data['bio'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      showreelUrl: data['showreelUrl'],
      keyRoles: List<String>.from(data['keyRoles'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      genres: List<String>.from(data['genres'] ?? [])
    );
  }
  // Method to convert UserModel to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'headline': headline,
      'availabilityStatus': availabilityStatus,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'showreelUrl': showreelUrl,
      'keyRoles': keyRoles,
      'skills': skills,
      'genres': genres,
    };
  }
}


