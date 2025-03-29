import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Variant {
  String variantId;
  String name;
  int costPrice;
  int sellingPrice;
  double discount; // Discount percentage (0.0 to 1.0)
  int inventory;
  bool isColor;
  Color? color;
  String? imageUrl;
  bool isSize;
  String? size;
  DateTime updatedAt;

  Variant({
    required this.variantId,
    required this.name,
    required this.costPrice,
    required this.sellingPrice,
    this.discount = 0.0,
    required this.inventory,
    required this.isColor,
    this.color,
    this.imageUrl,
    this.isSize = false,
    this.size,
    required this.updatedAt,
  });

  // Get the current price (discounted or regular)
  int get currentPrice =>
      (discount > 0 && discount < 1)
          ? (sellingPrice * (1 - discount)).round()
          : sellingPrice;

  // Convert Firestore JSON to Variant Object
  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      variantId: json['variantId']?['stringValue'] ?? '',
      name: json['name']?['stringValue'] ?? '',
      costPrice:
          int.tryParse(json['costPrice']?['integerValue']?.toString() ?? '0') ??
          0,
      sellingPrice:
          int.tryParse(
            json['sellingPrice']?['integerValue']?.toString() ?? '0',
          ) ??
          0,
      discount: json['discount']?['doubleValue']?.toDouble() ?? 0.0,
      inventory:
          int.tryParse(json['inventory']?['integerValue']?.toString() ?? '0') ??
          0,
      isColor: json['isColor']?['booleanValue'] ?? false,
      isSize: json['isSize']?['booleanValue'] ?? false,
      size: json['size']?['stringValue'],
      updatedAt:
          json['updatedAt']?['timestampValue'] != null
              ? DateTime.tryParse(json['updatedAt']['timestampValue']) ??
                  DateTime.now()
              : DateTime.now(),
      color:
          json['color']?['stringValue'] != null
              ? Color(
                int.tryParse(json['color']['stringValue'], radix: 16) ??
                    0xFF000000,
              )
              : null,
      imageUrl: json['imageUrl']?['stringValue'] ?? '',
    );
  }

  // Convert Variant Object to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "variantId": {"stringValue": variantId},
      "name": {"stringValue": name},
      "costPrice": {"integerValue": costPrice},
      "sellingPrice": {"integerValue": sellingPrice},
      "discount": {"doubleValue": discount},
      "inventory": {"integerValue": inventory},
      "isColor": {"booleanValue": isColor},
      "isSize": {"booleanValue": isSize},
      "size": size != null ? {"stringValue": size} : null,
      "updatedAt": {"timestampValue": updatedAt.toIso8601String()},
      "color":
          color != null
              ? {"stringValue": color!.value.toRadixString(16)}
              : null,
      "imageUrl": imageUrl != null ? {"stringValue": imageUrl} : null,
    };
  }
}
