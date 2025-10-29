import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auteurly/features/components/textfield.dart';

class Step1Essentials extends StatelessWidget {
  final TextEditingController headlineController;
  final TextEditingController locationController;
  final File? selectedImage;
  final VoidCallback onPickImage;

  const Step1Essentials({
    super.key,
    required this.headlineController,
    required this.locationController,
    required this.selectedImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'The Essentials',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload a profile picture and tell us your primary role.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: onPickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[800],
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : null,
              child: selectedImage == null
                  ? const Icon(Icons.camera_alt, color: Colors.white, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 48),
          MyTextfield(
            controller: headlineController,
            hintText: 'Primary Role (e.g., Actor, Director)',
          ),
          const SizedBox(height: 24),
          MyTextfield(
            controller: locationController,
            hintText: 'Location (City, Country)',
          ),
        ],
      ),
    );
  }
}
