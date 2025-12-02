import 'package:auteurly/core/widgets/message_bubble.dart';
import 'package:auteurly/core/widgets/message_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/models/message_model.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/features/profile/public_profile_page.dart'; // Import the target page
import 'package:timeago/timeago.dart' as timeago;

class ConversationScreen extends StatefulWidget {
  final String chatId;
  final UserModel otherUser;

  const ConversationScreen({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mark the chat as read when the screen opens
    if (_currentUserId != null) {
      _firestoreService.markChatAsRead(widget.chatId, _currentUserId!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && _currentUserId != null) {
      _firestoreService.sendMessage(
        widget.chatId,
        _messageController.text,
        _currentUserId!,
      );
      _messageController.clear(); // Clear the text field after sending
    }
  }

  // --- NEW: Navigation function to the other user's profile ---
  void _viewOtherUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Navigate to the PublicProfilePage using the other user's UID
        builder: (context) => PublicProfilePage(userId: widget.otherUser.uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        iconTheme: const IconThemeData(color: Colors.white),
        // --- FIX: Wrap the StreamBuilder (the title content) in a GestureDetector ---
        title: GestureDetector(
          onTap: _viewOtherUserProfile, // Add the tap handler
          child: StreamBuilder<UserModel?>(
            stream: _firestoreService
                .getUserProfileStream(widget.otherUser.uid)
                .map((doc) => UserModel.fromFirestore(doc)),
            builder: (context, snapshot) {
              final user =
                  snapshot.data ??
                  widget.otherUser; // Use initial data until stream updates
              final isOnline = user.status == 'online';

              return Row(
                children: [
                  CircleAvatar(
                    backgroundImage: user.profilePictureUrl != null
                        ? NetworkImage(user.profilePictureUrl!)
                        : null,
                    child: user.profilePictureUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (isOnline)
                        const Text(
                          'Online',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        )
                      else
                        Text(
                          'Last seen ${timeago.format(user.lastSeen.toDate())}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _firestoreService.getMessageStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true, // Shows messages from the bottom up
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;
                    return MessageBubble(isMe: isMe, text: message.text);
                  },
                );
              },
            ),
          ),
          MessageInputWidget(
            messageController: _messageController,
            onSendMessage: _sendMessage,
            isEnabled: true,
          ),
        ],
      ),
    );
  }
}
