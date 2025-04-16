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

  factory NewProduct.fromMap(dynamic source) {
    if (source is DocumentSnapshot) {
      final data = source.data() as Map<String, dynamic>;
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
        createdAt:
            data['createdAt'] is Timestamp
                ? data['createdAt'] as Timestamp
                : Timestamp.fromDate(DateTime.parse(data['createdAt'])),
        images: List<String>.from(data['images'] ?? []),
        costPrice: (data['costPrice'] ?? 0).toDouble(),
        sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
        discount: (data['discount'] ?? 0).toDouble(),
        specs: Map<String, dynamic>.from(data['specs'] ?? {}),
        availableColors: List<String>.from(data['availableColors'] ?? []),
        docSnapshot: source,
      );
    } else if (source is Map<String, dynamic>) {
      return NewProduct(
        id: source['id'],
        name: source['name'],
        brand: source['brand'],
        category: source['category'],
        description: source['description'],
        rating: (source['rating'] ?? 0).toDouble(),
        salesCount: source['salesCount'] ?? 0,
        totalReviews: source['totalReviews'] ?? 0,
        activated: source['activated'] ?? true,
        createdAt:
            source['createdAt'] is Timestamp
                ? source['createdAt'] as Timestamp
                : Timestamp.fromDate(DateTime.parse(source['createdAt'])),
        images: List<String>.from(source['images'] ?? []),
        costPrice: (source['costPrice'] ?? 0).toDouble(),
        sellingPrice: (source['sellingPrice'] ?? 0).toDouble(),
        discount: (source['discount'] ?? 0).toDouble(),
        specs: Map<String, dynamic>.from(source['specs'] ?? {}),
        availableColors: List<String>.from(source['availableColors'] ?? []),
        docSnapshot: null,
      );
    } else {
      throw TypeError();
    }
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
      'createdAt':
          createdAt
              .toDate()
              .toIso8601String(), // Convert Timestamp to ISO8601 string
      'images': images,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'discount': discount,
      'specs': specs,
      'availableColors': availableColors,
    };
  }
}

class ProductReview {
  final String username;
  final double? rating;
  final String comment;
  final Timestamp createdAt;
  final DocumentSnapshot? docSnapshot; // Added docSnapshot field

  ProductReview({
    required this.username,
    this.rating,
    required this.comment,
    required this.createdAt,
    this.docSnapshot, // Initialize docSnapshot
  });

  factory ProductReview.fromMap(
    Map<String, dynamic> json, {
    DocumentSnapshot? snapshot,
  }) {
    return ProductReview(
      username: json['username'],
      rating: json['rating']?.toDouble(),
      comment: json['comment'],
      createdAt:
          json['createdAt'] is Timestamp
              ? json['createdAt'] as Timestamp
              : Timestamp.fromDate(DateTime.parse(json['createdAt'])),
      docSnapshot: snapshot, // Assign snapshot
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      if (rating != null) 'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toDate().toIso8601String(),
    };
  }
}
