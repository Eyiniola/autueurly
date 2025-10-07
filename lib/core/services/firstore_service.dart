import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/credit_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
// Create a new user profile in Firestore
  Future<void> createUserProfile(String userId, String email, String fullName) async {
    final userData = {
      'uid': userId,
      'email': email,
      'fullName':fullName,
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
    return _db.collection('credits').where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CreditModel.fromFirestore(doc)).toList();
    });
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(userId).update(data);
  }
}