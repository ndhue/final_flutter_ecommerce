import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthDialogs {
  /// Handles the login process and loading state
  static Future<bool> _handleLogin({
    required BuildContext context,
    required String email,
    required String password,
    required AuthProvider authProvider,
    required CartProvider cartProvider,
    required OrderProvider orderProvider,
    required UserProvider userProvider,
  }) async {
    if (password.isEmpty) {
      return false;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool success = await authProvider.signIn(email, password);
      if (!context.mounted) {
        return false;
      }
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (success) {
        // Get user data after successful login
        final user = authProvider.user;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed. Please try again.")),
          );
          return false;
        }

        await userProvider.fetchUser(user.uid);

        return true;
      } else {
        // Show error for invalid credentials
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    }
  }

  /// Shows a login prompt dialog for when a user tries to checkout with an existing email
  static Future<bool> showLoginPrompt(
    BuildContext context,
    String email,
  ) async {
    final TextEditingController passwordController = TextEditingController();

    // Capture references to providers before showing the dialog
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // This function is designed to be independent of its calling context's lifecycle
    final result = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Account Exists'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('An account with $email already exists.'),
                const SizedBox(height: 16),
                const Text(
                  'Please sign in to continue with your purchase.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onSubmitted: (_) async {
                    if (passwordController.text.isNotEmpty) {
                      // Close the dialog first
                      Navigator.of(dialogContext).pop();

                      // Handle login with the extracted function
                      final success = await _handleLogin(
                        context: context,
                        email: email,
                        password: passwordController.text,
                        authProvider: authProvider,
                        cartProvider: cartProvider,
                        orderProvider: orderProvider,
                        userProvider: userProvider,
                      );

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(success);
                      }
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text.isEmpty) {
                    return;
                  }

                  // Close the dialog first
                  Navigator.of(dialogContext).pop();

                  // Handle login with the extracted function
                  final success = await _handleLogin(
                    context: context,
                    email: email,
                    password: passwordController.text,
                    authProvider: authProvider,
                    cartProvider: cartProvider,
                    orderProvider: orderProvider,
                    userProvider: userProvider,
                  );

                  // Return the success value
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(success);
                  }
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
    );

    return result ?? false;
  }
}
