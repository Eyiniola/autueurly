import 'package:cloud_firestore/cloud_firestore.dart';

class CreditModel {
  final String id;
  final String userId;
  final String projectId;
  final String projectTitle;
  final String userFullName;
  final String creatorName;
  final String role;
  final bool isVerified;
  final int year;

  CreditModel({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.projectTitle,
    required this.userFullName,
    required this.creatorName,
    required this.role,
    required this.isVerified,
    required this.year,
  });

  // Factory constructor to create a CreditModel from Firestore document

  factory CreditModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CreditModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      projectId: data['projectId'] ?? '',
      projectTitle: data['projectTitle'] ?? '',
      userFullName: data['userFullName'] ?? '',
      creatorName: data['creatorName'] ?? '',
      role: data['role'] ?? '',
      isVerified: data['isVerified'] ?? false,
      year: data['year'] ?? 0,
    );
  }

  // Method to convert CreditModel to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'userFullName': userFullName,
      'creatorName': creatorName,
      'role': role,
      'isVerified': isVerified,
      'year': year,
    };
  }
}
