import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final int defaultLimit = 10;

  CollectionReference get _products => _firestore.collection('products');

  // Fetch Products with Filtering, Sorting & Pagination
  Future<List<NewProduct>> fetchProducts({
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String orderBy = 'sellingPrice', // default để dùng pagination an toàn
    bool descending = false,
    List<String>? brands,
    List<String>? categories,
    int? minPrice,
    int? maxPrice,
  }) async {
    Query query = _products;

    // Filter brands
    if (brands != null && brands.isNotEmpty) {
      query = query.where('brand', whereIn: brands);
    }

    // Filter categories
    if (categories != null && categories.isNotEmpty) {
      List<String> specialCategories = [
        'Best Sellers',
        'Promotional',
        'New Products',
      ];
      List<String> normalCategories =
          categories.where((c) => !specialCategories.contains(c)).toList();

      bool hasBestSellers = categories.contains('Best Sellers');
      bool hasPromotional = categories.contains('Promotional');
      bool hasNewProducts = categories.contains('New Products');

      // Nếu có category thường, filter theo category
      if (normalCategories.isNotEmpty) {
        query = query.where('category', whereIn: normalCategories);
      }

      // Nếu có Best Sellers, orderBy soldCount
      if (hasBestSellers) {
        query = query.orderBy('soldCount', descending: true);
      }

      // Nếu có Promotional, filter discount > 0
      if (hasPromotional) {
        query = query.where('discount', isGreaterThan: 0);
      }

      // Nếu có New Products, orderBy createdAt
      if (hasNewProducts) {
        query = query.orderBy('createdAt', descending: true);
      }
    }

    // Filter price range
    if (minPrice != null) {
      query = query.where('sellingPrice', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('sellingPrice', isLessThanOrEqualTo: maxPrice);
    }

    // Sort — bắt buộc orderBy trước khi phân trang
    if (orderBy == 'sellingPrice') {
      query = query.orderBy('sellingPrice', descending: descending);
    }

    if (orderBy == 'name') {
      query = query.orderBy('name', descending: descending);
    }

    // Pagination
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    // Lấy dữ liệu
    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => NewProduct.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Fetch New Products (sorted by createdAt)
  Future<List<NewProduct>> fetchNewProducts({int limit = 10}) async {
    final snapshot =
        await _products
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();

    return snapshot.docs.map((doc) => NewProduct.fromMap(doc)).toList();
  }

  // Fetch Promotional Products (has discount)
  Future<List<NewProduct>> fetchPromotionalProducts({int limit = 10}) async {
    final snapshot =
        await _products
            .where('discount', isGreaterThan: 0)
            .orderBy('discount', descending: true)
            .limit(limit)
            .get();

    return snapshot.docs.map((doc) => NewProduct.fromMap(doc)).toList();
  }

  // Fetch Best Seller Products (sorted by soldCount)
  Future<List<NewProduct>> fetchBestSellers({int limit = 10}) async {
    final snapshot =
        await _products
            .orderBy('soldCount', descending: true)
            .limit(limit)
            .get();

    return snapshot.docs.map((doc) => NewProduct.fromMap(doc)).toList();
  }

  Future<List<NewProduct>> fetchProductsByCategory({
    required String category,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      Query query = _products;

      switch (category) {
        case 'All':
          // No filter
          break;
        case 'Best Sellers':
          query = query.orderBy('soldCount', descending: true);
          break;
        case 'Promotional':
          query = query
              .where('discount', isGreaterThan: 0)
              .orderBy('discount', descending: true);
          break;
        case 'New Products':
          query = query.orderBy('createdAt', descending: true);
          break;
        default:
          query = query.where('category', isEqualTo: category);
      }
      query.limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => NewProduct.fromMap(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return [];
    }
  }
}
