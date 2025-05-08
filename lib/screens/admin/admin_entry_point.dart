import 'package:final_ecommerce/screens/admin/Home/home_screen.dart';
import 'package:final_ecommerce/screens/admin/admin_screens_export.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

import 'components/navigation_drawer.dart';

class AdminEntryPoint extends StatefulWidget {
  const AdminEntryPoint({super.key});

  @override
  State<AdminEntryPoint> createState() => _AdminEntryPointState();
}

class _AdminEntryPointState extends State<AdminEntryPoint> {
  String _selectedItem = "Home"; // Track selected item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: CustomDrawer(
        selectedItem: _selectedItem,
        onItemSelected: (item) {
          setState(() {
            _selectedItem = item;
          });
          Navigator.pop(context); // Close the drawer
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_selectedItem) {
      case "Home":
        return DashboardScreen();
      case "Customers":
        return AdminCustomersScreen();
      case "Chats":
        return AdminChatsScreen();
      case "Shop":
        return Center(child: Text("Shop Screen"));
      case "Income":
        return OrderManagerScreen();
      case "Coupons":
        return AdminCouponScreen();
      case "Products":
        return AdminProductScreen();
      case "AddProduct":
        return AddProductPage();
      default:
        return Center(child: Text("Unknown Screen"));
    }
  }
}
