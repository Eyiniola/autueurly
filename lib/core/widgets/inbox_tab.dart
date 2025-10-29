import 'package:flutter/material.dart';
import 'package:auteurly/core/models/chat_model.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/widgets/chat_tile.dart';

class InboxTab extends StatefulWidget {
  final String? currentUserId;
  final FirestoreService firestoreService;

  const InboxTab({
    Key? key,
    required this.currentUserId,
    required this.firestoreService,
  }) : super(key: key);

  @override
  State<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab> {
  // You can move streams and logic here if needed
  // For a simple StreamBuilder, this is all you need.

  @override
  Widget build(BuildContext context) {
    if (widget.currentUserId == null) {
      return const Center(
        child: Text('Please log in.', style: TextStyle(color: Colors.white)),
      );
    }

    return StreamBuilder<List<ChatModel>>(
      stream: widget.firestoreService.getChatsStream(widget.currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final chats = snapshot.data!;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ChatTile(chat: chat);
          },
        );
      },
    );
  }
}
