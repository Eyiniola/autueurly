import 'package:flutter/material.dart';

class WarningPill extends StatelessWidget {
  final String message;
  final VoidCallback onDismissed;

  const WarningPill({
    Key? key,
    required this.message,
    required this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ), // Adjust vertical padding for height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0), // Pill shape
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Make the pill only as wide as needed
        children: [
          Expanded(
            // Allow text to take available space
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black87, // Or your desired text color
                fontSize: 12, // Small text
              ),
              overflow: TextOverflow
                  .ellipsis, // Prevent long messages from breaking layout
            ),
          ),
          const SizedBox(width: 8), // Space between text and icon
          GestureDetector(
            onTap: onDismissed,
            child: Container(
              padding: const EdgeInsets.all(2.0), // Small padding inside circle
              decoration: const BoxDecoration(
                color: Colors.red, // Red circle background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white, // White 'X' icon
                size: 14.0, // Small icon
              ),
            ),
          ),
        ],
      ),
    );
  }
}
