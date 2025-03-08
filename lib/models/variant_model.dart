import 'package:cloud_firestore/cloud_firestore.dart';

class Variant {
  String variantId;
  String name;
  int costPrice;
  int sellingPrice;
  double discount; // Discount percentage (0.0 to 1.0)
  int inventory;
  bool isColor;
  DateTime updatedAt;

  Variant({
    required this.variantId,
    required this.name,
    required this.costPrice,
    required this.sellingPrice,
    this.discount = 0.0,
    required this.inventory,
    required this.isColor,
    required this.updatedAt,
  });

  // Get the current price (discounted or regular)
  int get currentPrice {
    if (discount > 0 && discount < 1) {
      return (sellingPrice * (1 - discount)).round();
    }
    return sellingPrice;
  }

  // Convert Firestore JSON to Variant Object
  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      variantId: json['variantId']['stringValue'] ?? '',
      name: json['name']['stringValue'] ?? '',
      costPrice: json['costPrice']['integerValue'] ?? 0,
      sellingPrice: json['sellingPrice']['integerValue'] ?? 0,
      discount: (json['discount']?['doubleValue'] ?? 0.0).toDouble(),
      inventory: json['inventory']['integerValue'] ?? 0,
      isColor: json['isColor']['booleanValue'] ?? false,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt']['timestampValue'] is Timestamp
              ? json['updatedAt']['timestampValue']
              : Timestamp.fromDate(
                  DateTime.parse(json['updatedAt']['timestampValue']),
                ))
          : Timestamp.now(),
    );
  }

  // Convert Variant Object to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "variantId": {"stringValue": variantId},
      "name": {"stringValue": name},
      "costPrice": {"stringValue": costPrice},
      "sellingPrice": {"integerValue": sellingPrice},
      "inventory": {"integerValue": inventory},
      "isColor": {"booleanValue": isColor},
      "discount": {"doubleValue": discount},
      "updatedAt": {"timestampValue": updatedAt},
    };
  }
}
