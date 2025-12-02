import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  const MessageBubble({super.key, required this.isMe, required this.text});

  @override
  Widget build(BuildContext context) {
    // Determine the maximum width the bubble can take up.
    // We set it to 75% of the screen width.
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth, // <-- Constrain the width
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFA32626) : const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
              softWrap: true, // <-- Ensure text wraps onto new lines
            ),
          ),
        ),
      ],
    );
  }
}
