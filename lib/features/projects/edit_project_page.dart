import 'dart:io';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/widgets/search_user_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/services/storage_service.dart';
import 'package:auteurly/features/components/textfield.dart';

class EditProjectPage extends StatefulWidget {
  final String projectId;
  const EditProjectPage({super.key, required this.projectId});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // State
  bool _isLoading = true;
  bool _isSaving = false;
  File? _selectedImage;
  String? _existingPosterUrl;
  final _crewSearchController = TextEditingController();
  final List<NewCredit> _addedCrew = [];
  String _selectedStatus = 'Development'; // Default value
  final List<String> _projectStatuses = [
    'Development',
    'Pre-Production',
    'In Production',
    'Post-Production',
    'Completed',
    'Released',
    'On Hold',
  ];

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _projectType = 'Short Film';
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    final projectModel = await _firestoreService.getProject(widget.projectId);
    final existingCredits = await _firestoreService
        .getCreditsForProject(widget.projectId)
        .first;
    if (projectModel != null && mounted) {
      _titleController.text = projectModel.title;
      _descriptionController.text = projectModel.description;
      _yearController.text = projectModel.year.toString();
      _selectedStatus = projectModel.status;

      setState(() {
        _projectType = projectModel.projectType;
        _existingPosterUrl = projectModel.posterUrl;

        // Populate the _addedCrew list with the credits we just fetched
        _addedCrew.clear();
        _addedCrew.addAll(
          existingCredits.map(
            (credit) => NewCredit(
              userId: credit.userId,
              userFullName: credit.userFullName,
              role: credit.role,
            ),
          ),
        );

        _isLoading = false;
      });
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
    });

    String? posterUrl;
    if (_selectedImage != null) {
      posterUrl = await _storageService.uploadProjectPoster(
        widget.projectId,
        _selectedImage!,
      );
    }

    final updatedData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'projectType': _projectType,
      'year': int.parse(_yearController.text),
      'posterUrl': posterUrl ?? _existingPosterUrl,
      'status': _selectedStatus,
    };

    final allCredits = _addedCrew;

    try {
      await _firestoreService.updateProjectAndOverwriteCredits(
        projectId: widget.projectId,
        projectData: updatedData,
        credits: allCredits,
      );
      Navigator.pop(context); // Go back on success
    } catch (e) {
      // Show error
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
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        title: const Text('Edit Project'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveChanges,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: _isLoading
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
                              : (_existingPosterUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          _existingPosterUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child:
                            _selectedImage == null && _existingPosterUrl == null
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
                  // Form Fields
                  MyTextfield(
                    controller: _titleController,
                    hintText: 'Project Title',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _projectType,
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
                                value: label,
                                child: Text(label),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _projectType = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Project Type',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFA32626)),
                      ),
                    ),
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  MyTextfield(
                    controller: _yearController,
                    hintText: 'Year',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  MyTextfield(
                    controller: _descriptionController,
                    hintText: 'Description',
                    maxLines: 4,
                  ),

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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    items: _projectStatuses.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Project Status',
                      // Use your existing InputDecorationTheme or customize here
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor:
                        Colors.grey[800], // Match dropdown background
                    style: const TextStyle(
                      color: Colors.white,
                    ), // Text style for selected item
                    iconEnabledColor: Colors.grey[400],
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
