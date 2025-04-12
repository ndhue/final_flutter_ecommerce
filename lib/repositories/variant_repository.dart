import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';

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
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final variantMap = querySnapshot.docs.first.data();
      return NewVariant.fromMap(variantMap);
    } else {
      return null;
    }
  }
}
