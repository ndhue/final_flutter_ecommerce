import 'package:cloud_firestore/cloud_firestore.dart';

class NewProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double rating;
  final int salesCount;
  final int totalReviews;
  final bool activated;
  final Timestamp createdAt;
  final List<String> images;
  final double costPrice;
  final double sellingPrice;
  final double discount; // Discount percentage (0.0 to 1.0)
  final List<String> availableColors;
  final DocumentSnapshot? docSnapshot;
  // New specs field
  final Map<String, dynamic> specs;

  NewProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    this.rating = 0,
    this.salesCount = 0,
    this.totalReviews = 0,
    this.activated = true,
    required this.createdAt,
    required this.images,
    required this.costPrice,
    required this.sellingPrice,
    this.discount = 0.0,
    required this.specs,
    this.availableColors = const [],
    this.docSnapshot,
  });

  factory NewProduct.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewProduct(
      id: data['id'],
      name: data['name'],
      brand: data['brand'],
      category: data['category'],
      description: data['description'],
      rating: (data['rating'] ?? 0).toDouble(),
      salesCount: data['salesCount'] ?? 0,
      totalReviews: data['totalReviews'] ?? 0,
      activated: data['activated'] ?? true,
      createdAt: data['createdAt'],
      images: List<String>.from(data['images'] ?? []),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      specs: Map<String, dynamic>.from(data['specs'] ?? {}),
      availableColors: List<String>.from(data['availableColors'] ?? []),
      docSnapshot: doc,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'description': description,
      'rating': rating,
      'salesCount': salesCount,
      'totalReviews': totalReviews,
      'activated': activated,
      'createdAt': createdAt,
      'images': images,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'discount': discount,
      'specs': specs,
      'availableColors': availableColors,
    };
  }
}
