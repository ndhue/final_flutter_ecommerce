import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final DateTime createdAt;
  final List<OrderDetail> orderDetails;
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;
  final List<StatusHistory> statusHistory;
  final double total;
  final OrderUserDetails user;
  final OrderCouponDetails? coupon;

  OrderModel({
    required this.id,
    required this.createdAt,
    required this.orderDetails,
    required this.loyaltyPointsEarned,
    required this.loyaltyPointsUsed,
    required this.statusHistory,
    required this.total,
    required this.user,
    this.coupon,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    if (json['createdAt'] == null) {

      print('⚠️Missing orders');

    }

    return OrderModel(
      id: json['id'] ?? '',
      createdAt: _safeParseDate(json['createdAt']),
      orderDetails:
          (json['orderDetails'] as List? ?? [])
              .map((e) => OrderDetail.fromJson(e))
              .toList(),
      loyaltyPointsEarned: json['loyaltyPointsEarned'] ?? 0,
      loyaltyPointsUsed: json['loyaltyPointsUsed'] ?? 0,
      statusHistory:
          (json['statusHistory'] as List? ?? [])
              .map((e) => StatusHistory.fromJson(e))
              .toList(),
      total: (json['total'] ?? 0).toDouble(),
      user: OrderUserDetails.fromMap(json['user'] ?? {}),
      coupon:
          json['coupon'] != null
              ? OrderCouponDetails.fromMap(json['coupon'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': Timestamp.fromDate(createdAt),
    'orderDetails': orderDetails.map((e) => e.toJson()).toList(),
    'loyaltyPointsEarned': loyaltyPointsEarned,
    'loyaltyPointsUsed': loyaltyPointsUsed,
    'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
    'total': total,
    'user': user.toMap(),
    'coupon': coupon?.toMap(),
  };
}

class OrderDetail {
  final String productId;
  final String productName;
  final String imageUrl;
  final String variantId;
  final String colorName;
  final int quantity;
  final double price;
  final double discount;

  OrderDetail({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.variantId,
    required this.colorName,
    required this.quantity,
    required this.price,
    this.discount = 0.0,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
    productId: json['productId'] ?? '',
    productName: json['productName'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    variantId: json['variantId'] ?? '',
    colorName: json['colorName'] ?? '',
    quantity: json['quantity'] ?? 0,
    price: (json['price'] ?? 0).toDouble(),
    discount:
        json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0,
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'imageUrl': imageUrl,
    'variantId': variantId,
    'colorName': colorName,
    'quantity': quantity,
    'price': price,
    'discount': discount,
  };
}

class StatusHistory {
  final String status;
  final DateTime time;

  StatusHistory({required this.status, required this.time});

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: json['status'] ?? 'Unknown',
      time: _safeParseDate(json['time']),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'time': Timestamp.fromDate(time),
  };
}

class OrderUserDetails {
  final String userId;
  final String name;
  final String email;
  final String shippingAddress;

  OrderUserDetails({
    required this.userId,
    required this.name,
    required this.email,
    required this.shippingAddress,
  });

  factory OrderUserDetails.fromMap(Map<String, dynamic> json) =>
      OrderUserDetails(
        userId: json['userId'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        shippingAddress: json['shippingAddress'] ?? '',
      );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'email': email,
    'shippingAddress': shippingAddress,
  };
}

class OrderCouponDetails {
  final String code;
  final double value;

  OrderCouponDetails({required this.code, required this.value});

  factory OrderCouponDetails.fromMap(Map<String, dynamic> json) =>
      OrderCouponDetails(
        code: json['code'] ?? '',
        value: (json['value'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {'code': code, 'value': value};
}

/// Utility: parse Timestamp / String / DateTime / null an toàn
DateTime _safeParseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is DateTime) return value;
  return DateTime.now();
}
