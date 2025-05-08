import 'package:final_ecommerce/screens/admin/product/product_add.dart';
import 'package:final_ecommerce/screens/admin/product/product_detail.dart';
import 'package:final_ecommerce/screens/admin/product/product_screen.dart';
import 'package:flutter/material.dart';

class AdminRoutes {
  // Define route names
  static const String products = '/admin/products';
  static const String addProduct = '/admin/products/add';
  static const String productDetail = '/admin/products/detail';

  // Route generation function
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case products:
        return MaterialPageRoute(builder: (_) => const AdminProductScreen());
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductPage());
      case productDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AdminProductDetailScreen(product: args['product']),
        );
      default:
        return null;
    }
  }
}
