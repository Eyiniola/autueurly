import 'package:auteurly/features/notifications/conversation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/widgets/user_profile_content.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;
  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      // Use a FutureBuilder to fetch and display the user's data
      body: StreamBuilder<UserModel?>(
        stream: _firestoreService
            .getUserProfileStream(widget.userId)
            .map(
              (snapshot) =>
                  snapshot.exists ? UserModel.fromFirestore(snapshot) : null,
            ),
        builder: (context, snapshot) {
          // Show a loading spinner while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show an error message if something went wrong
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Error: Could not load profile.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // If data is available, build the profile content
          final user = snapshot.data!;

          return UserProfileContent(
            user: user,
            tabController: _tabController,
            actionButton: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_currentUserId != null) {
                    // 1. Get or create the chat room
                    final chatId = await _firestoreService.getOrCreateChat(
                      _currentUserId,
                      user.uid,
                      user.fullName,
                    );

                    // 2. Navigate to the conversation screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ConversationScreen(chatId: chatId, otherUser: user),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA32626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('MESSAGE'),
              ),
            ),
          );
        },
      ),
    );
  }
}
