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
    String? orderBy,
    bool descending = false,
    String? brand,
    String? category,
    int? minPrice,
    int? maxPrice,
  }) async {
    Query query = _products;

    if (brand != null) query = query.where('brand', isEqualTo: brand);
    if (category != null) {
      switch (category) {
        case 'All':
          // No filter
          break;
        case 'Best Sellers':
          debugPrint('Best Sellers');
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
    }
    if (minPrice != null) {
      query = query.where('sellingPrice', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('sellingPrice', isLessThanOrEqualTo: maxPrice);
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => NewProduct.fromMap(doc)).toList();
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
          debugPrint('Best Sellers');
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
