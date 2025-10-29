import 'package:auteurly/features/profile/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/widgets/user_profile_content.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables to hold the user data and loading state
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData(); // Fetch data when the page first loads
  }

  // New method to fetch the user's data once and store it
  Future<void> _fetchUserData() async {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      final userModel = await _firestoreService.getUserProfile(currentUserId);
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _user = userModel;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleAvailability() async {
    if (_user == null) return;

    final newStatus = _user!.availabilityStatus == 'Available'
        ? 'Not Available'
        : 'Available';

    // Optimistic UI update: change the state immediately
    setState(() {
      _user = _user!.copyWith(availabilityStatus: newStatus);
    });

    // Update Firestore in the background
    try {
      await _firestoreService.updateUserProfile(_user!.uid, {
        'availabilityStatus': newStatus,
      });
    } catch (e) {
      // Revert the change on failure and show an error
      setState(() {
        _user = _user!.copyWith(
          availabilityStatus: _user!.availabilityStatus == 'Available'
              ? 'Not Available'
              : 'Available',
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error updating status')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      // Build the UI based on the state variables, not a FutureBuilder
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(
              child: Text(
                'Error: Could not load profile.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : UserProfileContent(
              user: _user!,
              tabController: _tabController,
              onAvailabilityTap: _toggleAvailability,
              actionButton: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Logic to navigate to an EditProfilePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ).then((_) {
                      // This part is important: it re-fetches the user data
                      // when you return from the edit page, so the changes appear.
                      _fetchUserData();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('EDIT PROFILE'),
                ),
              ),
            ),
    );
  }
}
