import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';

class OrderRepository {
  final _orders = FirebaseFirestore.instance.collection('orders');

  Future<void> createOrder(OrderModel order) async {
    await _orders.doc(order.id).set(order.toJson());
  }

  // Create an order specifically for guest checkout - more secure approach
  Future<void> createGuestOrder(
    OrderModel order,
    Map<String, dynamic> guestInfo,
  ) async {
    final orderData = order.toJson();

    if (orderData['user']['userId'] == 'guest' &&
        guestInfo.containsKey('email')) {
      // If there's no specific userId, generate one based on email
      final guestUserId = generateGuestUserId(guestInfo['email']);
      orderData['user']['userId'] = guestUserId;
    }

    await _orders.doc(order.id).set(orderData);

    if (guestInfo.containsKey('email')) {
      await _orders.doc(order.id).update({
        'guestEmail': guestInfo['email'],
        'requiresAccountAssociation': true,
      });
    }
  }

  // Generate a consistent user ID for guests based on their email
  String generateGuestUserId(String email) {
    return 'guest_${email.hashCode.abs()}';
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
        await _orders
            .where('user.userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
    return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
  }

  Future<void> updateOrderStatus(
    String orderId,
    StatusHistory newStatus,
  ) async {
    final doc = await _orders.doc(orderId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final statusHistory = List<Map<String, dynamic>>.from(
        data['statusHistory'] ?? [],
      );
      statusHistory.insert(0, newStatus.toJson());
      await _orders.doc(orderId).update({'statusHistory': statusHistory});
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await _orders.doc(orderId).delete();
  }

  // Associate guest orders with a user account - more secure approach
  Future<void> associateGuestOrdersWithUser(String email, String userId) async {
    // Find orders that need to be associated with this user
    final guestOrders =
        await _orders
            .where('guestEmail', isEqualTo: email)
            .where('requiresAccountAssociation', isEqualTo: true)
            .get();

    if (guestOrders.docs.isEmpty) return;

    // Update all guest orders to be associated with this user
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in guestOrders.docs) {
      batch.update(doc.reference, {
        'user.userId': userId,
        'requiresAccountAssociation': false,
      });
    }

    await batch.commit();
  }
}
