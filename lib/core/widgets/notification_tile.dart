import 'package:flutter/material.dart';
import 'package:auteurly/core/models/notification_model.dart';
import 'package:auteurly/core/services/firstore_service.dart';

// Convert to StatefulWidget to manage loading state
class NotificationTile extends StatefulWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false; // To show loading indicator and disable buttons

  // --- Helper to show errors ---
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // --- Actions for Credit Verification ---
  Future<void> _acceptCredit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _firestoreService.verifyCredit(widget.notification.referenceId);
      // Delete notification after verifying
      await _firestoreService.deleteNotification(widget.notification.id);
      // No need to setState false if the widget is removed after deletion
    } catch (e) {
      print("Error accepting credit: $e");
      _showErrorSnackBar("Failed to accept credit. Please try again.");
      if (mounted) setState(() => _isLoading = false);
    }
    // Note: If delete fails but verify succeeds, the notification remains.
  }

  Future<void> _declineCredit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      // For declining a credit verification, we typically just delete the notification
      // We might also want to delete the underlying unverified 'credit' document
      // For now, just delete notification:
      await _firestoreService.deleteNotification(widget.notification.id);
    } catch (e) {
      print("Error declining credit: $e");
      _showErrorSnackBar("Failed to decline. Please try again.");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Actions for Join Request ---
  Future<void> _approveJoinRequest() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _firestoreService.approveJoinRequest(
        widget.notification.referenceId,
      );
      // Delete notification after approving
      await _firestoreService.deleteNotification(widget.notification.id);
    } catch (e) {
      print("Error approving join request: $e");
      _showErrorSnackBar("Failed to approve request. Please try again.");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _denyJoinRequest() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _firestoreService.denyJoinRequest(widget.notification.referenceId);
      // Delete notification after denying
      await _firestoreService.deleteNotification(widget.notification.id);
    } catch (e) {
      print("Error denying join request: $e");
      _showErrorSnackBar("Failed to deny request. Please try again.");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which type of notification this is
    final bool isJoinRequest = widget.notification.type == 'join_request';
    // Assume original type was 'credit_request' - adjust if different
    final bool isCreditRequest = widget.notification.type == 'credit_request';

    return Card(
      color: const Color(0xFF2C2C2C),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display sender info if available (for join requests)
            if (isJoinRequest)
              Row(
                children: [
                  // display profile pic
                  if (widget.notification.senderProfilePic != null)
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        widget.notification.senderProfilePic!,
                      ),
                    )
                  else
                    CircleAvatar(radius: 16, child: Icon(Icons.person)),
                  SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      widget.notification.senderName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            if (isJoinRequest) const SizedBox(height: 8),

            // Display the main message
            Text(
              widget.notification.message,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // --- Show Buttons based on Type ---
            if (isCreditRequest ||
                isJoinRequest) // Only show buttons for known actionable types
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _isLoading
                    ? [
                        const CircularProgressIndicator(strokeWidth: 2),
                      ] // Show spinner when loading
                    : [
                        // Decline/Deny Button
                        TextButton(
                          onPressed: isJoinRequest
                              ? _denyJoinRequest
                              : _declineCredit,
                          child: Text(
                            isJoinRequest ? 'Deny' : 'Decline',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Accept/Approve Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA32626),
                            foregroundColor:
                                Colors.white, // Ensure text is white
                          ),
                          onPressed: isJoinRequest
                              ? _approveJoinRequest
                              : _acceptCredit,
                          child: Text(isJoinRequest ? 'Approve' : 'Accept'),
                        ),
                      ],
              )
            else // Optional: Show a dismiss button for other notification types
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    // Just delete the notification
                    setState(() => _isLoading = true);
                    try {
                      await _firestoreService.deleteNotification(
                        widget.notification.id,
                      );
                    } catch (e) {
                      print("Error dismissing notification: $e");
                      _showErrorSnackBar("Failed to dismiss notification.");
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  child: Text(
                    'Dismiss',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
