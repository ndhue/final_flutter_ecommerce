import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    setState(() => _isLoading = true);

    String result = await authProvider.changePassword(
      _oldPasswordController.text.trim(),
      _newPasswordController.text.trim(),
    );

    setState(() => _isLoading = false);

    // Show a toast message based on the result
    if (result == "success") {
      Fluttertoast.showToast(msg: "Password changed successfully");
    } else {
      Fluttertoast.showToast(msg: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // Adjust for keyboard
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Old Password Input
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _isObscureOld,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  prefixIcon: const Icon(Icons.lock, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureOld ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(() => _isObscureOld = !_isObscureOld),
                  ),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? "Enter your current password"
                            : null,
              ),
              const SizedBox(height: 10),

              // New Password Input
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isObscureNew,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(() => _isObscureNew = !_isObscureNew),
                  ),
                ),
                validator:
                    (value) =>
                        (value == null || value.length < 6)
                            ? "Password must be at least 6 characters"
                            : null,
              ),
              const SizedBox(height: 10),

              // Confirm New Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isObscureConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _isObscureConfirm = !_isObscureConfirm,
                        ),
                  ),
                ),
                validator:
                    (value) =>
                        (value != _newPasswordController.text)
                            ? "Passwords do not match"
                            : null,
              ),
              const SizedBox(height: 20),

              // Confirm Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _handleChangePassword,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ),
              ),
              const SizedBox(height: 10),

              // Cancel Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
