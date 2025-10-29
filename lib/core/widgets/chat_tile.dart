import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auteurly/core/models/chat_model.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/features/notifications/conversation_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatTile extends StatefulWidget {
  final ChatModel chat;
  const ChatTile({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late String _otherUserId;

  @override
  void initState() {
    super.initState();
    // Find the ID of the other participant in the chat
    _otherUserId = widget.chat.participants.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => '',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_otherUserId.isEmpty) {
      return const SizedBox.shrink(); // Don't build if something is wrong
    }

    return StreamBuilder<UserModel?>(
      stream: _firestoreService
          .getUserProfileStream(_otherUserId)
          .map(
            (snapshot) =>
                snapshot.exists ? UserModel.fromFirestore(snapshot) : null,
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            title: Text('Loading...', style: TextStyle(color: Colors.grey)),
          );
        }

        final otherUser = snapshot.data!;
        final isOnline = otherUser.status == 'online';

        // <-- MODIFIED: Get the unread status from the chat model
        final bool isUnread = widget.chat.isUnread;

        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: otherUser.profilePictureUrl != null
                    ? NetworkImage(otherUser.profilePictureUrl!)
                    : null,
                child: otherUser.profilePictureUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              // Show green dot if online
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            otherUser.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            widget.chat.lastMessageText,
            // <-- MODIFIED: Style changes based on read status
            style: TextStyle(
              color: isUnread ? Colors.white : Colors.grey,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // --- Last seen time ---
              if (!isOnline)
                Text(
                  timeago.format(otherUser.lastSeen.toDate()),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                )
              else
                // Empty text to keep alignment consistent
                const Text("", style: TextStyle(fontSize: 10)),

              const SizedBox(height: 4), // Spacer
              // --- Red Unread Dot ---
              if (isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA32626), // Your app's red
                    shape: BoxShape.circle,
                  ),
                )
              else
                // Empty box to keep alignment consistent
                const SizedBox(width: 10, height: 10),
            ],
          ),
          onTap: () {
            // --- GOOD PRACTICE: Mark as read when tapping ---
            // (You already mark on 'ConversationScreen' load, but this
            // can also be done here just before navigating)
            if (isUnread && _currentUserId != null) {
              _firestoreService.markChatAsRead(widget.chat.id, _currentUserId!);
            }
            // ---

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationScreen(
                  chatId: widget.chat.id,
                  otherUser: otherUser,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
