import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auteurly/core/models/user_model.dart';
import 'package:auteurly/core/models/project_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auteurly/core/services/algolia_service.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/features/components/professional_card.dart';
import 'package:auteurly/features/components/project_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// 1. Add SingleTickerProviderStateMixin for the TabController
class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final AlgoliaService _algoliaService = AlgoliaService();
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  late TabController _tabController;
  Timer? _debounce;

  // State
  bool _isLoadingRecents = true;
  bool _isLoading = false;
  bool _hasSearched = false;
  List<UserModel> _userResults = [];
  List<ProjectModel> _projectResults = [];
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the list from storage, or an empty list if it's the first time
    final searches = prefs.getStringList('recent_searches') ?? [];
    setState(() {
      _recentSearches.addAll(searches);
      _isLoadingRecents = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel any previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text;
      if (query.isEmpty) {
        _clearSearch();
      } else {
        _performSearch(query);
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _isLoading = false;
      _hasSearched = false;
      _userResults = [];
      _projectResults = [];
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recent_searches', _recentSearches);
    } catch (e) {
      print('Error saving recent searches: $e');
    }

    try {
      // Perform both searches in parallel
      final results = await Future.wait([
        _algoliaService.searchUsers(query),
        _algoliaService.searchProjects(query),
      ]);

      final userIds = results[0];
      final projectIds = results[1];

      // Fetch full user and project models
      final users = await Future.wait(
        userIds.map((id) => _firestoreService.getUserProfile(id)),
      );
      final projects = await Future.wait(
        projectIds.map((id) => _firestoreService.getProject(id)),
      );

      setState(() {
        _userResults = users.whereType<UserModel>().toList();
        _projectResults = projects.whereType<ProjectModel>().toList();
      });
    } catch (e) {
      print('Search error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 2. Add the TabBar to the AppBar
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFA32626),
          labelColor: Colors.white,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'PROFESSIONALS'),
            Tab(text: 'PROJECTS'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search professionals, projects...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                ? _buildRecentSearches() // Show recents if no search yet
                : _buildSearchResults(), // Show results after search
          ),
        ],
      ),
    );
  }

  // Widget to build the initial "Recent Searches" view
  Widget _buildRecentSearches() {
    if (_isLoadingRecents) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Searches',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final term = _recentSearches[index];
                return ListTile(
                  title: Text(
                    term,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: const Icon(
                    Icons.north_west,
                    color: Colors.grey,
                    size: 16,
                  ),
                  onTap: () {
                    // When a recent term is tapped, populate the search bar and run the search
                    _searchController.text = term;
                    _performSearch(term);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the search results view
  Widget _buildSearchResults() {
    return TabBarView(
      controller: _tabController,
      children: [_buildUserResults(), _buildProjectResults()],
    );
  }

  // Helper method to build the user results list
  Widget _buildUserResults() {
    if (_userResults.isEmpty) {
      return const Center(
        child: Text(
          'No professionals found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _userResults.length,
      itemBuilder: (context, index) =>
          ProfessionalCard(user: _userResults[index]),
    );
  }

  // Helper method to build the project results list
  Widget _buildProjectResults() {
    if (_projectResults.isEmpty) {
      return const Center(
        child: Text('No projects found.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _projectResults.length,
      itemBuilder: (context, index) =>
          ProjectCard(project: _projectResults[index]),
    );
  }
}
