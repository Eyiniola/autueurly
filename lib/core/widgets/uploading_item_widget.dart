import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:auteurly/core/widgets/gallery_upload.dart';
import 'package:path/path.dart' as p;

class UploadingItemWidget extends StatelessWidget {
  final GalleryUpload upload;
  final VoidCallback onCancel;
  final Function(String) onDescriptionChanged;

  const UploadingItemWidget({
    super.key,
    required this.upload,
    required this.onCancel,
    required this.onDescriptionChanged,
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
    TaskState currentState = upload.task.snapshot.state;
    bool isUploading = currentState == TaskState.running || currentState == TaskState.paused;
    bool isFinished = currentState == TaskState.success || 
                     currentState == TaskState.canceled || 
                     currentState == TaskState.error;

    String displayName = _getFileName(upload.file.path);
    String progressText = "";
    Widget statusIcon = const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );

    if (upload.error != null || currentState == TaskState.error) {
      statusIcon = const Icon(Icons.error_outline, color: Colors.redAccent, size: 20);
    } else if (currentState == TaskState.success) {
      statusIcon = const Icon(
        Icons.check_circle_outline,
        color: Colors.greenAccent,
        size: 20,
      );
    } else if (isUploading && upload.progress > 0) {
      progressText = "${(upload.progress * 100).toStringAsFixed(0)}%";
      statusIcon = Text(
        progressText,
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: Colors.grey[400],
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              statusIcon,
              if (isUploading)
                IconButton(
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.orangeAccent,
                    size: 20,
                  ),
                  onPressed: onCancel,
                  tooltip: "Cancel Upload",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
          if (isUploading && upload.progress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: LinearProgressIndicator(
                value: upload.progress,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          if (upload.error != null || currentState == TaskState.error)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                upload.error ?? "Upload failed",
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: upload.descriptionController,
            enabled: upload.error == null,
            style: TextStyle(color: Colors.grey[300], fontSize: 12),
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: "Add description during upload...",
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
            onChanged: onDescriptionChanged,
          ),
        ],
      ),
    );
  }
}
