import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';

class OrderRepository {
  final _orders = FirebaseFirestore.instance.collection('orders');

  Future<void> createOrder(OrderModel order) async {
    await _orders.doc(order.id).set(order.toJson());
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    final snapshot =
        await _orders.where('user.userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
  }

  Future<void> updateOrderStatus(
    String orderId,
    StatusHistory newStatus,
  ) async {
    final doc = await _orders.doc(orderId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory'] ?? []);
      statusHistory.insert(0, newStatus.toJson());
      await _orders.doc(orderId).update({
        'statusHistory': statusHistory,
      });
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await _orders.doc(orderId).delete();
  }
}
