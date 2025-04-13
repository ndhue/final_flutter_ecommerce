import 'package:cloud_firestore/cloud_firestore.dart';

class NewVariant {
  final String variantId;
  final String colorCode;
  final String colorName;
  final int inventory;
  final bool activated;

  NewVariant({
    required this.variantId,
    required this.colorCode,
    required this.colorName,
    required this.inventory,
    required this.activated,
  });

  factory NewVariant.fromMap(dynamic source) {
    if (source is Map<String, dynamic>) {
      return NewVariant(
        variantId: source['variantId'],
        colorCode: source['colorCode'],
        colorName: source['colorName'],
        inventory: source['inventory'],
        activated: source['activated'],
      );
    } else if (source is DocumentSnapshot) {
      final data = source.data() as Map<String, dynamic>;
      return NewVariant(
        variantId: data['variantId'],
        colorCode: data['colorCode'],
        colorName: data['colorName'],
        inventory: data['inventory'],
        activated: data['activated'],
      );
    } else {
      throw TypeError();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'variantId': variantId,
      'colorCode': colorCode,
      'colorName': colorName,
      'inventory': inventory,
      'activated': activated,
    };
  }
}
