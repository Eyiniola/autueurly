import 'dart:io';
import 'package:flutter/material.dart';

class ProfilePicturePicker extends StatelessWidget {
  final File? selectedImage;
  final String? existingImageUrl;
  final VoidCallback onPickImage;
  final double radius;
  final bool showEditIcon;

  const ProfilePicturePicker({
    super.key,
    this.selectedImage,
    this.existingImageUrl,
    required this.onPickImage,
    this.radius = 60.0,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[800],
            backgroundImage: _getBackgroundImage(),
            child: _getChild(),
          ),
          if (showEditIcon)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1B1B1B), width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    } else if (existingImageUrl != null) {
      return NetworkImage(existingImageUrl!);
    }
    return null;
  }

  Widget? _getChild() {
    if (selectedImage == null && existingImageUrl == null) {
      return Icon(Icons.person, size: radius, color: Colors.grey);
    }
    return null;
  }
}
