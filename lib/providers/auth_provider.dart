import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import 'order_provider.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();

  User? _user;
  bool _isLoading = false;
  Timer? _tokenRefreshTimer; // Timer to refresh token

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeUser(); // Load stored user data on startup
  }

  // Load user data & set token refresh timer
  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();

    final userData = await _authRepository.loadUserData();
    if (userData != null) {
      _user = FirebaseAuth.instance.currentUser;
      _startTokenRefreshTimer();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Sign up
  Future<String> signUp(
    String email,
    String password,
    String fullName,
    String shippingAddress,
    String ward,
    String district,
    String city,
  ) async {
    _isLoading = true;
    notifyListeners();

    UserCredential? userCredential;
    try {
      userCredential = await _authRepository.signUp(email, password);

      if (userCredential != null) {
        _user = userCredential.user;
        _startTokenRefreshTimer();

        try {
          UserModel newUser = UserModel(
            id: _user!.uid,
            email: email,
            fullName: fullName,
            shippingAddress: shippingAddress,
            ward: ward,
            district: district,
            city: city,
            createdAt: Timestamp.now(),
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .set(newUser.toMap());

          await _authRepository.saveUserData(userCredential);

          _isLoading = false;
          notifyListeners();
          return _user!.uid;
        } catch (firestoreError) {
          _isLoading = false;
          notifyListeners();
          return '';
        }
      }
    } catch (authError) {
      if (_user != null) {
        try {
          await _user!.delete();
        } catch (e) {
          debugPrint("Error deleting partially created user: $e");
        }
      }
    }

    _isLoading = false;
    notifyListeners();
    return '';
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    UserCredential? userCredential = await _authRepository.signIn(
      email,
      password,
    );

    if (userCredential != null) {
      _user = userCredential.user;
      _startTokenRefreshTimer();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    await _authRepository.signOut();
    _user = null;
    _tokenRefreshTimer?.cancel(); // Stop token refresh
    notifyListeners();
  }

  // Start a timer to refresh the token before it expires
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel(); // Cancel any existing timer

    const refreshInterval = Duration(
      minutes: 50,
    ); // Refresh token every 50 minutes
    _tokenRefreshTimer = Timer.periodic(refreshInterval, (_) async {
      await _authRepository.refreshToken();
    });
  }

  // Change Password
  Future<String> changePassword(String oldPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return "User not found";
      }

      String email = user.email!;

      // Re-authenticate User
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
      return "success"; // Return success message
    } on FirebaseAuthException catch (e) {
      if (e.message == "INVALID_LOGIN_CREDENTIALS") {
        return "Incorrect old password. Please try again.";
      } else if (e.message == "CREDENTIAL_TOO_OLD_LOGIN_AGAIN") {
        return "Session expired. Please log in again.";
      }
      return "Failed to change password. Please try again.";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // Create user account during checkout
  Future<bool> createGuestAccount(
    String email,
    String password,
    String fullName,
    String shippingAddress,
    String ward,
    String district,
    String city,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await signUp(
        email,
        password,
        fullName,
        shippingAddress,
        ward,
        district,
        city,
      );

      debugPrint("Account creation result: $result");

      if (result.isNotEmpty) {
        // Associate orders if account was created successfully
        try {
          final orderProvider = OrderProvider();
          if (_user != null) {
            await orderProvider.associateGuestOrdersWithUser(email, _user!.uid);
          }
        } catch (e) {
          debugPrint("Error associating guest orders: $e");
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "Firebase Auth Exception during account creation: ${e.code} - ${e.message}",
      );

      _isLoading = false;
      notifyListeners();

      // Handle the case where the email already exists
      if (e.code == 'email-already-in-use') {
        return false;
      }
      return false;
    } catch (e) {
      debugPrint("Error during guest account creation: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if sign-in attempt is successful - replaces isEmailRegistered
  Future<bool> trySignInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user != null;
    } on FirebaseAuthException {
      return false;
    }
  }
}
