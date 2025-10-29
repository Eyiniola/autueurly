import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GalleryUpload {
  final String tempId; // Unique ID for tracking during upload
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

  void dispose() {
    descriptionController.dispose();
  }
}
