import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
// We don't need cloud_firestore in this file anymore

class PresenceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://auteurly-5d03b-default-rtdb.europe-west1.firebasedatabase.app",
  );

  void connect() {
    final user = _auth.currentUser;
    if (user == null) return;

    final myStatusRef = _rtdb.ref('status/${user.uid}');

    // 1. Set the onDisconnect handler in RTDB
    // This will run when the app is closed or crashes
    myStatusRef.onDisconnect().set({
      'status': 'offline',
      'timestamp': ServerValue.timestamp, // Use server-side timestamp
    });

    // 2. When connected, set the status to online
    // We add a timestamp here for data consistency
    myStatusRef.set({'status': 'online', 'timestamp': ServerValue.timestamp});

    // 3. REMOVED: Do NOT write to Firestore from the client.
    // The Cloud Function 'onUserStatusChanged' will handle this.
  }

  void disconnect() {
    final user = _auth.currentUser;
    if (user == null) return;

    // When the user manually signs out, set their status to offline
    final myStatusRef = _rtdb.ref('status/${user.uid}');
    myStatusRef.set({'status': 'offline', 'timestamp': ServerValue.timestamp});
  }
}
