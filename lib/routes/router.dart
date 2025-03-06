import 'package:final_ecommerce/screens/auth/login_screen.dart';
import 'package:final_ecommerce/screens/entry_point.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:flutter/material.dart';

import 'route_constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case homeScreenRoute:
      return MaterialPageRoute(builder: (context) => const HomeScreen());

    case categoriesScreenRoute:
      return MaterialPageRoute(builder: (context) => const CategoriesScreen());

    case profileScreenRoute:
      return MaterialPageRoute(builder: (context) => const ProfileScreen());

    case ordersScreenRoute:
      return MaterialPageRoute(builder: (context) => const OrdersScreen());

    case entryPointScreenRoute:
      return MaterialPageRoute(builder: (context) => const EntryPoint());

    case cartScreenRoute:
      return MaterialPageRoute(builder: (context) => const CartScreen());
    
    case authScreenRoute:
      return MaterialPageRoute(builder: (context) => LoginScreen());

    default:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
  }
}
