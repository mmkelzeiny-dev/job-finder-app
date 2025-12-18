import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart'; // <- make sure you import your AuthService

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = false;

  AuthProvider() {
    user = _auth.currentUser;
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // ===== Web =====
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // ===== Mobile (Android/iOS) =====
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          isLoading = false;
          notifyListeners();
          return; // User cancelled
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      user = userCredential.user;

      // ===== FIXED: always get token from Firebase user =====
      final idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        final success = await AuthService.signInWithGoogleCustomToken(idToken);
        if (!success) print("Backend JWT request failed");
      } else {
        print("Error: idToken is null, cannot send to backend");
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    await _auth.signOut();
    user = null;
    notifyListeners();
  }
}
