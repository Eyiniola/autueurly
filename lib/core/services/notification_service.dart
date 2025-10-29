import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // 1. Request permission from the user (for iOS & web)
    await _fcm.requestPermission();

    // 2. Get the unique FCM token for this device
    final token = await _fcm.getToken();
    print("======== FCM TOKEN: $token ========");

    // 3. Save the token to the user's Firestore document
    if (token != null && _auth.currentUser != null) {
      await _db.collection('users').doc(_auth.currentUser!.uid).update({
        'fcmToken': token,
      });
    }
  }
}
