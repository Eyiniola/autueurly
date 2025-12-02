import 'package:auteurly/core/widgets/chat_tile.dart';
import 'package:auteurly/core/widgets/inbox_tab.dart';
import 'package:auteurly/core/widgets/notification_tile.dart';
import 'package:auteurly/core/widgets/others_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auteurly/core/models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:auteurly/core/models/notification_model.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- FIX: Define the service and user ID here ---
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserId;
  // ---

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // --- FIX: Get the actual User ID string ---
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Add a listener to the TabController
    _tabController.addListener(_handleTabSelection);
  }

  // --- FIX: Add dispose method to prevent memory leaks ---
  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    // If the "Others" tab (index 1) is selected, mark notifications as read

    // --- FIX: This logic is now correct because _currentUserId is a String? ---
    if (_tabController.index == 1 && _currentUserId != null) {
      _firestoreService.markNotificationsAsRead(_currentUserId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- FIX: REMOVED DefaultTabController ---
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          // <-- FIX: Removed 'const'
          controller: _tabController, // <-- FIX: Assign your controller
          indicatorColor: const Color(0xFFA32626),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'INBOX'),
            Tab(text: 'OTHERS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // --- THIS IS THE KEY CHANGE ---
        // Pass the service and ID to the new widgets
        children: [
          InboxTab(
            currentUserId: _currentUserId,
            firestoreService: _firestoreService,
          ),
          OthersTab(
            currentUserId: _currentUserId,
            firestoreService: _firestoreService,
          ),
        ],
      ),
    );
  }
}
