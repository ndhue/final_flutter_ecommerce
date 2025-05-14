import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/cloudinary_service.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  bool _isLoading = false;
  bool _isAvatarLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAvatarLoading => _isAvatarLoading;

  // Cache to store fetched users by ID
  final Map<String, UserModel> _userCache = {};

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

  // Get a user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      // Check if user is already in the cache
      if (_userCache.containsKey(userId)) {
        return _userCache[userId];
      }

      // Fetch from Firestore if not in cache
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
        );
        // Store in cache for future use
        _userCache[userId] = userData;
        return userData;
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching user by ID: $e');
      return null;
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
    } catch (e) {
      FlutterError("Failed to update loyalty points");
    }
  }

  Future<bool> updateAvatar(XFile imageFile) async {
    if (_user == null) return false;

    try {
      _isAvatarLoading = true;
      notifyListeners();

      final imageUrl = await CloudinaryService.uploadImage(imageFile);

      if (imageUrl == null) {
        Fluttertoast.showToast(msg: "Failed to upload image");
        _isAvatarLoading = false;
        notifyListeners();
        return false;
      }

      await _firestore.collection('users').doc(_user!.id).update({
        'avatar': imageUrl,
      });

      _user = _user!.copyWith(avatar: imageUrl);

      _isAvatarLoading = false;
      notifyListeners();

      // Show success toast
      Fluttertoast.showToast(
        msg: "Avatar updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return true;
    } catch (e) {
      _isAvatarLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: "Failed to update avatar");
      return false;
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

  // Clear the user cache and reset the provider state
  Future<void> clearUserCache() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear shared preferences related to user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');

      // Reset the user data in memory
      _user = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Attempt to refresh user data from Firestore
  Future<void> refreshUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get the current Firebase user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        _user = UserModel.fromMap(userDoc.data()!);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', userDoc.data().toString());
      } else {
        _user = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
