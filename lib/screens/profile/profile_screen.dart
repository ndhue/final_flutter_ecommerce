import 'package:final_ecommerce/providers/providers_export.dart';
import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/services/auth_service.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/change_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body:
          userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
              ? Center(child: Text("User data not found. Please log in again."))
              : ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Card(
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/avatar-1.jpg',
                        ),
                        radius: 30,
                      ),
                      title: Text(
                        user.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(user.email),
                      trailing: Icon(Icons.edit, color: iconColor),
                    ),
                  ),
                  SizedBox(height: 20),

                  _buildSectionTitle("Personal Information"),

                  _buildMenuItem(
                    Icons.local_shipping,
                    "Shipping Address",
                    context,
                    shippingAddressScreenRoute,
                  ),
                  _buildMenuItem(
                    Icons.payment,
                    "Payment Method",
                    context,
                    paymentMethodScreenRoute,
                  ),
                  _buildMenuItem(
                    Icons.history,
                    "Order History",
                    context,
                    orderHistoryRouteScreen,
                  ),

                  SizedBox(height: 20),
                  _buildSectionTitle("Support & Information"),
                  _buildMenuItem(
                    Icons.security,
                    "Privacy Policy ",
                    context,
                    pravicyAndPolicyScreenRoute,
                  ),
                  _buildMenuItem(
                    Icons.help,
                    "Helps and support",
                    context,
                    helpsAndSupportScreenRoute,
                  ),
                  _buildMenuItem(
                    Icons.question_answer,
                    "FAQs",
                    context,
                    faqsScreenRoute,
                  ),

                  SizedBox(height: 20),
                  _buildSectionTitle("Account Management"),
                  _buildMenuItemCustom(Icons.lock, "Change Password", () {
                    _showChangePasswordDialog(context);
                  }),
                  _buildMenuItemCustom(Icons.logout, "Logout", () {
                    AppDialogs.showCustomDialog(
                      context: context,
                      title: "Log out",
                      content: "Are you sure you want to logout?",
                      confirmText: "Log out",
                      onConfirm: () => handleLogout(context),
                      cancelText: "Cancel",
                      icon: Icons.exit_to_app,
                      confirmColor: Colors.red,
                    );
                  }),
                ],
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    BuildContext context,
    String destination,
  ) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
        onTap: () {
          Navigator.pushNamed(context, destination);
        },
      ),
    );
  }

  Widget _buildMenuItemCustom(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ChangePasswordDialog(),
    );
  }
}
