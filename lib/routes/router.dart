import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/screens/admin/admin_screens_export.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:flutter/material.dart';

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
    case orderDetailsScreenRoute:
      if (settings.arguments is OrderModel) {
        final order = settings.arguments as OrderModel;
        page = OrderDetailScreen(order: order);
      } else {
        page = const EntryPoint();
      }
      break;
    case cartScreenRoute:
      page = const CartScreen();
      break;
    case paymentScreenRoute:
      page = const PaymentScreen();
      break;
    case authScreenRoute:
      page = LoginScreen();
      break;
    case forgotPasswordRoute:
      page = ForgotPasswordScreen();
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

    case pravicyAndPolicyScreenRoute:
      page = PravicyAndPolicy();
      break;
    case faqsScreenRoute:
      page = FAQs();
    case productSearchRoute:
      page = ProductSearch();
      break;

    case productDetailsRoute:
      if (settings.arguments is NewProduct) {
        final product = settings.arguments as NewProduct;
        page = ProductDetails(product: product);
      } else {
        page = const EntryPoint(); // Nếu không có sản phẩm, quay về trang chính
      }
      break;

    case searchResultRoute:
      final args = settings.arguments;
      if (args is String) {
        page = const SearchResults();
      } else {
        page = const SearchResults();
      }
      break;
    case chatScreenRoute:
      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        page = ChatScreen(userId: args['userId']);
      } else {
        return MaterialPageRoute(builder: (context) => const EntryPoint());
      }
      break;

    // ADMIN ROUTES
    case adminEntryPointRoute:
      page = AdminEntryPoint();
      break;

    case adminChatsRoute:
      page = AdminChatsScreen();
      break;

    case adminSingleChat:
      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        page = ChatScreen(userId: args['userId']);
        settings = RouteSettings(name: adminSingleChat, arguments: args);
      } else {
        return MaterialPageRoute(
          builder: (context) => const AdminChatsScreen(),
        );
      }
      break;

    default:
      page = const EntryPoint();
      break;
  }

  return MaterialPageRoute(builder: (context) => page, settings: settings);
}
