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
  final DateTime createdAt;
  final List<String> images;
  final double costPrice;
  final double sellingPrice;
  final List<String> availableColors;

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
    required this.specs,
    this.availableColors = const [],
  });

  factory NewProduct.fromMap(Map<String, dynamic> map) {
    return NewProduct(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      category: map['category'],
      description: map['description'],
      rating: map['rating'].toDouble(),
      salesCount: map['salesCount'],
      totalReviews: map['totalReviews'],
      activated: map['activated'],
      createdAt: DateTime.parse(map['createdAt']),
      images: List<String>.from(map['images']),
      costPrice: map['costPrice'].toDouble(),
      sellingPrice: map['sellingPrice'].toDouble(),
      specs: Map<String, dynamic>.from(map['specs'] ?? {}),
      availableColors: List<String>.from(map['availableColors'] ?? []),
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
      'createdAt': createdAt.toIso8601String(),
      'images': images,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'specs': specs,
      'availableColors': availableColors,
    };
  }
}
