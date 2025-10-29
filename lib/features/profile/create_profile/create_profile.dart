import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'steps/step1_essentials.dart';
import 'steps/step2_creative_identity.dart';
import 'steps/step3_portfolio.dart'; // Make sure Step3Portfolio is imported
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firstore_service.dart';
import '../../../core/services/storage_service.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  // Use separate FormKeys if validation is needed per step,
  // or keep one if final validation is sufficient.
  // For simplicity, using one key for the final step.
  final _step3FormKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Services and state
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService =
      StorageService(); // Keep StorageService
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSaving = false;

  // Text Controllers
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  // final _showreelController = TextEditingController(); // REMOVED

  // Lists for tags
  final List<String> _skills = [];
  final List<String> _keyRoles = [];
  final List<String> _genres = [];
  final List<String> _equipment = [];
  final List<String> _languages = [];

  // Variable for holding selected image
  File? _selectedImage;

  // --- ADDED: State variable for the final showreel URL ---
  String? _finalShowreelUrl;
  // --- END ADDITION ---

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _finishSetup() async {
    // Validate Step 3 form specifically before saving
    if (!_step3FormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct errors in Step 3.')),
      );
      return;
    }
    // You might add validation checks for other steps here if needed

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You are not logged in.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? profilePictureUrl;

    try {
      // Wrap the whole saving process in try/catch
      // Upload profile picture if selected
      if (_selectedImage != null) {
        profilePictureUrl = await _storageService.uploadProfilePicture(
          user.uid,
          _selectedImage!,
        );
      }

      // --- Use the state variable for showreel URL ---
      final profileData = {
        'headline': _headlineController.text.trim(),
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'showreelUrl':
            _finalShowreelUrl, // Use the URL from Step3Portfolio state
        'keyRoles': _keyRoles, // Added keyRoles
        'skills': _skills,
        'genres': _genres,
        'equipment': _equipment,
        'languages': _languages,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        'isProfileComplete': true,
      };
      // --- END CHANGE ---

      await _firestoreService.updateUserProfile(user.uid, profileData);

      print('Profile Updated Successfully');
      // AuthWrapper should handle navigation to HomePage now
      // No explicit navigation needed here if AuthWrapper listens to isProfileComplete
    } catch (e) {
      print('Error saving profile: $e'); // Log detailed error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving profile. Please try again. Details: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _nextPage() {
    // Optional: Add validation for current step before proceeding
    /*
    bool stepIsValid = true;
    if (_currentPage == 0) {
       // Validate Step 1 if needed
    } else if (_currentPage == 1) {
       // Validate Step 2 if needed
    }
    if (!stepIsValid) return;
    */

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // On the last page, call the finish setup method
      _finishSetup();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    // _showreelController.dispose(); // REMOVED
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        title: Text('Create Your Profile (Step ${_currentPage + 1} of 3)'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white, // Ensure title is white
        elevation: 0,
        automaticallyImplyLeading: false, // No back button needed
      ),
      body: Stack(
        // Keep Stack for loading indicator
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Prevent swiping
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              // --- Step 1 ---
              Step1Essentials(
                // Pass controllers and callbacks
                headlineController: _headlineController,
                locationController: _locationController,
                selectedImage: _selectedImage,
                onPickImage: _pickImage,
                // Add form key if Step 1 needs validation
                // formKey: _step1FormKey,
              ),
              // --- Step 2 ---
              Step2CreativeIdentity(
                // Pass controllers and callbacks
                bioController: _bioController,
                keyRoles: _keyRoles,
                skills: _skills,
                genres: _genres,
                onRoleAdded: (role) => setState(() => _keyRoles.add(role)),
                onRoleRemoved: (role) => setState(() => _keyRoles.remove(role)),
                onSkillAdded: (skill) => setState(() => _skills.add(skill)),
                onSkillRemoved: (skill) =>
                    setState(() => _skills.remove(skill)),
                onGenreAdded: (genre) => setState(() => _genres.add(genre)),
                onGenreRemoved: (genre) =>
                    setState(() => _genres.remove(genre)),
                // Add form key if Step 2 needs validation
                // formKey: _step2FormKey,
              ),
              // --- Step 3 ---
              Step3Portfolio(
                formKey:
                    _step3FormKey, // Pass the form key for final validation
                equipment: _equipment,
                languages: _languages,
                onEquipmentAdded: (item) =>
                    setState(() => _equipment.add(item)),
                onEquipmentRemoved: (item) =>
                    setState(() => _equipment.remove(item)),
                onLanguageAdded: (lang) => setState(() => _languages.add(lang)),
                onLanguageRemoved: (lang) =>
                    setState(() => _languages.remove(lang)),

                // --- PASS INITIAL URL AND CALLBACK ---
                initialShowreelUrl:
                    _finalShowreelUrl, // Pass the state variable
                onShowreelUrlChanged: (url) {
                  setState(() {
                    _finalShowreelUrl = url; // Update state when Step3 notifies
                  });
                },
                // --- END CHANGES ---
              ),
            ],
          ),
          // Loading Overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      // --- Bottom Navigation Button ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _nextPage, // Disable while saving
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA32626),
            foregroundColor: Colors.white,
            minimumSize: const Size(
              double.infinity,
              50,
            ), // Make button fill width
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(_currentPage < 2 ? 'Next' : 'Finish Setup'),
        ),
      ),
    );
  }
}
