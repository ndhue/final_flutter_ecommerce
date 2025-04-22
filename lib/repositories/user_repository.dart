import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Hash password before storing it
  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  // Verify password when logging in
  bool verifyPassword(String inputPassword, String hashedPassword) {
    return BCrypt.checkpw(inputPassword, hashedPassword);
  }

  // Get user details from Firestore
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return null;
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Save user info to SharedPreferences
  Future<void> saveUserLocally(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toMap()));
  }

  // Load user from local storage
  Future<UserModel?> loadUserLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData == null) return null;
    return UserModel.fromMap(jsonDecode(userData));
  }

  // Update user avatar in Firestore
  Future<bool> updateUserAvatar(String userId, String avatarUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'avatar': avatarUrl,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
