import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }

  Future<String?> uploadProjectPoster(String projectId, File imageFile) async {
    try {
      // Create a reference using the unique project ID
      final ref = _storage
          .ref()
          .child('project_posters')
          .child('$projectId.jpg');

      // Upload the file
      final uploadTask = ref.putFile(imageFile);

      // Get the download URL after the upload is complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading project poster: $e');
      return null;
    }
  }

  UploadTask uploadShowreelVideo(String userId, File videoFile) {
    // Generate a unique file name, keeping the original extension
    String fileExtension = p.extension(videoFile.path);
    String fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

    // Define the storage path: showreels/USER_ID/UNIQUE_FILENAME.mp4
    Reference ref = _storage.ref().child('showreels/$userId/$fileName');

    // Start the upload and return the UploadTask
    // The UploadTask allows tracking progress
    UploadTask uploadTask = ref.putFile(
      videoFile,
      SettableMetadata(
        contentType: 'video/${fileExtension.substring(1)}',
      ), // Set content type
    );
    return uploadTask;
  }

  // --- Optional: Add a method to delete old showreel if needed ---
  Future<void> deleteShowreelVideo(String? fileUrl) async {
    if (fileUrl == null || fileUrl.isEmpty) return;
    try {
      Reference photoRef = _storage.refFromURL(fileUrl);
      await photoRef.delete();
      print("Old showreel deleted successfully.");
    } catch (e) {
      print("Error deleting old showreel: $e");
      // Handle errors, e.g., file not found
    }
  }

  UploadTask uploadGalleryItem(String userId, File file) {
    String fileExtension = p.extension(file.path).toLowerCase();
    String fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    String contentType;

    // Determine content type based on extension
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(fileExtension)) {
      contentType = 'image/${fileExtension.substring(1)}';
    } else if ([
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      '.webm',
    ].contains(fileExtension)) {
      contentType = 'video/${fileExtension.substring(1)}';
    } else if (fileExtension == '.pdf') {
      contentType = 'application/pdf';
    } else {
      contentType = 'application/octet-stream'; // Generic fallback
    }

    Reference ref = _storage.ref().child('project_gallery/$userId/$fileName');
    UploadTask uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );
    return uploadTask;
  }

  // --- ADDED: Delete Gallery Item ---
  Future<void> deleteGalleryItem(String? fileUrl) async {
    if (fileUrl == null || fileUrl.isEmpty) return;
    try {
      Reference itemRef = _storage.refFromURL(fileUrl);
      await itemRef.delete();
      print("Gallery item deleted successfully.");
    } catch (e) {
      print("Error deleting gallery item: $e");
      // Consider re-throwing or handling specific errors (e.g., object-not-found)
      // Re-throwing allows the UI to know deletion failed.
      rethrow;
    }
  }
}
