import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

import '../repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetchedOrders = false;
  bool get hasFetchedOrders => _hasFetchedOrders;

  OrderProvider();

  Future<void> fetchOrdersByUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    _orders = await _orderRepository.getOrdersByUserId(userId);

    _isLoading = false;
    _hasFetchedOrders = true;
    notifyListeners();
  }

  Future<void> addOrder(OrderModel order) async {
    await _orderRepository.createOrder(order);
    _orders.add(order);
    _hasFetchedOrders = false; // Reset to refetch orders
    notifyListeners();
  }

  Future<void> updateOrderStatus(
    String orderId,
    StatusHistory newStatus,
  ) async {
    await _orderRepository.updateOrderStatus(orderId, newStatus);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].statusHistory.add(newStatus);
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await _orderRepository.deleteOrder(orderId);
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }
}
