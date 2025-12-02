import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/services/storage_service.dart';
import 'package:auteurly/core/widgets/tag_input_widget.dart';
import 'package:auteurly/core/widgets/gallery_upload.dart';
import 'package:auteurly/core/widgets/profile_picture_picker.dart';
import 'package:auteurly/core/widgets/showreel_upload_widget.dart';
import 'package:auteurly/core/widgets/gallery_item_widget.dart';
import 'package:auteurly/core/widgets/uploading_item_widget.dart';
import 'package:auteurly/features/components/textfield.dart';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _auth = FirebaseAuth.instance;

  // State
  bool _isLoading = true;
  bool _isSaving = false;
  File? _selectedImage;
  String? _existingImageUrl;
  String? _existingShowreelUrl; // Store existing showreel URL

  File? _selectedVideo;
  UploadTask? _uploadTask;
  double? _uploadProgress;

  List<Map<String, dynamic>> _projectGalleryItems = [];
  final List<GalleryUpload> _ongoingUploads = [];

  // Controllers and Lists for all editable fields
  late TextEditingController _headlineController;
  late TextEditingController _fullNameController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  List<String> _keyRoles = [];
  List<String> _skills = [];
  List<String> _genres = [];
  List<String> _equipment = [];
  List<String> _languages = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false); // Stop loading if no user
      // Optionally show an error or navigate away
      return;
    }

    try {
      final userModel = await _firestoreService.getUserProfile(user.uid);
      if (userModel != null) {
        _headlineController = TextEditingController(text: userModel.headline);
        _fullNameController = TextEditingController(text: userModel.fullName);
        _locationController = TextEditingController(text: userModel.location);
        _bioController = TextEditingController(text: userModel.bio);
        _existingShowreelUrl = userModel.showreelUrl;
        _existingImageUrl = userModel.profilePictureUrl;
        _keyRoles = List.from(userModel.keyRoles);
        _skills = List.from(userModel.skills);
        _genres = List.from(userModel.genres);
        _equipment = List.from(userModel.equipment);
        _languages = List.from(userModel.languages);
        // Load existing gallery items
        _projectGalleryItems = List<Map<String, dynamic>>.from(
          userModel.projectGallery,
        );
      } else {
        // Initialize empty for new profile
        _headlineController = TextEditingController();
        _fullNameController = TextEditingController();
        _locationController = TextEditingController();
        _bioController = TextEditingController();
      }
    } catch (e, st) {
      logger.severe("Error loading user data", e, st);
      // Handle error loading data (e.g., show error message)
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickShowreelVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
        _uploadTask = null; // Clear any previous upload task/progress
        _uploadProgress = null;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> _pickAndUploadGalleryItem() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please log in again."),
          backgroundColor: Colors.red,
        ),
      );
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
      ], // Specify allowed types
      allowMultiple: false, // Start with single file upload
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String tempId = DateTime.now().millisecondsSinceEpoch
          .toString(); // Unique ID for this upload
      UploadTask uploadTask = _storageService.uploadGalleryItem(userId, file);

      // Add to ongoing uploads list for UI tracking
      setState(() {
        _ongoingUploads.add(
          GalleryUpload(tempId: tempId, file: file, task: uploadTask),
        );
      });

      // Listen for progress and completion
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (mounted) {
            setState(() {
              // Find the upload by tempId and update its progress
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
              // Find the upload and mark it with an error
              final index = _ongoingUploads.indexWhere(
                (up) => up.tempId == tempId,
              );
              if (index != -1) {
                _ongoingUploads[index].error = "Upload failed";
                // Optionally remove after a delay or let user retry/remove
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Upload failed for ${_getFileName(file.path)}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onDone: () async {
          // Upload finished, get URL and add to final list
          try {
            TaskSnapshot snapshot =
                await uploadTask; // Ensure task is awaited here again for safety
            String downloadUrl = await snapshot.ref.getDownloadURL();
            String fileExtension = p
                .extension(file.path)
                .toLowerCase()
                .substring(1);
            String type = 'other'; // Default type

            if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
              type = 'image';
            } else if ([
              'mp4',
              'mov',
              'avi',
              'mkv',
              'webm',
            ].contains(fileExtension)) {
              type = 'video';
            } else if (fileExtension == 'pdf') {
              type = 'pdf';
            }

            final uploadIndex = _ongoingUploads.indexWhere(
              (up) => up.tempId == tempId,
            );
            String description = "";
            if (uploadIndex != -1) {
              description = _ongoingUploads[uploadIndex]
                  .descriptionController
                  .text
                  .trim();
            }

            if (mounted) {
              setState(() {
                // Add the completed item to the main list
                _projectGalleryItems.add({
                  'type': type,
                  'storageUrl': downloadUrl,
                  'description': '', // User can add description later if needed
                });
                // Remove from ongoing uploads
                _ongoingUploads.removeWhere((up) => up.tempId == tempId);
              });
            }
          } catch (e, st) {
            logger.severe("Error getting download URL for $tempId", e, st);
            if (mounted) {
              setState(() {
                final index = _ongoingUploads.indexWhere(
                  (up) => up.tempId == tempId,
                );
                if (index != -1) {
                  _ongoingUploads[index].error = "Processing failed";
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Processing failed for ${_getFileName(file.path)}",
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ); // End listen
    } else {
      // User canceled the picker
    }
  }

  // --- ADDED: DELETE GALLERY ITEM ---
  Future<void> _deleteGalleryItem(int index) async {
    if (index < 0 || index >= _projectGalleryItems.length) return;

    // Get the item to delete
    Map<String, dynamic> itemToDelete = _projectGalleryItems[index];
    String? urlToDelete = itemToDelete['storageUrl'];

    // Optimistically remove from UI
    setState(() {
      _projectGalleryItems.removeAt(index);
    });

    try {
      // Attempt to delete from storage
      await _storageService.deleteGalleryItem(urlToDelete);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gallery item removed."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      logger.severe("Error deleting gallery item from storage", e);
      // If deletion fails, add it back to the UI and show error
      if (mounted) {
        setState(() {
          _projectGalleryItems.insert(index, itemToDelete); // Put it back
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to delete item from storage. Please try again.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    // Check if gallery items are still uploading
    if (_ongoingUploads.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please wait for gallery uploads to complete."),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Prevent saving while uploads are in progress
    }

    setState(() {
      _isSaving = true;
      _uploadProgress = null; // Reset showreel progress
      _uploadTask = null;
    });

    String? finalImageUrl = _existingImageUrl;
    String? finalShowreelUrl = _existingShowreelUrl;

    try {
      // 1. Upload Profile Picture (if changed)
      if (_selectedImage != null) {
        finalImageUrl = await _storageService.uploadProfilePicture(
          _auth.currentUser!.uid,
          _selectedImage!,
        );
      }

      // 2. Upload Showreel Video (if changed)
      if (_selectedVideo != null) {
        await _storageService.deleteShowreelVideo(_existingShowreelUrl);
        final uploadTask = _storageService.uploadShowreelVideo(
          _auth.currentUser!.uid,
          _selectedVideo!,
        );
        setState(() {
          _uploadTask = uploadTask;
        }); // Show progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (mounted) {
            setState(
              () => _uploadProgress =
                  snapshot.bytesTransferred / snapshot.totalBytes,
            );
          }
        });
        TaskSnapshot snapshot = await uploadTask;
        finalShowreelUrl = await snapshot.ref.getDownloadURL();
      }

      // 3. Prepare Firestore Data (Include project gallery)
      final updatedData = {
        'fullName': _fullNameController.text.trim(),
        'headline': _headlineController.text.trim(),
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'showreelUrl': finalShowreelUrl,
        'keyRoles': _keyRoles,
        'skills': _skills,
        'genres': _genres,
        'equipment': _equipment,
        'languages': _languages,
        'profilePictureUrl': finalImageUrl,
        'projectGallery': _projectGalleryItems, // <-- ADDED GALLERY LIST
        'isProfileComplete': true,
      };

      // 4. Update Firestore
      await _firestoreService.updateUserProfile(
        _auth.currentUser!.uid,
        updatedData,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e, st) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      logger.severe("Error saving profile", e, st);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _uploadTask = null;
          _uploadProgress = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    // Dispose all ongoing uploads
    for (final upload in _ongoingUploads) {
      upload.dispose();
    }
    super.dispose();
  }

  String _getFileName(String? path) {
    if (path == null) return "No file selected";
    try {
      return p.basename(path); // Gets filename from path
    } catch (e) {
      return "Invalid path";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent, // Consistent styling
        foregroundColor: Colors.white, // Ensure icons/text are white
        elevation: 0,
        actions: [
          // Show spinner in action bar while saving
          if (_isSaving &&
              _uploadTask ==
                  null) // Show generic spinner only if not uploading video
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _isSaving ? null : _saveProfile,
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                // Use ListView for scrolling
                padding: const EdgeInsets.all(24.0),
                children: [
                  // --- Profile Picture ---
                  Center(
                    child: ProfilePicturePicker(
                      selectedImage: _selectedImage,
                      existingImageUrl: _existingImageUrl,
                      onPickImage: _pickImage,
                      showEditIcon: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Text Fields ---
                  MyTextfield(
                    controller: _fullNameController,
                    hintText: 'Full Name',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Full Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  MyTextfield(
                    controller: _headlineController,
                    hintText: 'Headline (e.g., Film Director, Cinematographer)',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Headline cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  MyTextfield(
                    controller: _locationController,
                    hintText: 'Location (e.g., Kigali, Rwanda)',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Location cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  MyTextfield(
                    controller: _bioController,
                    hintText: 'Bio (Tell us about yourself)',
                    maxLines: 6,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Bio cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 24), // Space before Showreel
                  // --- SHOWREEL SECTION ---
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
                    initialShowreelUrl: _existingShowreelUrl,
                    onUrlChanged: (url) {
                      setState(() {
                        _existingShowreelUrl = url;
                      });
                    },
                    storageService: _storageService,
                    userId: _auth.currentUser?.uid,
                    isEnabled: !_isSaving,
                  ),

                  // --- END SHOWREEL SECTION ---
                  const SizedBox(height: 24),

                  // --- PROJECT GALLERY SECTION ---
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
                    Column(
                      children: List.generate(
                        _projectGalleryItems.length,
                        (index) => GalleryItemWidget(
                          item: _projectGalleryItems[index],
                          index: index,
                          onDelete: () => _deleteGalleryItem(index),
                          onDescriptionChanged: (description) {
                            if (index < _projectGalleryItems.length) {
                              _projectGalleryItems[index]['description'] =
                                  description;
                            }
                          },
                          isEnabled: !_isSaving,
                        ),
                      ),
                    ),
                  // Display Ongoing Uploads
                  if (_ongoingUploads.isNotEmpty)
                    Column(
                      children: _ongoingUploads
                          .map(
                            (upload) => UploadingItemWidget(
                              upload: upload,
                              onCancel: () async {
                                try {
                                  TaskState currentState =
                                      upload.task.snapshot.state;
                                  if (currentState == TaskState.running ||
                                      currentState == TaskState.paused) {
                                    await upload.task.cancel();
                                    if (mounted) {
                                      setState(
                                        () => _ongoingUploads.removeWhere(
                                          (up) => up.tempId == upload.tempId,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      setState(
                                        () => _ongoingUploads.removeWhere(
                                          (up) => up.tempId == upload.tempId,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(
                                      () => _ongoingUploads.removeWhere(
                                        (up) => up.tempId == upload.tempId,
                                      ),
                                    );
                                  }
                                }
                              },
                              onDescriptionChanged: (description) {
                                // Description is handled by the upload's controller
                              },
                            ),
                          )
                          .toList(),
                    ),
                  // Add Item Button
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.add_photo_alternate_outlined, size: 18),
                      label: Text("Add Gallery Item (Image/Video)"),
                      onPressed: _isSaving
                          ? null
                          : _pickAndUploadGalleryItem, // Disable while saving profile
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

                  // --- Tag Inputs ---
                  TagInputWidget(
                    label: 'Key Roles',
                    hintText: 'Add a role (e.g., Director)...',
                    tags: _keyRoles,
                    onTagAdded: (tag) => setState(() => _keyRoles.add(tag)),
                    onTagRemoved: (tag) =>
                        setState(() => _keyRoles.remove(tag)),
                  ),

                  const SizedBox(height: 16),
                  TagInputWidget(
                    label: 'Skills',
                    hintText: 'Add a skill (e.g., Editing, Color Grading)...',
                    tags: _skills,
                    onTagAdded: (tag) => setState(() => _skills.add(tag)),
                    onTagRemoved: (tag) => setState(() => _skills.remove(tag)),
                  ),
                  const SizedBox(height: 16),
                  TagInputWidget(
                    label: 'Genres',
                    hintText: 'Add a genre (e.g., Drama, Documentary)...',
                    tags: _genres,
                    onTagAdded: (tag) => setState(() => _genres.add(tag)),
                    onTagRemoved: (tag) => setState(() => _genres.remove(tag)),
                  ),
                  const SizedBox(height: 16),
                  TagInputWidget(
                    label: 'Equipment',
                    hintText: 'Add equipment (e.g., RED Camera, Drone)...',
                    tags: _equipment,
                    onTagAdded: (tag) => setState(() => _equipment.add(tag)),
                    onTagRemoved: (tag) =>
                        setState(() => _equipment.remove(tag)),
                  ),
                  const SizedBox(height: 16),
                  TagInputWidget(
                    label: 'Languages',
                    hintText: 'Add a language (e.g., English, Kinyarwanda)...',
                    tags: _languages,
                    onTagAdded: (tag) => setState(() => _languages.add(tag)),
                    onTagRemoved: (tag) =>
                        setState(() => _languages.remove(tag)),
                  ),
                  const SizedBox(height: 30), // Bottom padding
                ],
              ),
            ),
    );
  }
}

// Setup logger
final Logger logger = Logger('EditProfilePage');

void setupLogger() {
  Logger.root.level = Level.ALL; // Log all levels
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('ERROR: ${record.error}');
    }
    if (record.stackTrace != null) {
      print(record.stackTrace);
    }
  });
}
