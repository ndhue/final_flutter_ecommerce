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

      final result = await _repository.fetchProducts(
        lastDocument: _lastDocument,
        limit: 10,
        orderBy: orderBy,
        descending: descending,
        brands: brand,
        categories: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
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
    await _repository.addProduct(product);
    notifyListeners();
  }

  // New Products - Cache logic
  Future<List<NewProduct>> getNewProducts() async {
    if (_newProducts.isNotEmpty) {
      return _newProducts;
    }
    _newProducts = await _repository.fetchNewProducts(limit: 10);
    return _newProducts;
  }

  // Promotional Products - Cache logic
  Future<List<NewProduct>> getPromotionalProducts() async {
    if (_promotionalProducts.isNotEmpty) {
      return _promotionalProducts;
    }
    _promotionalProducts = await _repository.fetchPromotionalProducts(
      limit: 10,
    );
    return _promotionalProducts;
  }

  // Best Sellers - Cache logic
  Future<List<NewProduct>> getBestSellers() async {
    if (_bestSellers.isNotEmpty) {
      return _bestSellers;
    }
    _bestSellers = await _repository.fetchBestSellers(limit: 10);
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
    if (_isLoading) return [];

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
        _productReviewsCache[productId]?.addAll(result);
      }

      return _productReviewsCache[productId] ?? [];
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
