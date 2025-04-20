import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/coupon_model.dart';

class CouponRepository {
  final CollectionReference _couponCollection = FirebaseFirestore.instance
      .collection('coupons');

  Future<List<Coupon>> fetchCoupons() async {
    try {
      QuerySnapshot snapshot = await _couponCollection.get();
      return snapshot.docs
          .map((doc) => Coupon.fromMap(doc))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      debugPrint('Error fetching coupons: $e');
      return [];
    }
  }

  Future<void> addCoupon(Coupon coupon) async {
    try {
      await _couponCollection.doc(coupon.id).set(coupon.toMap());
    } catch (e) {
      debugPrint('Error adding coupon: $e');
    }
  }

  Future<void> updateCoupon(String id, Map<String, dynamic> data) async {
    try {
      if (data.containsKey('value')) {
        data['value'] = (data['value'] as num).toDouble();
      }
      await _couponCollection.doc(id).update(data);
    } catch (e) {
      debugPrint('Error updating coupon: $e');
    }
  }

  Future<void> updateCouponUsage(
    String couponCode,
    String orderId, {
    bool revert = false,
  }) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('coupons')
            .where('code', isEqualTo: couponCode)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final couponDoc = snapshot.docs.first.reference;

      if (revert) {
        await couponDoc.update({
          'ordersApplied': FieldValue.arrayRemove([orderId]),
          'timesUsed': FieldValue.increment(-1),
        });
      } else {
        await couponDoc.update({
          'ordersApplied': FieldValue.arrayUnion([orderId]),
          'timesUsed': FieldValue.increment(1),
        });
      }
    } else {
      throw Exception('Coupon with code $couponCode not found');
    }
  }

  Future<void> deleteCoupon(String id) async {
    try {
      await _couponCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting coupon: $e');
    }
  }
}
