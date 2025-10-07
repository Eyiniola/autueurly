import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './firstore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    // REMOVED try...catch to let errors bubble up to the UI
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null; // User canceled the sign-in
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential = await _firebaseAuth
        .signInWithCredential(credential);

    if (userCredential.additionalUserInfo?.isNewUser == true &&
        userCredential.user != null) {
      await _firestoreService.createUserProfile(
        userCredential.user!.uid,
        userCredential.user!.email!,
        userCredential.user!.displayName!,
      );
    }
    return userCredential.user;
  }

  // Sign up with Email & Password
  Future<User?> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // REMOVED try...catch to let errors bubble up to the UI
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await _firestoreService.createUserProfile(
        credential.user!.uid,
        email,
        fullName,
      );
    }
    return credential.user;
  }

  // Sign in with Email
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // REMOVED try...catch to let errors bubble up to the UI
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
