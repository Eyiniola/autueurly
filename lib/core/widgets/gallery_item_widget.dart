import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class GalleryItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final VoidCallback onDelete;
  final Function(String) onDescriptionChanged;
  final bool isEnabled;

  const GalleryItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
    required this.onDescriptionChanged,
    this.isEnabled = true,
  });

  String _getFileName(String? path) {
    if (path == null) return "No file selected";
    try {
      return p.basename(path);
    } catch (e) {
      return "Invalid path";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String type = item['type'] ?? 'other';
    final String url = item['storageUrl'] ?? '';
    final String description = item['description'] ?? '';

    final TextEditingController descController = TextEditingController(
      text: description,
    );

    IconData iconData = Icons.insert_drive_file_outlined;
    if (type == 'image') iconData = Icons.image_outlined;
    if (type == 'video') iconData = Icons.videocam_outlined;
    if (type == 'pdf') iconData = Icons.picture_as_pdf_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(iconData, color: Colors.grey[400], size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getFileName(Uri.parse(url).pathSegments.last),
              style: TextStyle(color: Colors.grey[300], fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: isEnabled ? onDelete : null,
            tooltip: "Remove Item",
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: TextField(
              controller: descController,
              enabled: isEnabled,
              style: TextStyle(color: Colors.grey[300], fontSize: 12),
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                hintText: "Add a description...",
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 10.0,
                ),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (newDescription) {
                onDescriptionChanged(newDescription.trim());
              },
            ),
          ),
        ],
      ),
    );
  }
}
