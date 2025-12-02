import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auteurly/core/services/auth_service.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/features/profile/create_profile/create_profile.dart';
import 'package:auteurly/features/auth/login_page.dart';
import 'package:auteurly/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, authSnapshot) {
        // Show a loading spinner while checking auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If a user is logged in, check their profile status
        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;

          return StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getUserProfileStream(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Robust check for profile completion
              if (profileSnapshot.hasData && profileSnapshot.data!.exists) {
                final data =
                    profileSnapshot.data!.data() as Map<String, dynamic>;

                if (data.containsKey('isProfileComplete') &&
                    data['isProfileComplete'] == true) {
                  return const HomePage();
                } else {
                  return const CreateProfilePage();
                }
              } else {
                // If profile document doesn't exist yet
                return const CreateProfilePage();
              }
            },
          );
        } else {
          // If user is not logged in
          return LoginPage();
        }
      },
    );
  }
}
