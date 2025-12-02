import 'package:auteurly/core/models/chat_model.dart';
import 'package:auteurly/core/models/message_model.dart';
import 'package:auteurly/core/models/project_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/credit_model.dart';

class NewCredit {
  final String userId;
  final String userFullName;
  final String role;
  NewCredit({
    required this.userId,
    required this.userFullName,
    required this.role,
  });
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Create a new user profile in Firestore
  Future<void> createUserProfile(
    String userId,
    String email,
    String fullName,
  ) async {
    final userData = {
      'uid': userId,
      'email': email,
      'fullName': fullName,
      'isProfileComplete': false,
      'headline': '',
      'availabilityStatus': 'Available',
      'bio': '',
      'profilePictureUrl': null,
      'showreelUrl': null,
      'keyRoles': [],
      'skills': [],
      'genres': [],
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(userId).set(userData);
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<List<CreditModel>> getUserCredits(String userId) {
    return _db
        .collection('credits')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CreditModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get a live stream of all user profiles, excluding the current user

  Stream<List<UserModel>> getOtherUserProfilesStream(String currentUserId) {
    return _db
        .collection('users')
        // Sort by status FIRST (puts "online" before "offline")
        .orderBy('status', descending: true)
        // THEN sort by name
        .orderBy('fullName', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              // We still filter out the current user in the app,
              // but we fetch all others.
              .where((doc) => doc.id != currentUserId)
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  // In FirestoreService
  Stream<DocumentSnapshot> getUserProfileStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  Future<String?> getUserFullName(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      // Assuming 'fullName' is the correct field name in your UserModel/Firestore
      return doc.data()?['fullName'] as String?;
    }
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(userId).update(data);
  }

  // Add a new project
  Future<void> addProjectWithCredit({
    required String projectId,
    required String title,
    required String creatorFullName,
    required String description,
    required String projectType,
    required int year,
    String? posterUrl,
    required String createdBy,
    required List<NewCredit> credits,
  }) async {
    final newProjectRef = _db.collection('projects').doc(projectId);

    final newProjectData = {
      'title': title,
      'projectType': projectType,
      'year': year,
      'description': description,
      'posterUrl': posterUrl,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'Development',
    };
    WriteBatch batch = _db.batch();

    batch.set(newProjectRef, newProjectData);

    for (var credit in credits) {
      final bool isCreator = (credit.userId == createdBy);

      final newCreditRef = _db.collection('credits').doc();
      final newCreditData = {
        'userId': credit.userId,
        'projectId': projectId,
        'userFullName': credit.userFullName,
        'creatorName': creatorFullName,
        'projectTitle': title,
        'role': credit.role,
        'isVerified': isCreator ? true : false,
        'year': year,
        'createdAt': FieldValue.serverTimestamp(),
      };

      batch.set(newCreditRef, newCreditData);
    }

    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> getCreditsWithProjectDetails(
    String userId,
  ) {
    return _db
        .collection('credits')
        .where('userId', isEqualTo: userId)
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final creditsData = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            final credit = CreditModel.fromFirestore(doc);

            final projectDoc = await _db
                .collection('projects')
                .doc(credit.projectId)
                .get();

            if (projectDoc.exists) {
              print("SERVICE (READ): SUCCESS! Found a matching project.");
              final project = ProjectModel.fromFirestore(projectDoc);
              creditsData.add({'credit': credit, 'project': project});
            } else {
              print("SERVICE (READ): FAILED! No project found with that ID.");
            }
          }
          return creditsData;
        });
  }

  Future<void> updateProjectAndOverwriteCredits({
    required String projectId,
    required Map<String, dynamic> projectData, // The updated project details
    required List<NewCredit> credits, // The new, complete list of credits
  }) async {
    final projectRef = _db.collection('projects').doc(projectId);

    WriteBatch batch = _db.batch();

    // 1. Update the main project document
    projectData['updatedAt'] = FieldValue.serverTimestamp();
    batch.update(projectRef, projectData);

    // 2. Find and delete all existing credits for this project
    final oldCreditsQuery = await _db
        .collection('credits')
        .where('projectId', isEqualTo: projectId)
        .get();
    for (var doc in oldCreditsQuery.docs) {
      batch.delete(doc.reference);
    }

    // 3. Create new documents for the updated list of credits
    for (var credit in credits) {
      final newCreditRef = _db.collection('credits').doc();
      final newCreditData = {
        'userId': credit.userId,
        'projectId': projectId,
        'userFullName': credit.userFullName,
        'projectTitle': projectData['title'], // Use the updated title
        'role': credit.role,
        'isVerified': false,
        'year': projectData['year'], // Use the updated year
        'createdAt': FieldValue.serverTimestamp(),
      };
      batch.set(newCreditRef, newCreditData);
    }

    await batch.commit();
  }

  // Get projects created by the current user
  Stream<List<ProjectModel>> getProjectsCreatedByUser(String userId) {
    return _db
        .collection('projects')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProjectModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get a single project by its ID
  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _db.collection('projects').doc(projectId).get();
    if (doc.exists) {
      return ProjectModel.fromFirestore(doc);
    }
    return null;
  }

  // get a stream of Projects
  Stream<List<ProjectModel>> getProjectsStream() {
    return _db
        .collection('projects')
        // Order by the 'createdAt' field, newest first
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProjectModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get a live stream of all credits for a specific project
  Stream<List<CreditModel>> getCreditsForProject(String projectId) {
    return _db
        .collection('credits')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CreditModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('projects').doc(projectId).update(data);
  }

  // Get a Live stream of user's chats

  Stream<List<ChatModel>> getChatsStream(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromFirestore(doc, userId))
              .toList(),
        );
  }

  // Get a live stream of messages within a specific chat

  Stream<List<MessageModel>> getMessageStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Send a new message and update the parent chat document
  Future<void> sendMessage(String chatId, String text, String senderId) async {
    final messageData = {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Reference to the new message in the sub-collection
    final newMessageRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    // Reference to the parent chat document
    final chatRef = _db.collection('chats').doc(chatId);

    WriteBatch batch = _db.batch();
    // Create the new message
    batch.set(newMessageRef, messageData);
    // Update the last message preview on the parent chat
    batch.update(chatRef, {
      'lastMessageText': text,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessageSeenBy': [senderId],
    });

    await batch.commit();
  }

  // Method to find an existing chat or create a new one for two users
  Future<String> getOrCreateChat(
    String currentUserId,
    String otherUserId,
    String otherUserName,
  ) async {
    // Create a consistent, sorted ID for the chat room to prevent duplicates
    List<String> participants = [currentUserId, otherUserId]..sort();
    String chatId = participants.join('_'); // e.g., "uid1_uid2"

    final chatRef = _db.collection('chats').doc(chatId);
    final doc = await chatRef.get();

    // If the chat doesn't exist, create it
    if (!doc.exists) {
      await chatRef.set({
        'participants': participants,
        'lastMessageText': 'Chat started.',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        // Store names for easy access in notifications, etc.
        'participantNames': {
          currentUserId: FirebaseAuth.instance.currentUser?.displayName ?? 'Me',
          otherUserId: otherUserName,
        },
        'lastMessageSeenBy': [currentUserId],
      });
    }

    return chatId;
  }

  // 3. Call this when a user opens a chat screen
  Future<void> markChatAsRead(String chatId, String userId) {
    return _db.collection('chats').doc(chatId).update({
      'lastMessageSeenBy': FieldValue.arrayUnion([userId]),
    });
  }

  // 4. Call this when a user opens the "Others" tab
  Future<void> markNotificationsAsRead(String userId) async {
    final query = _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false);

    final snapshot = await query.get();
    WriteBatch batch = _db.batch();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // 5. Get a live stream of unread chat counts
  Stream<int> getUnreadChatsCountStream(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots() // 1. Get ALL chats the user is in
        .map((snapshot) {
          // 2. Manually filter the list in Dart (just like ChatModel does)
          final unreadDocs = snapshot.docs.where((doc) {
            final data = doc.data();

            // Check if 'lastMessageSeenBy' field exists and is a List
            if (data['lastMessageSeenBy'] is List) {
              final List<dynamic> seenByList = data['lastMessageSeenBy'];

              // If the user's ID is NOT in the list, it's unread
              return !seenByList.contains(userId);
            }

            // Fallback: If field is missing or malformed, consider it read
            return false;
          }).toList();

          // 3. Return the count of *only* the unread documents
          return unreadDocs.length;
        });
  }

  // 6. Get a live stream of unread notification counts
  Stream<int> getUnreadNotificationsCountStream(String userId) {
    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false) // Only count unread
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // In firestore_service.dart
  Stream<QuerySnapshot> getNotificationsStream(String recipientId) {
    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // In firestore_service.dart
  Future<void> deleteNotification(String notificationId) {
    return _db.collection('notifications').doc(notificationId).delete();
  }

  Future<void> verifyCredit(String creditId) {
    return _db.collection('credits').doc(creditId).update({'isVerified': true});
  }

  Future<void> saveDeviceToken(String token, String userId) async {
    if (userId.isEmpty) return;

    final userRef = _db.collection('users').doc(userId);

    // Save the token in a list. A user might have multiple devices.
    // We use FieldValue.arrayUnion to add it only if it's not already there.
    try {
      await userRef.update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
      print("Device token saved to Firestore.");
    } catch (e) {
      print("Error saving device token: $e");
    }
  }

  Future<void> createJoinRequest({
    required String projectId,
    required String projectTitle,
    required String projectCreatorId,
    required String requestingUserId,
    required String requestingUserName,
    String? requestingUserProfilePic, // Optional
    required String requestedRole,
  }) async {
    // Optional: Check if a pending request already exists for this user/project
    // Query joinRequests where projectId == projectId and requestingUserId == requestingUserId and status == 'pending'
    // If exists, maybe show a message "Request already sent".

    await _db.collection('joinRequests').add({
      'projectId': projectId,
      'projectTitle': projectTitle,
      'projectCreatorId': projectCreatorId,
      'requestingUserId': requestingUserId,
      'requestingUserName': requestingUserName,
      'requestingUserProfilePic': requestingUserProfilePic, // Pass if available
      'requestedRole': requestedRole,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approveJoinRequest(String joinRequestId) async {
    final joinRequestRef = _db.collection('joinRequests').doc(joinRequestId);
    final joinRequestDoc = await joinRequestRef.get();

    if (!joinRequestDoc.exists) {
      print("Error: Join request $joinRequestId not found.");
      throw Exception("Join request not found."); // Throw error to notify UI
    }

    final requestData = joinRequestDoc.data()!;

    // Check if already processed
    if (requestData['status'] != 'pending') {
      print(
        "Warning: Join request $joinRequestId is already ${requestData['status']}.",
      );
      // Decide if you want to proceed or just return
      // For safety, let's only proceed if pending
      return;
    }

    // Prepare data for the new credit document
    final newCreditData = {
      'userId': requestData['requestingUserId'],
      'projectId': requestData['projectId'],
      'userFullName': requestData['requestingUserName'],
      'projectTitle': requestData['projectTitle'],
      'role': requestData['requestedRole'],
      'isVerified': true, // Automatically verified when approved
      'createdAt': FieldValue.serverTimestamp(),
      // Add 'year' if available and needed for credits display
      // 'year': projectData['year'], // You might need to fetch project data if year is needed
    };

    final newCreditRef = _db.collection('credits').doc(); // Auto-generate ID

    // Use a batch write to ensure atomicity
    WriteBatch batch = _db.batch();

    // 1. Update the join request status
    batch.update(joinRequestRef, {'status': 'approved'});
    // 2. Create the new credit document
    batch.set(newCreditRef, newCreditData);

    await batch.commit();
    print("Join request approved and credit created.");
  }

  // --- ADDED: Deny Join Request ---
  Future<void> denyJoinRequest(String joinRequestId) async {
    final joinRequestRef = _db.collection('joinRequests').doc(joinRequestId);
    final joinRequestDoc = await joinRequestRef.get(); // Check existence/status

    if (!joinRequestDoc.exists) {
      print("Error: Join request $joinRequestId not found.");
      return; // Or throw
    }
    final requestData = joinRequestDoc.data()!;
    if (requestData['status'] != 'pending') {
      print(
        "Warning: Join request $joinRequestId is already ${requestData['status']}.",
      );
      return;
    }

    // Just update the status to denied
    await joinRequestRef.update({'status': 'denied'});
    print("Join request denied.");
  }
}
