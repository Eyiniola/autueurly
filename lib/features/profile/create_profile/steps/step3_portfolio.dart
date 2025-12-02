import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:auteurly/features/components/textfield.dart';
import 'package:auteurly/core/widgets/tag_input_widget.dart';
import 'package:auteurly/core/widgets/showreel_upload_widget.dart';
import 'package:path/path.dart' as p;
import 'package:auteurly/core/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Step3Portfolio extends StatefulWidget {
  // Keep existing callbacks and data
  final GlobalKey<FormState> formKey;
  final List<String> equipment;
  final List<String> languages;
  final Function(String) onEquipmentAdded;
  final Function(String) onEquipmentRemoved;
  final Function(String) onLanguageAdded;
  final Function(String) onLanguageRemoved;

  // --- ADDED: Callback for when showreel is uploaded ---
  final Function(String? url) onShowreelUrlChanged;
  final String?
  initialShowreelUrl; // To display if already uploaded in a previous attempt

  const Step3Portfolio({
    super.key,
    required this.formKey,
    required this.equipment,
    required this.languages,
    required this.onEquipmentAdded,
    required this.onEquipmentRemoved,
    required this.onLanguageAdded,
    required this.onLanguageRemoved,
    required this.onShowreelUrlChanged, // Add this to constructor
    this.initialShowreelUrl, // Add this to constructor
  });

  @override
  State<Step3Portfolio> createState() => _Step3PortfolioState();
}

class _Step3PortfolioState extends State<Step3Portfolio> {
  // --- State for Video Upload ---
  File? _selectedVideo;
  UploadTask? _uploadTask;
  double? _uploadProgress;
  String? _currentShowreelUrl; // Local state to track URL
  final bool _isUploading = false;

  // Assume StorageService and AuthService are accessible
  // You might need to get these via Provider or pass them in
  final StorageService _storageService = StorageService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _currentShowreelUrl = widget.initialShowreelUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio & Logistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Showcase your work and provide some final practical details.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // --- REPLACED TEXTFIELD WITH UPLOAD SECTION ---
            Text(
              "Showreel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ShowreelUploadWidget(
              initialShowreelUrl: _currentShowreelUrl,
              onUrlChanged: widget.onShowreelUrlChanged,
              storageService: _storageService,
              userId: _userId,
              isEnabled: true,
            ),

            // --- END OF REPLACEMENT ---
            const SizedBox(height: 24),

            // --- Equipment Input Section ---
            TagInputWidget(
              label: 'Equipment',
              hintText: 'e.g., Sony FX6',
              tags: widget.equipment,
              onTagAdded: widget.onEquipmentAdded,
              onTagRemoved: widget.onEquipmentRemoved,
            ),
            const SizedBox(height: 24),

            // --- Languages Input Section ---
            TagInputWidget(
              label: 'Languages',
              hintText: 'e.g., Kinyarwanda',
              tags: widget.languages,
              onTagAdded: widget.onLanguageAdded,
              onTagRemoved: widget.onLanguageRemoved,
            ),
            const SizedBox(height: 30), // Bottom padding
          ],
        ),
      ),
    );
  }
}
