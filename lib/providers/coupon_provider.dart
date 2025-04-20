import 'package:flutter/material.dart';

import '../models/coupon_model.dart';
import '../repositories/coupon_repository.dart';

class CouponProvider with ChangeNotifier {
  final CouponRepository _couponRepository = CouponRepository();
  List<Coupon> _coupons = [];
  bool _isLoading = false;
  Coupon? _appliedCoupon; //

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;

  Coupon? get appliedCoupon => _appliedCoupon; //

  Future<void> loadCoupons() async {
    _isLoading = true;
    notifyListeners();

    _coupons = await _couponRepository.fetchCoupons();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCoupon(Coupon coupon) async {
    await _couponRepository.addCoupon(coupon);
    await loadCoupons();
  }

  Future<void> updateCoupon(String id, Map<String, dynamic> data) async {
    await _couponRepository.updateCoupon(id, data);
    await loadCoupons();
  }

  Future<void> deleteCoupon(String id) async {
    await _couponRepository.deleteCoupon(id);
    await loadCoupons();
  }

  Future<void> updateCouponUsage(
    String couponId,
    String orderId, {
    bool revert = false,
  }) async {
    try {
      await _couponRepository.updateCouponUsage(
        couponId,
        orderId,
        revert: revert,
      );
      // Update the local applied coupon if it matches
      if (_appliedCoupon != null && _appliedCoupon!.id == couponId) {
        _appliedCoupon = _appliedCoupon!.copyWith(
          timesUsed: _appliedCoupon!.timesUsed + 1,
          ordersApplied: [..._appliedCoupon!.ordersApplied, orderId],
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating coupon usage: $e');
    }
  }

  int getTotalCoupons() => _coupons.length;

  int getUsedCoupons() =>
      _coupons.where((coupon) => coupon.timesUsed > 0).length;

  int getActiveCoupons() => _coupons.where((coupon) => !coupon.disable).length;

  int getDisabledCoupons() => _coupons.where((coupon) => coupon.disable).length;

  double calculateDiscount(double totalAmount) {
    if (_appliedCoupon == null) return 0.0;

    if (_appliedCoupon!.type == CouponType.fixed) {
      return totalAmount >= _appliedCoupon!.value
          ? _appliedCoupon!.value
          : totalAmount;
    } else {
      return totalAmount * _appliedCoupon!.value;
    }
  }

  void applyCouponByCode(String code) {
    final match = _coupons.firstWhere(
      (c) =>
          c.code.toLowerCase() == code.toLowerCase() &&
          !c.disable &&
          c.timesUsed < c.maxUses,
      orElse: () => null as Coupon,
    );

    if (match != null) {
      _appliedCoupon = match;
      notifyListeners();
    } else {
      _appliedCoupon = null;
      notifyListeners();
      throw Exception("Coupon is invalid or expired.");
    }
  }

  void clearAppliedCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }
}
