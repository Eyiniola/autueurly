import 'package:auteurly/features/projects/edit_project_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auteurly/core/models/project_model.dart';
import 'package:auteurly/core/models/credit_model.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/features/profile/public_profile_page.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _isSendingRequest = false;
  String? _currentUserFullName;
  String? _currentUserProfilePic;
  bool _isAlreadyCredited = false;
  bool _isCreator = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData(); // Fetch user data needed for the request
  }

  // Fetch current user's name (and optional pic)
  Future<void> _fetchCurrentUserData() async {
    if (_currentUserId != null) {
      final userModel = await _firestoreService.getUserProfile(_currentUserId!);
      if (mounted && userModel != null) {
        setState(() {
          _currentUserFullName = userModel.fullName;
          _currentUserProfilePic = userModel.profilePictureUrl;
        });
      }
    }
  }

  // --- ADDED: Show Role Input Dialog ---
  Future<void> _showRoleInputDialog(ProjectModel project) async {
    final roleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String? selectedRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C), // Dark background
          title: const Text(
            'Request to Join Project',
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: roleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter desired role (e.g., Editor)',
                hintStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a role';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog, return null
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA32626), // Button color
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Request'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(
                    roleController.text.trim(),
                  ); // Close dialog, return role
                }
              },
            ),
          ],
        );
      },
    );

    // If a role was entered, send the request
    if (selectedRole != null && selectedRole.isNotEmpty) {
      _sendJoinRequest(project, selectedRole);
    }
  }

  // --- ADDED: Send Join Request Logic ---
  Future<void> _sendJoinRequest(
    ProjectModel project,
    String requestedRole,
  ) async {
    if (_currentUserId == null || _currentUserFullName == null) {
      _showErrorSnackBar("Could not get your user details. Please try again.");
      return;
    }
    if (_isSendingRequest) return; // Prevent double taps

    setState(() => _isSendingRequest = true);

    try {
      await _firestoreService.createJoinRequest(
        projectId: project.id,
        projectTitle: project.title,
        projectCreatorId: project.createdBy,
        requestingUserId: _currentUserId!,
        requestingUserName: _currentUserFullName!,
        requestingUserProfilePic: _currentUserProfilePic, // Pass optional pic
        requestedRole: requestedRole,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Join request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally disable button after successful request? Or change text?
      }
    } catch (e) {
      print("Error sending join request: $e");
      _showErrorSnackBar("Failed to send join request. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isSendingRequest = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: FutureBuilder<ProjectModel?>(
        future: _firestoreService.getProject(widget.projectId),
        builder: (context, projectSnapshot) {
          if (projectSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!projectSnapshot.hasData || projectSnapshot.data == null) {
            return const Center(
              child: Text(
                'Project not found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final project = projectSnapshot.data!;

          print("Current User ID: $_currentUserId");
          print("Project Creator ID: ${project.createdBy}");
          print("Is Current User the Creator? $_isCreator");

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                floating: false,
                backgroundColor: const Color(0xFF1B1B1B),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    project.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (project.posterUrl != null)
                        Image.network(
                          project.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF2C2C2C)),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // Conditionally show the Edit button
                  if (project.createdBy == _currentUserId)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProjectPage(projectId: project.id),
                          ),
                        ).then((_) {
                          // This re-fetches the data when you return from the edit page
                          setState(() {});
                        });
                      },
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${project.projectType} - ${project.year}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4), // Add space
                      // Display Status with a Chip-like look
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(
                            0.7,
                          ), // Semi-transparent dark chip
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'SYNOPSIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.description.isNotEmpty
                            ? project.description
                            : 'No description available.',
                        style: const TextStyle(color: Colors.grey, height: 1.5),
                      ),
                      const Divider(color: Color(0xFF2C2C2C), height: 40),
                      const Text(
                        'CAST & CREW',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder<List<CreditModel>>(
                stream: _firestoreService.getCreditsForProject(
                  widget.projectId,
                ),
                builder: (context, creditSnapshot) {
                  if (creditSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final credits = creditSnapshot.data ?? [];
                  // Determine eligibility flags INSIDE the builder where credits are known
                  _isAlreadyCredited = credits.any(
                    (credit) => credit.userId == _currentUserId,
                  );
                  // Ensure _isCreator is set based on the project data from the FutureBuilder scope
                  // (It should already be set correctly outside/before this StreamBuilder)
                  bool shouldShowButton =
                      _currentUserId != null &&
                      !_isCreator &&
                      !_isAlreadyCredited;

                  // --- BUILD THE BUTTON WIDGET ---
                  Widget requestButtonWidget =
                      const SizedBox.shrink(); // Use SizedBox.shrink() for no space
                  if (shouldShowButton) {
                    requestButtonWidget = Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        8.0,
                        16.0,
                        16.0,
                      ), // Add padding around button
                      child: ElevatedButton.icon(
                        icon: _isSendingRequest
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add, size: 18),
                        label: Text(
                          _isSendingRequest
                              ? 'Sending Request...'
                              : 'Request to Join',
                        ),
                        onPressed:
                            _isSendingRequest || _currentUserFullName == null
                            ? null
                            : () => _showRoleInputDialog(
                                project,
                              ), // 'project' is available from FutureBuilder scope
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                    );
                  }
                  // --- END BUILDING BUTTON ---

                  // --- BUILD THE CREDITS LIST/MESSAGE WIDGET ---
                  Widget creditsContentWidget;
                  if (credits.isEmpty) {
                    creditsContentWidget = const SliverToBoxAdapter(
                      // Use SliverToBoxAdapter for single items
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          'No crew listed yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  } else {
                    creditsContentWidget = SliverList(
                      // Use SliverList for multiple items
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final credit = credits[index];
                        return ListTile(
                          title: Text(
                            credit.userFullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            credit.role,
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
                                    PublicProfilePage(userId: credit.userId),
                              ),
                            );
                          },
                        );
                      }, childCount: credits.length),
                    );
                  }
                  // --- END BUILDING CREDITS CONTENT ---

                  // --- RETURN SLIVERS ---
                  // Use SliverMainAxisGroup to group slivers generated within the builder
                  return SliverMainAxisGroup(
                    slivers: [
                      // Always include the button's sliver (it's SizedBox.shrink if not shown)
                      SliverToBoxAdapter(child: requestButtonWidget),
                      // Include the credits content sliver
                      creditsContentWidget,
                    ],
                  );
                  // --- END RETURN ---
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
