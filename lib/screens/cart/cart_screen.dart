import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/format.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;
    final bool hasSelectedItems = cartProvider.selectedItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {}, // TODO: Chuyển đến trang giỏ hàng chi tiết
          ),
        ],
      ),
      body: Column(
        children: [
          // Phần chọn địa chỉ giao hàng
          GestureDetector(
            onTap: () {
              _showAddressDialog(context, cartProvider);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery to',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        '${cartProvider.city}, ${cartProvider.district}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child:
                cartItems.isEmpty
                    ? const Center(child: Text('Your cart is empty'))
                    : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final product = item.product;
                        final variant = product.variants.first;
                        final imageUrl =
                            product.images.isNotEmpty
                                ? product.images.first
                                : 'https://via.placeholder.com/100';

                        return ListTile(
                          leading: Checkbox(
                            value: cartProvider.selectedItems.contains(product),
                            onChanged: (isChecked) {
                              cartProvider.toggleSelection(product);
                            },
                          ),
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Variant: ${variant.name}'),
                              Text(
                                'Unit Price: ${FormatHelper.formatCurrency(variant.currentPrice)}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  cartProvider.decreaseQuantity(product);
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  cartProvider.increaseQuantity(product);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  cartProvider.removeFromCart(product);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),

          // Phần hiển thị Order Summary khi có sản phẩm được chọn
          if (hasSelectedItems)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.keyboard_arrow_up),
                ],
              ),
            ),

          // Phần hiển thị tổng tiền và nút thanh toán
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Totals',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      FormatHelper.formatCurrency(cartProvider.totalPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed:
                      hasSelectedItems
                          ? () {
                            // TODO: Xử lý khi chọn phương thức thanh toán
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSelectedItems ? Colors.green : Colors.grey,
                  ),
                  child: Text(
                    hasSelectedItems
                        ? 'Select payment method'
                        : 'Continue for payments',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị hộp thoại chọn địa chỉ
  void _showAddressDialog(BuildContext context, CartProvider cartProvider) {
    String selectedCity = cartProvider.city;
    String selectedDistrict = cartProvider.district;
    TextEditingController addressController = TextEditingController(
      text: cartProvider.address,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Delivery Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCity,
                items:
                    ['Hồ Chí Minh', 'Hà Nội', 'Đà Nẵng', 'Cần Thơ']
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCity = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                items:
                    ['Quận 1', 'Quận 2', 'Quận 3', 'Quận 7']
                        .map(
                          (district) => DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedDistrict = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'District'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Specific Address',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                cartProvider.updateAddress(
                  selectedCity,
                  selectedDistrict,
                  addressController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
