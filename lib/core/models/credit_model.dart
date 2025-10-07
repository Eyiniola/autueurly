import 'package:cloud_firestore/cloud_firestore.dart';

class CreditModel {
  final String id;
  final String userId;
  final String projectId;
  final String projectTitle;
  final String role;
  final bool isVerified;

  CreditModel({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.projectTitle,
    required this.role,
    required this.isVerified,
  });

  // Factory constructor to create a CreditModel from Firestore document

  factory CreditModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CreditModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      projectId: data['projectId'] ?? '',
      projectTitle: data['projectTitle'] ?? '',
      role: data['role'] ?? '',
      isVerified: data['isVerified'] ?? false,
    );
  }

  // Method to convert CreditModel to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'role': role,
      'isVerified': isVerified,
    };
  }
}