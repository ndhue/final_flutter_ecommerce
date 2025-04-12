import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:flutter/material.dart';

import '../repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository;
  final List<NewProduct> _products = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  List<NewProduct> get products => _products;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  ProductProvider({ProductRepository? repository})
    : _repository = repository ?? ProductRepository();

  // Fetch paginated products with filters & sorting
  Future<void> fetchProducts({
    String? orderBy,
    bool descending = false,
    String? brand,
    String? category,
    int? minPrice,
    int? maxPrice,
    bool isInitial = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

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
      brand: brand,
      category: category,
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

    _isLoading = false;
    notifyListeners();
  }

  // New Products
  Future<List<NewProduct>> getNewProducts() {
    return _repository.fetchNewProducts(limit: 10);
  }

  // Promotional Products
  Future<List<NewProduct>> getPromotionalProducts() {
    return _repository.fetchPromotionalProducts(limit: 10);
  }

  // Best Sellers
  Future<List<NewProduct>> getBestSellers() {
    return _repository.fetchBestSellers(limit: 10);
  }

  void resetPagination() {
    _lastDocument = null;
    _products.clear();
    _hasMore = true;
    notifyListeners();
  }

  Future<void> fetchProductsByCategory({
    required String category,
    bool isInitial = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

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

    _isLoading = false;
    notifyListeners();
  }
}
