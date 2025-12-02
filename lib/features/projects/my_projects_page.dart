import 'package:auteurly/features/projects/project_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/models/project_model.dart';

class MyProjectsPage extends StatefulWidget {
  const MyProjectsPage({super.key});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        title: const Text('My Created Projects'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _currentUserId == null
          ? const Center(
              child: Text(
                "Not logged in",
                style: TextStyle(color: Colors.white),
              ),
            )
          : StreamBuilder<List<ProjectModel>>(
              stream: _firestoreService.getProjectsCreatedByUser(
                _currentUserId, // <-- Use the '!' operator for null safety
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // Good practice to handle errors
                  return const Center(
                    child: Text(
                      'Something went wrong.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "You haven't created any projects yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final projects = snapshot.data!;

                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ListTile(
                      // Provide a placeholder to prevent layout shifts
                      leading: SizedBox(
                        width: 50, // Give a fixed width
                        child: project.posterUrl != null
                            ? Image.network(
                                project.posterUrl!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.movie, color: Colors.grey),
                      ),
                      title: Text(
                        project.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${project.projectType} - ${project.year}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProjectDetailsPage(projectId: project.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
