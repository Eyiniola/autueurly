import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessageText;
  final Timestamp lastMessageTimestamp;
  final bool isUnread;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessageText,
    required this.lastMessageTimestamp,
    required this.isUnread,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    Map data = doc.data() as Map<String, dynamic>;

    bool isUnread = false;

    // Check if the 'lastMessageSeenBy' field exists and is a list
    if (data['lastMessageSeenBy'] is List) {
      final List<dynamic> seenByList = data['lastMessageSeenBy'];
      // If the current user's ID is NOT in the list, the message is unread
      if (!seenByList.contains(currentUserId)) {
        isUnread = true;
      }
    } else {
      // Fallback: if 'lastMessageSeenBy' is missing or not a list,
      // and the last sender wasn't me, mark it unread.
      // (This assumes you have a 'lastMessageSenderId' field)
      if (data['lastMessageSenderId'] != null &&
          data['lastMessageSenderId'] != currentUserId) {
        isUnread = true;
      }
    }
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessageText: data['lastMessageText'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? Timestamp.now(),
      isUnread: isUnread,
    );
  }
}
