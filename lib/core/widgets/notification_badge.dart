import 'package:flutter/material.dart';
import 'package:async/async.dart'; // <-- Import the new package
import 'package:auteurly/core/services/firstore_service.dart';

class NotificationBadge extends StatefulWidget {
  final String? currentUserId;
  final FirestoreService firestoreService;
  final Widget child; // This will be your bell icon

  const NotificationBadge({
    super.key,
    required this.currentUserId,
    required this.firestoreService,
    required this.child,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  // We will combine two streams into one
  late Stream<List<int>> _combinedStream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    if (widget.currentUserId != null) {
      _combinedStream = StreamZip([
        widget.firestoreService.getUnreadNotificationsCountStream(
          widget.currentUserId!,
        ),
        widget.firestoreService.getUnreadChatsCountStream(
          widget.currentUserId!,
        ),
      ]);
    }
  }

  // This ensures if the user logs in/out, the stream rebuilds
  @override
  void didUpdateWidget(covariant NotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != oldWidget.currentUserId) {
      _setupStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUserId == null) {
      return widget.child; // Just show the icon if logged out
    }

    return StreamBuilder<List<int>>(
      stream: _combinedStream,
      builder: (context, snapshot) {
        int totalUnread = 0;

        // When data is available, snapshot.data will be a list like [notifCount, chatCount]
        if (snapshot.hasData && snapshot.data!.length == 2) {
          totalUnread = snapshot.data![0] + snapshot.data![1];
        }

        // Use a Stack to overlay the dot on the icon
        return Stack(
          clipBehavior: Clip.none, // Allows dot to go outside the icon's box
          children: [
            widget.child, // This is the Icon(Icons.notifications_none_outlined)
            // The Red Dot
            if (totalUnread > 0)
              Positioned(
                top: 0, // Adjust this value to move the dot vertically
                right: 0, // Adjust this value to move the dot horizontally
                child: Container(
                  width: 10, // Dot size
                  height: 10, // Dot size
                  decoration: BoxDecoration(
                    color: const Color(0xFFA32626), // Your red
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
