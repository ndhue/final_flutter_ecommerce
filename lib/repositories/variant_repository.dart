import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

class VariantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<NewVariant?> getVariantByColor({
    required String productId,
    required String colorCode,
  }) async {
    final lowerCaseColorCode = colorCode.toLowerCase();

    final querySnapshot =
        await _firestore
            .collection('products')
            .doc(productId)
            .collection('variantInventory')
            .where('colorCode', isEqualTo: lowerCaseColorCode)
            .orderBy('createdAt') 
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

  Future<void> deleteVariant({
    required String productId,
    required String variantId,
    required String colorCode,
  }) async {
    try {
      // Delete the variant document
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('variantInventory')
          .doc(variantId)
          .delete();

      // Check if we need to remove the color from availableColors
      final remainingVariantsWithColor =
          await _firestore
              .collection('products')
              .doc(productId)
              .collection('variantInventory')
              .where('colorCode', isEqualTo: colorCode)
              .get();

      // If no more variants with this color, remove from availableColors
      if (remainingVariantsWithColor.docs.isEmpty) {
        // Get current availableColors
        final productDoc =
            await _firestore.collection('products').doc(productId).get();

        if (productDoc.exists) {
          final data = productDoc.data() as Map<String, dynamic>;
          final List<dynamic> availableColors = List.from(
            data['availableColors'] ?? [],
          );

          // Remove the color
          availableColors.remove(colorCode);

          // Update the product document
          await _firestore.collection('products').doc(productId).update({
            'availableColors': availableColors,
          });
        }
      }
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
      // Create new variant
      final variant = {
        'variantId': variantId,
        'colorName': colorName,
        'colorCode': colorCode,
        'inventory': inventory,
        'activated': activated,
        'createdAt': Timestamp.now(),
      };

      // Add variant to Firebase
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('variantInventory')
          .doc(variantId)
          .set(variant);

      // Add color to product's availableColors if it's not already there
      final productDoc =
          await _firestore.collection('products').doc(productId).get();

      if (productDoc.exists) {
        final data = productDoc.data() as Map<String, dynamic>;
        final List<String> availableColors = List<String>.from(
          data['availableColors'] ?? [],
        );

        if (!availableColors.contains(colorCode)) {
          availableColors.add(colorCode);

          // Update product in Firestore
          await _firestore.collection('products').doc(productId).update({
            'availableColors': availableColors,
          });
        }
      }
    } catch (e) {
      debugPrint('Error adding variant: $e');
      rethrow;
    }
  }
}
