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

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    createdAt: DateTime.parse(json['createdAt']),
    orderDetails:
        (json['orderDetails'] as List)
            .map((e) => OrderDetail.fromJson(e))
            .toList(),
    loyaltyPointsEarned: json['loyaltyPointsEarned'],
    loyaltyPointsUsed: json['loyaltyPointsUsed'],
    statusHistory:
        (json['statusHistory'] as List)
            .map((e) => StatusHistory.fromJson(e))
            .toList(),
    total: json['total'],
    user: OrderUserDetails.fromMap(json['user']),
    coupon: json['coupon'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'orderDetails': orderDetails.map((e) => e.toJson()).toList(),
    'loyaltyPointsEarned': loyaltyPointsEarned,
    'loyaltyPointsUsed': loyaltyPointsUsed,
    'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
    'total': total,
    'user': user.toMap(),
    'coupon': coupon,
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
  final double? discount;

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
    productId: json['productId'],
    productName: json['productName'],
    imageUrl: json['imageUrl'],
    variantId: json['variantId'],
    quantity: json['quantity'],
    price: json['price'],
    colorName: '${json['colorName']}',
    discount: json['discount'] != null ? json['discount'].toDouble() : 0.0,
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

  factory StatusHistory.fromJson(Map<String, dynamic> json) =>
      StatusHistory(status: json['status'], time: DateTime.parse(json['time']));

  Map<String, dynamic> toJson() => {
    'status': status,
    'time': time.toIso8601String(),
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
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        shippingAddress: json['shippingAddress'],
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
      OrderCouponDetails(code: json['code'], value: json['value']);

  Map<String, dynamic> toMap() => {'code': code, 'value': value};
}
