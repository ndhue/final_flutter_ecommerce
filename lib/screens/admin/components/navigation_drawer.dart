import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/services/auth_service.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/dialog.dart';
import 'package:flutter/material.dart';

import '../../profile/components/change_password.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Close Button & Logo
          SizedBox(
            height: 90, // Đặt chiều cao mong muốn
            child: DrawerHeader(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: iconColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Image.asset('assets/images/shopping.png', height: 40),
                ],
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(Icons.home, "Home"),
                _buildExpandableNavItem(
                  context: context,
                  icon: Icons.filter_alt_outlined,
                  title: "Products",
                  children: [
                    _buildSubNavItem("Dashboard", isSelected: true),
                    _buildSubNavItem("Add Product"),
                  ],
                ),
                _buildExpandableNavItem(
                  context: context,
                  icon: Icons.people_outline,
                  title: "Customers",
                  children: [
                    _buildSubNavItem("Dashboard", isSelected: true),
                    _buildSubNavItem(
                      "Chats",
                      onTap: () {
                        Navigator.pushNamed(context, adminChatsRoute);
                      },
                    ),
                  ],
                ),
                _buildNavItem(Icons.storefront, "Shop"),
                _buildExpandableNavItem(
                  context: context,
                  icon: Icons.pie_chart_outline,
                  title: "Income",
                ),
                _buildNavItem(Icons.campaign_outlined, "Promote"),
              ],
            ),
          ),

          // User Info Card
          _buildUserInfoCard(context),
        ],
      ),
    );
  }

  // Nav Item (Single)
  Widget _buildNavItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  // Expandable Nav Item
  Widget _buildExpandableNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    List<Widget>? children,
    String? activeItem, // Track active item
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children:
            children
                ?.map((child) => _styledChild(child, activeItem, context))
                .toList() ??
            [],
      ),
    );
  }

  //  Style active children
  Widget _styledChild(Widget child, String? activeItem, BuildContext context) {
    return ListTileTheme(
      child:
          child is ListTile
              ? ListTile(
                title: child.title,
                onTap: child.onTap,
                contentPadding: EdgeInsets.symmetric(horizontal: 55),
                tileColor:
                    (child.title is Text &&
                            (child.title as Text).data == activeItem)
                        ? Theme.of(context).primaryColor.withOpacity(
                          0.2,
                        ) // Active highlight
                        : Colors.transparent,
              )
              : child,
    );
  }

  // Sub Nav Item (for expandable menus)
  Widget _buildSubNavItem(
    String title, {
    bool isSelected = false,
    int? badgeCount,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (badgeCount != null)
            Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$badgeCount",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      selected: isSelected,
      selectedTileColor: Colors.grey.shade200,
      onTap: onTap,
    );
  }

  // User Info Card
  Widget _buildUserInfoCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(
              'assets/images/avatar-1.jpg',
            ), // Fake avatar
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "First Name Last Name",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.expand_more),
            onSelected: (value) {
              if (value == 'Change Password') {
                _showChangePasswordDialog(context);
              } else if (value == 'Logout') {
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
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'Change Password',
                    child: Text('Change Password'),
                  ),
                  PopupMenuItem(value: 'Logout', child: Text('Logout')),
                ],
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
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
