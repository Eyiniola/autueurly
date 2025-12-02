import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:auteurly/core/services/storage_service.dart'; // Adjust path
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart'; // For user ID
import 'package:logging/logging.dart'; // Import logger

// Re-use GalleryUpload or define locally if preferred
// Assuming GalleryUpload class is defined elsewhere or moved to a shared location
// import 'gallery_upload.dart'; // If moved

// Setup logger (ensure setupLogger() is called in main())
final Logger logger = Logger('ProjectGalleryEditor');

class ProjectGalleryEditor extends StatefulWidget {
  final List<Map<String, dynamic>> initialItems;
  final Function(List<Map<String, dynamic>> updatedItems)
  onItemsChanged; // Callback to parent
  final StorageService storageService; // Pass instance

  const ProjectGalleryEditor({
    super.key,
    required this.initialItems,
    required this.onItemsChanged,
    required this.storageService,
  });

  @override
  State<ProjectGalleryEditor> createState() => _ProjectGalleryEditorState();
}

class _ProjectGalleryEditorState extends State<ProjectGalleryEditor> {
  List<Map<String, dynamic>> _projectGalleryItems = []; // Local state
  final List<GalleryUpload> _ongoingUploads = [];
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Initialize local list with a deep copy to avoid modifying parent's list directly
    _projectGalleryItems = List<Map<String, dynamic>>.from(
      widget.initialItems.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  Future<void> _pickAndUploadGalleryItem() async {
    if (_userId == null) {
      _showError("Please log in to upload.");
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'mp4',
        'mov',
        'avi',
        'mkv',
        'webm',
        'pdf',
      ],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String tempId = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = widget.storageService.uploadGalleryItem(
        _userId,
        file,
      );

      GalleryUpload newUpload = GalleryUpload(
        tempId: tempId,
        file: file,
        task: uploadTask,
      );
      setState(() => _ongoingUploads.add(newUpload));

      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (mounted) {
            setState(() {
              final index = _ongoingUploads.indexWhere(
                (up) => up.tempId == tempId,
              );
              if (index != -1) {
                _ongoingUploads[index].progress =
                    snapshot.bytesTransferred / snapshot.totalBytes;
              }
            });
          }
        },
        onError: (error) {
          logger.severe("Gallery Upload Error for $tempId", error);
          if (mounted) {
            setState(() {
              final index = _ongoingUploads.indexWhere(
                (up) => up.tempId == tempId,
              );
              if (index != -1) _ongoingUploads[index].error = "Upload failed";
            });
            _showError("Upload failed for ${_getFileName(file.path)}");
          }
        },
        onDone: () async {
          try {
            TaskSnapshot snapshot = await uploadTask;
            String downloadUrl = await snapshot.ref.getDownloadURL();
            String fileExtension = p
                .extension(file.path)
                .toLowerCase()
                .substring(1);
            String type = 'other';
            if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
              type = 'image';
            } else if ([
              'mp4',
              'mov',
              'avi',
              'mkv',
              'webm',
            ].contains(fileExtension))
              type = 'video';
            else if (fileExtension == 'pdf')
              type = 'pdf';

            final uploadIndex = _ongoingUploads.indexWhere(
              (up) => up.tempId == tempId,
            );
            String description = "";
            if (uploadIndex != -1) {
              description = _ongoingUploads[uploadIndex]
                  .descriptionController
                  .text
                  .trim();
              // Dispose controller after getting value
              _ongoingUploads[uploadIndex].descriptionController.dispose();
            }

            if (mounted) {
              // Create the final map
              final newItem = {
                'type': type,
                'storageUrl': downloadUrl,
                'description': description,
              };
              setState(() {
                _projectGalleryItems.add(newItem); // Add to local list
                _ongoingUploads.removeWhere(
                  (up) => up.tempId == tempId,
                ); // Remove from ongoing
              });
              widget.onItemsChanged(_projectGalleryItems); // Notify parent
            }
          } catch (e, st) {
            logger.severe("Error processing upload for $tempId", e, st);
            if (mounted) {
              setState(() {
                final index = _ongoingUploads.indexWhere(
                  (up) => up.tempId == tempId,
                );
                if (index != -1) {
                  _ongoingUploads[index].error = "Processing failed";
                }
              });
              _showError("Processing failed for ${_getFileName(file.path)}");
            }
          }
        },
      );
    }
  }

  Future<void> _deleteGalleryItem(int index) async {
    if (index < 0 || index >= _projectGalleryItems.length) return;
    Map<String, dynamic> itemToDelete = _projectGalleryItems[index];
    String? urlToDelete = itemToDelete['storageUrl'];

    setState(() => _projectGalleryItems.removeAt(index)); // Optimistic remove
    widget.onItemsChanged(_projectGalleryItems); // Notify parent

    try {
      await widget.storageService.deleteGalleryItem(urlToDelete);
      _showInfo("Gallery item removed.");
    } catch (e) {
      logger.severe("Error deleting gallery item", e);
      if (mounted) {
        setState(
          () => _projectGalleryItems.insert(index, itemToDelete),
        ); // Add back
        widget.onItemsChanged(_projectGalleryItems); // Notify parent
        _showError("Failed to delete item file.");
      }
    }
  }

  Future<void> _cancelUpload(GalleryUpload upload) async {
    try {
      TaskState currentState = upload.task.snapshot.state;
      if (currentState == TaskState.running ||
          currentState == TaskState.paused) {
        await upload.task.cancel();
      }
      upload.descriptionController.dispose(); // Dispose controller on cancel
      if (mounted) {
        setState(
          () => _ongoingUploads.removeWhere((up) => up.tempId == upload.tempId),
        );
      }
      logger.info("Upload cancelled: ${upload.tempId}");
    } catch (e, st) {
      logger.warning("Error cancelling upload task", e, st);
      upload.descriptionController.dispose(); // Ensure dispose on error too
      if (mounted) {
        setState(
          () => _ongoingUploads.removeWhere((up) => up.tempId == upload.tempId),
        );
      }
    }
  }

  // Update description in the local state list
  void _updateItemDescription(int index, String newDescription) {
    if (index >= 0 && index < _projectGalleryItems.length) {
      setState(() {
        _projectGalleryItems[index]['description'] = newDescription.trim();
      });
      // Notify parent immediately or just let final save handle it?
      // Let's notify immediately for consistency
      widget.onItemsChanged(_projectGalleryItems);
    }
  }

  String _getFileName(String? path) {
    if (path == null) return "No file selected";
    try {
      return p.basename(path);
    } catch (e) {
      return "Invalid path";
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showInfo(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Project Gallery",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Display Existing Items
        if (_projectGalleryItems.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _projectGalleryItems.length,
            itemBuilder: (context, index) =>
                _buildGalleryItem(_projectGalleryItems[index], index),
          ),
        // Display Ongoing Uploads
        if (_ongoingUploads.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _ongoingUploads.length,
            itemBuilder: (context, index) =>
                _buildUploadingItem(_ongoingUploads[index]),
          ),

        // Show empty message if nothing is uploaded or uploading
        if (_projectGalleryItems.isEmpty && _ongoingUploads.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                "Add images, videos, or PDFs to showcase your work.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ),

        // Add Item Button
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: OutlinedButton.icon(
            icon: Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text("Add Gallery Item (Image/Video/PDF)"),
            // Disable button if an upload is in progress? Optional.
            // onPressed: _ongoingUploads.any((up) => up.error == null) ? null : _pickAndUploadGalleryItem,
            onPressed: _pickAndUploadGalleryItem,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[400],
              side: BorderSide(color: Colors.grey[700]!),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryItem(Map<String, dynamic> item, int index) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: Colors.grey[400], size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getFileName(
                    Uri.decodeComponent(Uri.parse(url).pathSegments.last),
                  ), // Decode name
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => _deleteGalleryItem(index),
                tooltip: "Remove Item",
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descController,
            style: TextStyle(color: Colors.grey[300], fontSize: 12),
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: "Add a description...",
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
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
            onChanged: (newDescription) =>
                _updateItemDescription(index, newDescription),
            onEditingComplete: () {
              // Optionally unfocus or do something else when editing is done
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingItem(GalleryUpload upload) {
    TaskState currentState = upload.task.snapshot.state;
    bool isUploading =
        currentState == TaskState.running || currentState == TaskState.paused;

    Widget statusIcon = SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    if (upload.error != null || currentState == TaskState.error) {
      statusIcon = Icon(Icons.error_outline, color: Colors.redAccent, size: 20);
    } else if (currentState == TaskState.success) {
      statusIcon = Icon(
        Icons.check_circle_outline,
        color: Colors.greenAccent,
        size: 20,
      );
    } else if (isUploading && upload.progress > 0) {
      statusIcon = Text(
        "${(upload.progress * 100).toStringAsFixed(0)}%",
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
                  _getFileName(upload.file.path),
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              statusIcon,
              if (isUploading)
                IconButton(
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.orangeAccent,
                    size: 20,
                  ),
                  onPressed: () => _cancelUpload(upload),
                  tooltip: "Cancel Upload",
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
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
                style: TextStyle(color: Colors.redAccent, fontSize: 11),
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
              contentPadding: EdgeInsets.symmetric(
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers for ongoing uploads
    for (var upload in _ongoingUploads) {
      upload.descriptionController.dispose();
      // Don't cancel task here if you want it to complete in background
      // upload.task.cancel();
    }
    super.dispose();
  }
}

// Assume GalleryUpload class is defined here or imported
class GalleryUpload {
  final String tempId;
  final File file;
  final UploadTask task;
  double progress;
  String? error;
  final TextEditingController descriptionController;

  GalleryUpload({
    required this.tempId,
    required this.file,
    required this.task,
    this.progress = 0.0,
    this.error,
  }) : descriptionController = TextEditingController();
}
