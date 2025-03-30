import 'package:flutter/material.dart';

import '../models/coupon_model.dart';
import '../repositories/coupon_repository.dart';

class CouponProvider with ChangeNotifier {
  final CouponRepository _couponRepository = CouponRepository();
  List<Coupon> _coupons = [];
  bool _isLoading = false;

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;

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

  int getTotalCoupons() => _coupons.length;

  int getUsedCoupons() =>
      _coupons.where((coupon) => coupon.timesUsed > 0).length;

  int getActiveCoupons() => _coupons.where((coupon) => !coupon.disable).length;

  int getDisabledCoupons() => _coupons.where((coupon) => coupon.disable).length;
}
