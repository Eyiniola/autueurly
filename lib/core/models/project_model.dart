import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String title;
  final String projectType;
  final String description;
  final int year;
  final String? posterUrl; // <-- Changed to nullable String?
  final String createdBy; // <-- Added this field
  final String status;

  ProjectModel({
    required this.id,
    required this.title,
    required this.projectType,
    required this.description,
    required this.year,
    this.posterUrl,
    required this.createdBy,
    required this.status,
  });

  // Factory constructor to create a ProjectModel from Firestore document
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      title: data['title'] ?? '',
      projectType: data['projectType'] ?? '',
      description: data['description'] ?? '',
      year: data['year'] ?? 0,
      posterUrl: data['posterUrl'], // <-- No default needed for nullable
      createdBy: data['createdBy'] ?? '', // <-- Added this line
      status: data['status'] ?? 'Development',
    );
  }

  // Method to convert ProjectModel to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'projectType': projectType,
      'description': description,
      'year': year,
      'posterUrl': posterUrl,
      'createdBy': createdBy, // <-- Added this line
      'status': status,
    };
  }
}
