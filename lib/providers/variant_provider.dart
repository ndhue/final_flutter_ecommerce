import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

import '../repositories/variant_repository.dart';

class VariantProvider with ChangeNotifier {
  final VariantRepository _variantRepo = VariantRepository();

  NewVariant? _selectedVariant;
  bool _isLoading = false;

  NewVariant? get selectedVariant => _selectedVariant;
  bool get isLoading => _isLoading;

  Future<void> fetchVariantByColor({
    required String productId,
    required String colorCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    final variant = await _variantRepo.getVariantByColor(
      productId: productId,
      colorCode: colorCode,
    );

    _selectedVariant = variant;
    _isLoading = false;
    notifyListeners();
  }

  void clearSelectedVariant() {
    _selectedVariant = null;
    notifyListeners();
  }
}
