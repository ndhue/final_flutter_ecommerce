import 'package:final_ecommerce/screens/admin/admin_screens_export.dart';
import 'package:final_ecommerce/screens/entry_point.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:flutter/material.dart';
import 'package:final_ecommerce/screens/product/search_result.dart';
import 'package:final_ecommerce/screens/product/product_search.dart';
import 'route_constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/');
  final path = uri.path;

  Widget page;

  switch (path) {
    case entryPointScreenRoute:
      page = const EntryPoint();
      break;
    case homeScreenRoute:
      page = const HomeScreen();
      break;
    case categoriesScreenRoute:
      page = const CategoriesScreen();
      break;
    case profileScreenRoute:
      page = const ProfileScreen();
      break;
    case ordersScreenRoute:
      page = const OrdersScreen();
      break;
    case cartScreenRoute:
      page = const CartScreen();
      break;
    case authScreenRoute:
      page = LoginScreen();
      break;
    case shippingAddressScreenRoute:
      page = ShippingAddress();
      break;
    case paymentMethodScreenRoute:
      page = PaymentMethod();
      break;
    case helpsAndSupportScreenRoute:
      page = HelpsSupport();
      break;
    case adminChatsRoute:
      page = AdminChatsScreen();
      break;
    case productSearchRoute:
      page = ProductSearch();
      break;
    case searchResultRoute:
      final args = settings.arguments;
      if (args is String) {
        page = const SearchResults();
      } else {
        page = const SearchResults();
      }
      break;
    case customerChatRoute:
      final args = settings.arguments as Map<String, dynamic>;
      page = HelpCenterScreen(userId: args['userId']);
      break;
    default:
      page = const HomeScreen();
      break;
  }

  return MaterialPageRoute(
    builder: (context) => page,
    settings: settings, // Giữ nguyên arguments để SearchResults nhận được
  );
}
