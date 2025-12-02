import 'package:auteurly/core/models/project_model.dart';
import 'package:auteurly/core/services/presence_service.dart';
import 'package:auteurly/core/services/push_notification_service.dart';
import 'package:auteurly/core/widgets/notification_badge.dart';
import 'package:auteurly/features/notifications/inbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/features/components/professional_card.dart';
import 'package:auteurly/features/components/project_card.dart';
import 'package:auteurly/core/widgets/app_drawer.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final PushNotificationService _notificationService =
      PushNotificationService();
  final PresenceService _presenceService = PresenceService();

  @override
  void initState() {
    super.initState();

    // Initialize push notifications
    _notificationService.initialize();

    _presenceService.connect();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF1B1B1B),
        drawer: const AppDrawer(), // The drawer now lives here
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B1B1B),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Image.asset('lib/images/logo.png', height: 100, width: 100),
          centerTitle: false,
          actions: [
            IconButton(
              // --- THIS IS THE CHANGE ---
              icon: NotificationBadge(
                firestoreService: _firestoreService,
                currentUserId: _currentUserId,
                child: const Icon(
                  Icons.notifications_none_outlined,
                ), // Your original icon
              ),

              onPressed: () {
                // Navigate to InboxScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InboxScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFA32626),
            indicatorWeight: 3.0,
            labelColor: Colors.white,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Professionals'),
              Tab(text: 'Projects'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Professionals tab
            _currentUserId == null
                ? const Center(child: Text("Not logged in"))
                : StreamBuilder<List<UserModel>>(
                    stream: _firestoreService.getOtherUserProfilesStream(
                      _currentUserId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "No other professionals found.",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      final users = snapshot.data!;
                      return GridView.builder(
                        padding: const EdgeInsets.all(10.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  2, // <-- This creates the two-column layout
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio:
                                  0.75, // <-- Matches the 3/4 aspect ratio of the card
                            ),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ProfessionalCard(user: user);
                        },
                      );
                    },
                  ),

            // Projects tab
            StreamBuilder<List<ProjectModel>>(
              stream: _firestoreService.getProjectsStream(),
              builder: (context, snapshot) {
                // Show a loading spinner while fetching data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Show a message if no projects are found
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No projects have been added yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final projects = snapshot.data!;

                // Build the list using the fetched projects
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    // Pass the project data to your ProjectCard
                    return ProjectCard(project: project);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
