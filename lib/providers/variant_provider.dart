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

  Future<void> updateVariantInventory({
    required String productId,
    required String variantId,
    required int quantityChange,
  }) async {
    try {
      await _variantRepo.updateVariantInventory(
        productId: productId,
        variantId: variantId,
        quantityChange: quantityChange,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating variant inventory: $e');
    }
  }

  Future<void> deleteVariant({
    required String productId,
    required String variantId,
    required String colorCode,
  }) async {
    try {
      await _variantRepo.deleteVariant(
        productId: productId,
        variantId: variantId,
        colorCode: colorCode,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting variant: $e');
      rethrow;
    }
  }

  Future<void> addVariant({
    required String productId,
    required String variantId,
    required String colorName,
    required String colorCode,
    required int inventory,
    required bool activated,
  }) async {
    try {
      await _variantRepo.addVariant(
        productId: productId,
        variantId: variantId,
        colorName: colorName,
        colorCode: colorCode,
        inventory: inventory,
        activated: activated,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding variant: $e');
      rethrow;
    }
  }
}
