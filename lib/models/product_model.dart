import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/variant_model.dart';

class Product {
  String id;
  String name;
  String brand;
  String category;
  String description;
  double rating;
  int salesCount;
  int totalReviews;
  List<String> images;
  List<Variant> variants;
  bool activated;
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.rating,
    required this.salesCount,
    required this.totalReviews,
    required this.images,
    required this.variants,
    required this.activated,
    required this.createdAt,
  });

  // Convert Firestore JSON to Product Object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      salesCount: (json['salesCount'] ?? 0),
      totalReviews: (json['totalReviews'] ?? 0),
      images:
          (json['images'] != null)
              ? List<String>.from(
                json['images']['arrayValue']['values'].map(
                  (img) => img['stringValue'],
                ),
              )
              : [],
      variants:
          (json['variants'] != null)
              ? List<Variant>.from(
                json['variants']['arrayValue']['values'].map(
                  (varJson) => Variant.fromJson(varJson['mapValue']['fields']),
                ),
              )
              : [],
      activated: json['activated'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt']['timestampValue'] is Timestamp
                  ? json['createdAt']['timestampValue']
                  : Timestamp.fromDate(
                    DateTime.parse(json['createdAt']['timestampValue']),
                  ))
              : Timestamp.now(),
    );
  }

  // Convert Product Object to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "brand": brand,
      "category": category,
      "description": description,
      "rating": rating,
      "salesCount": salesCount,
      "totalReviews": totalReviews,
      "images": {
        "arrayValue": {
          "values": images.map((img) => {"stringValue": img}).toList(),
        },
      },
      "variants": {
        "arrayValue": {
          "values":
              variants
                  .map(
                    (variant) => {
                      "mapValue": {"fields": variant.toJson()},
                    },
                  )
                  .toList(),
        },
      },
      "activated": activated,
      "createdAt": {"timestampValue": createdAt},
    };
  }
}
