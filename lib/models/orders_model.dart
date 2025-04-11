import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final DateTime createdAt;
  final String orderStatus;
  final List<OrderDetail> orderDetails;
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;
  final List<StatusHistory> statusHistory;
  final double total;
  final User user;

  Order({
    required this.id,
    required this.createdAt,
    required this.orderStatus,
    required this.orderDetails,
    required this.loyaltyPointsEarned,
    required this.loyaltyPointsUsed,
    required this.statusHistory,
    required this.total,
    required this.user,
  });

  factory Order.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Order(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      orderStatus: data['orderStatus'],
      orderDetails: (data['orderDetails'] as List)
          .map((item) => OrderDetail.fromMap(item))
          .toList(),
      loyaltyPointsEarned: data['loyaltyPointsEarned'],
      loyaltyPointsUsed: data['loyaltyPointsUsed'],
      statusHistory: (data['statusHistory'] as List)
          .map((status) => StatusHistory.fromMap(status))
          .toList(),
      total: (data['total'] as num).toDouble(),
      user: User.fromMap(data['user']),
    );
  }
}

class OrderDetail {
  final String id;
  final String name;
  final String variant;
  final int quantity;
  final double price;
  final double finalPrice;
  final double discountApplied;

  OrderDetail({
    required this.id,
    required this.name,
    required this.variant,
    required this.quantity,
    required this.price,
    required this.finalPrice,
    required this.discountApplied,
  });

  factory OrderDetail.fromMap(Map<String, dynamic> data) {
    return OrderDetail(
      id: data['id'],
      name: data['name'],
      variant: data['variant'],
      quantity: data['quantity'],
      price: (data['price'] as num).toDouble(),
      finalPrice: double.parse(data['finalPrice']),
      discountApplied: (data['discountApplied'] as num).toDouble(),
    );
  }
}

class StatusHistory {
  final String status;
  final DateTime timestamp;

  StatusHistory({
    required this.status,
    required this.timestamp,
  });

  factory StatusHistory.fromMap(Map<String, dynamic> data) {
    return StatusHistory(
      status: data['status'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String shippingAddress;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.shippingAddress,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      fullName: data['fullName'],
      email: data['email'],
      shippingAddress: data['shippingAddress'],
    );
  }
}
