import 'dart:io';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/widgets/search_user_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/services/storage_service.dart';
import 'package:auteurly/features/components/textfield.dart';

class CreateProjectPage extends StatefulWidget {
  final VoidCallback onProjectCreated;
  final VoidCallback onCancel;
  const CreateProjectPage({
    super.key,
    required this.onProjectCreated,
    required this.onCancel,
  });

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _auth = FirebaseAuth.instance;

  // State
  bool _isSaving = false;
  File? _selectedImage;

  // Controllers
  final _titleController = TextEditingController();
  String _projectType = 'Short Film'; // Default value
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _roleController = TextEditingController();
  final _crewSearchController = TextEditingController();
  final List<NewCredit> _addedCrew = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showSearchUserDialog() async {
    // Show the dialog and wait for it to return a UserModel
    final UserModel? selectedUser = await showDialog<UserModel>(
      context: context,
      builder: (context) => const SearchUserDialog(),
    );

    // If the user selected someone (i.e., didn't press cancel)
    if (selectedUser != null) {
      // Then show the dialog to add their role
      _showAddRoleDialog(selectedUser);
    }
  }

  void _showAddRoleDialog(UserModel user) {
    final roleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // --- STYLING APPLIED HERE ---
        backgroundColor: const Color(0xFF2C2C2C), // Dark background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Add ${user.fullName}",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: roleController,
          autofocus: true,
          style: const TextStyle(color: Colors.white), // User input color
          decoration: InputDecoration(
            hintText: "Their role...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFA32626)),
            ),
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          // Add button
          TextButton(
            child: const Text(
              "Add",
              style: TextStyle(
                color: Color(0xFFA32626),
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              if (roleController.text.isNotEmpty) {
                setState(() {
                  _addedCrew.add(
                    NewCredit(
                      userId: user.uid,
                      userFullName: user.fullName,
                      role: roleController.text,
                    ),
                  );
                });
                Navigator.pop(context); // Close role dialog
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    final creatorCredit = NewCredit(
      userId: user.uid,
      userFullName: user.displayName ?? user.email ?? '',
      role: _roleController.text,
    );

    final allCredits = [creatorCredit, ..._addedCrew];

    try {
      final newProjectId = FirebaseFirestore.instance
          .collection('projects')
          .doc()
          .id;

      String? posterUrl;
      if (_selectedImage != null) {
        // You'll need a method in StorageService to upload project posters
        posterUrl = await _storageService.uploadProjectPoster(
          newProjectId,
          _selectedImage!,
        );
      }
      await _firestoreService.addProjectWithCredit(
        projectId: newProjectId,
        title: _titleController.text,
        projectType: _projectType,
        description: _descriptionController.text,
        year: int.parse(_yearController.text),
        posterUrl: posterUrl,
        createdBy: user.uid,
        credits: allCredits,
      );

      widget.onProjectCreated(); // Go back on success
    } catch (e) {
      // Show error SnackBar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving project: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _crewSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        title: const Text('Add New Project'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onCancel, // Call the callback when pressed
        ),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveProject,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // --- Project Poster ---
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- Project Title ---
                  MyTextfield(
                    controller: _titleController,
                    hintText: 'Project Title',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  // --- Project Type Dropdown ---
                  DropdownButtonFormField<String>(
                    value: _projectType,
                    items:
                        [
                              'Short Film',
                              'Feature Film',
                              'Commercial',
                              'Music Video',
                              'Documentary',
                            ]
                            .map(
                              (label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _projectType = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Project Type',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  MyTextfield(
                    controller: _descriptionController,
                    hintText: 'Project Synopsis/Description',
                    maxLines: 4, // Make it a larger text field
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  // --- Year ---
                  MyTextfield(
                    controller: _yearController,
                    hintText: 'Year',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a year' : null,
                  ),
                  const SizedBox(height: 16),
                  // --- Your Role ---
                  MyTextfield(
                    controller: _roleController,
                    hintText: 'Your Role on this Project',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your role' : null,
                  ),
                  const Divider(color: Color(0xFF2C2C2C), height: 40),

                  // --- NEW: Cast & Crew Section ---
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Add Cast & Crew',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFFA32626),
                        ),
                        onPressed: _showSearchUserDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // List of added crew members
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _addedCrew.length,
                    itemBuilder: (context, index) {
                      final crewMember = _addedCrew[index];
                      return ListTile(
                        title: Text(
                          crewMember.userFullName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          crewMember.role,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _addedCrew.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
