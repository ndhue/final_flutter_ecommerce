import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  // Update user's address in Firestore
  Future<bool> updateAddress({
    required String city,
    required String district,
    required String ward,
    required String shippingAddress,
  }) async {
    if (_user == null) return false;

    try {
      await _firestore.collection('users').doc(_user!.id).update({
        'city': city,
        'district': district,
        'ward': ward,
        'shippingAddress': shippingAddress,
      });

      // Update the local user model
      _user = _user!.copyWith(
        city: city,
        district: district,
        ward: ward,
        shippingAddress: shippingAddress,
      );
      notifyListeners();

      // Show success toast
      Fluttertoast.showToast(msg: "Address updated successfully");
      return true;
    } catch (e) {
      // Show failure toast
      Fluttertoast.showToast(msg: "Failed to update address");
      return false;
    }
  }

  // Update user's full name in Firestore
  Future<bool> updateFullName(String fullName) async {
    if (_user == null) return false;

    try {
      await _firestore.collection('users').doc(_user!.id).update({
        'fullName': fullName,
      });

      // Update the local user model
      _user = _user!.copyWith(fullName: fullName);
      notifyListeners();

      // Show success toast
      Fluttertoast.showToast(msg: "Name updated successfully");
      return true;
    } catch (e) {
      // Show failure toast
      Fluttertoast.showToast(msg: "Failed to update name");
      return false;
    }
  }

  // Update user's loyalty points and loyaltyPointsUsed in Firestore
  Future<void> updateLoyaltyPoints({
    int pointsChange = 0,
    int pointsUsed = 0,
  }) async {
    if (_user == null) return;

    try {
      final newLoyaltyPoints =
          (_user!.loyaltyPoints + pointsChange)
              .clamp(0, double.infinity)
              .toInt();
      final newLoyaltyPointsUsed =
          (_user!.loyaltyPointsUsed + pointsUsed)
              .clamp(0, double.infinity)
              .toInt();

      await _firestore.collection('users').doc(_user!.id).update({
        'loyaltyPoints': newLoyaltyPoints,
        'loyaltyPointsUsed': newLoyaltyPointsUsed,
      });

      // Update the local user model
      _user = _user!.copyWith(
        loyaltyPoints: newLoyaltyPoints,
        loyaltyPointsUsed: newLoyaltyPointsUsed,
      );
      notifyListeners();

      debugPrint("Loyalty points updated successfully");
    } catch (e) {
      debugPrint("Failed to update loyalty points");
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
