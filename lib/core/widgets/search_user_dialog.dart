import 'package:flutter/material.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/services/algolia_service.dart';
import 'package:auteurly/core/services/firstore_service.dart';

class SearchUserDialog extends StatefulWidget {
  const SearchUserDialog({super.key});

  @override
  State<SearchUserDialog> createState() => _SearchUserDialogState();
}

class _SearchUserDialogState extends State<SearchUserDialog> {
  final AlgoliaService _algoliaService = AlgoliaService();
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  bool _isLoading = false;
  List<UserModel> _results = [];

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    final userIds = await _algoliaService.searchUsers(query);
    final users = await Future.wait(
      userIds.map((id) => _firestoreService.getUserProfile(id)),
    );

    if (mounted) {
      setState(() {
        _results = users.whereType<UserModel>().toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: const Text(
        "Search for a Professional",
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter name...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => _performSearch(_searchController.text),
                ),
              ),
              onSubmitted: (value) => _performSearch(value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? const Center(
                      child: Text(
                        "No users found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final user = _results[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.profilePictureUrl != null
                                ? NetworkImage(user.profilePictureUrl!)
                                : null,
                            child: user.profilePictureUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            user.fullName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            // When a user is tapped, pop the dialog and return the selected user
                            Navigator.pop(context, user);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
