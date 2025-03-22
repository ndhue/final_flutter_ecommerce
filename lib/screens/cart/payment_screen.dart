import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/format.dart';
import '../../widgets/buttons/cart_button.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final List selectedItems =
        cartProvider.selectedItems.toList(); // Chuyển Set thành List

    return Scaffold(
      appBar: AppBar(title: const Text('Checkouts'), actions: [CartButton()]),
      body:
          selectedItems.isEmpty
              ? const Center(child: Text('No items selected for checkout.'))
              : Column(
                children: [
                  // Phần chọn địa chỉ giao hàng
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    color: Colors.grey[200],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery to',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${cartProvider.city}, ${cartProvider.district}'),
                      ],
                    ),
                  ),

                  // Danh sách sản phẩm đã chọn
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedItems.length,
                      itemBuilder: (context, index) {
                        final product = selectedItems[index];
                        final variant = product.variants.first;

                        return ListTile(
                          leading: Image.network(
                            product.images.isNotEmpty
                                ? product.images.first
                                : 'https://via.placeholder.com/100',
                            width: 50,
                            height: 50,
                          ),
                          title: Text(product.name),
                          subtitle: Text('Variant: ${variant.name}'),
                          trailing: Text(
                            FormatHelper.formatCurrency(variant.currentPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),

                  // 🛒 Phần chọn phương thức giao hàng & mã giảm giá
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        // Nút chọn phương thức giao hàng
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select the delivery option',
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Nút nhập mã giảm giá
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Apply a discount',
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 📦 Order Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total price (${selectedItems.length} items)',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              FormatHelper.formatCurrency(
                                cartProvider.totalPrice,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
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
                              FormatHelper.formatCurrency(
                                cartProvider.totalPrice,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🔥 Nút chọn phương thức thanh toán
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Xử lý khi nhấn thanh toán
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Select payment method',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
