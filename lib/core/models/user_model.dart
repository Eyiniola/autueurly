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
  final String location;
  final List<String> keyRoles;
  final List<String> skills;
  final List<String> genres;
  final List<String> equipment;
  final List<String> languages;
  final String status;
  final List<Map<String, dynamic>> projectGallery;
  final Timestamp lastSeen;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.headline,
    required this.availabilityStatus,
    required this.bio,
    this.profilePictureUrl,
    this.showreelUrl,
    required this.location,
    required this.keyRoles,
    required this.skills,
    required this.genres,
    required this.equipment,
    required this.languages,
    required this.status,
    required this.projectGallery,
    required this.lastSeen,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? headline,
    String? availabilityStatus,
    String? bio,
    String? profilePictureUrl,
    String? showreelUrl,
    String? location, // <-- ADDED
    List<String>? keyRoles,
    List<String>? skills,
    List<String>? genres,
    List<String>? equipment, // <-- ADDED
    List<String>? languages, // <-- ADDED
    String? status,
    List<Map<String, dynamic>>? projectGallery,
    Timestamp? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      headline: headline ?? this.headline,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      showreelUrl: showreelUrl ?? this.showreelUrl,
      location: location ?? this.location, // <-- ADDED
      keyRoles: keyRoles ?? this.keyRoles,
      skills: skills ?? this.skills,
      genres: genres ?? this.genres,
      equipment: equipment ?? this.equipment, // <-- ADDED
      languages: languages ?? this.languages, // <-- ADDED
      status: status ?? this.status,
      projectGallery: projectGallery ?? this.projectGallery,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // --- More Robust Parsing ---
    String status = 'offline'; // Default status
    if (data.containsKey('status') && data['status'] is String) {
      status = data['status'];
    }

    Timestamp lastSeen = Timestamp.now(); // Default timestamp
    if (data.containsKey('lastSeen') && data['lastSeen'] is Timestamp) {
      lastSeen = data['lastSeen'];
    }
    // --- End of Robust Parsing ---

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      headline: data['headline'] ?? '',
      availabilityStatus: data['availabilityStatus'] ?? 'available',
      bio: data['bio'] ?? '',
      profilePictureUrl: data['profilePictureUrl'], // Stays null if missing
      showreelUrl: data['showreelUrl'], // Stays null if missing
      location: data['location'] ?? '',
      keyRoles: List<String>.from(data['keyRoles'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      genres: List<String>.from(data['genres'] ?? []),
      equipment: List<String>.from(data['equipment'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      status: status,
      projectGallery: List<Map<String, dynamic>>.from(
        data['projectGallery'] ?? [],
      ),
      lastSeen: lastSeen, // Use the parsed timestamp
    );
  }

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
      'location': location, // <-- ADDED
      'keyRoles': keyRoles,
      'skills': skills,
      'genres': genres,
      'equipment': equipment, // <-- ADDED
      'languages': languages, // <-- ADDED
      'status': status,
      'projectGallery': projectGallery,
      'lastSeen': lastSeen,
    };
  }
}
