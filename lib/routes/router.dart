import 'package:final_ecommerce/screens/entry_point.dart';
import 'package:final_ecommerce/screens/orders/order_history.dart';
import 'package:final_ecommerce/screens/screen_export.dart';
import 'package:flutter/material.dart';
import 'route_constants.dart';



Route<dynamic> generateRoute(RouteSettings settings) {
  // Phân tích URL từ settings.name
  final uri = Uri.parse(settings.name ?? '/');
  final path = uri.path; // Lấy đường dẫn chính (ví dụ: /home, /profile)
  // final queryParams =
  //     uri.queryParameters;
  Widget page;
  // Xử lý route dựa trên path
  switch (path) {
    //case '/':
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
    case pravicyAndPolicyScreenRoute:
      page = PravicyAndPolicy();
      break;
    case faqsScreenRoute:
      page = FAQs();
    case orderHistoryRouteScreen:
      page  = OrdersHistoryScreen();
      break;
    default:
      // Xử lý trường hợp không tìm thấy route
      page = const HomeScreen(); // Hoặc có thể hiển thị màn hình 404
      break;
  }
  // Trả về MaterialPageRoute với widget tương ứng
  return MaterialPageRoute(builder: (context) => page, settings: settings);
}
