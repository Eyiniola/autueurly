import 'package:auteurly/features/profile/create_profile/create_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:auteurly/core/services/auth_service.dart';
import 'package:auteurly/core/services/firstore_service.dart'; // Corrected import
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
            // **CHANGE 2: Call the new stream method**
            stream: firestoreService.getUserProfileStream(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // **CHANGE 3: Check for the flag**
              // The logic here is the same, but it now runs on every data change
              if (profileSnapshot.hasData &&
                  (profileSnapshot.data!.data()
                          as Map<String, dynamic>)['isProfileComplete'] ==
                      true) {
                return HomePage();
              } else {
                return const CreateProfilePage();
              }
            },
          );
        } else {
          return LoginPage();
        }
      },
    );
  }
}
