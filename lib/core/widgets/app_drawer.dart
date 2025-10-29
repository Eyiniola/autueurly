import 'package:auteurly/core/services/presence_service.dart';
import 'package:auteurly/features/profile/user_profile.dart';
import 'package:auteurly/features/projects/my_projects_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auteurly/core/services/auth_service.dart';
// import 'package:auteurly/features/profile/profile_page.dart';
// import 'package:auteurly/features/settings/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Drawer(
      backgroundColor: const Color(0xFF1B1B1B), // Dark background color
      child: Column(
        children: [
          // This Expanded widget pushes the Logout button to the bottom
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                top: 60.0,
                left: 20.0,
              ), // Add padding
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  text: 'MY PROFILE',
                  onTap: () {
                    Navigator.pop(context); // Close the drawer first
                    // Then navigate to the profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OwnerProfilePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildDrawerItem(
                  icon: Icons.movie_creation_outlined,
                  text: 'MY PROJECTS',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyProjectsPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  text: 'SETTINGS',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings page
                  },
                ),
              ],
            ),
          ),

          // This is the Logout button at the bottom
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 40.0),
            child: _buildDrawerItem(
              icon: Icons.logout,
              text: 'LOGOUT',
              color: const Color(0xFFA32626), // Use the red accent color
              onTap: () async {
                final presenceService = PresenceService();

                // 2. Call disconnect() to manually set status to offline
                presenceService.disconnect();

                // 3. Now, sign the user out
                FirebaseAuth.instance.signOut();
                await authService.signOut();
                // The AuthWrapper will automatically handle navigating to the LoginPage
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build each drawer item consistently
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
