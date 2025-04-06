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

  factory NewVariant.fromMap(Map<String, dynamic> map) {
    return NewVariant(
      variantId: map['variantId'],
      colorCode: map['colorCode'],
      colorName: map['colorName'],
      inventory: map['inventory'],
      activated: map['activated'],
    );
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
