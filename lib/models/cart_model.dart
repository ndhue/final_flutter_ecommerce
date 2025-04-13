import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final CartProduct product;
  final CartVariant variant;
  int quantity;

  CartItem({required this.product, required this.variant, this.quantity = 1});

  double get totalPrice => product.price * quantity * (1 - product.discount);

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
        product: CartProduct.fromMap(json['product']),
        variant: CartVariant.fromMap(json['variant']),
        quantity: json['quantity'],
      );
    } else if (json is DocumentSnapshot) {
      final data = json.data() as Map<String, dynamic>;
      return CartItem(
        product: CartProduct.fromMap(data['product']),
        variant: CartVariant.fromMap(data['variant']),
        quantity: data['quantity'],
      );
    } else {
      throw TypeError();
    }
  }
}

class CartProduct {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double discount;

  CartProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.discount,
  });

  factory CartProduct.fromMap(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      discount: json['discount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'discount': discount,
    };
  }
}

class CartVariant {
  final String variantId;
  final String colorCode;
  final String colorName;

  CartVariant({
    required this.variantId,
    required this.colorCode,
    required this.colorName,
  });

  factory CartVariant.fromMap(Map<String, dynamic> json) {
    return CartVariant(
      variantId: json['variantId'],
      colorCode: json['colorCode'],
      colorName: json['colorName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'variantId': variantId,
      'colorCode': colorCode,
      'colorName': colorName,
    };
  }
}
