import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  final Set<Product> _selectedItems = {}; // Danh sách sản phẩm được chọn

  String _city = "Hồ Chí Minh";
  String _district = "Quận 1";
  String _address = "";

  List<CartItem> get cartItems => _cartItems;
  Set<Product> get selectedItems => _selectedItems;

  String get city => _city;
  String get district => _district;
  String get address => _address;

  /// Cập nhật địa chỉ giao hàng
  void updateAddress(String city, String district, String address) {
    _city = city;
    _district = district;
    _address = address;
    notifyListeners();
  }

  /// Tính tổng tiền của sản phẩm đã chọn
  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems) {
      if (_selectedItems.contains(item.product)) {
        final price = item.product.variants.first.currentPrice;
        total += price * item.quantity;
      }
    }
    return total;
  }

  /// Thêm sản phẩm vào giỏ hàng
  void addToCart(Product product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index != -1) {
      _cartItems[index].quantity += 1;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    _selectedItems.remove(product); // Xóa luôn khỏi danh sách chọn nếu có
    notifyListeners();
  }

  /// Tăng số lượng sản phẩm
  void increaseQuantity(Product product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index != -1) {
      _cartItems[index].quantity += 1;
      notifyListeners();
    }
  }

  /// Giảm số lượng sản phẩm
  void decreaseQuantity(Product product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index != -1 && _cartItems[index].quantity > 1) {
      _cartItems[index].quantity -= 1;
    } else {
      _cartItems.removeAt(index);
      _selectedItems.remove(product); // Xóa luôn khỏi danh sách chọn nếu có
    }
    notifyListeners();
  }

  /// Chọn hoặc bỏ chọn sản phẩm
  void toggleSelection(Product product) {
    if (_selectedItems.contains(product)) {
      _selectedItems.remove(product);
    } else {
      _selectedItems.add(product);
    }
    notifyListeners();
  }
}
