import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';

class CartItem {
  final NewProduct product;
  final NewVariant variant;
  int quantity;

  CartItem({required this.product, required this.variant, this.quantity = 1});

  double get totalPrice =>
      product.sellingPrice * quantity * (1 - product.discount);

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'variant': variant.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CartItem(
        product: NewProduct.fromMap(json['product']),
        variant: NewVariant.fromMap(json['variant']),
        quantity: json['quantity'],
      );
    } else if (json is DocumentSnapshot) {
      final data = json.data() as Map<String, dynamic>;
      return CartItem(
        product: NewProduct.fromMap(data['product']),
        variant: NewVariant.fromMap(data['variant']),
        quantity: data['quantity'],
      );
    } else {
      throw TypeError();
    }
  }
}
