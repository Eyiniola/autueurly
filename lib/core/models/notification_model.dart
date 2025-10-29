import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String senderName;
  final String type; // e.g., 'credit_request'
  final String message;
  final String referenceId; // The ID of the project or credit
  final Timestamp timestamp;
  final bool isRead;
  final String? senderId;
  final String? senderProfilePic;
  final String? projectId;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.senderName,
    required this.type,
    required this.message,
    required this.referenceId,
    required this.timestamp,
    required this.isRead,
    this.senderId,
    this.senderProfilePic,
    this.projectId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      senderName: data['senderName'] ?? '',
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      referenceId: data['referenceId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? true,
      senderId: data['senderId'],
      senderProfilePic: data['senderProfilePic'],
      projectId: data['projectId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // No need to include 'id' as it's the document ID, not usually stored within the document
      'recipientId': recipientId,
      'type': type,
      'message': message,
      'referenceId': referenceId,
      'timestamp': timestamp, // Keep as Timestamp for Firestore
      'isRead': isRead,
      'senderName': senderName, // Include if not null
      'senderId': senderId, // Include if not null
      'senderProfilePic': senderProfilePic, // Include if not null
      'projectId': projectId, // Include if not null
    };
  }
}
