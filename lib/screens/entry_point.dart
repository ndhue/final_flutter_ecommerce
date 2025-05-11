import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:final_ecommerce/widgets/buttons/cart_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _pages = [
      const HomeScreen(),
      const CategoriesScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
  }

  // Check if user is logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    setState(() {
      _isLoggedIn = uid != null;
    });
  }

  // Show login dialog
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Sign In Required"),
            content: const Text("Please sign in to access this feature."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, authScreenRoute);
                },
                child: const Text("Sign In"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.only(right: defaultPadding),
        backgroundColor: Colors.white,
        title: Align(
          alignment: isLargeScreen ? Alignment.center : Alignment.centerLeft,
          child: Row(
            mainAxisSize: isLargeScreen ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Image.asset('assets/images/shopping.png', height: 28),
              const SizedBox(width: 8),
              const Text(
                "Naturify Shop",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        centerTitle: isLargeScreen,
        actions: [CartButton()],
      ),
      body: isLargeScreen ? _buildWebLayout() : _pages[_currentIndex],
      bottomNavigationBar:
          isLargeScreen
              ? null
              : Container(
                padding: const EdgeInsets.only(top: defaultPadding / 2),
                color: Colors.white,
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (!_isLoggedIn && (index == 2 || index == 3)) {
                      _showLoginDialog();
                    } else {
                      setState(() {
                        _currentIndex = index;
                      });
                    }
                  },
                  backgroundColor: Colors.white,
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: const TextStyle(color: primaryColor),
                  selectedFontSize: 12,
                  selectedItemColor: primaryColor,
                  unselectedItemColor: iconColor,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_filled),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_outlined),
                      activeIcon: Icon(Icons.grid_view_rounded),
                      label: "Categories",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.access_time_outlined),
                      activeIcon: Icon(Icons.access_time_filled_rounded),
                      label: "Orders",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person_rounded),
                      label: "Profile",
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        // Navigation Sidebar
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(25),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildNavItem(0, "Home", Icons.home_outlined, Icons.home_filled),
              _buildNavItem(
                1,
                "Categories",
                Icons.grid_view_outlined,
                Icons.grid_view_rounded,
              ),
              _buildNavItem(
                2,
                "Orders",
                Icons.access_time_outlined,
                Icons.access_time_filled_rounded,
              ),
              _buildNavItem(
                3,
                "Profile",
                Icons.person_outline,
                Icons.person_rounded,
              ),
            ],
          ),
        ),
        // Main content
        Expanded(child: _pages[_currentIndex]),
      ],
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    IconData activeIcon,
  ) {
    final bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        if (!_isLoggedIn && (index == 2 || index == 3)) {
          _showLoginDialog();
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryColor : iconColor,
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
