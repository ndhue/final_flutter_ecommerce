import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/providers/user_provider.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleLogout(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Preserve all cart-related data
    final keysToPreserve =
        prefs.getKeys().where((key) => key.startsWith('cart_')).toList();
    final preservedData = {
      for (var key in keysToPreserve) key: prefs.getString(key),
    };

    // Clear all preferences
    await prefs.clear();

    // Restore preserved cart data
    for (var entry in preservedData.entries) {
      await prefs.setString(entry.key, entry.value!);
    }

    await FirebaseAuth.instance.signOut();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<UserProvider>().clearUser();

        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          entryPointScreenRoute,
          (Route<dynamic> route) => false,
        );
      }
    });
  } catch (e) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logout failed. Please try again.")),
        );
      }
    });
  }
}
