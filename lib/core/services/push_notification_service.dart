import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:auteurly/core/services/firstore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> initialize() async {
    // 1. Request Permission from the user
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Get the device token
    String? token = await _fcm.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }

    // 3. Save the token to Firestore
    if (token != null && _currentUserId != null) {
      await _saveTokenToFirestore(token, _currentUserId);
    }

    // 4. Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      if (_currentUserId != null) {
        _saveTokenToFirestore(newToken, _currentUserId);
      }
    });

    // 5. Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        if (message.notification != null) {
          print(
            'Message also contained a notification: ${message.notification}',
          );
        }
      }
      // You could show a local notification/snackbar here
    });
  }

  Future<void> _saveTokenToFirestore(String token, String userId) async {
    // We'll add this 'saveDeviceToken' method to FirestoreService next
    await _firestoreService.saveDeviceToken(token, userId);
  }
}
