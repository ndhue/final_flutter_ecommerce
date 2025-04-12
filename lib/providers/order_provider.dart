// lib/providers/order_provider.dart
import 'package:flutter/material.dart';

class Order {
  final String id;
  final String productName;
  final double price;
  final int quantity;
  final String status;

  Order({
    required this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.status,
  });
}

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  List<Order> getByStatus(String status) =>
      _orders.where((order) => order.status == status).toList();

  void addOrder(Order order) {
    _orders.insert(0, order); // Thêm đầu danh sách
    notifyListeners();
  }
}
