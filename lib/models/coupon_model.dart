import 'package:cloud_firestore/cloud_firestore.dart';

enum CouponType { fixed, percent } //

class Coupon {
  final String id;
  final String code;
  final Timestamp createdAt;
  final bool disable;
  final int maxUses;
  final int timesUsed;
  final double value;
  final CouponType type;
  final List<String> ordersApplied;

  Coupon({
    required this.id,
    required this.code,
    required this.createdAt,
    required this.disable,
    required this.maxUses,
    required this.timesUsed,
    required this.value,
    required this.ordersApplied,
    required this.type,
  });

  factory Coupon.fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Coupon(
      id: data['id'],
      code: data['code'],
      createdAt: data['createdAt'],
      disable: data['disable'],
      maxUses: data['maxUses'],
      timesUsed: data['timesUsed'],
      value: (data['value'] as num).toDouble(),
      ordersApplied: List<String>.from(data['ordersApplied']),
      type: data['type'] == 'fixed' ? CouponType.fixed : CouponType.percent, //
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'createdAt': createdAt,
      'disable': disable,
      'maxUses': maxUses,
      'timesUsed': timesUsed,
      'value': value,
      'ordersApplied': ordersApplied,
      'type': type == CouponType.fixed ? 'fixed' : 'percent', //
    };
  }
}
