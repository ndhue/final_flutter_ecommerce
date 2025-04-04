import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';

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
  Future<bool> signUp(
    String email,
    String password,
    String fullName,
    String shippingAddress,
  ) async {
    _isLoading = true;
    notifyListeners();

    UserCredential? userCredential = await _authRepository.signUp(
      email,
      password,
    );

    if (userCredential != null) {
      _user = userCredential.user;
      _startTokenRefreshTimer();

      final timestamp = FieldValue.serverTimestamp();

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set({
              'uid': _user!.uid,
              'email': email,
              'fullName': fullName,
              'shippingAddress': shippingAddress,
              'createdAt': timestamp,
            });

        await _authRepository.saveUserData(userCredential);

        _user = user;
        _startTokenRefreshTimer();
      } catch (e) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
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
      if (user == null) return "User not found";

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
}
