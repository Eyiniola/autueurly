import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:auteurly/core/services/storage_service.dart'; // Adjust path
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart'; // For user ID

class ShowreelEditor extends StatefulWidget {
  final String? initialShowreelUrl;
  final Function(String? newUrl) onUrlChanged; // Callback to parent
  final StorageService storageService; // Pass instance

  const ShowreelEditor({
    super.key,
    this.initialShowreelUrl,
    required this.onUrlChanged,
    required this.storageService,
  });

  @override
  State<ShowreelEditor> createState() => _ShowreelEditorState();
}

class _ShowreelEditorState extends State<ShowreelEditor> {
  File? _selectedVideo;
  UploadTask? _uploadTask;
  double? _uploadProgress;
  String? _currentShowreelUrl; // Local state mirroring parent
  bool _isUploading = false; // Track upload state locally

  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _currentShowreelUrl = widget.initialShowreelUrl;
  }

  // Update local state if the initial URL changes (e.g., parent reloads)
  @override
  void didUpdateWidget(covariant ShowreelEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialShowreelUrl != oldWidget.initialShowreelUrl) {
      setState(() {
        _currentShowreelUrl = widget.initialShowreelUrl;
        // Optionally cancel ongoing upload if initial URL changes externally?
        // _cancelCurrentUpload();
        _selectedVideo = null; // Clear selection if initial changes
      });
    }
  }

  Future<void> _pickAndUploadShowreelVideo() async {
    if (_userId == null) {
      _showError("Please log in to upload.");
      return;
    }
    // Cancel any previous upload before starting a new one
    await _cancelCurrentUpload();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      File videoFile = File(result.files.single.path!);

      // Delete the old video *before* starting the new upload
      // Do this only if user confirms replacement, or handle failure gracefully
      String? oldUrlToDelete = _currentShowreelUrl; // Capture current URL

      setState(() {
        _selectedVideo = videoFile; // Show selected file immediately
        _uploadProgress = 0.0; // Show progress bar starting
        _isUploading = true;
        _currentShowreelUrl = null; // Clear current URL display during upload
        widget.onUrlChanged(null); // Notify parent URL is temporarily invalid
        _uploadTask = widget.storageService.uploadShowreelVideo(
          _userId!,
          videoFile,
        );
      });

      // Attempt to delete old video after selection, before upload completes
      if (oldUrlToDelete != null) {
        try {
          await widget.storageService.deleteShowreelVideo(oldUrlToDelete);
          print("Old showreel deleted preemptively.");
        } catch (e) {
          print("Could not delete old showreel preemptively: $e");
          // Decide if you want to proceed with upload anyway or show error
        }
      }

      _uploadTask?.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (mounted) {
            setState(
              () => _uploadProgress =
                  snapshot.bytesTransferred / snapshot.totalBytes,
            );
          }
        },
        onError: (error) {
          print("Showreel Upload Error: $error");
          if (mounted) {
            _showError("Upload failed: ${error.toString()}");
            setState(() {
              _isUploading = false;
              _uploadTask = null;
              _uploadProgress = null;
              _selectedVideo = null;
            });
            // Should we restore _currentShowreelUrl if upload fails? Maybe not if old one was deleted.
          }
        },
        onDone: () async {
          try {
            TaskSnapshot snapshot = await _uploadTask!;
            String downloadUrl = await snapshot.ref.getDownloadURL();
            if (mounted) {
              setState(() {
                _currentShowreelUrl = downloadUrl; // Update local state
                _selectedVideo = null; // Clear selected file display
                _isUploading = false;
                _uploadTask = null;
                _uploadProgress = null;
              });
              widget.onUrlChanged(downloadUrl); // Notify parent
            }
          } catch (e) {
            print("Error getting showreel download URL: $e");
            if (mounted) {
              _showError("Processing failed after upload.");
              setState(() {
                _isUploading = false;
                _uploadTask = null;
                _uploadProgress = null;
                _selectedVideo = null;
              });
            }
          }
        },
      );
    } else {
      // User canceled picker
    }
  }

  Future<void> _removeShowreel() async {
    await _cancelCurrentUpload(); // Cancel if uploading

    if (_selectedVideo != null) {
      // If just selected, clear selection
      setState(() {
        _selectedVideo = null;
      });
      return;
    }

    if (_currentShowreelUrl != null) {
      String? urlToDelete = _currentShowreelUrl;
      setState(() {
        _currentShowreelUrl = null; // Clear UI
        widget.onUrlChanged(null); // Notify parent
      });
      try {
        await widget.storageService.deleteShowreelVideo(urlToDelete);
        _showInfo("Showreel removed.");
      } catch (e) {
        print("Error removing showreel: $e");
        _showError("Failed to remove showreel file.");
        // Revert UI if needed
        // setState(() { _currentShowreelUrl = urlToDelete; widget.onUrlChanged(urlToDelete); });
      }
    }
  }

  Future<void> _cancelCurrentUpload() async {
    if (_uploadTask != null && _isUploading) {
      try {
        await _uploadTask!.cancel();
        print("Showreel upload cancelled.");
      } catch (e) {
        print("Error cancelling showreel upload: $e");
      } finally {
        if (mounted) {
          setState(() {
            _uploadTask = null;
            _uploadProgress = null;
            _isUploading = false;
            _selectedVideo = null; // Clear selection on cancel
            // Should we restore _currentShowreelUrl? Probably not if cancel happened mid-upload
          });
        }
      }
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
    String displayFileName = "No showreel uploaded";
    bool hasShowreel = false;

    if (_selectedVideo != null) {
      displayFileName = _getFileName(_selectedVideo!.path);
      hasShowreel = true; // Indicates something is selected/uploading
    } else if (_currentShowreelUrl != null && _currentShowreelUrl!.isNotEmpty) {
      try {
        displayFileName =
            "Current: ${_getFileName(Uri.parse(_currentShowreelUrl!).pathSegments.last)}";
        hasShowreel = true;
      } catch (e) {
        displayFileName = "Current showreel uploaded";
        hasShowreel = true;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Showreel",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _isUploading
                          ? "Uploading: ${_getFileName(_selectedVideo?.path)}"
                          : displayFileName,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Show Upload/Change button OR Remove button
                  if (hasShowreel &&
                      !_isUploading) // Show remove if URL exists or video selected but NOT uploading
                    TextButton.icon(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      label: Text("Remove"),
                      onPressed: _removeShowreel,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        textStyle: TextStyle(fontSize: 14),
                      ),
                    )
                  else // Show Upload/Change button otherwise (or if uploading)
                    TextButton.icon(
                      icon: Icon(
                        _isUploading
                            ? Icons.hourglass_top
                            : (hasShowreel
                                  ? Icons.edit_outlined
                                  : Icons.upload_file),
                        size: 18,
                      ),
                      label: Text(
                        _isUploading
                            ? "Uploading..."
                            : (hasShowreel ? "Change" : "Upload"),
                      ),
                      onPressed: _isUploading
                          ? null
                          : _pickAndUploadShowreelVideo, // Disable while uploading
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
              // Show progress bar if uploading
              if (_isUploading && _uploadProgress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              // Optionally show cancel button during upload
              if (_isUploading)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(
                      "Cancel Upload",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: _cancelCurrentUpload,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cancelCurrentUpload();
    super.dispose();
  }
}
