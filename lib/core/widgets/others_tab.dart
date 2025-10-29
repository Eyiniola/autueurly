import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auteurly/core/models/notification_model.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/widgets/notification_tile.dart';

class OthersTab extends StatefulWidget {
  final String? currentUserId;
  final FirestoreService firestoreService;

  const OthersTab({
    Key? key,
    required this.currentUserId,
    required this.firestoreService,
  }) : super(key: key);

  @override
  State<OthersTab> createState() => _OthersTabState();
}

class _OthersTabState extends State<OthersTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.currentUserId == null) {
      return const Center(child: Text("Not logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: widget.firestoreService.getNotificationsStream(
        widget.currentUserId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No requests or notifications.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final notifications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = NotificationModel.fromFirestore(
              notifications[index],
            );
            return NotificationTile(notification: notification);
          },
        );
      },
    );
  }
}
