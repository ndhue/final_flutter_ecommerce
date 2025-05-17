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
    String orderBy = 'sellingPrice',
    bool descending = false,
    List<String>? brands,
    List<String>? categories,
    int? minPrice,
    int? maxPrice,
    bool includeInactive = false,
    bool? activationStatus,
  }) async {
    Query query = _products;

    if (activationStatus != null) {
      query = query.where('activated', isEqualTo: activationStatus);
    } else if (!includeInactive) {
      query = query.where('activated', isEqualTo: true);
    }

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

      if (normalCategories.isNotEmpty) {
        query = query.where('category', whereIn: normalCategories);
      }

      if (hasBestSellers) {
        query = query.orderBy('salesCount', descending: true);
      }

      if (hasPromotional) {
        query = query.where('discount', isGreaterThan: 0);
      }

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
  Future<List<NewProduct>> fetchNewProducts({
    int limit = 10,
    bool includeInactive = false,
  }) async {
    Query query = _products.orderBy('createdAt', descending: true);

    final snapshot = await query.limit(limit).get();

    return snapshot.docs.map((doc) => NewProduct.fromMap(doc)).toList();
  }

  //Add new product
  Future<void> addProduct(NewProduct product) async {
    try {
      await _products.doc(product.id).set(product.toMap());
    } catch (e) {
      debugPrint('Error adding product: $e');
    }
  }

  // Fetch Promotional Products (has discount)
  Future<List<NewProduct>> fetchPromotionalProducts({
    int limit = 10,
    bool includeInactive = false,
  }) async {
    Query query = _products
        .where('discount', isGreaterThan: 0)
        .orderBy('discount', descending: true);

    final snapshot = await query.limit(limit).get();

    return snapshot.docs.map((doc) => NewProduct.fromMap(doc)).toList();
  }

  // Fetch Best Seller Products (sorted by soldCount)
  Future<List<NewProduct>> fetchBestSellers({
    int limit = 10,
    bool includeInactive = false,
  }) async {
    Query query = _products.orderBy('salesCount', descending: true);

    final snapshot = await query.limit(limit).get();

    return snapshot.docs.map((doc) => NewProduct.fromMap(doc)).toList();
  }

  Future<List<NewProduct>> fetchProductsByCategory({
    required String category,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    bool includeInactive = false,
  }) async {
    try {
      Query query = _products;

      // Filter out inactive products by default
      if (!includeInactive) {
        query = query.where('activated', isEqualTo: true);
      }

      switch (category) {
        case 'All':
          // No filter
          break;
        case 'Best Sellers':
          query = query.orderBy('salesCount', descending: true);
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

  Future<void> addProductReview({
    required String productId,
    required String username,
    String? comment,
    double? rating,
  }) async {
    try {
      final review = {
        'username': username,
        'rating': rating,
        'comment': comment ?? '',
        'createdAt': Timestamp.now(),
      };

      await _products.doc(productId).collection('reviews').add(review);

      if (rating != null) {
        final productSnapshot = await _products.doc(productId).get();
        final productData = productSnapshot.data() as Map<String, dynamic>;

        final currentTotalReviews = (productData['totalReviews'] ?? 0) as int;

        final currentRatingRaw = productData['rating'] ?? 0;
        final currentRating =
            (currentRatingRaw is int)
                ? currentRatingRaw.toDouble()
                : (currentRatingRaw as double);

        final newTotalReviews = currentTotalReviews + 1;
        final newRating =
            ((currentRating * currentTotalReviews) + rating) / newTotalReviews;

        final roundedNewRating = double.parse(newRating.toStringAsFixed(1));

        await _products.doc(productId).update({
          'totalReviews': newTotalReviews,
          'rating': roundedNewRating,
        });
      } else {
        await _products.doc(productId).update({
          'totalReviews': FieldValue.increment(1),
        });
      }
    } catch (e) {
      debugPrint('Error adding product review: $e');
      rethrow;
    }
  }

  Future<List<ProductReview>> fetchProductReviews({
    required String productId,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      Query query = _products
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      final allDocs = snapshot.docs;

      // Nếu offset vượt quá số lượng reviews, trả về mảng rỗng
      if (offset >= allDocs.length) {
        return [];
      }

      // Cắt mảng theo offset và limit
      final paginatedDocs = allDocs.skip(offset).take(limit).toList();

      return paginatedDocs
          .map(
            (doc) => ProductReview.fromMap(
              doc.data() as Map<String, dynamic>,
              snapshot: doc,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching product reviews: $e');
      return [];
    }
  }

  Future<NewProduct> fetchProductById(String productId) async {
    try {
      final doc = await _products.doc(productId).get();
      if (doc.exists) {
        return NewProduct.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      debugPrint('Error fetching product by ID: $e');
      rethrow;
    }
  }

  Future<List<NewProduct>> fetchProductsByKeyword({
    required String keyword,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String orderBy = 'name',
    bool descending = false,
    bool includeInactive = false,
  }) async {
    try {
      // For keyword search, we need a different approach because of the compound query limitation
      // Firestore doesn't allow inequality filters on different fields in a compound query

      // First get all products matching the name pattern
      Query query = _products
          .orderBy('name', descending: descending)
          .where('name', isGreaterThanOrEqualTo: keyword)
          .where('name', isLessThanOrEqualTo: '$keyword\uf8ff');

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot =
          await query
              .limit(includeInactive ? limit : limit * 2)
              .get(); // Fetch more to account for filtering

      // Then filter out inactive products in the application
      List<NewProduct> products =
          snapshot.docs
              .map(
                (doc) => NewProduct.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      if (!includeInactive) {
        products = products.where((product) => product.activated).toList();
      }

      // Limit the results after filtering
      return products.take(limit).toList();
    } catch (e) {
      debugPrint('Error fetching products by keyword: $e');
      return [];
    }
  }

  // Increment product's salesCount when an order is delivered
  Future<void> incrementProductSellCount({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      // Use a transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        final docRef = _products.doc(productId);
        final snapshot = await transaction.get(docRef);

        if (snapshot.exists) {
          final currentSales =
              (snapshot.data() as Map<String, dynamic>)['salesCount'] ?? 0;
          transaction.update(docRef, {'salesCount': currentSales + quantity});
        }
      });
    } catch (e) {
      debugPrint('Error incrementing product sell count: $e');
      rethrow;
    }
  }

  Future<List<NewProduct>> fetchProductsPaginated({
    int offset = 0,
    int limit = 10,
    String orderBy = 'sellingPrice',
    bool descending = false,
    List<String>? brands,
    List<String>? categories,
    int? minPrice,
    int? maxPrice,
    bool includeInactive = false,
    bool? activationStatus,
  }) async {
    try {
      Query query = _products;

      if (activationStatus != null) {
        query = query.where('activated', isEqualTo: activationStatus);
      } else if (!includeInactive) {
        query = query.where('activated', isEqualTo: true);
      }

      if (brands != null && brands.isNotEmpty) {
        query = query.where('brand', whereIn: brands);
      }

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

        if (normalCategories.isNotEmpty) {
          query = query.where('category', whereIn: normalCategories);
        }

        if (hasBestSellers) {
          query = query.orderBy('salesCount', descending: true);
        }

        if (hasPromotional) {
          query = query.where('discount', isGreaterThan: 0);
        }

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

      // Sort
      if (orderBy == 'sellingPrice') {
        query = query.orderBy('sellingPrice', descending: descending);
      }

      if (orderBy == 'name') {
        query = query.orderBy('name', descending: descending);
      }

  
      final snapshot = await query.get();

      final allDocs = snapshot.docs;

      if (offset >= allDocs.length) {
        return [];
      }

      final paginatedDocs = allDocs.skip(offset).take(limit).toList();

      return paginatedDocs
          .map((doc) => NewProduct.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching products paginated: $e');
      return [];
    }
  }

  Future<List<NewProduct>> fetchProductsByCategoryPaginated({
    required String category,
    int offset = 0,
    int limit = 10,
    bool includeInactive = false,
  }) async {
    try {
      Query query = _products;

      // Filter out inactive products by default
      if (!includeInactive) {
        query = query.where('activated', isEqualTo: true);
      }

      switch (category) {
        case 'All':
          // No filter
          break;
        case 'Best Sellers':
          query = query.orderBy('salesCount', descending: true);
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

      final snapshot = await query.get();
      final allDocs = snapshot.docs;

      if (offset >= allDocs.length) {
        return [];
      }

      final paginatedDocs = allDocs.skip(offset).take(limit).toList();

      return paginatedDocs.map((doc) => NewProduct.fromMap(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching products by category paginated: $e');
      return [];
    }
  }

  Future<List<NewProduct>> fetchProductsByKeywordPaginated({
    required String keyword,
    int offset = 0,
    int limit = 10,
    String orderBy = 'name',
    bool descending = false,
    bool includeInactive = false,
  }) async {
    try {
      // First get all products matching the name pattern
      Query query = _products
          .orderBy('name', descending: descending)
          .where('name', isGreaterThanOrEqualTo: keyword)
          .where('name', isLessThanOrEqualTo: '$keyword\uf8ff');

      final snapshot = await query.get();

      // Then filter out inactive products in the application
      List<NewProduct> products =
          snapshot.docs
              .map(
                (doc) => NewProduct.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      if (!includeInactive) {
        products = products.where((product) => product.activated).toList();
      }

      // Phân trang sau khi lọc
      if (offset >= products.length) {
        return [];
      }

      return products.skip(offset).take(limit).toList();
    } catch (e) {
      debugPrint('Error fetching products by keyword paginated: $e');
      return [];
    }
  }
}
