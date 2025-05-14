import 'dart:convert';

import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/repositories/variant_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  // Change from Set<String> to store composite keys (productId:variantId)
  Set<String> _selectedItemIds = {};
  String _userId = 'guest';
  AddressInfo? _addressInfo;
  final String _guestCartKey = 'cart_guest';
  bool get isGuestUser => _userId == 'guest';

  // Store guest address info separately
  Map<String, dynamic>? _guestCheckoutInfo;
  Map<String, dynamic>? get guestCheckoutInfo => _guestCheckoutInfo;

  CartProvider() {
    loadCart();
  }

  List<CartItem> get cartItems => _cartItems;
  Set<String> get selectedItemIds => _selectedItemIds;
  AddressInfo? get addressInfo => _addressInfo;

  // Helper method to create a composite key
  String _getItemKey(String productId, String variantId) {
    return "$productId:$variantId";
  }

  void updateAddress(AddressInfo info) {
    _addressInfo = info;
    notifyListeners();
  }

  void loadUserAddress(UserModel? user) {
    if (user != null) {
      _addressInfo = AddressInfo(
        city: user.city,
        district: user.district,
        ward: user.ward,
        detailedAddress: user.shippingAddress,
        receiverName: user.fullName,
      );
    } else {
      _addressInfo = null;
    }
    notifyListeners();
  }

  // Save guest cart before switching to logged-in user
  Future<void> _saveGuestCart() async {
    final prefs = await SharedPreferences.getInstance();
    final guestCartJson = jsonEncode(_cartItems.map((e) => e.toMap()).toList());
    await prefs.setString(_guestCartKey, guestCartJson);
  }

  // Load guest cart when logging out
  Future<void> _loadGuestCart() async {
    final prefs = await SharedPreferences.getInstance();
    final guestCartJson = prefs.getString(_guestCartKey);

    if (guestCartJson != null) {
      final List decoded = jsonDecode(guestCartJson);
      _cartItems = decoded.map((e) => CartItem.fromMap(e)).toList();
    } else {
      _cartItems = [];
    }

    notifyListeners();
  }

  void setUser(String? userId) {
    if (_userId == 'guest' && userId != null) {
      _saveGuestCart();
    }

    _userId = userId ?? 'guest';

    if (_userId == 'guest') {
      _loadGuestCart();
    } else {
      loadCart();
    }
  }

  // Save guest checkout information
  void saveGuestCheckoutInfo(Map<String, dynamic> info) {
    _guestCheckoutInfo = info;
    notifyListeners();
  }

  // Convert guest cart to user cart on login/registration
  Future<void> convertGuestCartToUser(String userId) async {
    if (_userId == 'guest') {
      final prefs = await SharedPreferences.getInstance();
      final guestCartJson = prefs.getString(_guestCartKey);

      if (guestCartJson != null) {
        // Save current guest cart to the user's cart key
        await prefs.setString('cart_$userId', guestCartJson);

        // Clear guest cart
        await prefs.remove(_guestCartKey);
      }

      _userId = userId;
      loadCart(); // Load the newly associated cart
    }
  }

  // Prepare guest checkout with user information
  Future<void> prepareGuestCheckout(Map<String, dynamic> userInfo) async {
    _guestCheckoutInfo = userInfo;

    if (userInfo.containsKey('address')) {
      final addressData = userInfo['address'] as Map<String, dynamic>;
      updateAddress(
        AddressInfo(
          city: addressData['city'] ?? '',
          district: addressData['district'] ?? '',
          ward: addressData['ward'] ?? '',
          detailedAddress: addressData['detailedAddress'] ?? '',
          receiverName: userInfo['fullName'] ?? '',
        ),
      );
    }

    notifyListeners();
  }

  void toggleItemSelection(String productId, String variantId) {
    final itemKey = _getItemKey(productId, variantId);

    if (_selectedItemIds.contains(itemKey)) {
      _selectedItemIds.remove(itemKey);
    } else {
      _selectedItemIds.add(itemKey);
    }
    notifyListeners();
  }

  void toggleSelectAll(bool selectAll) {
    if (selectAll) {
      _selectedItemIds =
          _cartItems
              .map(
                (item) => _getItemKey(item.product.id, item.variant.variantId),
              )
              .toSet();
    } else {
      _selectedItemIds.clear();
    }
    notifyListeners();
  }

  bool isAllSelected() =>
      _cartItems.isNotEmpty &&
      _cartItems.every(
        (item) => _selectedItemIds.contains(
          _getItemKey(item.product.id, item.variant.variantId),
        ),
      );

  bool isSelected(String productId, String variantId) =>
      _selectedItemIds.contains(_getItemKey(productId, variantId));

  Future<void> addToCart(CartItem newItem) async {
    final index = _cartItems.indexWhere(
      (item) =>
          item.product.id == newItem.product.id &&
          item.variant.variantId == newItem.variant.variantId,
    );

    if (index >= 0) {
      _cartItems[index].quantity += newItem.quantity;
    } else {
      _cartItems.insert(0, newItem);
    }

    await saveCart();
    notifyListeners();
  }

  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_cartItems.map((e) => e.toMap()).toList());
      await prefs.setString('cart_$_userId', cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart_$_userId');

    if (cartJson != null) {
      final List decoded = jsonDecode(cartJson);
      _cartItems = decoded.map((e) => CartItem.fromMap(e)).toList();
    } else {
      _cartItems = [];
    }

    notifyListeners();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_$_userId');
    notifyListeners();
  }

  Future<void> clearSelection() async {
    // Use the composite keys to identify items to remove
    final itemsToRemove =
        _cartItems
            .where(
              (item) => _selectedItemIds.contains(
                _getItemKey(item.product.id, item.variant.variantId),
              ),
            )
            .toList();

    for (var item in itemsToRemove) {
      _cartItems.remove(item);
    }

    _selectedItemIds.clear();
    await saveCart(); // Use await to ensure completion
    notifyListeners();
  }

  Future<void> removeItem(String productId, String variantId) async {
    final itemKey = _getItemKey(productId, variantId);
    _selectedItemIds.remove(itemKey);

    _cartItems.removeWhere(
      (item) =>
          item.product.id == productId && item.variant.variantId == variantId,
    );

    await saveCart();

    notifyListeners();
  }

  double get totalAmount {
    return _cartItems
        .where(
          (item) => _selectedItemIds.contains(
            _getItemKey(item.product.id, item.variant.variantId),
          ),
        )
        .fold(
          0,
          (sum, item) =>
              sum +
              item.product.price * (1 - item.product.discount) * item.quantity,
        );
  }

  void updateItemQuantity(String productId, String variantId, int newQuantity) {
    final index = _cartItems.indexWhere(
      (item) =>
          item.product.id == productId && item.variant.variantId == variantId,
    );

    if (index != -1) {
      _cartItems[index].quantity = newQuantity;
      saveCart(); 
      notifyListeners();
    }
  }

  Future<void> updateProductVariantInventory() async {
    final variantRepository = VariantRepository();

    try {
      for (final cartItem in _cartItems) {
        await variantRepository.updateVariantInventory(
          productId: cartItem.product.id,
          variantId: cartItem.variant.variantId,
          quantityChange: -cartItem.quantity,
        );
      }
    } catch (e) {
      debugPrint('Error updating product variant inventory: $e');
    }
  }

  Future<void> removePurchasedItems(List<CartItem> purchasedItems) async {
    _cartItems.removeWhere(
      (cartItem) => purchasedItems.any(
        (purchasedItem) =>
            purchasedItem.product.id == cartItem.product.id &&
            purchasedItem.variant.variantId == cartItem.variant.variantId,
      ),
    );
    await saveCart();
    notifyListeners();
  }
}
