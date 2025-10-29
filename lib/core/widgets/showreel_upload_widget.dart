import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:auteurly/core/services/storage_service.dart';
import 'package:path/path.dart' as p;

class ShowreelUploadWidget extends StatefulWidget {
  final String? initialShowreelUrl;
  final Function(String? newUrl) onUrlChanged;
  final StorageService storageService;
  final String? userId;
  final bool isEnabled;

  const ShowreelUploadWidget({
    super.key,
    this.initialShowreelUrl,
    required this.onUrlChanged,
    required this.storageService,
    required this.userId,
    this.isEnabled = true,
  });

  @override
  State<ShowreelUploadWidget> createState() => _ShowreelUploadWidgetState();
}

class _ShowreelUploadWidgetState extends State<ShowreelUploadWidget> {
  File? _selectedVideo;
  UploadTask? _uploadTask;
  double? _uploadProgress;
  String? _currentShowreelUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentShowreelUrl = widget.initialShowreelUrl;
  }

  @override
  void didUpdateWidget(covariant ShowreelUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialShowreelUrl != oldWidget.initialShowreelUrl) {
      setState(() {
        _currentShowreelUrl = widget.initialShowreelUrl;
        _selectedVideo = null;
      });
    }
  }

  Future<void> _pickShowreelVideo() async {
    if (widget.userId == null) {
      _showError("Please log in to upload.");
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      File videoFile = File(result.files.single.path!);
      setState(() {
        _selectedVideo = videoFile;
        _uploadProgress = null;
        _isUploading = true;
        _uploadTask = widget.storageService.uploadShowreelVideo(widget.userId!, videoFile);
      });

      _uploadTask?.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      try {
        TaskSnapshot snapshot = await _uploadTask!;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        if (mounted) {
          setState(() {
            _currentShowreelUrl = downloadUrl;
            _selectedVideo = null;
            _isUploading = false;
            _uploadTask = null;
            _uploadProgress = null;
          });
          widget.onUrlChanged(downloadUrl);
        }
      } catch (e) {
        _showError("Upload failed: $e");
        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadTask = null;
            _uploadProgress = null;
          });
        }
      }
    }
  }

  Future<void> _removeShowreel() async {
    if (_uploadTask != null && _isUploading) {
      await _uploadTask!.cancel();
      setState(() {
        _uploadTask = null;
        _uploadProgress = null;
        _isUploading = false;
        _selectedVideo = null;
      });
      return;
    }

    if (_selectedVideo != null) {
      setState(() {
        _selectedVideo = null;
      });
      return;
    }

    if (_currentShowreelUrl != null) {
      String? urlToDelete = _currentShowreelUrl;
      setState(() {
        _currentShowreelUrl = null;
        widget.onUrlChanged(null);
      });
      try {
        await widget.storageService.deleteShowreelVideo(urlToDelete);
        _showSuccess("Showreel removed.");
      } catch (e) {
        _showError("Failed to remove showreel file.");
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayFileName = "No showreel uploaded";
    bool hasShowreel = false;

    if (_selectedVideo != null) {
      displayFileName = _getFileName(_selectedVideo!.path);
      hasShowreel = true;
    } else if (_currentShowreelUrl != null && _currentShowreelUrl!.isNotEmpty) {
      try {
        displayFileName = "Current: ${_getFileName(Uri.parse(_currentShowreelUrl!).pathSegments.last)}";
        hasShowreel = true;
      } catch (e) {
        displayFileName = "Current showreel uploaded";
        hasShowreel = true;
      }
    }

    return Container(
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
                  displayFileName,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!hasShowreel || _selectedVideo != null)
                TextButton.icon(
                  icon: Icon(
                    _isUploading ? Icons.hourglass_top : Icons.upload_file,
                    size: 18,
                  ),
                  label: Text(
                    _isUploading ? "Uploading..." : (hasShowreel ? "Change" : "Upload"),
                  ),
                  onPressed: (!widget.isEnabled || _isUploading) ? null : _pickShowreelVideo,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                )
              else
                TextButton.icon(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  label: const Text("Remove"),
                  onPressed: (!widget.isEnabled || _isUploading) ? null : _removeShowreel,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
            ],
          ),
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
          if (_isUploading)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text(
                  "Cancel Upload",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
                onPressed: () async {
                  if (_uploadTask != null) {
                    await _uploadTask!.cancel();
                    setState(() {
                      _uploadTask = null;
                      _uploadProgress = null;
                      _isUploading = false;
                      _selectedVideo = null;
                    });
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
