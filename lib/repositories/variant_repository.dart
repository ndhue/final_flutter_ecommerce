import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

class VariantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<NewVariant?> getVariantByColor({
    required String productId,
    required String colorCode,
  }) async {
    final querySnapshot =
        await _firestore
            .collection('products')
            .doc(productId)
            .collection('variantInventory')
            .where('colorCode', isEqualTo: colorCode)
            .orderBy('createdAt') // sort theo createdAt tăng dần
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final variantMap = querySnapshot.docs.first.data();
      return NewVariant.fromMap(variantMap);
    } else {
      return null;
    }
  }

  Future<void> updateVariantInventory({
    required String productId,
    required String variantId,
    required int quantityChange,
  }) async {
    try {
      final variantDoc = _firestore
          .collection('products')
          .doc(productId)
          .collection('variantInventory')
          .doc(variantId);

      await variantDoc.update({
        'inventory': FieldValue.increment(quantityChange),
      });
    } catch (e) {
      debugPrint('Error updating variant inventory: $e');
      rethrow;
    }
  }
}
