import 'package:flutter/material.dart';

class GalleryThumbnailWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const GalleryThumbnailWidget({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String type = item['type'] ?? 'other';
    final String url = item['storageUrl'] ?? '';

    Widget content;

    if (type == 'image') {
      content = Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: Icon(Icons.broken_image_outlined, color: Colors.grey[600]),
        ),
      );
    } else if (type == 'video') {
      content = Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white70,
            size: 40,
          ),
        ),
      );
    } else if (type == 'pdf') {
      content = Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Icons.picture_as_pdf_outlined,
            color: Colors.white70,
            size: 40,
          ),
        ),
      );
    } else {
      content = Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Icons.insert_drive_file_outlined,
            color: Colors.white70,
            size: 40,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Colors.grey[800],
        child: content,
      ),
    );
  }
}
