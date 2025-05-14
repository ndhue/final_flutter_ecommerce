import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository;
  final List<NewProduct> _products = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  // Các danh sách sản phẩm lưu cache
  List<NewProduct> _newProducts = [];
  List<NewProduct> _promotionalProducts = [];
  List<NewProduct> _bestSellers = [];

  final Map<String, List<ProductReview>> _productReviewsCache = {};
  final Map<String, DocumentSnapshot?> _lastReviewDocuments = {};
  final Map<String, int> _reviewCounts = {};

  List<NewProduct> get products => _products;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  ProductProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepository();

  // Fetch paginated products with filters & sorting
  Future<void> fetchProducts({
    String orderBy = 'sellingPrice',
    bool descending = false,
    List<String>? brand,
    List<String>? category,
    int? minPrice,
    int? maxPrice,
    bool isInitial = false,
    bool includeInactive = false, // Add this parameter
  }) async {
    if ((_isLoading || !_hasMore) && !isInitial) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (isInitial) {
        _products.clear();
        _lastDocument = null;
        _hasMore = true;
      }

      // Check if category contains "All" and set it to null to fetch all categories
      List<String>? filteredCategory = category;
      if (category != null && category.contains('All')) {
        filteredCategory = null; // Pass null to fetch all categories
      }

      final result = await _repository.fetchProducts(
        lastDocument: _lastDocument,
        limit: 10,
        orderBy: orderBy,
        descending: descending,
        brands: brand,
        categories: filteredCategory, // Use the filtered category
        minPrice: minPrice,
        maxPrice: maxPrice,
        includeInactive: includeInactive,
      );

      if (result.length < 10) {
        _hasMore = false;
      }

      if (result.isNotEmpty) {
        _lastDocument = result.last.docSnapshot;
        _products.addAll(result);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Add new product
  Future<void> addProduct(NewProduct product) async {
    debugPrint('Adding product: ${product.name}');
    await _repository.addProduct(product);
    notifyListeners();
  }

  // New Products - Cache logic
  Future<List<NewProduct>> getNewProducts({
    bool includeInactive = false,
  }) async {
    if (_newProducts.isNotEmpty) {
      // If we have cached products and don't need inactive ones, filter them
      if (!includeInactive) {
        return _newProducts.where((product) => product.activated).toList();
      }
      return _newProducts;
    }
    _newProducts = await _repository.fetchNewProducts(
      limit: 10,
      includeInactive: includeInactive,
    );
    return _newProducts;
  }

  // Promotional Products - Cache logic
  Future<List<NewProduct>> getPromotionalProducts({
    bool includeInactive = false,
  }) async {
    if (_promotionalProducts.isNotEmpty) {
      // If we have cached products and don't need inactive ones, filter them
      if (!includeInactive) {
        return _promotionalProducts
            .where((product) => product.activated)
            .toList();
      }
      return _promotionalProducts;
    }
    _promotionalProducts = await _repository.fetchPromotionalProducts(
      limit: 10,
      includeInactive: includeInactive,
    );
    return _promotionalProducts;
  }

  // Best Sellers - Cache logic
  Future<List<NewProduct>> getBestSellers({
    bool includeInactive = false,
  }) async {
    if (_bestSellers.isNotEmpty) {
      // If we have cached products and don't need inactive ones, filter them
      if (!includeInactive) {
        return _bestSellers.where((product) => product.activated).toList();
      }
      return _bestSellers;
    }
    _bestSellers = await _repository.fetchBestSellers(
      limit: 10,
      includeInactive: includeInactive,
    );
    return _bestSellers;
  }

  // Reset pagination and cache
  void resetPagination() {
    _lastDocument = null;
    _products.clear();
    _hasMore = true;
    _newProducts.clear();
    _promotionalProducts.clear();
    _bestSellers.clear();
    notifyListeners();
  }

  void resetLoadingState() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProductsByCategory({
    required String category,
    bool isInitial = false,
    bool includeInactive = false, // Add this parameter
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (isInitial) {
        _products.clear();
        _lastDocument = null;
        _hasMore = true;
      }

      final result = await _repository.fetchProductsByCategory(
        category: category,
        lastDocument: _lastDocument,
        limit: 10,
        includeInactive: includeInactive, // Pass the parameter
      );

      if (result.length < 10) {
        _hasMore = false;
      }

      if (result.isNotEmpty) {
        _lastDocument = result.last.docSnapshot;
        _products.addAll(result);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByKeyword({
    required String keyword,
    String orderBy = 'name',
    bool descending = false,
    bool isInitial = false,
    bool includeInactive = false, // Add this parameter
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (isInitial) {
        _products.clear();
        _lastDocument = null;
        _hasMore = true;
      }

      final result = await _repository.fetchProductsByKeyword(
        keyword: keyword,
        lastDocument: _lastDocument,
        limit: 10,
        orderBy: orderBy,
        descending: descending,
        includeInactive: includeInactive, // Pass the parameter
      );

      if (result.length < 10) {
        _hasMore = false;
      }

      if (result.isNotEmpty) {
        _lastDocument = result.last.docSnapshot;
        _products.addAll(result);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview({
    required String productId,
    required String username,
    String? comment,
    double? rating,
  }) async {
    try {
      await _repository.addProductReview(
        productId: productId,
        username: username,
        comment: comment,
        rating: rating,
      );
      Fluttertoast.showToast(
        msg: "Review added successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      notifyListeners();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error adding review: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      debugPrint('Error adding review: $e');
    }
  }

  Future<List<ProductReview>> fetchProductReviews({
    required String productId,
    bool isInitial = false,
  }) async {
    if (_isLoading && !isInitial) return _productReviewsCache[productId] ?? [];

    _isLoading = true;
    notifyListeners();

    try {
      if (isInitial) {
        _productReviewsCache[productId] = [];
        _lastReviewDocuments[productId] = null;
      }

      final result = await _repository.fetchProductReviews(
        productId: productId,
        lastDocument: _lastReviewDocuments[productId],
        limit: 10,
      );

      if (result.isNotEmpty) {
        _lastReviewDocuments[productId] = result.last.docSnapshot;

        // Create a new list to avoid concurrent modification
        List<ProductReview> updatedList = [];
        if (!isInitial && _productReviewsCache.containsKey(productId)) {
          updatedList = [..._productReviewsCache[productId]!];
        }
        updatedList.addAll(result);
        _productReviewsCache[productId] = updatedList;
      }

      _reviewCounts[productId] = _productReviewsCache[productId]?.length ?? 0;

      return _productReviewsCache[productId] ?? [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkForNewReviews(String productId) async {
    try {
      if (!_reviewCounts.containsKey(productId)) {
        return false;
      }

      final product = await _repository.fetchProductById(productId);
      final currentReviewCount = _reviewCounts[productId] ?? 0;

      return product.totalReviews > currentReviewCount;
    } catch (e) {
      debugPrint('Error checking for new reviews: $e');
      return false;
    }
  }

  Future<void> reloadProduct(String productId) async {
    try {
      final updatedProduct = await _repository.fetchProductById(productId);
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error reloading product: $e');
    }
  }

  Future<NewProduct> fetchProductById(String productId) async {
    try {
      return await _repository.fetchProductById(productId);
    } catch (e) {
      debugPrint('Error fetching product by ID: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(NewProduct product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({
            'name': product.name,
            'brand': product.brand,
            'category': product.category,
            'description': product.description,
            'costPrice': product.costPrice,
            'sellingPrice': product.sellingPrice,
            'discount': product.discount,
            'activated': product.activated,
          });

      // Update the product in the local list
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> updateProductStatus(String productId, bool status) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'activated': status});

      // Update the product in the local list
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = NewProduct(
          id: _products[index].id,
          name: _products[index].name,
          brand: _products[index].brand,
          category: _products[index].category,
          description: _products[index].description,
          createdAt: _products[index].createdAt,
          images: _products[index].images,
          costPrice: _products[index].costPrice,
          sellingPrice: _products[index].sellingPrice,
          discount: _products[index].discount,
          specs: _products[index].specs,
          activated: status,
          availableColors: _products[index].availableColors,
          rating: _products[index].rating,
          salesCount: _products[index].salesCount,
          totalReviews: _products[index].totalReviews,
          docSnapshot: _products[index].docSnapshot,
        );
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating product status: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // First, delete all variants in the variantInventory subcollection
      final variantSnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .collection('variantInventory')
              .get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in variantSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Then delete the product document itself
      batch.delete(
        FirebaseFirestore.instance.collection('products').doc(productId),
      );

      await batch.commit();

      // Update local list
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  // Increment the product sell count when an order is delivered
  Future<void> incrementSellCount({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      // Use repository to update in Firestore
      await _repository.incrementProductSellCount(
        productId: productId,
        quantity: quantity,
      );

      // Update in local cache if product exists
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        final product = _products[index];
        _products[index] = NewProduct(
          id: product.id,
          name: product.name,
          brand: product.brand,
          category: product.category,
          description: product.description,
          createdAt: product.createdAt,
          images: product.images,
          costPrice: product.costPrice,
          sellingPrice: product.sellingPrice,
          discount: product.discount,
          specs: product.specs,
          activated: product.activated,
          availableColors: product.availableColors,
          rating: product.rating,
          salesCount: product.salesCount + quantity,
          totalReviews: product.totalReviews,
          docSnapshot: product.docSnapshot,
        );

        // Also update in other cached lists
        _updateProductInCachedLists(productId, quantity);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error incrementing product sell count: $e');
      rethrow;
    }
  }

  // Helper method to update product in cached lists
  void _updateProductInCachedLists(String productId, int quantityToAdd) {
    // Update in new products list if exists
    final newProductIndex = _newProducts.indexWhere((p) => p.id == productId);
    if (newProductIndex != -1) {
      final product = _newProducts[newProductIndex];
      _newProducts[newProductIndex] = NewProduct(
        id: product.id,
        name: product.name,
        brand: product.brand,
        category: product.category,
        description: product.description,
        createdAt: product.createdAt,
        images: product.images,
        costPrice: product.costPrice,
        sellingPrice: product.sellingPrice,
        discount: product.discount,
        specs: product.specs,
        activated: product.activated,
        availableColors: product.availableColors,
        rating: product.rating,
        salesCount: product.salesCount + quantityToAdd,
        totalReviews: product.totalReviews,
        docSnapshot: product.docSnapshot,
      );
    }

    // Update in promotional products list if exists
    final promoIndex = _promotionalProducts.indexWhere(
      (p) => p.id == productId,
    );
    if (promoIndex != -1) {
      final product = _promotionalProducts[promoIndex];
      _promotionalProducts[promoIndex] = NewProduct(
        id: product.id,
        name: product.name,
        brand: product.brand,
        category: product.category,
        description: product.description,
        createdAt: product.createdAt,
        images: product.images,
        costPrice: product.costPrice,
        sellingPrice: product.sellingPrice,
        discount: product.discount,
        specs: product.specs,
        activated: product.activated,
        availableColors: product.availableColors,
        rating: product.rating,
        salesCount: product.salesCount + quantityToAdd,
        totalReviews: product.totalReviews,
        docSnapshot: product.docSnapshot,
      );
    }

    // Update in best sellers list if exists
    final bestSellerIndex = _bestSellers.indexWhere((p) => p.id == productId);
    if (bestSellerIndex != -1) {
      final product = _bestSellers[bestSellerIndex];
      _bestSellers[bestSellerIndex] = NewProduct(
        id: product.id,
        name: product.name,
        brand: product.brand,
        category: product.category,
        description: product.description,
        createdAt: product.createdAt,
        images: product.images,
        costPrice: product.costPrice,
        sellingPrice: product.sellingPrice,
        discount: product.discount,
        specs: product.specs,
        activated: product.activated,
        availableColors: product.availableColors,
        rating: product.rating,
        salesCount: product.salesCount + quantityToAdd,
        totalReviews: product.totalReviews,
        docSnapshot: product.docSnapshot,
      );
    }
  }
}
