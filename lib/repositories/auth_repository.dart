import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up new user
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'role': 'user', // Default role
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save login data locally
      await _saveUserData(userCredential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Sign Up Error: ${e.message}");
      }
      return null;
    }
  }

  // Sign in existing user
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login data locally
      await _saveUserData(userCredential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("Sign In Error: ${e.message}");
      }
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear stored user data
  }

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Save user data & token locally
  Future<void> _saveUserData(UserCredential userCredential) async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = await userCredential.user!.getIdToken();

    await prefs.setString('uid', userCredential.user!.uid);
    await prefs.setString('email', userCredential.user!.email ?? "");
    await prefs.setString('idToken', idToken!);
  }

  // Refresh token before expiration
  Future<void> refreshToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      String? newToken = await user.getIdToken(true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('idToken', newToken!);
      if (kDebugMode) {
        print("Token refreshed!");
      }
    }
  }

  // Load stored user data
  Future<Map<String, String>?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userId')) return null;

    return {
      'userId': prefs.getString('userId') ?? "",
      'email': prefs.getString('email') ?? "",
      'idToken': prefs.getString('idToken') ?? "",
    };
  }
}
