import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/variant_model.dart';

/// **Mô hình CartItem**
class CartItem {
  final Product product;
  final Variant variant;
  int quantity;

  CartItem({required this.product, required this.variant, this.quantity = 1});

  String get imageUrl => product.images.isNotEmpty ? product.images.first : '';
  double get price => variant.currentPrice.toDouble();

  /// ✅ Mã định danh duy nhất cho mỗi CartItem (bao gồm màu + size nếu có)
  String get cartKey {
    final colorHex =
        variant.isColor ? variant.color?.value.toRadixString(16) ?? '' : '';
    final size = variant.isSize ? variant.size ?? '' : '';
    return '${product.id}_${variant.variantId}_${colorHex}_$size';
  }
}

/// **Provider quản lý giỏ hàng**
class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  final Set<String> _selectedKeys = {}; // Chứa cartKey

  String _city = "Hồ Chí Minh";
  String _district = "Quận 1";
  String _ward = "Phường Bến Nghé";
  String _address = "";
  String _receiverName = "";
  String _phoneNumber = "";

  List<CartItem> get cartItems => _cartItems;
  Set<CartItem> get selectedItems =>
      _cartItems.where((item) => _selectedKeys.contains(item.cartKey)).toSet();

  String get city => _city;
  String get district => _district;
  String get ward => _ward;
  String get address => _address;
  String get receiverName => _receiverName;
  String get phoneNumber => _phoneNumber;

  void updateAddress(
    String city,
    String district,
    String ward,
    String address,
    String receiverName,
    String phoneNumber,
  ) {
    _city = city;
    _district = district;
    _ward = ward;
    _address = address.isNotEmpty ? address : "Chưa nhập địa chỉ";
    _receiverName = receiverName;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  double get totalPrice => _cartItems.fold(
    0.0,
    (total, item) => total + (item.price * item.quantity),
  );

  double get selectedTotalPrice => selectedItems.fold(
    0.0,
    (total, item) => total + (item.price * item.quantity),
  );

  String _buildCartKey(Product product, Variant variant) {
    final colorHex =
        variant.isColor ? variant.color?.value.toRadixString(16) ?? '' : '';
    final size = variant.isSize ? variant.size ?? '' : '';
    return '${product.id}_${variant.variantId}_${colorHex}_$size';
  }

  void addToCart(Product product, Variant variant) {
    final key = _buildCartKey(product, variant);
    final index = _cartItems.indexWhere((item) => item.cartKey == key);

    if (index != -1) {
      _cartItems[index].quantity += 1;
    } else {
      _cartItems.add(CartItem(product: product, variant: variant));
    }
    notifyListeners();
  }

  void removeFromCart(Product product, Variant variant) {
    final key = _buildCartKey(product, variant);
    _cartItems.removeWhere((item) => item.cartKey == key);
    _selectedKeys.remove(key);
    notifyListeners();
  }

  void increaseQuantity(Product product, Variant variant) {
    final key = _buildCartKey(product, variant);
    final index = _cartItems.indexWhere((item) => item.cartKey == key);
    if (index != -1) {
      _cartItems[index].quantity += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(Product product, Variant variant) {
    final key = _buildCartKey(product, variant);
    final index = _cartItems.indexWhere((item) => item.cartKey == key);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity -= 1;
      } else {
        _cartItems.removeAt(index);
        _selectedKeys.remove(key);
      }
      notifyListeners();
    }
  }

  void toggleSelection(Product product, Variant variant) {
    final key = _buildCartKey(product, variant);
    if (_selectedKeys.contains(key)) {
      _selectedKeys.remove(key);
    } else {
      _selectedKeys.add(key);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _selectedKeys.clear();
    notifyListeners();
  }

  void selectAll() {
    _selectedKeys.clear();
    _selectedKeys.addAll(_cartItems.map((item) => item.cartKey));
    notifyListeners();
  }

  void deselectAll() {
    _selectedKeys.clear();
    notifyListeners();
  }
}
