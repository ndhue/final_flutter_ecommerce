import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Check if the user is logged in
  bool get isLoggedIn => _user != null;

  // Check if the user is an admin
  bool get isAdmin => _user?.role == 'admin';

  // Fetch user details from Firestore
  Future<void> fetchUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        _user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        _user = null;
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user data on app start
  Future<void> loadUserOnAppStart() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await fetchUser(firebaseUser.uid);
    }
  }

  // Get user role
  String? getUserRole() {
    return _user?.role;
  }

  // Clear user data
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
